# TODO: restore when noflo-test supports graphs
# test = require "noflo-test"

# test.component("adapters/HashToObject").
#   discuss("give it a hash string").
#     send.connect("in").
#     send.data("in", "a=1,b=2,c=3").
#     send.disconnect("in").
#   discuss("it becomes an object!").
#     receive.data("out", { a: 1, b: 2, c: 3 }).

#   next().
#   discuss("give it a hash string missing a value").
#     send.connect("in").
#     send.data("in", "a=1,b=2,c").
#     send.disconnect("in").
#   discuss("it drops the corresponding key").
#     receive.data("out", { a: 1, b: 2 }).

# export module
