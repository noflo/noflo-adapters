noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  PacketsToArray = require '../components/PacketsToArray.coffee'
else
  PacketsToArray = require 'noflo-adapters/components/PacketsToArray.js'

describe 'PacketsToArray component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = PacketsToArray.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'convert packets to array', ->
    it 'turns some IPs into an array', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.deep.equal [1, 2, 3]
        done()

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.disconnect()

    it 'turns just one IP into an array of one', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.deep.equal [1]
        done()

      ins.connect()
      ins.send 1
      ins.disconnect()

    it 'converts within groups', (done) ->
      packets = ['a', [1], [2]]

      out.on 'begingroup', (group) ->
        chai.expect(packets.shift()).to.equal group
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.endGroup 'a'
      ins.send 2
      ins.disconnect()

    it 'converts within groups but without top-level data packets', (done) ->
      packets = ['a', [1]]

      out.on 'begingroup', (group) ->
        chai.expect(packets.shift()).to.equal group
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.endGroup 'a'
      ins.disconnect()
