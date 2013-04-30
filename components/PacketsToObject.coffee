noflo = require("noflo")
_ = require("underscore")

class PacketsToObject extends noflo.Component

  description: "Convert a structure of grouped packets into an object"

  constructor: ->
    @inPorts =
      in: new noflo.Port
    @outPorts =
      out: new noflo.Port

    @inPorts.in.on "connect", =>
      @groups = []
      @object = {}

    @inPorts.in.on "begingroup", (group) =>
      here = @locate()
      here[group] = []
      @groups.push group

    @inPorts.in.on "data", (data) =>
      here = @locate()
      here.push data

    @inPorts.in.on "endgroup", (group) =>
      @groups.pop()

    @inPorts.in.on "disconnect", =>
      @outPorts.out.send @object
      @outPorts.out.disconnect()

  locate: ->
    here = @object
    here = here[group] for group in @groups
    here

exports.getComponent = -> new PacketsToObject
