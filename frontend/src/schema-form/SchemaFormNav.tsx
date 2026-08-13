import { useEffect, useState } from "react";
import type { AttributeNode } from "./types";

export function SchemaFormNav({ nodes }: { nodes: AttributeNode[] }) {
  const [activeCode, setActiveCode] = useState<string | null>(
    nodes[0]?.attr.code ?? null
  );

  useEffect(() => {
    if (nodes.length === 0) return;

    const elements = nodes
      .map((node) =>
        document.querySelector<HTMLElement>(
          `[data-attribute-code="${CSS.escape(node.attr.code)}"]`
        )
      )
      .filter((el): el is HTMLElement => el !== null);

    if (elements.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((entry) => entry.isIntersecting)
          .sort(
            (a, b) =>
              a.boundingClientRect.top - b.boundingClientRect.top
          );

        if (visible.length > 0) {
          const element = visible[0].target as HTMLElement;
          const code = element.dataset.attributeCode;

          if (code) {
            setActiveCode(code);
          }
        }
      },
      {
        rootMargin: "-120px 0px -60% 0px",
        threshold: 0,
      }
    );

    elements.forEach((element) => observer.observe(element));

    return () => observer.disconnect();
  }, [nodes]);

  function scrollTo(code: string) {
    const element = document.querySelector<HTMLElement>(
      `[data-attribute-code="${CSS.escape(code)}"]`
    );

    if (!element) return;

    element.scrollIntoView({
      behavior: "smooth",
      block: "start",
    });

    setActiveCode(code);
  }

  function scrollToJson() {
    const element = document.querySelector<HTMLElement>(
      ".panel--terminal"
    );

    if (!element) return;

    element.scrollIntoView({
      behavior: "smooth",
      block: "start",
    });
  }

  if (nodes.length === 0) {
    return null;
  }

  return (
    <nav className="side-nav" aria-label="Formular-Navigation">
      <div className="side-nav-inner">

        <div className="side-nav-track" aria-hidden="true" />

        {nodes.map((node) => (
          <button
            key={node.attr.code}
            type="button"
            className={`side-nav-item ${
              activeCode === node.attr.code ? "active" : ""
            }`}
            onClick={() => scrollTo(node.attr.code)}
          >
            <span className="side-nav-dot" />

            <span className="side-nav-label">
              {node.attr.label}
            </span>
          </button>
        ))}

        {}
        <div className="side-nav-divider" />

        {}
        <button
          type="button"
          className="side-nav-json"
          onClick={scrollToJson}
        >
          <span className="side-nav-json-icon">
            {"{}"}
          </span>

          <span>JSON</span>
        </button>

      </div>
    </nav>
  );
}