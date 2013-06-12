(function() {
  var colors, logger, winston;

  colors = require('colors');

  winston = require('winston');

  logger = new winston.Logger({
    transports: [
      new winston.transports.Console({
        level: 'silly'
      })
    ]
  });

  exports.info = function(msg) {
    return logger.info(msg);
  };

  exports.debug = function(msg) {
    return logger.debug(msg.grey);
  };

  exports.error = function(msg) {
    return logger.error(msg.red);
  };

  exports.warn = function(msg) {
    return logger.warn(msg.yellow);
  };

}).call(this);
