import { useEffect, useState } from "react";
import type { AttributeNode } from "./types";

export function SchemaFormNav({ nodes }: { nodes: AttributeNode[] }) 
{
  // Track the currently active navigation item
  const [activeCode, setActiveCode] = useState<string | null>(
    nodes[0]?.attr.code ?? null
  );

  // Observe form sections and update the active item on scroll
  useEffect(() => {
    if (nodes.length === 0) return;

    // Find the corresponding form elements
    const elements = nodes
      .map((node) =>
        document.querySelector<HTMLElement>(
          `[data-attribute-code="${CSS.escape(node.attr.code)}"]`
        )
      )
      .filter((el): el is HTMLElement => el !== null);

    if (elements.length === 0) return;

    // Watch which section is currently visible
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

          if (code) 
          {
            setActiveCode(code);
          }
        }
      },
      {
        rootMargin: "-120px 0px -60% 0px",
        threshold: 0,
      }
    );
  // Start observing all form sections
    elements.forEach((element) => observer.observe(element));

  // Clean up the observer
    return () => observer.disconnect();
  }, [nodes]);

  // Scroll to the selected form section
  function scrollTo(code: string) 
  {
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

  // Scroll to the JSON output panel
  function scrollToJson() 
  {
    const element = document.querySelector<HTMLElement>(
      ".panel--terminal"
    );

    if (!element) return;

    element.scrollIntoView({
      behavior: "smooth",
      block: "start",
    });
  }
  // Render nothing if there are no nodes
  if (nodes.length === 0)
  {
    return null;
  }
  
  // Render the side navigation
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