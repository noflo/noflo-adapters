import { Component } from "@noflo/noflo";

/**
 * @param {any[]} object
 * @param {any[]} groups
 * @returns {any}
 */
const locate = (object, groups) => {
  /** @type {any} */
  let here = object;
  for (const group of groups) {
    here = here[group];
  }
  return here;
};

/**
 * @param {any} object
 * @returns {any}
 */
const objectify = (object) => {
  if (typeof object !== "object" || object === null) {
    return object;
  }
  /** @type {any} */
  let obj = {};
  const length = object.length;

  // If it's not a pure object, drop the array portion
  if (Object.keys(object).length > length) {
    for (const key of Object.keys(object)) {
      // 1.x kept every own key here (`_.isNumber` checks the type, and
      // Object.keys yields strings), including numeric-string keys
      obj[key] = objectify(object[key]);
    }
    // Otherwise, use the array
  } else {
    obj = object.slice();
  }

  // Return the objectified object
  return obj;
};

/** @returns {import("@noflo/noflo").Component} The configured component */
export function getComponent() {
  const c = new Component({
    description: "Convert the structure of a packet stream into an object",
    icon: "compress",
    forwardBrackets: {},
    inPorts: {
      in: { datatype: "all", required: true },
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
    );
    /** @type {unknown[]} */
    const groups = [];
    /** @type {any[]} */
    const object = [];

    if (stream[0].type === "openBracket") {
      // Remove the surrounding brackets
      stream.shift();
      stream.pop();
    }

    for (const packet of stream) {
      if (packet.type === "openBracket") {
        const here = locate(object, groups);
        here[packet.data] = [];
        groups.push(packet.data);
        continue;
      }
      if (packet.type === "data") {
        const here = locate(object, groups);
        here.push(packet.data);
        continue;
      }
      if (packet.type === "closeBracket") {
        groups.pop();
      }
    }

    const result = objectify(object);
    output.sendDone({ out: result });
  });

  return c;
}
