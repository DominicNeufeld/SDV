
-- 1) Attribut global definieren
INSERT INTO attribute_definitions
    (code, label, description, data_type, unit, enum_values)
VALUES
    ('color',
     'Color',
     'The Color of the Material',
     'STRING',
     NULL,
     NULL);

-- 2) Attribut der Kategorie CHEMICAL zuordnen
INSERT INTO category_attributes
    (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT
    c.id,
    a.id,
    false,
    50,
    NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'CHEMICAL'
  AND a.code = 'color';

