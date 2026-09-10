import type { AttributeNode, PathSegment } from "./types";
import { getIn } from "./valuePath";

export function buildFlatValues(
  nodes: AttributeNode[],
  values: unknown
): Record<string, unknown> {
  const flat: Record<string, unknown> = {};

  // Process each node
  function walk(node: AttributeNode, path: PathSegment[]) {

    // Get current value
    flat[node.attr.code] = getIn(values, path);

    // Stop at repeatable groups
    if (node.attr.dataType === "GROUP" && node.attr.repeatable) {
      return;
    }

    // Process children and variants
    for (const child of node.children) {
      walk(child, [...path, child.attr.code]);
    }
    for (const variant of node.variants) {
      walk(variant, [...path, variant.attr.code]);
    }
  }

  for (const node of nodes) {
    walk(node, [node.attr.code]);
  }

  return flat;
}
