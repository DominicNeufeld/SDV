import type { Rule } from "./types";


export function evaluateRule(rule: Rule | null | undefined, siblingValues: Record<string, unknown>): boolean {
  if (!rule) return true;

  if (rule.and) {
    return rule.and.every((r) => evaluateRule(r, siblingValues));
  }
  if (rule.or) {
    return rule.or.some((r) => evaluateRule(r, siblingValues));
  }

  const actual = siblingValues[rule.attribute ?? ""];
  const expected = rule.value;
  const operator = rule.operator || "EQUALS";

  switch (operator) {
    case "EQUALS":
      return String(actual ?? "") === String(expected ?? "");
    case "NOT_EQUALS":
      return String(actual ?? "") !== String(expected ?? "");
    case "IN":
      return Array.isArray(expected) && expected.map(String).includes(String(actual));
    case "NOT_IN":
      return !(Array.isArray(expected) && expected.map(String).includes(String(actual)));
    case "IS_EMPTY":
      return actual === undefined || actual === null || actual === "";
    case "IS_NOT_EMPTY":
      return !(actual === undefined || actual === null || actual === "");
    default:
      console.warn("Unbekannter Operator:", operator);
      return true;
  }
}
