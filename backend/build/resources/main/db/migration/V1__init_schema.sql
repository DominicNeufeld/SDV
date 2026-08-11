-- =====================================================================
-- Globale Attribut-Definitionen: JEDES Attribut existiert genau EINMAL,
-- unabhaengig davon, wie viele Kategorien es benutzen.
-- =====================================================================
CREATE TABLE attribute_definitions (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(100) NOT NULL UNIQUE,      -- z.B. "gasPressureBar"
    label         VARCHAR(255) NOT NULL,             -- Anzeigename fuer das Formular
    description   VARCHAR(1000),
    data_type     VARCHAR(20)  NOT NULL,              -- STRING, NUMBER, BOOLEAN, ENUM, DATE
    unit          VARCHAR(50),                        -- z.B. "bar", "kg" (optional)
    enum_values   JSONB,                               -- nur relevant bei data_type = ENUM
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

-- =====================================================================
-- Materialkategorien
-- =====================================================================
CREATE TABLE categories (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(100) NOT NULL UNIQUE,       -- z.B. "CHEMICAL"
    name          VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT now()
);

-- =====================================================================
-- Zuordnungstabelle: welche Kategorie besitzt welches globale Attribut,
-- und mit welchen kategoriespezifischen Eigenschaften (required, Reihenfolge,
-- Sichtbarkeitsregel).
-- =====================================================================
CREATE TABLE category_attributes (
    id                       BIGSERIAL PRIMARY KEY,
    category_id              BIGINT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    attribute_definition_id  BIGINT NOT NULL REFERENCES attribute_definitions(id) ON DELETE CASCADE,
    required                 BOOLEAN NOT NULL DEFAULT false,
    sort_order                INT NOT NULL DEFAULT 0,
    -- Regel, als Daten hinterlegt, z.B.:
    -- {"attribute": "physicalState", "operator": "EQUALS", "value": "GAS"}
    -- oder komplex: {"and": [ {...}, {...} ]}
    visible_when              JSONB,
    default_value             VARCHAR(255),
    created_at                 TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT uq_category_attribute UNIQUE (category_id, attribute_definition_id)
);

CREATE INDEX idx_category_attributes_category ON category_attributes(category_id);

-- =====================================================================
-- Die eigentlichen Materialdatensaetze. Die Werte liegen NICHT als
-- einzelne Spalten vor, sondern als JSONB-Map { attributeCode: wert }.
-- =====================================================================
CREATE TABLE materials (
    id            BIGSERIAL PRIMARY KEY,
    category_id   BIGINT NOT NULL REFERENCES categories(id),
    name          VARCHAR(255) NOT NULL,
    values        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_materials_category ON materials(category_id);
CREATE INDEX idx_materials_values_gin ON materials USING GIN (values);
