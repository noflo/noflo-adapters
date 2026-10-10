import { Component } from "@noflo/noflo";

/**
 * Stringifies a simple object with configurable associator and
 * delimiter.
 * @returns {import("@noflo/noflo").Component} The configured component
 */
export function getComponent() {
  const c = new Component({
    icon: "font",
    description:
      "stringifies a simple object with configurable associator and delimiter",
    inPorts: {
      in: {
        datatype: "object",
        description: "Object to convert",
        required: true,
      },
      assoc: {
        datatype: "string",
        description: "Associating string for key/value pairs",
        control: true,
        default: ":",
      },
      delim: {
        datatype: "string",
        description: "Delimiter string between object properties",
        control: true,
        default: ",",
      },
    },
    outPorts: {
      out: { datatype: "string" },
    },
  });

  c.process((input, output) => {
    if (!input.hasData("in")) {
      return;
    }
    if (input.attached("assoc").length && !input.hasData("assoc")) {
      return;
    }
    if (input.attached("delim").length && !input.hasData("delim")) {
      return;
    }

    const assoc = input.hasData("assoc") ? input.getData("assoc") : ":";
    const delim = input.hasData("delim") ? input.getData("delim") : ",";
    const data = input.getData("in");

    const str = [];
    for (const key of Object.keys(data)) {
      let value = data[key];
      if (Object.prototype.toString.apply(value) !== "[object String]") {
        value = JSON.stringify(value);
      }

      str.push(`${key}${assoc}${value}`);
    }

    output.sendDone({ out: str.join(delim) });
  });

  return c;
}
