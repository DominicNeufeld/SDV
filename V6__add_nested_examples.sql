WITH parent_component AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, is_repeatable)
    VALUES ('sampleComponents', 'Sample Components', 'One or more components of the sample', 'GROUP', NULL, NULL, true)
    RETURNING id
),
attach_component_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, p.id, false, 50, NULL
    FROM categories c, parent_component p
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
child_component_name AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'componentName', 'Component name', 'Name of the sample component', 'STRING', NULL, NULL, p.id, true, 10
    FROM parent_component p
    RETURNING id
),
child_component_formula AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'componentChemicalFormula', 'Chemical formula', 'Chemical formula of the component', 'STRING', NULL, NULL, p.id, false, 20
    FROM parent_component p
    RETURNING id
)
SELECT 1;


WITH parent_reference AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleReference', 'Sample Reference', 'Coordinates of the sample reference system', 'GROUP', NULL, NULL)
    RETURNING id
),
attach_reference_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, p.id, false, 60, NULL
    FROM categories c, parent_reference p
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
-- Diskriminator: normales Kind-Attribut von sampleReference (kein Variant)
discriminator AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'referenceType', 'Reference type', 'Type of coordinate system used', 'ENUM', NULL,
           '["cartesian", "polar", "none"]'::jsonb, p.id, true, 10
    FROM parent_reference p
    RETURNING id
),
variant_cartesian AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, variant_of_attribute_id, variant_key)
    SELECT 'cartesianCoordinates', 'Cartesian coordinates', 'x/y/z coordinates', 'GROUP', NULL, NULL, p.id, 'cartesian'
    FROM parent_reference p
    RETURNING id
),
cartesian_x AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coordX', 'X', NULL, 'NUMBER', NULL, NULL, v.id, true, 10 FROM variant_cartesian v
    RETURNING id
),
cartesian_y AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coordY', 'Y', NULL, 'NUMBER', NULL, NULL, v.id, true, 20 FROM variant_cartesian v
    RETURNING id
),
cartesian_z AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coordZ', 'Z', NULL, 'NUMBER', NULL, NULL, v.id, false, 30 FROM variant_cartesian v
    RETURNING id
),
-- Variante 2: polar (variant_of_attribute_id = sampleReference.id)
variant_polar AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, variant_of_attribute_id, variant_key)
    SELECT 'polarCoordinates', 'Polar coordinates', 'radius/theta coordinates', 'GROUP', NULL, NULL, p.id, 'polar'
    FROM parent_reference p
    RETURNING id
),
polar_radius AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coordRadius', 'Radius', NULL, 'NUMBER', NULL, NULL, v.id, true, 10 FROM variant_polar v
    RETURNING id
),
polar_theta AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coordTheta', 'Theta', NULL, 'NUMBER', NULL, NULL, v.id, true, 20 FROM variant_polar v
    RETURNING id
)
SELECT 1;
