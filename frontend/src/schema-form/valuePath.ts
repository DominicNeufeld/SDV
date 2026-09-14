import type { PathSegment } from "./types";

// Get a value from a nested path
export function getIn(root: unknown, path: PathSegment[]): unknown {
  let current: unknown = root;

  // Traverse the path
  for (const key of path) 
  {
    if (current === null || current === undefined) return undefined;
    current = (current as Record<PathSegment, unknown>)[key];
  }
  return current;
}

// Set a value at a nested path
export function setIn(root: unknown, path: PathSegment[], value: unknown): unknown 
{
  // Return the value when the path is complete
  if (path.length === 0) return value;

  const [key, ...rest] = path;

  // Detect whether the path points to an array
  const isArrayKey = typeof key === "number";

  let base: Record<PathSegment, unknown> | unknown[];

  // Create or copy the base structure
  if (root === null || root === undefined) 
  {
    base = isArrayKey ? [] : {};
  } 
  else if (Array.isArray(root)) 
  {
    base = [...root];
  } else 
  {
    base = { ...(root as Record<PathSegment, unknown>) };
  }

  const current = (base as Record<PathSegment, unknown>)[key];

  // Recursively update the nested value
  (base as Record<PathSegment, unknown>)[key] = setIn(current, rest, value);
  return base;
}

// Remove an item from an array at a given path
export function removeIndexIn(root: unknown, path: PathSegment[], index: number): unknown 
{
  const current = getIn(root, path);
  if (!Array.isArray(current)) return root;

  const next = current.filter((_, i) => i !== index);
  return setIn(root, path, next);
}
