# STANDARD LIBRARY MODULES

# THIRD-PARTIES MODULES
colors = require 'colors'
winston = require 'winston'

# PROJECT MODULES

# LOGGER
logger = new winston.Logger transports: [
    new winston.transports.Console level: 'silly'
    #new winston.transports.File filename: 'somefile.log'
  ]

# EXPORTS
exports.info = (msg) -> logger.info msg
exports.debug = (msg) -> logger.debug msg.grey
exports.error = (msg) -> logger.error msg.red
exports.warn = (msg) -> logger.warn msg.yellow

