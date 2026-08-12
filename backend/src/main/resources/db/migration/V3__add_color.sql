-- Color:
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values) VALUES
    ('color',
'Color',
'Color of the material',
'STRING',
NULL,
NULL);

-- ---------------------------------------------------------------------
-- 2) PHYSICAL Category Attributes
-- ---------------------------------------------------------------------
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 35, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY' AND a.code = 'color';