import { Component } from "@noflo/noflo";

/**
 * Transposes an object of properties holding id-keyed values into an
 * object of ids holding property values.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    inPorts: {
      in: { datatype: "object", required: true },
    },
    outPorts: {
      out: { datatype: "object" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    const object = input.getData("in");
    /** @type {Record<string, Record<string, unknown>>} */
    const data = {};
    for (const property of Object.keys(object)) {
      const values = object[property];
      for (const id of Object.keys(values)) {
        if (!data[id]) {
          data[id] = {};
        }
        data[id][property] = values[id];
      }
    }
    output.sendDone({ out: data });
  });

  return c;
}
