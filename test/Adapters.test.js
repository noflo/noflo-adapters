import assert from "node:assert/strict";
import { describe, it } from "node:test";
import * as noflo from "@noflo/noflo";

import { getComponent as getObjectToPackets } from "../components/ObjectToPackets.js";
import { getComponent as getObjectToString } from "../components/ObjectToString.js";
import { getComponent as getPacketsToArray } from "../components/PacketsToArray.js";
import { getComponent as getPacketsToObject } from "../components/PacketsToObject.js";
import { getComponent as getPairsToObject } from "../components/PairsToObject.js";
import { getComponent as getPropertiesToObjects } from "../components/PropertiesToObjects.js";
import { collect, render, waitStream } from "./helpers.js";

describe("ObjectToPackets component", () => {
  /** @returns {{ c: import("@noflo/noflo").Component, inSocket: import("@noflo/noflo").internalSocket.InternalSocket, depthSocket: import("@noflo/noflo").internalSocket.InternalSocket|null, outIps: import("@noflo/noflo").IP[], emptyIps: import("@noflo/noflo").IP[] }} */
  const build = (attachDepth = false) => {
    const c = getObjectToPackets();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const emptySocket = noflo.internalSocket.createSocket();
    /** @type {import("@noflo/noflo").internalSocket.InternalSocket|null} */
    let depthSocket = null;
    c.inPorts.in.attach(inSocket);
    if (attachDepth) {
      depthSocket = noflo.internalSocket.createSocket();
      c.inPorts.depth.attach(depthSocket);
    }
    c.outPorts.out.attach(outSocket);
    c.outPorts.empty.attach(emptySocket);
    return {
      c,
      inSocket,
      depthSocket,
      outIps: collect(outSocket),
      emptyIps: collect(emptySocket),
    };
  };

  it("converts an object into a bracketed stream", async () => {
    const { c, inSocket, outIps } = build();
    inSocket.post(new noflo.IP("data", { a: 1, b: { c: 2, d: [3, 4] } }));
    await waitStream(outIps, (ips) => ips.length >= 10);
    assert.deepEqual(render(outIps), [
      "< null",
      "< a",
      "DATA 1",
      ">",
      "< b",
      "< c",
      "DATA 2",
      ">",
      "< d",
      "DATA 3",
      "DATA 4",
      ">",
      ">",
      ">",
    ]);
    c.tearDown?.();
  });

  it("sends a bang on empty when an empty object is received", async () => {
    const { c, inSocket, emptyIps } = build();
    inSocket.post(new noflo.IP("data", {}));
    await waitStream(emptyIps, (ips) => ips.length > 0);
    assert.equal(emptyIps.length, 1);
    c.tearDown?.();
  });

  it("sends plain values as-is", async () => {
    const { c, inSocket, outIps } = build();
    inSocket.post(new noflo.IP("data", "plain"));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(render(outIps), ['DATA "plain"']);
    c.tearDown?.();
  });

  it("honors the depth control", async () => {
    const { c, inSocket, depthSocket, outIps } = build(true);
    depthSocket?.post(new noflo.IP("data", 1));
    inSocket.post(new noflo.IP("data", { a: { b: 2 } }));
    await waitStream(outIps, (ips) => ips.length >= 3);
    // Depth 1: the nested object is emitted whole instead of expanded
    assert.deepEqual(render(outIps), [
      "< null",
      "< a",
      'DATA {"b":2}',
      ">",
      ">",
    ]);
    c.tearDown?.();
  });
});

