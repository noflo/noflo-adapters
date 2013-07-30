test = require "noflo-test"

expected = []
expected.a = ["a"]
expected.a.b = ["ab1", "ab2"]
expected.c = ["c"]

test.component("adapters/PacketsToObject").
  discuss("provide some grouped packets").
    send.connect("in").
      send.beginGroup("in", "a").
        send.data("in", "a").
        send.beginGroup("in", "b").
          send.data("in", "ab1").
          send.data("in", "ab2").
        send.endGroup("in").
      send.endGroup("in").
      send.beginGroup("in", "c").
        send.data("in", "c").
      send.endGroup("in").
    send.disconnect("in").
  discuss("get back the object representation").
    receive.connect("out").
      receive.data("out", expected).
    receive.disconnect("out").

export module
