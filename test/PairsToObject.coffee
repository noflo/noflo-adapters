test = require "noflo-test"

test.component("adapters/PairsToObject").
  discuss("send some IPs that represent pairs").
    send.connect("in").
      send.data("in", "a").
      send.data("in", 1).
      send.data("in", "b").
      send.data("in", 2).
    send.disconnect("in").
  discuss("turn them into an object").
    receive.data("out", { a: 1, b: 2 }).

  next().
  discuss("sending odd number of packets...").
    send.connect("in").
      send.data("in", "a").
      send.data("in", 1).
      send.data("in", "b").
    send.disconnect("in").
  discuss("drops the last packet").
    receive.data("out", { a: 1 }).

  next().
  discuss("sending non-string as keys...").
    send.connect("in").
      send.data("in", { a: 1 }).
      send.data("in", 1).
      send.data("in", "b").
      send.data("in", 2).
    send.disconnect("in").
  discuss("drops the corresponding value").
    receive.data("out", { b: 2 }).

  next().
  discuss("no groups please").
    send.connect("in").
      send.beginGroup("in", "group").
        send.data("in", "a").
        send.data("in", 1).
      send.endGroup("in").
    send.disconnect("in").
  discuss("they're ignored").
    receive.data("out", { a: 1 }).

export module
