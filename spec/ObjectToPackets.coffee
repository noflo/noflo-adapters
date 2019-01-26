describe 'ObjectToPackets component', ->
  c = null
  depth = null
  ins = null
  out = null
  empty = null
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
    empty = noflo.internalSocket.createSocket()
    c.outPorts.empty.attach empty
  afterEach ->
    c.outPorts.out.detach out
    out = null
    c.outPorts.empty.detach empty
    empty = null

  describe 'given any object', ->
    it 'it becomes grouped packets', (done) ->
      expected = [
        '< null'
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
        '>'
      ]
      received = []

      empty.on 'ip', (ip) ->
        done new Error 'Unexpected empty received'
      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      depth.send Infinity
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
        '< null'
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
        '>'
        '>'
        '>'
      ]
      received = []

      empty.on 'ip', (ip) ->
        done new Error 'Unexpected empty received'
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
        '< null'
        'DATA 1'
        'DATA 2'
        'DATA 3'
        '>'
      ]
      received = []

      empty.on 'ip', (ip) ->
        done new Error 'Unexpected empty received'
      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      depth.send Infinity
      ins.send [1, 2, 3]
      ins.disconnect()
  describe 'given a plain string', ->
    it 'it becomes a single packet', (done) ->
      expected = [
        'DATA foo'
      ]
      received = []

      empty.on 'ip', (ip) ->
        done new Error 'Unexpected empty received'
      out.on 'begingroup', (grp) ->
        received.push "< #{grp}"
      out.on 'data', (data) ->
        received.push "DATA #{data}"
      out.on 'endgroup', ->
        received.push '>'
      out.on 'disconnect', ->
        chai.expect(received).to.eql expected
        done()

      depth.send Infinity
      ins.send 'foo'
      ins.disconnect()

  describe 'given an empty object', ->
    it 'gets sent to EMPTY port', (done) ->
      expected = [
        'EMPTY data null'
      ]
      received = []
      out.on 'ip', (ip) ->
        received.push "OUT #{ip.type} #{JSON.stringify(ip.data)}"
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      empty.on 'ip', (ip) ->
        received.push "EMPTY #{ip.type} #{JSON.stringify(ip.data)}"
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.send {}

  describe 'given an empty array', ->
    it 'gets sent to EMPTY port', (done) ->
      expected = [
        'EMPTY data null'
      ]
      received = []
      out.on 'ip', (ip) ->
        received.push "OUT #{ip.type} #{JSON.stringify(ip.data)}"
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      empty.on 'ip', (ip) ->
        received.push "EMPTY #{ip.type} #{JSON.stringify(ip.data)}"
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.send []
