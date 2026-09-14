import type { AttributeNode, AttributeSchema } from "./types";

// Build a hierarchical tree from the flat attribute list
export function buildAttributeTree(attributes: AttributeSchema[]): AttributeNode[] 
{
  // Create a tree node including its children and variants
  function makeNode(attr: AttributeSchema): AttributeNode 
  {

    // Find child attributes
    const children = attributes
      .filter((a) => a.parentCode === attr.code && !a.variantOfCode)
      .map(makeNode);

     // Find variant attributes
    const variants = attributes
      .filter((a) => a.variantOfCode === attr.code)
      .map(makeNode);
    return { attr, children, variants };
  }

  // Return top-level attributes
  return attributes
    .filter((a) => !a.parentCode && !a.variantOfCode)
    .map(makeNode);
}

// Find the field that controls the selected variant
export function findDiscriminatorChild(node: AttributeNode): AttributeNode | undefined 
{
  if (node.variants.length === 0) return undefined;
  const variantKeys = new Set(node.variants.map((v) => v.attr.variantKey).filter(Boolean));

  // Find an ENUM child whose values match a variant key
  return node.children.find(
    (c) => c.attr.dataType === "ENUM" && (c.attr.enumValues || []).some((v) => variantKeys.has(v))
  );
}
