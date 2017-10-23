noflo = require "noflo"

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'font'
  c.description = "stringifies a simple object with configurable associator and
    delimiter"
  c.inPorts.add 'in',
    datatype: 'object'
    description: 'Object to convert'
  c.inPorts.add 'assoc',
    datatype: 'string'
    description: 'Associating string for key/value pairs'
    control: true
    default: ':'
  c.inPorts.add 'delim',
    datatype: 'string'
    description: 'Delimiter string between object properties'
    control: true
    default: ','
  c.outPorts.add 'out',
    datatype: 'string'
  c.process (input, output) ->
    return unless input.hasData 'in'
    return if input.attached('assoc').length and not input.hasData 'assoc'
    return if input.attached('delim').length and not input.hasData 'delim'

    assoc = if input.hasData('assoc') then input.getData('assoc') else ':'
    delim = if input.hasData('delim') then input.getData('delim') else ','
    data = input.getData 'in'

    str = []
    for key, value of data
      if Object::toString.apply(value) isnt "[object String]"
        value = JSON.stringify value

      str.push "#{key}#{assoc}#{value}"

    output.sendDone
      out: str.join delim
