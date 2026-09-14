import { createContext, useContext, useEffect, useMemo, useState } from "react";
import type { AttributeNode, PathSegment } from "./types";
import { evaluateRule } from "./rules";
import { findDiscriminatorChild } from "./tree";
import { buildFlatValues } from "./flatValues";
import { convertUnitValue } from "./unitConversion";
import { getIn, removeIndexIn, setIn } from "./valuePath";

interface ValuesContextValue {
  values: unknown;
  flatValues: Record<string, unknown>;
  setValue: (path: PathSegment[], value: unknown) => void;
  removeAt: (path: PathSegment[], index: number) => void;
  fieldErrors: Record<string, string>;
}

// Context for shared form state
const ValuesContext = createContext<ValuesContextValue | null>(null);

// Ensure component is inside provider
function useValuesContext(): ValuesContextValue 
{
  const ctx = useContext(ValuesContext);

  if (!ctx) {
    throw new Error("SchemaForm Components have to be in <SchemaFormProvider>");
  }

  return ctx;
}

// Main provider for form data and actions
export function SchemaFormProvider({
  values,
  tree,
  onChange,
  fieldErrors,
  children,
}: {
  values: unknown;

  tree: AttributeNode[];
  onChange: (next: unknown) => void;
  fieldErrors: Record<string, string>;
  children: React.ReactNode;
}) {
  const setValue = (path: PathSegment[], value: unknown) =>
    onChange(setIn(values, path, value));

  const removeAt = (path: PathSegment[], index: number) =>
    onChange(removeIndexIn(values, path, index));

  // Build flat values for rule evaluation
  const flatValues = useMemo(
    () => buildFlatValues(tree, values),
    [tree, values],
  );

  return (
    <ValuesContext.Provider
      value={{
        values,
        flatValues,
        setValue,
        removeAt,
        fieldErrors,
      }}
    >
      {children}
    </ValuesContext.Provider>
  );
}

// Render all root fields
export function SchemaFormFields({ nodes }: { nodes: AttributeNode[] }) {
  return (
    <>
      {nodes.map((node) => (
        <AttributeNodeField
          key={node.attr.code}
          node={node}
          path={[node.attr.code]}
        />
      ))}
    </>
  );
}

// Evaluate visibility and required rules
function AttributeNodeField({
  node,
  path,
}: {
  node: AttributeNode;
  path: PathSegment[];
}) 
{
  const { flatValues } = useValuesContext();

  const visible = evaluateRule(node.attr.visibleWhen, flatValues);

  const required = node.attr.requiredWhen
    ? evaluateRule(node.attr.requiredWhen, flatValues)
    : Boolean(node.attr.required);

  if (node.attr.dataType === "GROUP") {
    return <GroupField node={node} path={path} visible={visible} />;
  }

  return (
    <LeafField node={node} path={path} visible={visible} required={required} />
  );
}

// Render external info link
function FieldLink({ href }: { href: string }) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className="field-link-icon"
      title="More Information"
      aria-label="More Information"
    >
      Info
    </a>
  );
}

// Render group fields
function GroupField({
  node,
  path,
  visible,
}: {
  node: AttributeNode;
  path: PathSegment[];
  visible: boolean;
}) {
  const { values, setValue } = useValuesContext();

  if (node.attr.repeatable) {
    const items = (getIn(values, path) as unknown[]) ?? [];

    return (
      <div
        className={`field field--group${visible ? "" : " hidden"}`}
        data-attribute-code={node.attr.code}
      >
        <div className="group-legend">
          {node.attr.label}
          {node.attr.link && <FieldLink href={node.attr.link} />}

          {node.attr.description && (
            <div className="field-description">{node.attr.description}</div>
          )}
        </div>

        {items.map((_, index) => (
          <GroupInstance
            key={index}
            node={node}
            path={[...path, index]}
            onRemove={() => removeItem(index)}
          />
        ))}

        <button type="button" className="btn-add" onClick={addItem}>
          + {node.attr.label} add
        </button>
      </div>
    );

    // Add new repeatable group item
    function addItem() {
      setValue(path, [...items, {}]);
    }

    // Remove group item
    function removeItem(index: number) {
      setValue(
        path,
        items.filter((_, i) => i !== index),
      );
    }
  }

  return (
    <div
      className={`field field--group${visible ? "" : " hidden"}`}
      data-attribute-code={node.attr.code}
    >
      <div className="group-legend">
        {node.attr.label}
        {node.attr.link && <FieldLink href={node.attr.link} />}

        {node.attr.description && (
          <div className="field-description">{node.attr.description}</div>
        )}
      </div>

      <GroupInstance node={node} path={path} />
    </div>
  );
}


