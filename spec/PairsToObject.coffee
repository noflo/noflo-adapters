noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  PairsToObject = require '../components/PairsToObject.coffee'
else
  PairsToObject = require 'noflo-adapters/components/PairsToObject.js'
 
describe 'PairsToObject component', ->
  c = null
  ins = null
  out = null
 
  beforeEach ->
    c = PairsToObject.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out
 
  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
 
  describe 'given some paired packets', ->
    it 'turns into an object', (done) ->
      packets = [{ a: 1, b: 2 }]
 
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()
 
      ins.connect()
      ins.send 'a'
      ins.send 1
      ins.send 'b'
      ins.send 2
      ins.disconnect()
 
  describe 'given an odd number of packets', ->
    it 'drops the last packet', (done) ->
      packets = [{ a: 1 }]
 
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()
 
      ins.connect()
      ins.send 'a'
      ins.send 1
      ins.send 'b'
      ins.disconnect()
 
  describe 'sending non-string as keys', ->
    it 'drops the corresponding value', (done) ->
      packets = [{ b: 2 }]
 
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()
 
      ins.connect()
      ins.send { a: 1 }
      ins.send 1
      ins.send 'b'
      ins.send 2
      ins.disconnect()
 
  describe 'no groups please', ->
    it 'drops all groups', (done) ->
      packets = [{ a: 1 }]
 
      out.on 'data', (data) ->
        chai.expect(packets.shift()).to.deep.equal data
      out.on 'disconnect', ->
        chai.expect(packets.length).to.equal 0
        done()
 
      ins.connect()
      ins.beginGroup 'group'
      ins.send 'a'
      ins.send 1
      ins.endGroup 'group'
      ins.disconnect()
