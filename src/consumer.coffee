{Range} = require 'semver'

module.exports =
class Consumer
  constructor: (@keyPath, versionRange, @callback) ->
    @versionRange = new Range(versionRange)
