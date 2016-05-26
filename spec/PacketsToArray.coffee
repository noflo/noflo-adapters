noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-adapters'

describe 'PacketsToArray component', ->
  c = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/PacketsToArray', (err, instance) ->
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

  describe 'with three IPs without groups', ->
    it 'should turn them into an array', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql [1, 2, 3]
        done()

      ins.connect()
      ins.send 1
      ins.send 2
      ins.send 3
      ins.disconnect()

  describe 'with single IP without groups', ->
    it 'should turn it into an array', (done) ->
      out.on 'data', (data) ->
        chai.expect(data).to.eql [1]
        done()

      ins.connect()
      ins.send 1
      ins.disconnect()

  describe 'with grouped and ungrouped IPs', ->
    it 'should turn them into separate an arrays', (done) ->
      expected = [
        '< a'
        'DATA [1]'
        '>'
        'DATA [2]'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()
      out.on 'data', (data) ->
        chai.expect(data).to.eql [1]
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.endGroup()
      ins.send 2
      ins.disconnect()

  describe 'with group but without toplevel data packets', ->
    it 'should send a grouped array', (done) ->
      expected = [
        '< a'
        'DATA [1]'
        '>'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        data = JSON.stringify data if typeof data is 'object'
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()
      out.on 'data', (data) ->
        chai.expect(data).to.eql [1]
        done()

      ins.connect()
      ins.beginGroup 'a'
      ins.send 1
      ins.endGroup()
      ins.disconnect()
