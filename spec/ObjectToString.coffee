noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  ObjectToString = require '../components/ObjectToString.coffee'
else
  ObjectToString = require 'noflo-adapters/components/ObjectToString.js'

describe 'ObjectToString component', ->
  c = null
  ins = null
  out = null
  assoc = null
  delim = null

  beforeEach ->
    c = ObjectToString.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    assoc = noflo.internalSocket.createSocket()
    delim = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.assoc.attach assoc
    c.inPorts.delim.attach delim
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      chai.expect(c.inPorts.assoc).to.be.an 'object'
      chai.expect(c.inPorts.delim).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'given an object', ->
    input =
      a: 1
      b:
        c: 2
        d: [3, 4]

    it 'becomes a string using the default associator and delimitor', (done) ->
      packets = ["a:1,b:#{JSON.stringify(input.b)}"]

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send input
      ins.disconnect()

    it 'stringifies an object with configurable associator and delimiter', (done) ->
      packets = ["a=1|b=#{JSON.stringify(input.b)}"]

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      assoc.send '='
      delim.send '|'
      ins.connect()
      ins.send input
      ins.disconnect()
