/**
 * Generischer Formular-Renderer (React-Version).
 *
 * Wichtig: Diese Komponente kennt KEIN einziges konkretes Attribut
 * ("physicalState", "gasPressureBar" o.ae. tauchen hier nirgends als
 * String auf). Alles kommt zur Laufzeit aus dem Schema-Endpunkt.
 * Neues Attribut in der DB -> taucht hier automatisch im Formular auf,
 * ohne dass diese Datei angefasst wird.
 *
 * Die Sichtbarkeitspruefung (visibleWhen) wird hier client-seitig
 * gespiegelt, damit sich das Formular beim Tippen live aktualisiert.
 * Massgeblich und Source of Truth bleibt aber IMMER das Backend
 * (siehe MaterialValidationService), das jede Anfrage nochmal komplett
 * prueft.
 */

import { useEffect, useMemo, useState } from "react";
import "./style.css";

type DataType = "STRING" | "NUMBER" | "BOOLEAN" | "DATE" | "ENUM";

interface Category {
  code: string;
  name: string;
}

interface Rule {
  and?: Rule[];
  or?: Rule[];
  attribute?: string;
  operator?: "EQUALS" | "NOT_EQUALS" | "IN" | "NOT_IN" | "IS_EMPTY" | "IS_NOT_EMPTY";
  value?: unknown;
}

interface AttributeSchema {
  code: string;
  label: string;
  description?: string;
  unit?: string;
  required?: boolean;
  dataType: DataType;
  enumValues?: string[];
  defaultValue?: string;
  visibleWhen?: Rule | null;
}

interface CategorySchema {
  categoryCode: string;
  attributes: AttributeSchema[];
}

type FieldValues = Record<string, string | boolean | undefined>;

interface FieldError {
  attribute: string;
  message: string;
}

/** Wertet eine visibleWhen-Regel generisch aus (spiegelt RuleEngine.java). */
function evaluateRule(rule: Rule | null | undefined, values: FieldValues): boolean {
  if (!rule) return true;

  if (rule.and) {
    return rule.and.every((r) => evaluateRule(r, values));
  }
  if (rule.or) {
    return rule.or.some((r) => evaluateRule(r, values));
  }

  const actual = values[rule.attribute ?? ""];
  const expected = rule.value;
  const operator = rule.operator || "EQUALS";

  switch (operator) {
    case "EQUALS":
      return String(actual ?? "") === String(expected ?? "");
    case "NOT_EQUALS":
      return String(actual ?? "") !== String(expected ?? "");
    case "IN":
      return Array.isArray(expected) && expected.map(String).includes(String(actual));
    case "NOT_IN":
      return !(Array.isArray(expected) && expected.map(String).includes(String(actual)));
    case "IS_EMPTY":
      return actual === undefined || actual === null || actual === "";
    case "IS_NOT_EMPTY":
      return !(actual === undefined || actual === null || actual === "");
    default:
      console.warn("Unbekannter Operator:", operator);
      return true;
  }
}

