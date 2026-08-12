import { createContext, useContext } from "react";
import type { AttributeNode, PathSegment } from "./types";
import { evaluateRule } from "./rules";
import { findDiscriminatorChild } from "./tree";
import { getIn, removeIndexIn, setIn } from "./valuePath";

// ---------------------------------------------------------------------
// Werte-Kontext: eine einzige verschachtelte Werte-Wurzel fuer das ganze
// Formular. Jede Komponente kennt nur ihren eigenen Pfad hinein.
// ---------------------------------------------------------------------
interface ValuesContextValue {
  values: unknown;
  setValue: (path: PathSegment[], value: unknown) => void;
  removeAt: (path: PathSegment[], index: number) => void;
  fieldErrors: Record<string, string>;
}

const ValuesContext = createContext<ValuesContextValue | null>(null);

function useValuesContext(): ValuesContextValue {
  const ctx = useContext(ValuesContext);
  if (!ctx) throw new Error("SchemaForm-Komponenten muessen innerhalb von <SchemaFormProvider> stehen");
  return ctx;
}

export function SchemaFormProvider({
  values,
  onChange,
  fieldErrors,
  children,
}: {
  values: unknown;
  onChange: (next: unknown) => void;
  fieldErrors: Record<string, string>;
  children: React.ReactNode;
}) {
  const setValue = (path: PathSegment[], value: unknown) => onChange(setIn(values, path, value));
  const removeAt = (path: PathSegment[], index: number) => onChange(removeIndexIn(values, path, index));

  return (
    <ValuesContext.Provider value={{ values, setValue, removeAt, fieldErrors }}>
      {children}
    </ValuesContext.Provider>
  );
}

// ---------------------------------------------------------------------
// Top-Level-Einstieg: rendert alle Wurzel-Knoten des Baums
// ---------------------------------------------------------------------
export function SchemaFormFields({ nodes }: { nodes: AttributeNode[] }) {
  return (
    <>
      {nodes.map((node) => (
        <AttributeNodeField key={node.attr.code} node={node} path={[node.attr.code]} />
      ))}
    </>
  );
}

// ---------------------------------------------------------------------
// Ein einzelner Knoten: entscheidet GROUP vs. Leaf-Feld
// ---------------------------------------------------------------------
function AttributeNodeField({ node, path }: { node: AttributeNode; path: PathSegment[] }) {
  const { values } = useValuesContext();

  // Sichtbarkeit/Pflicht werden immer gegen die GESCHWISTER auf derselben
  // Ebene ausgewertet, also gegen das Werte-Objekt EINE Ebene ueber diesem Feld.
  const siblingScope = path.slice(0, -1);
  const siblingValues = (getIn(values, siblingScope) as Record<string, unknown>) ?? {};

  const visible = evaluateRule(node.attr.visibleWhen, siblingValues);
  const required = node.attr.requiredWhen
    ? evaluateRule(node.attr.requiredWhen, siblingValues)
    : Boolean(node.attr.required);

  if (node.attr.dataType === "GROUP") {
    return <GroupField node={node} path={path} visible={visible} />;
  }

  return <LeafField node={node} path={path} visible={visible} required={required} />;
}

// ---------------------------------------------------------------------
// GROUP: entweder eine einzelne Instanz oder (bei repeatable) ein Array
// ---------------------------------------------------------------------
function GroupField({ node, path, visible }: { node: AttributeNode; path: PathSegment[]; visible: boolean }) {
  const { values, setValue } = useValuesContext();

  if (node.attr.repeatable) {
    const items = (getIn(values, path) as unknown[]) ?? [];
    return (
      <div className={`field field--group${visible ? "" : " hidden"}`} data-attribute-code={node.attr.code}>
        <div className="group-legend">
          {node.attr.label}
          {node.attr.description && <div className="field-description">{node.attr.description}</div>}
        </div>

        {items.map((_, index) => (
          <GroupInstance key={index} node={node} path={[...path, index]} onRemove={() => removeItem(index)} />
        ))}

        <button type="button" className="btn-add" onClick={addItem}>
          + {node.attr.label} hinzufügen
        </button>
      </div>
    );

    function addItem() {
      setValue(path, [...items, {}]);
    }
    function removeItem(index: number) {
      setValue(path, items.filter((_, i) => i !== index));
    }
  }

  return (
    <div className={`field field--group${visible ? "" : " hidden"}`} data-attribute-code={node.attr.code}>
      <div className="group-legend">
        {node.attr.label}
        {node.attr.description && <div className="field-description">{node.attr.description}</div>}
      </div>
      <GroupInstance node={node} path={path} />
    </div>
  );
}

