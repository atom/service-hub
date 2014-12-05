exports.getValueAtKeyPath = (object, keyPath) ->
  keys = splitKeyPath(keyPath)
  for key in keys
    object = object[key]
    return unless object?
  object

exports.setValueAtKeyPath = (object, keyPath, value) ->
  keys = splitKeyPath(keyPath)
  while keys.length > 1
    key = keys.shift()
    object[key] ?= {}
    object = object[key]
  object[keys.shift()] = value

splitKeyPath = (keyPath) ->
  return [] unless keyPath?
  startIndex = 0
  keys = []
  for char, i in keyPath
    if char is '.' and (i is 0 or keyPath[i-1] != '\\')
      keys.push keyPath.substring(startIndex, i)
      startIndex = i + 1
  keys.push keyPath.substr(startIndex, keyPath.length)
  keys
