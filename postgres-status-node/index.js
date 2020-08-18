const delay = require('util').promisify(setTimeout)
const db = process.env.DATABASE_URL || ''
const fastify = require('fastify')({logger: {level: process.env.LOGLEVEL || 'warn', base: null}})
const safeConnectionString = db.replace(/\/\/([^\/:]+):([^:]+)@/, '//$1:[redacted]@')
const truthy = new Set(['t', 'true', 'on', '1'])

fastify.register(async () => {
  fastify.log.warn("Connecting to postgres using '%s'", safeConnectionString)

  const notAvailableState = {statusCode: 503, error: 'Service Unavailable'}
  let state = notAvailableState

  const {Pool} = require('pg')
  const pool = new Pool({
    connectionString: db,
    max: 1,
    application_name: 'postgres-status'
  })

  let checkWaitTimeout
  pool.on('error', (err) => {
    if (!checkWaitTimeout) return
    clearTimeout(checkWaitTimeout.timeout)
    checkWaitTimeout.resolve()
  })

  async function refreshState () {
    const [replicaQuery, readonlyQuery] = await pool.query(`
      SELECT pg_is_in_recovery();
      SHOW transaction_read_only;
    `)

    const replica = replicaQuery.rows[0].pg_is_in_recovery
    const readonly = truthy.has(readonlyQuery.rows[0].transaction_read_only)
    return {statusCode: 200, primary: !replica, replica, readonly}
  }

  fastify.ready(async () => {
    while (true) {
      try {
        state = await refreshState()
      } catch (err) {
        state = notAvailableState
      }

      await new Promise((resolve) => {
        checkWaitTimeout = {timeout: setTimeout(resolve, 1000), resolve}
      })
    }
  })

  fastify.get('/', {
    schema: {
      query: {
        properties: {
          target_session_attrs: {
            enum: ['any', 'read-write', 'read-only'],
            default: 'read-write'
          }
        }
      },
      response: {
        '*': {
          type: 'object',
          properties: {
            statusCode: {type: 'number'},
            error: {type: 'string'},
            primary: {type: 'boolean'},
            replica: {type: 'boolean'},
            readonly: {type: 'boolean'}
          }
        }
      }
    },
    handler (req, rep) {
      if (state.statusCode === 503) return rep.code(state.statusCode).send(state)

      const target = req.query.target_session_attrs
      if (target === 'read-write' && !state.primary) state.statusCode = 503
      else if (target === 'read-only' && !state.readonly) state.statusCode = 503
      else state.statusCode = 200
      return rep.code(state.statusCode).send(state)
    }
  })
})

const port = process.env.PORT || 8000
const host = '0.0.0.0'
fastify.listen(port, host)
  .then((address) => fastify.log.warn("Listening on %s", address))

process.on('SIGTERM', () => {
  process.stdout.write('\n')
  fastify.log.warn('Received SIGTERM, exiting')
  process.exit(0)
})

process.on('SIGINT', () => {
  process.stdout.write('\n')
  fastify.log.warn('Received SIGINT, exiting')
  process.exit(0)
})

process.on('unhandledRejection', (err) => {
  fastify.log.fatal(err)
  process.exit(1)
})

process.on('uncaughtException', (err) => {
  fastify.log.fatal(err)
  process.exit(1)
})

process.stdin.resume()
