semver = require 'semver'

{getValueAtKeyPath, setValueAtKeyPath} = require './helpers'

module.exports =
class Provider
  constructor: (keyPath, @version, service) ->
    @service = {}
    setValueAtKeyPath(@service, keyPath, service)

  provide: ({keyPath, versionRange, callback}) ->
    if semver.satisfies(@version, versionRange)
      if value = getValueAtKeyPath(@service, keyPath)
        callback(value)
