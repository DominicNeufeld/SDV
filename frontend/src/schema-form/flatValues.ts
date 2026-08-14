import type { AttributeNode, PathSegment } from "./types";
import { getIn } from "./valuePath";

export function buildFlatValues(
  nodes: AttributeNode[],
  values: unknown
): Record<string, unknown> {
  const flat: Record<string, unknown> = {};

  function walk(node: AttributeNode, path: PathSegment[]) {
    flat[node.attr.code] = getIn(values, path);

    if (node.attr.dataType === "GROUP" && node.attr.repeatable) {
      return;
    }

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
