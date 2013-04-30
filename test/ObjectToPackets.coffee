test = require "noflo-test"

input =
  a: 1
  b:
    c: 2
    d: [3, 4]

test.component("adapters/ObjectToPackets").
  discuss("given any object").
    send.connect("in").
    send.data("in", input).
    send.disconnect("in").
  discuss("it becomes grouped packets").
    receive.beginGroup("out", "a").
      receive.data("out", 1).
    receive.endGroup("out").
    receive.beginGroup("out", "b").
      receive.beginGroup("out", "c").
        receive.data("out", 2).
      receive.endGroup("out").
      receive.beginGroup("out", "d").
        receive.data("out", 3).
        receive.data("out", 4).
      receive.endGroup("out").
    receive.endGroup("out").

export module
