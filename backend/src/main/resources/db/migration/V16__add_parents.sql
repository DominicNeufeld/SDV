WITH parents AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, is_repeatable)
    VALUES ('parents', 'Parents',
            'One or more entities which were used as input of the processes to obtain the output entity described in this schema. This field is needed to reconstruct the provenance.',
            'GROUP', NULL, NULL, true)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, p.id, true, 160, NULL
    FROM categories c, parents p
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),

parent_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'parentType', 'Parent Type',
           'Type of parent used as input of the process to obtain the output entity described in this schema.',
           'ENUM', NULL,
           '["not applicable", "material", "sample"]'::jsonb,
           p.id, true, 10
    FROM parents p
    RETURNING id
),
parent_reference_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_required_when)
    SELECT 'parentReferenceType', 'Parent Reference Type',
           'Type of reference to the file where the parent is described, if any. Ideally, this is the MetaStore URI.',
           'ENUM', NULL,
           '["plain text", "external URL", "MetaStore URI"]'::jsonb,
           p.id, false, 20,
           '{"attribute": "parentType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM parents p
    RETURNING id
),
parent_reference AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_required_when)
    SELECT 'parentReference', 'Parent Reference',
           'Reference to the file where the parent is described. Ideally, this is the URI of the parent metadata document in MetaStore. If parentReferenceType is ''MetaStore URI'' it is possible to easily fill this field in a later stage.',
           'STRING', NULL, NULL,
           p.id, false, 30,
           '{"attribute": "parentType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM parents p
    RETURNING id
)
SELECT 1;