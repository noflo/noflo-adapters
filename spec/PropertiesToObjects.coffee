describe 'PropertiesToObjects component', ->
  c = null
  ins = null
  out = null
  loader = null

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/PropertiesToObjects', (err, instance) ->
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
  describe 'receiving an object', ->
    it 'should convert it', (done) ->
      expected = [
        '< a'
        {
          bar:
            foo: 42
          hello:
            baz: 1
        }
        '>'
      ]
      received = []
      out.on 'begingroup', (group) ->
        received.push "< #{group}"
      out.on 'data', (data) ->
        received.push data
      out.on 'endgroup', ->
        received.push '>'
        return unless received.length is expected.length
        chai.expect(received).to.eql expected
        done()
      ins.beginGroup 'a'
      ins.send
        foo:
          bar: 42
        baz:
          hello: 1
      ins.endGroup()
