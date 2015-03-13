{CompositeDisposable} = require 'event-kit'
semver = require 'semver'

{getValueAtKeyPath, setValueAtKeyPath} = require './helpers'

module.exports =
class Provider
  constructor: (keyPath, servicesByVersion) ->
    @consumersDisposable = new CompositeDisposable
    @servicesByVersion = {}
    for version, service of servicesByVersion
      @servicesByVersion[version] = {}
      setValueAtKeyPath(@servicesByVersion[version], keyPath, service)

  provide: ({keyPath, versionRange, callback}) ->
    for version in Object.keys(@servicesByVersion).sort(semver.rcompare)
      if semver.satisfies(version, versionRange)
        if value = getValueAtKeyPath(@servicesByVersion[version], keyPath)
          consumerDisposable = callback(value)
          if typeof consumerDisposable?.dispose is 'function'
            @consumersDisposable.add(consumerDisposable)
          return
    return

  destroy: ->
    @consumersDisposable.dispose()
