import { Component } from "@noflo/noflo";

/**
 * Assumes packets at odd positions to be keys and those at even
 * positions to be values, building an object.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    description:
      "Assume packets at odd numbers to be keys and those at even numbers to be values",
    icon: "link",
    forwardBrackets: {},
    inPorts: {
      in: {
        datatype: "all",
        description:
          "Stream of IPs representing key(odd packets) and value(even packets)",
        required: true,
      },
    },
    outPorts: {
      out: { datatype: "object" },
    },
  });

  c.process((input, output) => {
    if (!input.hasStream("in")) {
      return;
    }
    const stream = /** @type {import("@noflo/noflo").IP[]} */ (
      input.getStream("in")
    ).filter((ip) => ip.type === "data");
    let count = 0;
    /** @type {Record<string, unknown>} */
    const object = {};
    let key = null;
    for (const packet of stream) {
      count += 1;
      // Even numbers
      if (count % 2 === 0) {
        // There's a key that is a string
        if (key != null) {
          object[key] = packet.data;
          key = null;
        }
        continue;
      }
      // Odd numbers and a string
      if (typeof packet.data === "string") {
        key = packet.data;
      }
    }
    output.sendDone({ out: object });
  });

  return c;
}