// Render one group instance
function GroupInstance({
  node,
  path,
  onRemove,
}: 
{
  node: AttributeNode;
  path: PathSegment[];
  onRemove?: () => void;
}) 
{
  const { values } = useValuesContext();

  const instanceValues = (getIn(values, path) as Record<string, unknown>) ?? {};

  const discriminator = findDiscriminatorChild(node);

  const selectedVariantKey = discriminator
    ? instanceValues[discriminator.attr.code]
    : undefined;

  const selectedVariant = node.variants.find(
    (v) => v.attr.variantKey === selectedVariantKey,
  );

  return (
    <div className="group-instance">
      {onRemove && (
        <button
          type="button"
          className="btn-remove"
          onClick={onRemove}
          aria-label="Remove Entry"
        >
          ✕
        </button>
      )}

      {node.children.map((child) => (
        <AttributeNodeField
          key={child.attr.code}
          node={child}
          path={[...path, child.attr.code]}
        />
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

// Render single input field
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

  const error = path.length === 1 ? fieldErrors[attr.code] : undefined;

  const optional = !required;

  const [open, setOpen] = useState(required);


// Open optional field on validation error
  useEffect(() => {
    if (error) {
      setOpen(true);
    }
  }, [error]);

  return (
    <div
      className={`field${visible ? "" : " hidden"}`}
      data-attribute-code={attr.code}
    >
      {optional ? (
        <>
          {}
          <button
            type="button"
            className="optional-field-toggle"
            onClick={() => setOpen((current) => !current)}
            aria-expanded={open}
            aria-controls={`${id}_content`}
          >
            <span className="optional-field-arrow">{open ? "▾" : "▸"}</span>

            <span className="optional-field-label">{attr.label}</span>

            {attr.unit && <span className="field-unit">({attr.unit})</span>}
          </button>

          {}
          {open && (
            <div id={`${id}_content`} className="optional-field-content">
              {(attr.description || attr.link) && (
                <div className="field-description">
                  {attr.description}
                  {attr.link && <FieldLink href={attr.link} />}
                </div>
              )}

              {renderInput()}

              <div className={`field-error${error ? "" : " hidden"}`}>
                {error}
              </div>
            </div>
          )}
        </>
      ) : (
        <>
          {}
          <div className="field-label-row">
            <label htmlFor={id}>{attr.label}</label>

            <span className="required-marker">*</span>

            {attr.unit && <span className="field-unit">({attr.unit})</span>}
          </div>

          {(attr.description || attr.link) && (
            <div className="field-description">
              {attr.description}
              {attr.link && <FieldLink href={attr.link} />}
            </div>
          )}

          {renderInput()}

          <div className={`field-error${error ? "" : " hidden"}`}>{error}</div>
        </>
      )}
    </div>
  );

  // Render input by data type
  function renderInput() 
  {
    // Radio buttons for enum values
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
// Checkboxes for multi-select values
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
// Quantity input with unit selection
    if (attr.dataType === "QUANTITY") {
      const q =
        (value as
          | {
              value?: string;
              unit?: string;
            }
          | undefined) ?? {};

      const hasUnitOptions =
        Array.isArray(attr.unitOptions) && attr.unitOptions.length > 0;

      return (
        <div className="quantity-group" id={id}>
          <input
            type="number"
            step="any"
            placeholder="Wert"
            value={q.value ?? ""}
            onChange={(e) => setValue([...path, "value"], e.target.value)}
          />

          {hasUnitOptions ? (
            <select
              value={q.unit ?? ""}
             onChange={(e) => {
                const newUnit = e.target.value;
                const oldUnit = q.unit;
                const rawValue = q.value;
 
                if (
                  oldUnit &&
                  newUnit &&
                  rawValue !== undefined &&
                  rawValue !== ""
                ) {
                  const numeric = Number(rawValue);
                  if (!Number.isNaN(numeric)) 
                    {

                    // Convert value when unit changes
                    const converted = convertUnitValue(
                      numeric,
                      oldUnit,
                      newUnit
                    );
                    if (converted !== null) {
                      setValue(path, {
                        value: String(converted),
                        unit: newUnit,
                      });
                      return;
                    }
                  }
                }
 
                setValue([...path, "unit"], newUnit);
              }}
            >
              <option value="">Select Unit</option>
              {attr.unitOptions!.map((option) => (
                <option key={option} value={option}>
                  {option}
                </option>
              ))}
            </select>
          ) : (
            <input
              type="text"
              placeholder="Unit"
              value={q.unit ?? ""}
              onChange={(e) => setValue([...path, "unit"], e.target.value)}
            />
          )}
        </div>
      );
    }
// Checkbox for boolean values
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

    const inputType =
      attr.dataType === "NUMBER"
        ? "number"
        : attr.dataType === "DATE"
          ? "date"
          : "text";

    const stringValue =
      (value as string | undefined) ?? attr.defaultValue ?? "";

  // Default text, number or date input
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
