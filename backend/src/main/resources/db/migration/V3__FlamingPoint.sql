-- =====================================================================
-- BEISPIEL: Ein viertes Attribut hinzufuegen - OHNE Java-/JS-Code,
-- OHNE Redeploy. Einfach diese Datei nach
--   src/main/resources/db/migration/V3__add_flash_point.sql
-- kopieren; Flyway wendet sie beim naechsten Start automatisch an.
--
-- Fachliches Beispiel: "flashPointCelsius" (Flammpunkt) soll nur bei
-- physicalState = LIQUID sichtbar und dann Pflichtfeld sein.
-- =====================================================================

-- 1) Attribut global (einmalig) definieren
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values) VALUES
    ('flashPointCelsius',
     'Flammpunkt',
     'Temperatur, ab der sich entzündliche Dämpfe bilden - nur bei fluessigen Stoffen relevant',
     'NUMBER',
     '°C',
     NULL);

-- 2) Attribut der Kategorie CHEMICAL zuordnen, inkl. Sichtbarkeitsregel
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 40,
       '{"attribute": "physicalState", "operator": "EQUALS", "value": "LIQUID"}'::jsonb
FROM categories c, attribute_definitions a
WHERE c.code = 'CHEMICAL' AND a.code = 'flashPointCelsius';

-- Das war's. Nach Neustart der Anwendung:
--   - GET /api/categories/CHEMICAL/schema liefert das neue Feld
--   - das Frontend rendert es automatisch (inkl. Ein-/Ausblenden)
--   - POST /api/materials validiert es automatisch (Pflichtfeld bei LIQUID)
