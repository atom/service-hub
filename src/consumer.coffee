module.exports =
class Consumer
  constructor: (@keyPath, @versionRange, @callback) ->
    @isDestroyed = false

  destroy: ->
    @isDestroyed = true
