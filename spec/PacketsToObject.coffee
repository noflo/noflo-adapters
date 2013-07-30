noflo = require 'noflo'
if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  PacketsToObject = require '../components/PacketsToObject.coffee'
else
  PacketsToObject = require 'noflo-adapters/components/PacketsToObject.js'

describe 'PacketsToObject component', ->
  c = null
  ins = null
  out = null

  beforeEach ->
    c = PacketsToObject.getComponent()
    ins = noflo.internalSocket.createSocket()
    out = noflo.internalSocket.createSocket()
    c.inPorts.in.attach ins
    c.outPorts.out.attach out

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'

  describe 'provided some grouped packets', ->
    it 'gets back the object representation', (done) ->
      expected = []
      expected.a = ['a']
      expected.a.b = ['ab1', 'ab2']
      expected.c = ['c']

      out.on 'data', (data) ->
        chai.expect(data).to.deep.equal expected
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 'a'
      ins.beginGroup 'b'
      ins.send 'ab1'
      ins.send 'ab2'
      ins.endGroup 'b'
      ins.endGroup 'a'
      ins.beginGroup 'c'
      ins.send 'c'
      ins.endGroup 'c'
      ins.disconnect()
