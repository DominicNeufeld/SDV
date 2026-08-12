import type { AttributeNode, AttributeSchema } from "./types";


export function buildAttributeTree(attributes: AttributeSchema[]): AttributeNode[] {
  function makeNode(attr: AttributeSchema): AttributeNode {
    const children = attributes
      .filter((a) => a.parentCode === attr.code && !a.variantOfCode)
      .map(makeNode);
    const variants = attributes
      .filter((a) => a.variantOfCode === attr.code)
      .map(makeNode);
    return { attr, children, variants };
  }

  return attributes
    .filter((a) => !a.parentCode && !a.variantOfCode)
    .map(makeNode);
}


export function findDiscriminatorChild(node: AttributeNode): AttributeNode | undefined {
  if (node.variants.length === 0) return undefined;
  const variantKeys = new Set(node.variants.map((v) => v.attr.variantKey).filter(Boolean));
  return node.children.find(
    (c) => c.attr.dataType === "ENUM" && (c.attr.enumValues || []).some((v) => variantKeys.has(v))
  );
}
