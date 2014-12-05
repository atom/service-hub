semver = require 'semver'

module.exports =
class Provider
  constructor: (@keyPath, @version, @service) ->

  match: ({keyPath, versionRange}) ->
    @keyPath.indexOf(keyPath) is 0 and semver.satisfies(@version, versionRange)
