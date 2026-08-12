import type { PathSegment } from "./types";

export function getIn(root: unknown, path: PathSegment[]): unknown {
  let current: unknown = root;
  for (const key of path) {
    if (current === null || current === undefined) return undefined;
    current = (current as Record<PathSegment, unknown>)[key];
  }
  return current;
}



export function setIn(root: unknown, path: PathSegment[], value: unknown): unknown {
  if (path.length === 0) return value;

  const [key, ...rest] = path;
  const isArrayKey = typeof key === "number";

  let base: Record<PathSegment, unknown> | unknown[];
  if (root === null || root === undefined) {
    base = isArrayKey ? [] : {};
  } else if (Array.isArray(root)) {
    base = [...root];
  } else {
    base = { ...(root as Record<PathSegment, unknown>) };
  }

  const current = (base as Record<PathSegment, unknown>)[key];
  (base as Record<PathSegment, unknown>)[key] = setIn(current, rest, value);
  return base;
}

export function removeIndexIn(root: unknown, path: PathSegment[], index: number): unknown {
  const current = getIn(root, path);
  if (!Array.isArray(current)) return root;
  const next = current.filter((_, i) => i !== index);
  return setIn(root, path, next);
}