describe("PacketsToObject component", () => {
  it("converts a bracketed stream into an object", async () => {
    const c = getPacketsToObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    // The surrounding unnamed bracket is stripped by the component
    inSocket.post(new noflo.IP("openBracket", null));
    inSocket.post(new noflo.IP("openBracket", "a"));
    inSocket.post(new noflo.IP("data", "a"));
    inSocket.post(new noflo.IP("openBracket", "b"));
    inSocket.post(new noflo.IP("data", "ab1"));
    inSocket.post(new noflo.IP("data", "ab2"));
    inSocket.post(new noflo.IP("closeBracket", "b"));
    inSocket.post(new noflo.IP("closeBracket", "a"));
    inSocket.post(new noflo.IP("openBracket", "c"));
    inSocket.post(new noflo.IP("data", "c"));
    inSocket.post(new noflo.IP("closeBracket", "c"));
    inSocket.post(new noflo.IP("closeBracket", null));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [{ a: { 0: "a", b: ["ab1", "ab2"] }, c: ["c"] }],
    );
    c.tearDown?.();
  });
});

describe("PacketsToArray component", () => {
  it("merges a bracketed stream into an array", async () => {
    const c = getPacketsToArray();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("openBracket", null));
    inSocket.post(new noflo.IP("data", 1));
    inSocket.post(new noflo.IP("data", 2));
    inSocket.post(new noflo.IP("data", 3));
    inSocket.post(new noflo.IP("closeBracket", null));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [[1, 2, 3]],
    );
    c.tearDown?.();
  });

  it("sends a single IP as an array", async () => {
    const c = getPacketsToArray();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("data", 1));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [[1]],
    );
    c.tearDown?.();
  });
});

describe("ObjectToString component", () => {
  it("stringifies with the default associator and delimiter", async () => {
    const c = getObjectToString();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("data", { a: 1, b: "two" }));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      ["a:1,b:two"],
    );
    c.tearDown?.();
  });

  it("honors custom assoc and delim", async () => {
    const c = getObjectToString();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    const assocSocket = noflo.internalSocket.createSocket();
    const delimSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.inPorts.assoc.attach(assocSocket);
    c.inPorts.delim.attach(delimSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    assocSocket.post(new noflo.IP("data", "="));
    delimSocket.post(new noflo.IP("data", ";"));
    inSocket.post(new noflo.IP("data", { a: 1, b: "two" }));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      ["a=1;b=two"],
    );
    c.tearDown?.();
  });
});

describe("PairsToObject component", () => {
  it("pairs odd packets as keys and even packets as values", async () => {
    const c = getPairsToObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    // Consecutive data IPs form one stream inside a bracket
    inSocket.post(new noflo.IP("openBracket", null));
    inSocket.post(new noflo.IP("data", "key1"));
    inSocket.post(new noflo.IP("data", "value1"));
    inSocket.post(new noflo.IP("data", "key2"));
    inSocket.post(new noflo.IP("data", 42));
    inSocket.post(new noflo.IP("closeBracket", null));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [{ key1: "value1", key2: 42 }],
    );
    c.tearDown?.();
  });

  it("ignores non-string odd packets", async () => {
    const c = getPairsToObject();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(new noflo.IP("openBracket", null));
    inSocket.post(new noflo.IP("data", 99));
    inSocket.post(new noflo.IP("data", "ignored"));
    inSocket.post(new noflo.IP("data", "real"));
    inSocket.post(new noflo.IP("data", "value"));
    inSocket.post(new noflo.IP("closeBracket", null));
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [{ real: "value" }],
    );
    c.tearDown?.();
  });
});

describe("PropertiesToObjects component", () => {
  it("transposes properties into id-keyed objects", async () => {
    const c = getPropertiesToObjects();
    const inSocket = noflo.internalSocket.createSocket();
    const outSocket = noflo.internalSocket.createSocket();
    c.inPorts.in.attach(inSocket);
    c.outPorts.out.attach(outSocket);
    const outIps = collect(outSocket);
    inSocket.post(
      new noflo.IP("data", {
        name: { a: "Alice", b: "Bob" },
        age: { a: 30, b: 40 },
      }),
    );
    await waitStream(outIps, (ips) => ips.length > 0);
    assert.deepEqual(
      outIps.filter((ip) => ip.type === "data").map((ip) => ip.data),
      [
        {
          a: { name: "Alice", age: 30 },
          b: { name: "Bob", age: 40 },
        },
      ],
    );
    c.tearDown?.();
  });
});
