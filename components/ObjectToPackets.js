import { Component, IP } from "@noflo/noflo";

/**
 * Converts each incoming object into a stream, keys becoming groups.
 * The conversion is destructive on a deep copy of the input.
 * @param {any} object
 * @param {number} level
 * @param {{ send(map: Record<string, unknown>): void }} output
 */
const convert = (object, level, output) => {
  let subject = object;
  // Deal with data packets
  if (Array.isArray(subject)) {
    for (let i = 0; i < subject.length; i += 1) {
      output.send({ out: subject[i] });
      delete subject[i];
    }
    // Clean up after deletion
    subject = subject.filter((item) => item !== undefined);
  }

  // Stop if we've reached deep enough
  if (level <= 0) {
    if (Object.keys(subject).length > 0) {
      output.send({ out: subject });
    }
    return;
  }

  // Go through the groups
  for (const key of Object.keys(subject)) {
    const value = subject[key];
    output.send({ out: new IP("openBracket", key) });

    if (typeof value === "object" && value !== null) {
      convert(value, level - 1, output);
    } else {
      output.send({ out: value });
    }

    output.send({ out: new IP("closeBracket", key) });
  }
};

/** @returns {import("@noflo/noflo").Component} The configured component */
export function getComponent() {
  const c = new Component({
    description: "Convert each incoming object into a stream",
    icon: "expand",
    inPorts: {
      in: {
        datatype: "all",
        description: "Array/Object packets to convert",
        required: true,
      },
      depth: {
        datatype: "int",
        description:
          "Maximum level of recursion when conversion incoming object packet",
        control: true,
      },
    },
    outPorts: {
      out: {
        datatype: "all",
        description:
          "Inner items from incoming array/objects with associated keys as groups",
      },
      empty: {
        datatype: "bang",
        description: "Sends when an empty object or array was received",
      },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (input.attached("depth").length && !input.hasData("depth")) {
      return;
    }

    const depth = input.hasData("depth")
      ? input.getData("depth")
      : Number.POSITIVE_INFINITY;
    const data = input.getData("in");
    if (!Array.isArray(data) && (typeof data !== "object" || data === null)) {
      // Plain value, send as-is
      output.sendDone({ out: data });
      return;
    }

    if (Array.isArray(data) && data.length === 0) {
      output.sendDone({ empty: null });
      return;
    }
    if (
      typeof data === "object" &&
      !Array.isArray(data) &&
      Object.keys(data).length === 0
    ) {
      output.sendDone({ empty: null });
      return;
    }

    // Deep copy because conversion is destructive
    const object = structuredClone(data);
    // Send data as a stream
    output.send({ out: new IP("openBracket", null) });
    convert(object, depth, output);
    output.send({ out: new IP("closeBracket", null) });
    output.done();
  });

  return c;
}
