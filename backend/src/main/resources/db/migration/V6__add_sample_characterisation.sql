WITH sample_characterization AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleCharacterization', 'Sample Characterization', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, scz.id, false, 80, NULL
    FROM categories c, sample_characterization scz
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
char_phase_of_matter AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'charPhaseOfMatter', 'Phase of Matter', NULL, 'ENUM', NULL,
           '["not applicable", "solid", "liquid", "gas", "plasma", "mixture"]'::jsonb,
           scz.id, false, 10
    FROM sample_characterization scz
    RETURNING id
),
char_material_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'charMaterialType', 'Material Type', NULL, 'GROUP', NULL, NULL, scz.id, false, 20,
           '{"attribute": "charPhaseOfMatter", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM sample_characterization scz
    RETURNING id
),
char_material_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'charMaterialOptions', 'Material Options', NULL, 'MULTI_ENUM', NULL,
           '["not applicable", "alloy", "biological", "biomaterial", "ceramic", "composite", "glass", "inorganic material", "metal", "metamaterial", "molecularFluid", "organicCompound", "organometallic", "polymer", "pure chemical element", "smart material", "other (please add in the comment)"]'::jsonb,
           mt.id, false, 10
    FROM char_material_type mt
    RETURNING id
),
char_other_material_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'charOtherMaterialTypeProperties', 'Other Material Type', NULL, 'STRING', NULL, NULL, mt.id, false, 20,
           '{"attribute": "charMaterialOptions", "operator": "CONTAINS", "value": "other (please add in the comment)"}'::jsonb
    FROM char_material_type mt
    RETURNING id
),
char_material_properties AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'charMaterialProperties', 'Material Properties', NULL, 'GROUP', NULL, NULL, scz.id, false, 30,
           '{"attribute": "charPhaseOfMatter", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM sample_characterization scz
    RETURNING id
),
char_properties_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'charPropertiesOptions', 'Properties Options', NULL, 'MULTI_ENUM', NULL,
           '["diamagnetic", "paramagnetic", "ferromagnetic", "antiferromagnetic", "ferrimagnetic", "nonmagnetic", "conductor", "semiconductor", "superconductor", "insulator", "dielectric", "other (please add in the comment)"]'::jsonb,
           mp.id, false, 10
    FROM char_material_properties mp
    RETURNING id
),
char_other_material_properties AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'charOtherMaterialProperties', 'Other Material Properties', NULL, 'STRING', NULL, NULL, mp.id, false, 20,
           '{"attribute": "charPropertiesOptions", "operator": "CONTAINS", "value": "other (please add in the comment)"}'::jsonb
    FROM char_material_properties mp
    RETURNING id
)
SELECT 1;