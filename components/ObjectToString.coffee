noflo = require "noflo"

class ObjectToString extends noflo.Component

  description: "stringifies a simple object with configurable associator and
    delimiter"

  constructor: ->
    @assoc = ":"
    @delim = ","

    @inPorts = new noflo.InPorts
      in:
        datatype: 'object'
        description: 'Objects to convert'
      assoc:
        datatype: 'string'
        description: 'Associating string for key/value pairs'
      delim:
        datatype: 'string'
        description: 'Delimiter string between object properties'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'string'

    @inPorts.assoc.on "data", (@assoc) =>
    @inPorts.delim.on "data", (@delim) =>

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup group

    @inPorts.in.on "data", (data) =>
      str = []

      for key, value of data
        if Object::toString.apply(value) isnt "[object String]"
          value = JSON.stringify value

        str.push "#{key}#{@assoc}#{value}"

      @outPorts.out.send str.join @delim

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

exports.getComponent = -> new ObjectToString
