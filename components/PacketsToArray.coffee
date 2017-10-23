noflo = require "noflo"

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'compress'
  c.description = "Merges incoming IPs stream into one array"
  c.inPorts.add 'in',
    datatype: 'all'
  c.outPorts.add 'out',
    datatype: 'array'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream 'in'
    level = 0
    data = []
    current = data
    for packet in stream
      if packet.type is 'openBracket'
        current = []
        level++
      if packet.type is 'data'
        current.push packet.data
        continue
      if packet.type is 'closeBracket'
        data.push current
        level--
    if data.length is 1 and Array.isArray data[0]
      output.send data[0]
    else
      output.send data
    output.done()
