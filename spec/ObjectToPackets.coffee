noflo = require 'noflo'

unless noflo.isBrowser()
  chai = require 'chai'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'
else
  baseDir = 'noflo-adapters'

describe 'ObjectToPackets component', ->
  c = null
  depth = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/ObjectToPackets', (err, instance) ->
      return done err if err
      c = instance
      depth = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.depth.attach depth
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null
    depth.send Infinity

  describe 'given any object', ->
    it 'it becomes grouped packets', (done) ->
      expected = [
        '< a'
        'DATA 1'
        '>'
        '< b'
        '< c'
        'DATA 2'
        '>'
        '< d'
        'DATA 3'
        'DATA 4'
        '>'
        '< e'
        '< f'
        'DATA 5'
        'DATA 6'
        '>'
        '>'
        '>'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.send
        a: 1
        b:
          c: 2
          d: [3, 4]
          e:
            f: [5, 6]
      ins.disconnect()

  describe 'given a number of levels to objectify', ->
    it 'it becomes grouped packets', (done) ->
      expected = [
        '< a'
        'DATA 1'
        '>'
        '< b'
        '< c'
        'DATA 2'
        '>'
        '< d'
        'DATA 3'
        'DATA 4'
        '>'
        '< e'
        'DATA {"f":[5,6]}'
        'DATA 6'
        '>'
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

      depth.send 2
      ins.send
        a: 1
        b:
          c: 2
          d: [3, 4]
          e:
            f: [5, 6]
      ins.disconnect()

  describe 'given a plain array', ->
    it 'it becomes set of packets', (done) ->
      expected = [
        'DATA 1'
        'DATA 2'
        'DATA 3'
      ]
      received = []

      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      ins.send [1, 2, 3]
      ins.disconnect()
