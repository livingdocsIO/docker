#!/usr/bin/env node
// The README `buildcontainer` lines of livingdocs/node, server-base and editor-base are the
// list of images and their tags. `release` bumps them for new node releases, `plan` lists what
// is missing on Docker Hub.
import {readFileSync, writeFileSync} from 'node:fs'
import {fileURLToPath} from 'node:url'
import path from 'node:path'

const root = process.env.REPO_ROOT || path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..')
const read = (file) => readFileSync(path.join(root, file), 'utf8')
const write = (file, content) => writeFileSync(path.join(root, file), content)
const log = (...args) => console.error(...args)
const REPOS = ['node', 'server-base', 'editor-base']
const PLATFORMS = ['amd64', 'arm64']

async function getJson (url) {
  for (let attempt = 1; ; attempt++) {
    const res = await fetch(url)
    if (res.status === 404) return null
    if (res.ok) return res.json()
    if (attempt === 3) throw new Error(`${url} returned HTTP ${res.status}`)
    await new Promise((resolve) => setTimeout(resolve, attempt * 5000))
  }
}

const hubTag = (repo, tag) => getJson(`https://hub.docker.com/v2/repositories/${repo}/tags/${tag}`)

async function hubTags (repo, prefix) {
  const names = []
  let url = `https://hub.docker.com/v2/repositories/${repo}/tags?page_size=100&name=${prefix}`
  while (url) {
    const page = await getJson(url)
    names.push(...(page?.results || []).map((t) => t.name))
    url = page?.next
  }
  return names
}

async function missingPlatforms (image) {
  const [name, tag] = image.split(':')
  const res = await hubTag(name.includes('/') ? name : `library/${name}`, tag)
  const have = new Set((res?.images || []).filter((i) => i.os === 'linux').map((i) => i.architecture))
  return PLATFORMS.filter((p) => !have.has(p))
}

function parseCounter (tag) {
  const m = /^(\d+)\.(\d+)(-[a-z]+)?$/.exec(tag)
  return m && {major: m[1], counter: Number(m[2]), suffix: m[3] || ''}
}

function readmeBuilds () {
  const builds = []
  for (const line of read('README.md').split('\n')) {
    const args = line.trim().split(/\s+/)
    if (args.shift() !== 'buildcontainer') continue
    const build = {tags: [], buildArgs: {}}
    while (args.length) {
      const arg = args.shift()
      if (arg === '-t') build.tags.push(args.shift())
      else if (arg === '-f') build.dockerfile = path.normalize(args.shift())
      else if (arg === '--build-arg') {
        const [key, ...value] = args.shift().split('=')
        build.buildArgs[key] = value.join('=')
      } else build.context = path.normalize(arg)
    }
    const [image] = build.tags
    const m = /^livingdocs\/([\w-]+):(.+)$/.exec(image || '')
    if (!m || !REPOS.includes(m[1])) continue
    const counter = parseCounter(m[2])
    if (!counter) throw new Error(`README: the first tag of '${line.trim()}' is no <major>.<counter> tag`)
    Object.assign(build, counter, {repo: `livingdocs/${m[1]}`, line: counter.major + counter.suffix})
    builds.push(build)
  }
  return builds
}

function pinnedVersion (dockerfile) {
  const content = read(dockerfile)
  const m = /^ENV NODE_VERSION=(\d+\.\d+\.\d+)/m.exec(content) || /^FROM node:(\d+\.\d+\.\d+)-/m.exec(content)
  if (!m) throw new Error(`${dockerfile}: no pinned node version`)
  return m[1]
}

const nodeImages = (dockerfile) => [...read(dockerfile).matchAll(/^FROM (?:--platform=\S+ )?(node:\S+)/gm)].map((m) => m[1])
const cmpVersion = (a, b) => {
  const [x, y] = [a, b].map((v) => v.split('.').map(Number))
  return x[0] - y[0] || x[1] - y[1] || x[2] - y[2]
}

