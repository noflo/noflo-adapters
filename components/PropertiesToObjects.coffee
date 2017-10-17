noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.inPorts.add 'in',
    datatype: 'object'
  c.outPorts.add 'out',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'in'
    object = input.getData 'in'
    data = {}
    for property, objects of object
      for id, value of objects
        data[id] = {} unless data[id]
        data[id][property] = value
    output.sendDone
      out: data
