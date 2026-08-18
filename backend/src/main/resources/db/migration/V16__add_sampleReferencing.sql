WITH sample_referencing AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleReferencing', 'Sample Referencing', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, sh.id, false, 130, NULL
    FROM categories c, sample_referencing sh
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
-- ---------------------------------------------------------------------
-- sampleReference
-- ---------------------------------------------------------------------
sample_reference AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleReference', 'Sample Reference', '(Optional) - Coordinates of the markers in the sample reference system.',
           'STRING', NULL,
           NULL,
           sh.id, false, 10
    FROM sample_reference sh
    RETURNING id
),