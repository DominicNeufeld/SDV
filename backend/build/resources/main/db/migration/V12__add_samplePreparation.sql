WITH samplePreparation AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('samplePreparation', 'Sample Preparation',
            NULL,
            'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, shp.id, false, 110, NULL
    FROM categories c, samplePreparation shp
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),

-- ---------------------------------------------------------------------
-- researchUser
-- ---------------------------------------------------------------------
research_User AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'researchUser', 'Research User', '(Recommended). Reseach user(s) involved in the sample preparation. If the sample under handling underwent a previous sample preparation by someone else, that one should be described in an other sample metadata document and mentioned in this document under Parent.',
     'GROUP', NULL, NULL, shp.id, false, 10
    FROM samplePreparation shp
    RETURNING id
)
SELECT 1;