describe 'ObjectToString component', ->
  c = null
  assoc = null
  delim = null
  ins = null
  out = null
  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/ObjectToString', (err, instance) ->
      return done err if err
      c = instance
      assoc = noflo.internalSocket.createSocket()
      delim = noflo.internalSocket.createSocket()
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
  afterEach ->
    c.outPorts.out.detach out
    out = null

  describe 'Stringifying a simple object', ->
    it 'should become a string using default associator and delimiter', (done) ->
      obj =
        a: 1
        b:
          c: 2
          d: [3, 4]
      out.on 'data', (data) ->
        chai.expect(data).to.equal "a:1,b:#{JSON.stringify(obj.b)}"
        done()
      ins.send obj

  describe 'Stringifying with custom associator and delimiter', ->
    before ->
      c.inPorts.assoc.attach assoc
      c.inPorts.delim.attach delim
    after ->
      c.inPorts.assoc.detach assoc
      c.inPorts.delim.detach delim
    it 'should become the expected string', (done) ->
      obj =
        a: 1
        b:
          c: 2
          d: [3, 4]
      out.on 'data', (data) ->
        chai.expect(data).to.equal "a=1|b=#{JSON.stringify(obj.b)}"
        done()
      assoc.send '='
      delim.send '|'
      ins.send obj
