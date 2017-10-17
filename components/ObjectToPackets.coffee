_ = require "underscore"
noflo = require "noflo"
owl = require "owl-deepcopy"

convert = (object, level, output) ->
  # Deal with data packets
  if _.isArray object
    for datum, i in object
      output.send
        out: datum
      delete object[i]
    # Clean up after deletion
    object = _.compact object

  # Stop if we've reached deep enough
  if level <= 0
    unless _.isEmpty object
      output.send
        out: object
    return

  # Go through the groups
  for key, value of object
    output.send
      out: new noflo.IP 'openBracket', key

    if _.isObject value
      convert value, level - 1, output
    else
      output.send
        out: value

    output.send
      out: new noflo.IP 'closeBracket', key

exports.getComponent = ->
  c = new noflo.Component
  c.description = "Convert each incoming object into grouped packets"
  c.inPorts.add 'in',
    datatype: 'all'
    description: 'Array/Object packets to convert'
  c.inPorts.add 'depth',
    datatype: 'int'
    description: 'Maximum level of recursion when conversion incoming
     object packet'
    control: true
  c.outPorts.add 'out',
    datatype: 'all'
    description: 'Inner items from incoming array/objects with associated
     keys as groups'
  c.process (input, output) ->
    return unless input.hasData 'in'
    return if input.attached('depth') and not input.hasData 'depth'

    depth = if input.hasData('depth') then input.getData('depth') else Infinity
    data = input.getData 'in'

    # Deep copy because conversion is destructive
    object = owl.deepCopy data

    output.send
      out: new noflo.IP 'openBracket', null
    convert object, depth, output
    output.send
      out: new noflo.IP 'closeBracket', null
    output.done()
