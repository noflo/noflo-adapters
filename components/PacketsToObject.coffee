noflo = require "noflo"
_ = require "underscore"

locate = (object, groups) ->
  here = object
  for group in groups
    here = here[group]
  here

objectify = (object) ->
  return object unless _.isObject object
  obj = {}
  length = object.length

  # If it's not a pure object, drop the array portion
  if _.keys(object).length > length
    for own key, value of object
      unless _.isNumber key
        obj[key] = objectify value
  # Otherwise, use the array
  else
    obj = object.slice()

  # Return the objectified object
  obj

exports.getComponent = -> new PacketsToObject

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'compress'
  c.description = "Convert the structure of a packet stream into an object"
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'object'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'
    groups = []
    object = []

    if stream[0].type is 'openBracket'
      # Remove the surrounding brackets
      before = stream.shift()
      after = stream.pop()

    for packet in stream
      if packet.type is 'openBracket'
        here = locate object, groups
        here[packet.data] = []
        groups.push packet.data
        continue
      if packet.type is 'data'
        here = locate object, groups
        here.push packet.data
      if packet.type is 'closeBracket'
        groups.pop()

    result = objectify object
    output.sendDone result
