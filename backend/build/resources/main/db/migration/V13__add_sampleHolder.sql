WITH sample_holder AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleHolder', 'Sample Holder', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, sh.id, false, 120, NULL
    FROM categories c, sample_holder sh
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleHolderType
-- ---------------------------------------------------------------------
sample_holder_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleHolderType', 'Sample Holder Type', '(Optional) - Type of sample holder.',
           'ENUM', NULL,
           '["Not applicable", "stub", "dish", "cylinder", "glass slide", "TEM grid", "tilting support", "custom holder", "Other (please add in the comments)"]'::jsonb,
           sh.id, false, 10
    FROM sample_holder sh
    RETURNING id
),
other_holder_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherHolderType', 'Other Holder Type', NULL, 'STRING', NULL, NULL, sh.id, false, 20,
           '{"attribute": "sampleHolderType", "operator": "EQUALS", "value": "Other (please add in the comments)"}'::jsonb
    FROM sample_holder sh
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleHolderSize (GROUP, nicht ENUM!)
-- ---------------------------------------------------------------------
sample_holder_size AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleHolderSize', 'Sample Holder Size',
           'Size of the sample holder. Relevant especially in case of a liquid/gaseous sample. Mainly needed to evaluate whether the sample fits a certain measurement. Regardless of the shape, the sample holder size can be approximated (e.g. the diameter of a cylinder can be indicated as sizeX and sizeY).',
           'GROUP', NULL, NULL, sh.id, false, 30
    FROM sample_holder sh
    RETURNING id
),
holder_size_x AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'holderSizeX', 'Size X', 'Size of the sample holder in the x dimension (e.g. the diameter of a cylinder).',
           'QUANTITY', NULL, NULL, shs.id, false, 10
    FROM sample_holder_size shs
    RETURNING id
),
holder_size_y AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'holderSizeY', 'Size Y', 'Size of the sample holder in the y dimension.',
           'QUANTITY', NULL, NULL, shs.id, false, 20
    FROM sample_holder_size shs
    RETURNING id
),
holder_size_z AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'holderSizeZ', 'Size Z', 'Size of the sample holder in the z dimension (e.g. the height of a cylinder).',
           'QUANTITY', NULL, NULL, shs.id, false, 30
    FROM sample_holder_size shs
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleHolderDescription
-- ---------------------------------------------------------------------
sample_holder_description AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleHolderDescription', 'Sample Holder Description',
           'Any additional description which might be useful to identify the sample holder.',
           'STRING', NULL, NULL, sh.id, false, 40
    FROM sample_holder sh
    RETURNING id
),

-- ---------------------------------------------------------------------
-- fixingMethod
-- ---------------------------------------------------------------------
fixing_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'fixingMethod', 'Fixing Method', 'Method used to hold the sample on the sample holder.',
           'ENUM', NULL,
           '["Not applicable", "silver tape", "carbon tape", "silver paint", "carbon paint", "aluminium tape", "glue", "Other (please add in the comments)"]'::jsonb,
           sh.id, false, 50
    FROM sample_holder sh
    RETURNING id
),
other_fixing_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherFixingMethod', 'Other Fixing Method', NULL, 'STRING', NULL, NULL, sh.id, false, 60,
           '{"attribute": "fixingMethod", "operator": "EQUALS", "value": "Other (please add in the comments)"}'::jsonb
    FROM sample_holder sh
    RETURNING id
)
SELECT 1;