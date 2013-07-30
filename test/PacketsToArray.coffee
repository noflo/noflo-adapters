test = require "noflo-test"

test.component("adapters/PacketsToArray").
  discuss("send some IPs").
    send.connect("in").
      send.data("in", 1).
      send.data("in", 2).
      send.data("in", 3).
    send.disconnect("in").
  discuss("turn them into an array").
    receive.data("out", [1, 2, 3]).

  next().
  discuss("send just one IP").
    send.connect("in").
      send.data("in", 1).
    send.disconnect("in").
  discuss("turn it into an array of one").
    receive.data("out", [1]).

  next().
  discuss("within groups too").
    send.connect("in").
      send.beginGroup("in", "a").
        send.data("in", 1).
      send.endGroup("in").
      send.data("in", 2).
    send.disconnect("in").
  discuss("turn it into an array of one").
    receive.beginGroup("out", "a").
      receive.data("out", [1]).
    receive.endGroup("out").
    receive.data("out", [2]).

  next().
  discuss("within groups but without top-level data packets").
    send.connect("in").
      send.beginGroup("in", "a").
        send.data("in", 1).
      send.endGroup("in").
    send.disconnect("in").
  discuss("turn it into an array of one").
    receive.beginGroup("out", "a").
      receive.data("out", [1]).
    receive.endGroup("out").

export module
