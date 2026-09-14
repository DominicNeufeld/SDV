import type { Rule } from "./types";

export function evaluateRule(
  rule: Rule | null | undefined,
  flatValues: Record<string, unknown>
): boolean {

  // No Rule
  if (!rule) return true;

  // And Rule
  if (rule.and)
  {
    return rule.and.every((r) => evaluateRule(r, flatValues));
  }

  // Or Rule
  if (rule.or) 
  {
    return rule.or.some((r) => evaluateRule(r, flatValues));
  }

  // Get values for comparison
  const actual = flatValues[rule.attribute ?? ""];
  const expected = rule.value;
  const operator = rule.operator || "EQUALS";

  // Check operator
  switch (operator) 
  {
    case "EQUALS":
      return String(actual ?? "") === String(expected ?? "");
    case "NOT_EQUALS":
      return String(actual ?? "") !== String(expected ?? "");
    case "IN":
      return Array.isArray(expected) && expected.map(String).includes(String(actual));
    case "NOT_IN":
      return !(Array.isArray(expected) && expected.map(String).includes(String(actual)));
    case "IS_EMPTY":
      return (
        actual === undefined ||
        actual === null ||
        actual === "" ||
        (Array.isArray(actual) && actual.length === 0)
      );
    case "IS_NOT_EMPTY":
      return !(
        actual === undefined ||
        actual === null ||
        actual === "" ||
        (Array.isArray(actual) && actual.length === 0)
      );
    case "CONTAINS":
      return Array.isArray(actual) && actual.map(String).includes(String(expected));
    case "NOT_CONTAINS":
      return !(Array.isArray(actual) && actual.map(String).includes(String(expected)));
    default:
      console.warn("Unkown Operator:", operator);
      return true;
  }
}