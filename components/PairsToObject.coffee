_ = require "underscore"
noflo = require "noflo"

class PairsToObject extends noflo.Component

  description: "Assume packets at odd numbers to be keys and those at
  even numbers to be values"

  constructor: ->
    @inPorts = new noflo.InPorts
      in:
        datatype: 'all'
        description: 'Interleaved IPs representing key(odd packets) and
         value(even packets)'
    @outPorts = new noflo.OutPorts
      out:
        datatype: 'object'

    @inPorts.in.on "connect", =>
      @count = 0
      @object = {}
      @key = null

    @inPorts.in.on "data", (data) =>
      @count++

      # Even numbers
      if @count % 2 is 0
        # There's a key that is a string
        if @key?
          @object[@key] = data
          @key = null

      # Odd numbers and a string
      else if _.isString data
        @key = data

    @inPorts.in.on "disconnect", =>
      @outPorts.out.send @object
      @outPorts.out.disconnect()

exports.getComponent = -> new PairsToObject
