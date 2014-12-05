Provider = require './provider'

module.exports =
class ServiceHub
  constructor: ->
    @providers = []

  provide: (keyPath, version, service) ->
    @providers.push(new Provider(keyPath, version, service))

  consume: (keyPath, versionRange, callback) ->
    for provider in @providers
      if provider.match(keyPath, versionRange)
        callback(provider.service)