// ---------------------------------------------------------------------
// Eine Instanz einer Gruppe: rendert alle Kind-Attribute rekursiv, plus
// - falls vorhanden - die aktuell ausgewaehlte Variante (oneOf)
// ---------------------------------------------------------------------
function GroupInstance({
  node,
  path,
  onRemove,
}: {
  node: AttributeNode;
  path: PathSegment[];
  onRemove?: () => void;
}) {
  const { values } = useValuesContext();
  const instanceValues = (getIn(values, path) as Record<string, unknown>) ?? {};

  const discriminator = findDiscriminatorChild(node);
  const selectedVariantKey = discriminator ? instanceValues[discriminator.attr.code] : undefined;
  const selectedVariant = node.variants.find((v) => v.attr.variantKey === selectedVariantKey);

  return (
    <div className="group-instance">
      {onRemove && (
        <button type="button" className="btn-remove" onClick={onRemove} aria-label="Eintrag entfernen">
          ✕
        </button>
      )}

      {node.children.map((child) => (
        <AttributeNodeField key={child.attr.code} node={child} path={[...path, child.attr.code]} />
      ))}

      {selectedVariant && (
        <AttributeNodeField
          key={selectedVariant.attr.code}
          node={selectedVariant}
          path={[...path, selectedVariant.attr.code]}
        />
      )}
    </div>
  );
}

// ---------------------------------------------------------------------
// Leaf-Feld: STRING / NUMBER / BOOLEAN / DATE / ENUM / MULTI_ENUM
// ---------------------------------------------------------------------
function LeafField({
  node,
  path,
  visible,
  required,
}: {
  node: AttributeNode;
  path: PathSegment[];
  visible: boolean;
  required: boolean;
}) {
  const { values, setValue, fieldErrors } = useValuesContext();
  const attr = node.attr;
  const value = getIn(values, path);
  const id = `field_${path.join("_")}`;
  // Fehler aus dem Backend sind aktuell nur fuer Top-Level-Codes verfuegbar.
  const error = path.length === 1 ? fieldErrors[attr.code] : undefined;

  return (
    <div className={`field${visible ? "" : " hidden"}`} data-attribute-code={attr.code}>
      <div className="field-label-row">
        <label htmlFor={id}>{attr.label}</label>
        {required && <span className="required-marker">*</span>}
        {attr.unit && <span className="field-unit">({attr.unit})</span>}
      </div>

      {attr.description && <div className="field-description">{attr.description}</div>}

      {renderInput()}

      <div className={`field-error${error ? "" : " hidden"}`}>{error}</div>
    </div>
  );

  function renderInput() {
    if (attr.dataType === "ENUM") {
      return (
        <div className="radio-group" id={id}>
          {(attr.enumValues || []).map((option, index) => {
            const optionId = `${id}_${index}`;
            const checked = (value ?? attr.defaultValue) === option;
            return (
              <div className="radio-option" key={option}>
                <input
                  type="radio"
                  id={optionId}
                  name={id}
                  value={option}
                  checked={checked}
                  onChange={() => setValue(path, option)}
                />
                <label htmlFor={optionId} className="radio-label">
                  {option}
                </label>
              </div>
            );
          })}
        </div>
      );
    }

    if (attr.dataType === "MULTI_ENUM") {
      const selected = Array.isArray(value) ? (value as string[]) : [];
      return (
        <div className="checkbox-group" id={id}>
          {(attr.enumValues || []).map((option, index) => {
            const optionId = `${id}_${index}`;
            const checked = selected.includes(option);
            return (
              <div className="checkbox-option" key={option}>
                <input
                  type="checkbox"
                  id={optionId}
                  value={option}
                  checked={checked}
                  onChange={(e) => {
                    const next = e.target.checked
                      ? [...selected, option]
                      : selected.filter((v) => v !== option);
                    setValue(path, next);
                  }}
                />
                <label htmlFor={optionId} className="radio-label">
                  {option}
                </label>
              </div>
            );
          })}
        </div>
      );
    }

    if (attr.dataType === "BOOLEAN") {
      const checked = Boolean(value ?? false);
      return (
        <input
          type="checkbox"
          id={id}
          checked={checked}
          onChange={(e) => setValue(path, e.target.checked)}
        />
      );
    }

    const inputType = attr.dataType === "NUMBER" ? "number" : attr.dataType === "DATE" ? "date" : "text";
    const stringValue = (value as string | undefined) ?? attr.defaultValue ?? "";

    return (
      <input
        type={inputType}
        id={id}
        step={attr.dataType === "NUMBER" ? "any" : undefined}
        value={stringValue}
        onChange={(e) => setValue(path, e.target.value)}
      />
    );
  }
}
