const path = require('path')
const fs = require('fs').promises
const Fastify = require('fastify')
const FastifyJWT = require('fastify-jwt')

async function start () {
  const fastify = Fastify({logger: {level: 'info'}})

  const secret = process.env.JWT_SECRET || [Math.random() * 1e16, Math.random() * 1e16].map((v) => v.toString(32)).join('') // eslint-disable-line
  if (!process.env.JWT_SECRET) fastify.log.warn('Please configure the environment variable JWT_SECRET to support http requests.') // eslint-disable-line

  fastify.register(FastifyJWT, {secret})

  fastify.addHook('onRequest', async (req, rep) => {
    try {
      req.token = await req.jwtVerify()
    } catch (err) {
      rep.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Invalid Credentials'
      })
    }
  })

  const letsencryptDir = process.env.LETSENCRYPT_DIR || '/etc/letsencrypt'
  const dir = path.join(letsencryptDir, 'certificates')
  fastify.get('/list', async (req, reply) => {
    const certs = await Promise.all([...req.token.domains].map(async (domainName) => {
      const domain = domainName.replace('*', '_')
      try {
        const [key, cert] = await Promise.all([
          `${dir}/${domain}.key`,
          `${dir}/${domain}.crt`
        ].map((p) => fs.readFile(p, 'utf8')))
        return {domain, key, cert}
      } catch (error) {
        reply.status(500)
        return {domain, error: "Not Found"}
      }
    }))

    return certs.filter(Boolean)
  })

  await fastify.ready()

  const args = process.argv.slice(2)
  if (args[0] === 'sign') return console.log(fastify.jwt.sign({domains: args[1].split(',').filter(Boolean)}))

  fastify.listen(process.env.PORT || 8080, '0.0.0.0')
}

start()
