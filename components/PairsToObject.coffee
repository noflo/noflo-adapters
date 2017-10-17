noflo = require "noflo"

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Assume packets at odd numbers to be keys and those at
  even numbers to be values"
  c.inPorts.add 'in',
    datatype: 'all'
    description: 'Stream of IPs representing key(odd packets) and
     value(even packets)'
  c.outPorts.add 'out',
    datatype: 'object'
  c.forwardBrackets = {}
  c.process (input, output) ->
    return unless input.hasStream 'in'
    stream = input.getStream('in').filter (ip) -> ip.type is 'data'
    count = 0
    object = {}
    key = null
    for packet in stream
      count++
      # Even numbers
      if count % 2 is 0
        # There's a key that is a string
        if key?
          object[key] = packet.data
          key = null
        continue
      # Odd numbers and a string
      else if typeof packet.data is 'string'
        key = packet.data
        continue
    output.sendDone
      out: object
