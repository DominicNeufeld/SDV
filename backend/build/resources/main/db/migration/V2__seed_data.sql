-- =====================================================================
-- SEED-DATEN / ZENTRALE ERWEITERUNGSSTELLE
-- =====================================================================
-- Um ein neues Attribut hinzuzufuegen:
--   1) INSERT INTO attribute_definitions (...)   -- einmal global definieren
--   2) INSERT INTO category_attributes (...)      -- der/den Kategorie(n) zuordnen
-- Um eine neue Kategorie hinzuzufuegen:
--   1) INSERT INTO categories (...)
--   2) INSERT INTO category_attributes (...)      -- vorhandene Attribute zuordnen
--
-- Kein Java-/TypeScript-Code, kein Redeploy noetig - nur eine neue
-- Flyway-Migration (z.B. V3__add_attribute_x.sql) mit weiteren INSERTs
-- nach diesem Muster.
-- =====================================================================

-- Kategorie fuer den Prototyp
INSERT INTO categories (code, name) VALUES
    ('CHEMICAL', 'Chemikalien');

-- ---------------------------------------------------------------------
-- 1) Globale Attribut-Definitionen (jedes Attribut existiert nur EINMAL)
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values) VALUES
    ('materialName',
     'Materialname',
     'Bezeichnung des Materials',
     'STRING',
     NULL,
     NULL),

    ('physicalState',
     'Aggregatzustand',
     'Aggregatzustand des Materials bei Standardbedingungen',
     'ENUM',
     NULL,
     '["SOLID", "LIQUID", "GAS"]'::jsonb),

    ('gasPressureBar',
     'Gasdruck',
     'Druck des Gases in bar - nur relevant, wenn Aggregatzustand = GAS',
     'NUMBER',
     'bar',
     NULL);

-- ---------------------------------------------------------------------
-- 2) Zuordnung der Attribute zur Kategorie CHEMICAL
-- ---------------------------------------------------------------------

-- materialName: immer sichtbar, immer Pflichtfeld
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 10, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'CHEMICAL' AND a.code = 'materialName';

-- physicalState: immer sichtbar, immer Pflichtfeld
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 20, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'CHEMICAL' AND a.code = 'physicalState';

-- gasPressureBar: nur sichtbar (und nur dann Pflichtfeld), wenn physicalState = GAS
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 30,
       '{"attribute": "physicalState", "operator": "EQUALS", "value": "GAS"}'::jsonb
FROM categories c, attribute_definitions a
WHERE c.code = 'CHEMICAL' AND a.code = 'gasPressureBar';
