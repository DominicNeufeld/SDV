WITH sample_components AS (
    SELECT id FROM attribute_definitions WHERE code = 'sampleComponents'
),
comp_cas_number AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'componentCASNumber', 'CAS Number', 'CAS number of the sample component, if known and applicable.',
           'STRING', NULL, NULL, sc.id, false, 30
    FROM sample_components sc
    RETURNING id
),
comp_material_data_sheet AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'componentMaterialDataSheet', 'Material Data Sheet',
           'Link to the file describing the composition specification (Material Data Sheet), if available.',
           'STRING', NULL, NULL, sc.id, false, 40
    FROM sample_components sc
    RETURNING id
),
comp_additional_features AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'componentAdditionalFeatures', 'Additional Features',
           'Description of missing relevant features describing the sample component, if any.',
           'STRING', NULL, NULL, sc.id, false, 50
    FROM sample_components sc
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleCharacteristics
-- ---------------------------------------------------------------------
sample_characteristics AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleCharacteristics', 'Sample Characteristics', NULL, 'GROUP', NULL, NULL, sc.id, false, 60
    FROM sample_components sc
    RETURNING id
),
char_phase_of_matter AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'phaseOfMatter', 'Phase of Matter',
           'A matter object throughout which all physical properties of a material are essentially uniform.',
           'ENUM', NULL,
           '["not applicable", "solid", "liquid", "gas", "plasma", "mixture"]'::jsonb,
           sch.id, false, 10
    FROM sample_characteristics sch
    RETURNING id
),
char_material_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'materialType', 'Material Type',
           'Main group, characterized by common basic attributes, the material can be assigned to.',
           'GROUP', NULL, NULL, sch.id, false, 20,
           '{"attribute": "phaseOfMatter", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM sample_characteristics sch
    RETURNING id
),
char_material_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'materialOptions', 'Material Options', NULL, 'MULTI_ENUM', NULL,
           '["not applicable", "alloy", "biological", "biomaterial", "ceramic", "composite", "glass", "inorganic material", "metal", "metamaterial", "molecularFluid", "organicCompound", "organometallic", "polymer", "pure chemical element", "smart material", "other (please add in the comment)"]'::jsonb,
           mt.id, false, 10
    FROM char_material_type mt
    RETURNING id
),
char_other_material_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherMaterialTypeProperties', 'Other Material Type', NULL, 'STRING', NULL, NULL, mt.id, false, 20,
           '{"attribute": "materialOptions", "operator": "CONTAINS", "value": "other (please add in the comment)"}'::jsonb
    FROM char_material_type mt
    RETURNING id
),
char_material_properties AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'materialProperties', 'Material Properties',
           'One or more known properties of the material.',
           'GROUP', NULL, NULL, sch.id, false, 30,
           '{"attribute": "phaseOfMatter", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM sample_characteristics sch
    RETURNING id
),
char_properties_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'propertiesOptions', 'Properties Options', NULL, 'MULTI_ENUM', NULL,
           '["diamagnetic", "paramagnetic", "ferromagnetic", "antiferromagnetic", "ferrimagnetic", "nonmagnetic", "conductor", "semiconductor", "superconductor", "insulator", "dielectric", "other (please add in the comment)"]'::jsonb,
           mp.id, false, 10
    FROM char_material_properties mp
    RETURNING id
),
char_other_material_properties AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherMaterialProperties', 'Other Material Properties', NULL, 'STRING', NULL, NULL, mp.id, false, 20,
           '{"attribute": "propertiesOptions", "operator": "CONTAINS", "value": "other (please add in the comment)"}'::jsonb
    FROM char_material_properties mp
    RETURNING id
)
SELECT 1;