describe 'PairsToObject component', ->
  c = null
  ins = null
  out = null
  loader = null

  before (done) ->
    @timeout 4000
    loader = new noflo.ComponentLoader baseDir
    loader.load 'adapters/PairsToObject', (err, instance) ->
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
      ins.beginGroup()
      ins.send 'a'
      ins.send 1
      ins.send 'b'
      ins.send 2
      ins.endGroup()
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
      ins.beginGroup()
      ins.send 'a'
      ins.send 1
      ins.send 'b'
      ins.endGroup()
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
      ins.beginGroup()
      ins.send { a: 1 }
      ins.send 1
      ins.send 'b'
      ins.send 2
      ins.endGroup()
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
