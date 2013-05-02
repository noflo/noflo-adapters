test = require "noflo-test"

input1 =
  a: 1
  b:
    c: 2
    d: [3, 4]

input2 = [1, 2, 3]

test.component("adapters/ObjectToPackets").
  discuss("given any object").
    send.connect("in").
    send.data("in", input1).
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

  next().
  discuss("given a plain array").
    send.connect("in").
    send.data("in", input2).
    send.disconnect("in").
  discuss("works just as well").
    receive.data("out", 1).
    receive.data("out", 2).
    receive.data("out", 3).

export module
