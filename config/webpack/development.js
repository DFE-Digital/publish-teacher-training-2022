const fs = require('fs')

process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')

environment.config.devServer.https = {
  key: fs.readFileSync('./config/localhost/https/localhost.key'),
  cert: fs.readFileSync('./config/localhost/https/localhost.crt')
}

module.exports = environment.toWebpackConfig()