async function fetchJson<T>(url: string): Promise<T> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${url} -> ${res.status}`);
  return res.json() as Promise<T>;
}

export default function App() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [schema, setSchema] = useState<CategorySchema | null>(null);
  const [values, setValues] = useState<FieldValues>({});
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [loadError, setLoadError] = useState<string | null>(null);
  const [resultOutput, setResultOutput] = useState<string>("");

  // Kategorien einmalig laden
  useEffect(() => {
    (async () => {
      try {
        const cats = await fetchJson<Category[]>("/api/categories");
        if (cats.length === 0) {
          setLoadError("Keine Kategorien gefunden. Sind die Flyway-Migrationen (V1/V2) gelaufen?");
          return;
        }
        setCategories(cats);
        setSelectedCategory(cats[0].code);
      } catch (err) {
        setLoadError(String(err));
      }
    })();
  }, []);

  // Schema neu laden, sobald sich die Kategorie aendert
  useEffect(() => {
    if (!selectedCategory) return;
    (async () => {
      try {
        const loadedSchema = await fetchJson<CategorySchema>(
          `/api/categories/${selectedCategory}/schema`
        );
        setSchema(loadedSchema);
        setValues({});
        setFieldErrors({});
        setLoadError(null);
      } catch (err) {
        setLoadError(String(err));
      }
    })();
  }, [selectedCategory]);

  const visibility = useMemo(() => {
    if (!schema) return {} as Record<string, boolean>;
    const result: Record<string, boolean> = {};
    for (const attr of schema.attributes) {
      result[attr.code] = evaluateRule(attr.visibleWhen, values);
    }
    return result;
  }, [schema, values]);

  function setFieldValue(code: string, value: string | boolean) {
    setValues((prev) => ({ ...prev, [code]: value }));
  }

  function clearFieldErrors() {
    setFieldErrors({});
  }

  async function onSubmit(event: React.FormEvent) {
    event.preventDefault();
    if (!schema) return;
    clearFieldErrors();

    const payload = {
      categoryCode: schema.categoryCode,
      name: String(values["materialName"] ?? ""),
      values,
    };

    try {
      const response = await fetch("/api/materials", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const body = await response.json();

      if (!response.ok) {
        const errors: FieldError[] = body.errors || [];
        setFieldErrors(
          Object.fromEntries(errors.map((e) => [e.attribute, e.message]))
        );
        setResultOutput(JSON.stringify(body, null, 2));
        return;
      }

      setResultOutput(JSON.stringify(body, null, 2));
    } catch (err) {
      setResultOutput("Fehler: " + err);
    }
  }

  function renderInput(attr: AttributeSchema) {
    const id = `field_${attr.code}`;

    if (attr.dataType === "ENUM") {
      return (
        <div className="radio-group" id={id}>
          {(attr.enumValues || []).map((value, index) => {
            const optionId = `${id}_${index}`;
            const checked = (values[attr.code] ?? attr.defaultValue) === value;
            return (
              <div className="radio-option" key={value}>
                <input
                  type="radio"
                  id={optionId}
                  name={attr.code}
                  value={value}
                  checked={checked}
                  onChange={() => setFieldValue(attr.code, value)}
                />
                <label htmlFor={optionId} className="radio-label">
                  {value}
                </label>
              </div>
            );
          })}
        </div>
      );
    }

    if (attr.dataType === "BOOLEAN") {
      const checked = Boolean(values[attr.code] ?? false);
      return (
        <input
          type="checkbox"
          id={id}
          name={attr.code}
          checked={checked}
          onChange={(e) => setFieldValue(attr.code, e.target.checked)}
        />
      );
    }

    const inputType = attr.dataType === "NUMBER" ? "number" : attr.dataType === "DATE" ? "date" : "text";
    const value = (values[attr.code] as string | undefined) ?? attr.defaultValue ?? "";

    return (
      <input
        type={inputType}
        id={id}
        name={attr.code}
        step={attr.dataType === "NUMBER" ? "any" : undefined}
        value={value}
        onChange={(e) => setFieldValue(attr.code, e.target.value)}
      />
    );
  }

  return (
    <>
      <header>
        <p className="eyebrow">
          Schema-getriebenes Formular · generiert aus <code>attribute_definitions</code>
        </p>
        <h1>Material anlegen</h1>
        <p className="subtitle">
          Jedes Feld unten wird zur Laufzeit aus dem Schema gerendert, das{" "}
          <code>GET /api/categories/{"{code}"}/schema</code> liefert. Der Mono-Tag neben jedem Label
          ist der echte JSON-Attributschlüssel.
        </p>
      </header>

      <main>
        <section className="panel">
          <div className="panel-heading">Formular</div>

          {loadError && (
            <p style={{ color: "#c0392b" }}>
              Schema konnte nicht geladen werden: {loadError}. Prüfe in der Browser-Konsole (F12)
              und im Backend-Log, ob der Server unter dem gleichen Origin läuft und
              /api/categories erreichbar ist.
            </p>
          )}

          <form onSubmit={onSubmit}>
            <div className="field">
              <div className="field-label-row">
                <label htmlFor="categorySelect">Kategorie</label>
              </div>
              <select
                id="categorySelect"
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
              >
                {categories.map((c) => (
                  <option key={c.code} value={c.code}>
                    {c.name} ({c.code})
                  </option>
                ))}
              </select>
            </div>


            {schema?.attributes.map((attr) => (
              <div
                className={`field${visibility[attr.code] ? "" : " hidden"}`}
                data-attribute-code={attr.code}
                key={attr.code}
              >
                <div className="field-label-row">
                  <span className="field-code">{attr.code}</span>
                  <label htmlFor={`field_${attr.code}`}>{attr.label}</label>
                  {attr.required && <span className="required-marker">*</span>}
                  {attr.unit && <span className="field-unit">({attr.unit})</span>}
                </div>

                {attr.description && <div className="field-description">{attr.description}</div>}

                {renderInput(attr)}

                <div className={`field-error${fieldErrors[attr.code] ? "" : " hidden"}`}>
                  {fieldErrors[attr.code]}
                </div>
              </div>
            ))}

            <button type="submit">Material anlegen</button>
          </form>
        </section>

        <section className="panel panel--terminal">
          <div className="panel-heading panel-heading--terminal">Antwort</div>
          <pre className="white">{resultOutput}</pre>
        </section>
      </main>
    </>
  );
}
