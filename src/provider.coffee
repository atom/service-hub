{CompositeDisposable} = require 'event-kit'
{SemVer} = require 'semver'

{getValueAtKeyPath, setValueAtKeyPath} = require './helpers'

module.exports =
class Provider
  constructor: (keyPath, servicesByVersion) ->
    @consumersDisposable = new CompositeDisposable
    @servicesByVersion = {}
    @versions = []
    for version, service of servicesByVersion
      @servicesByVersion[version] = {}
      @versions.push(new SemVer(version))
      setValueAtKeyPath(@servicesByVersion[version], keyPath, service)

    @versions.sort((a, b) -> b.compare(a))

  provide: (consumer) ->
    for version in @versions
      if consumer.versionRange.test(version)
        if value = getValueAtKeyPath(@servicesByVersion[version.toString()], consumer.keyPath)
          consumerDisposable = consumer.callback.call(null, value)
          if typeof consumerDisposable?.dispose is 'function'
            @consumersDisposable.add(consumerDisposable)
          return
    return

  destroy: ->
    @consumersDisposable.dispose()
