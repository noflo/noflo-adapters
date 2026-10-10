import { Component } from "@noflo/noflo";

/**
 * Merges the incoming IP stream into one array; each closed bracket
 * level becomes a nested array.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description: "Merges incoming IPs stream into one array",
    icon: "compress",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
    },
    outPorts: {
      out: { datatype: "array" },
    },
  });

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const stream = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    );
    let level = 0;
    /** @type {unknown[]} */
    const data = [];
    let current = data;
    for (const packet of stream) {
      if (packet.type === "openBracket") {
        current = [];
        level += 1;
      }
      if (packet.type === "data") {
        current.push(packet.data);
        continue;
      }
      if (packet.type === "closeBracket") {
        data.push(current);
        level -= 1;
      }
    }
    if (data.length === 1 && Array.isArray(data[0])) {
      output.send({ out: data[0] });
    } else {
      output.send({ out: data });
    }
    output.done();
  });

  return c;
}
