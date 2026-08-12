-- =====================================================================
-- SEED DATA
-- =====================================================================

-- Categories: PHYSICALLY
INSERT INTO categories (code, name) VALUES
    ('PHYSICALLY', 'Physically');

-- ---------------------------------------------------------------------
-- 1) Global Attribut Definitions
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values) VALUES
    ('materialName',
     'Material name',
      Null,
     'STRING',
     NULL,
     NULL),

    ('stateOfMatter',
     'State of matter',
     'Material`s State of matter',
     'ENUM',
     NULL,
     '["SOLID", "LIQUID", "GAS"]'::jsonb),

    ('gasPressure',
     'Gas Pressure',
     NULL,
     'NUMBER',
     'bar',
     NULL);

-- ---------------------------------------------------------------------
-- 2) Physically Category Attributes
-- ---------------------------------------------------------------------

-- materialName:
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 10, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY' AND a.code = 'materialName';

-- stateOfMatter:
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 20, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY' AND a.code = 'stateOfMatter';

-- gasPressureBar:
INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, true, 30,
       '{"attribute": "stateOfMatter", "operator": "EQUALS", "value": "GAS"}'::jsonb
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY' AND a.code = 'gasPressure';
