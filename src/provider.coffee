{CompositeDisposable} = require 'event-kit'
semver = require 'semver'

{getValueAtKeyPath, setValueAtKeyPath} = require './helpers'

module.exports =
class Provider
  constructor: (keyPath, @version, service) ->
    @consumersDisposable = new CompositeDisposable
    @service = {}
    setValueAtKeyPath(@service, keyPath, service)

  provide: ({keyPath, versionRange, callback}) ->
    if semver.satisfies(@version, versionRange)
      if value = getValueAtKeyPath(@service, keyPath)
        consumerDisposable = callback(value)
        if typeof consumerDisposable?.dispose is 'function'
          @consumersDisposable.add(consumerDisposable)

  destroy: ->
    @consumersDisposable.dispose()
