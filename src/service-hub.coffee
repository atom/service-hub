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
      if provider.match(consumer)
        consumer.callback(provider.service)

  consume: (keyPath, versionRange, callback) ->
    consumer = new Consumer(keyPath, versionRange, callback)
    @consumers.push(consumer)

    for provider in @providers
      if provider.match(consumer)
        consumer.callback(provider.service)

    new Disposable =>
      index = @consumers.indexOf(consumer)
      @consumers.splice(index, 1)