async function release ({all}) {
  const builds = readmeBuilds()
  const releases = (await getJson('https://nodejs.org/dist/index.json'))
    .map((r) => r.version.slice(1))
    .filter((v) => /^\d+\.\d+\.\d+$/.test(v))
  let readme = read('README.md')
  const changes = []

  for (const node of builds.filter((b) => b.repo === 'livingdocs/node')) {
    const pinned = pinnedVersion(node.dockerfile)
    const latest = releases.filter((v) => v.startsWith(`${node.major}.`)).sort(cmpVersion).at(-1)
    const upgrade = latest && cmpVersion(latest, pinned) > 0
    if (!upgrade && !all) {
      log(`${node.dockerfile}: node ${pinned} is the latest ${node.major}.x release`)
      continue
    }

    let dockerfile = read(node.dockerfile)
    if (upgrade) {
      dockerfile = dockerfile
        .replace(`ENV NODE_VERSION=${pinned}`, `ENV NODE_VERSION=${latest}`)
        .replace(`FROM node:${pinned}-`, `FROM node:${latest}-`)
    }
    const unavailable = []
    for (const image of new Set(nodeImages(node.dockerfile).map((i) => i.replace(pinned, latest)))) {
      const missing = await missingPlatforms(image)
      if (missing.length) unavailable.push(`${image} (${missing.join(', ')})`)
    }
    if (unavailable.length) {
      log(`${node.dockerfile}: waiting for ${unavailable.join(', ')} on Docker Hub`)
      continue
    }

    const tags = []
    for (const build of builds.filter((b) => b.line === node.line)) {
      const published = (await hubTags(build.repo, `${node.major}.`))
        .map(parseCounter)
        .filter((c) => c && c.major === node.major && c.suffix === node.suffix)
        .map((c) => c.counter)
      const next = Math.max(build.counter, ...published) + 1
      const counterTag = new RegExp(`(${build.repo}:${node.major}\\.)\\d+(${node.suffix})(?![\\w.-])`, 'g')
      readme = readme.replace(counterTag, `$1${next}$2`)
      tags.push(`${build.repo}:${node.major}.${next}${node.suffix}`)
    }
    write(node.dockerfile, dockerfile)
    changes.push({line: node.line, from: pinned, to: upgrade ? latest : pinned, tags})
    log(`${node.dockerfile}: node ${pinned} -> ${upgrade ? latest : pinned}, ${tags.join(' ')}`)
  }

  write('README.md', readme)
  return changes
}

async function plan ({force}) {
  const builds = readmeBuilds()
  const lines = []
  for (const node of builds.filter((b) => b.repo === 'livingdocs/node')) {
    const [nodeRef] = node.tags
    const version = pinnedVersion(node.dockerfile)
    const unavailable = []
    for (const image of new Set(nodeImages(node.dockerfile))) {
      const missing = await missingPlatforms(image)
      if (missing.length) unavailable.push(`${image} (${missing.join(', ')})`)
    }
    if (unavailable.length) {
      log(`${node.dockerfile}: skipped, waiting for ${unavailable.join(', ')} on Docker Hub`)
      continue
    }

    const buildNode = force || !(await hubTag(node.repo, nodeRef.split(':')[1]))
    const bases = []
    for (const base of builds.filter((b) => b.line === node.line && b !== node)) {
      if (buildNode || !(await hubTag(base.repo, base.tags[0].split(':')[1]))) {
        bases.push({repo: base.repo, tags: base.tags, dockerfile: base.dockerfile, context: base.context})
      }
    }
    if (!buildNode && !bases.length) {
      log(`${node.dockerfile}: ${nodeRef} and its base images are published`)
      continue
    }
    log(`${node.dockerfile}: build ${[buildNode && nodeRef, ...bases.map((b) => b.tags[0])].filter(Boolean).join(', ')}`)
    lines.push({
      line: node.line,
      dockerfile: node.dockerfile,
      version,
      pointer_compression: node.suffix === '-pc',
      build_node: buildNode,
      node_tags: node.tags,
      node_tag: nodeRef.split(':')[1],
      bases
    })
  }
  return lines
}

const [command, ...flags] = process.argv.slice(2)
if (command === 'release') {
  console.log(JSON.stringify(await release({all: flags.includes('--all')})))
} else if (command === 'plan') {
  console.log(JSON.stringify(await plan({force: flags.includes('--force')})))
} else {
  log('Usage: node-images.mjs release [--all] | plan [--force]')
  process.exit(1)
}
