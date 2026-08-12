import { useEffect, useMemo, useState } from "react";
import "./style.css";
import type { CategorySchema } from "./schema-form/types";
import { buildAttributeTree } from "./schema-form/tree";
import { SchemaFormFields, SchemaFormProvider } from "./schema-form/SchemaForm";
import { getIn } from "./schema-form/valuePath";

interface Category {
  code: string;
  name: string;
}

interface FieldError {
  attribute: string;
  message: string;
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
  // values ist jetzt ein verschachtelter Baum (nicht mehr flach), Struktur
  // ergibt sich aus parentCode/repeatable/variantOfCode im Schema.
  const [values, setValues] = useState<unknown>({});
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [loadError, setLoadError] = useState<string | null>(null);
  const [resultOutput, setResultOutput] = useState<string>("");

  const tree = useMemo(() => (schema ? buildAttributeTree(schema.attributes) : []), [schema]);

  // Kategorien einmalig laden
  useEffect(() => {
    (async () => {
      try {
        const cats = await fetchJson<Category[]>("/api/categories");
        if (cats.length === 0) {
          setLoadError("No category found!");
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

  function clearFieldErrors() {
    setFieldErrors({});
  }

  async function onSubmit(event: React.FormEvent) {
    event.preventDefault();
    if (!schema) return;
    clearFieldErrors();

    const payload = {
      categoryCode: schema.categoryCode,
      name: String(getIn(values, ["materialName"]) ?? ""),
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

  return (
    <>
      <header>
        <h1>Create Material</h1>
      </header>

      <main>
        <section className="panel">
          <div className="panel-heading">Form</div>

          {loadError && (
            <p style={{ color: "#c0392b" }}>
              Schema could not be loaded: {loadError}. Check the browser console (F12)
              and the backend log to see if the server is running on the same origin and
              /api/categories is accessible.
            </p>
          )}

          <form onSubmit={onSubmit}>
            <div className="field">
              <div className="field-label-row">
                <label htmlFor="categorySelect">Category</label>
              </div>
              <select
                id="categorySelect"
                value={selectedCategory}
                onChange={(e) => setSelectedCategory(e.target.value)}
              >
                {categories.map((c) => (
                  <option key={c.code} value={c.code}>
                    {c.name}
                  </option>
                ))}
              </select>
            </div>


            <SchemaFormProvider values={values} onChange={setValues} fieldErrors={fieldErrors}>
              <SchemaFormFields nodes={tree} />
            </SchemaFormProvider>

            <button type="submit">Create Material</button>
          </form>
        </section>

        <section className="panel panel--terminal">
          <div className="panel-heading panel-heading--terminal">JSON</div>
          <pre className="white">{resultOutput}</pre>
        </section>
      </main>
    </>
  );
}
