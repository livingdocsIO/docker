const path = require('path')
const fs = require('fs').promises
const Fastify = require('fastify')
const FastifyJWT = require('fastify-jwt')

async function start () {
  const fastify = Fastify({logger: {level: 'info'}})

  const letsencryptDir = process.env.LETSENCRYPT_DIR || '/etc/letsencrypt'
  const letsencryptCertificatesDir = path.join(letsencryptDir, 'certificates')

  const letsencryptWebRoot = path.resolve(process.env.LETSENCRYPT_WEBROOT || './well-known-acme-challenge')
  await fs.mkdir(letsencryptWebRoot).catch((err) => {
    if (err.code !== 'EEXIST') throw err
  })

  const jwtSecret = process.env.JWT_SECRET || [Math.random() * 1e16, Math.random() * 1e16].map((v) => v.toString(32)).join('') // eslint-disable-line
  if (!process.env.JWT_SECRET) fastify.log.warn('Please configure the environment variable JWT_SECRET to support http requests.') // eslint-disable-line

  fastify.register(require('fastify-static'), {
    root: letsencryptWebRoot,
    prefix: '/.well-known/acme-challenge/'
  })

  fastify.register(FastifyJWT, {secret: jwtSecret})
  const tokenVerificationHandler = async (req, rep) => {
    try {
      req.token = await req.jwtVerify()
    } catch (err) {
      rep.status(401).send({
        statusCode: 401,
        error: 'Unauthorized',
        message: 'Invalid Credentials'
      })
    }
  }

  async function getDomainByName (domainName) {
    const domain = domainName.replace('*', '_')
    try {
      const [key, cert] = await Promise.all([
        fs.readFile(`${letsencryptCertificatesDir}/${domain}.key`, 'utf8'),
        fs.readFile(`${letsencryptCertificatesDir}/${domain}.crt`, 'utf8')
      ])
      return {domain, key, cert}
    } catch (error) {
      throw new Err(404, `Domain '${domainName}' not Found`)
    }
  }

  fastify.get('/list', {
    onRequest: tokenVerificationHandler,
    async handler (req, reply) {
      return Promise.all(req.token.domains.map(getDomainByName))
    }
  })

  function Err (statusCode, message) {
    this.name = this.constructor.name
    this.message = message
    this.statusCode = statusCode
    Error.call(this, message)
    Error.captureStackTrace(this, this.constructor)
  }

  require('util').inherits(Err, Error)

  await fastify.ready()

  const args = process.argv.slice(2)
  if (args[0] === 'sign') return console.log(fastify.jwt.sign({domains: args[1].split(',').filter(Boolean)}))

  fastify.listen(process.env.PORT || 8080, '0.0.0.0')
}

start()
