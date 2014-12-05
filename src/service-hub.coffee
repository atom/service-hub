{Disposable} = require 'event-kit'

Consumer = require './consumer'
Provider = require './provider'

module.exports =
class ServiceHub
  constructor: ->
    @consumers = []
    @providers = []

  provide: (keyPath, version, service) ->
    provider = new Provider(keyPath, version, service)
    @providers.push(provider)

    for consumer in @consumers
      provider.provide(consumer)

    new Disposable =>
      index = @providers.indexOf(provider)
      @providers.splice(index, 1)

  consume: (keyPath, versionRange, callback) ->
    consumer = new Consumer(keyPath, versionRange, callback)
    @consumers.push(consumer)

    for provider in @providers
      provider.provide(consumer)

    new Disposable =>
      index = @consumers.indexOf(consumer)
      @consumers.splice(index, 1)
