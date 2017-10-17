noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-adapters'

describe 'PacketsToObject component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/PacketsToObject', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'given a tree of grouped packets', ->
    it 'it becomes an object', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql
          a:
            '0': 'a'
            b: ['ab1', 'ab2']
          c: ['c']
        done()

      ins.connect()
      ins.beginGroup()
      ins.beginGroup 'a'
      ins.send 'a'
      ins.beginGroup 'b'
      ins.send 'ab1'
      ins.send 'ab2'
      ins.endGroup()
      ins.endGroup()
      ins.beginGroup 'c'
      ins.send 'c'
      ins.endGroup()
      ins.endGroup()
      ins.disconnect()
  describe 'given a single packet', ->
    it 'it becomes an array', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql ['a']
        done()
      ins.send 'a'
