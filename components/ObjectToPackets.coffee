_ = require "underscore"
noflo = require "noflo"
owl = require "owl-deepcopy"

class ObjectToPackets extends noflo.Component

  description: "Convert each incoming object into grouped packets"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "begingroup", (group) =>
      @outPorts.out.beginGroup group

    @inPorts.in.on "data", (object) =>
      # Deep copy because conversation is destructive
      @convert owl.deepCopy object

    @inPorts.in.on "endgroup", (group) =>
      @outPorts.out.endGroup()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.disconnect()

  convert: (object) ->
    for key, value of object
      @outPorts.out.beginGroup key

      if _.isArray value
        for datum, i in value
          @outPorts.out.send datum
          delete value[i]

      if _.isObject value
        @convert value
      else
        @outPorts.out.send value

      @outPorts.out.endGroup()

exports.getComponent = -> new ObjectToPackets
