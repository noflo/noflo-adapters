noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  ObjectToPackets = require '../components/ObjectToPackets.coffee'
else
  ObjectToPackets = require 'noflo-adapters/components/ObjectToPackets.js'

describe 'ObjectToPackets component', ->
  c = null
  ins = null
  out = null
  depth = null

  beforeEach ->
    c = ObjectToPackets.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    depth = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.inPorts.depth.attach depth
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
      chai.expect(c.inPorts.depth).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'given an object', ->
    input =
      a: 1
      b:
        c: 2
        d: [3, 4]
        e:
          f: [5, 6]

    it 'becomes grouped packets', (done) ->
      packets = ['a', 1, 'b', 'c', 2, 'd', 3, 4, 'e', 'f', 5, 6]

      out.on 'begingroup', (group) ->
        chai.expect(packets.shift()).to.equal group
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send input
      ins.disconnect()

    it 'becomes grouped packets with a specified number of levels', (done) ->
      packets = ['a', 1, 'b', 'c', 2, 'd', 3, 4, 'e', { f: [5, 6] }]

      out.on 'begingroup', (group) ->
        chai.expect(packets.shift()).to.equal group
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      depth.send 2
      ins.connect()
      ins.send input
      ins.disconnect()

  describe 'given a plain array', ->
    input = [1, 2, 3]

    it 'works just as well', (done) ->
      packets = [1, 2, 3]

      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.equal data
      out.on 'disconnect', (data) ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.send input
      ins.disconnect()
