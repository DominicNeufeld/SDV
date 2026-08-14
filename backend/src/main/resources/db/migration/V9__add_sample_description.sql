WITH sample_description AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleDescription', 'Sample Description', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, sd.id, false, 90, NULL
    FROM categories c, sample_description sd
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),


child_expiration_date AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'expirationDate', 'Expiration Date',
           'Sample expiration date, if any. Relevant in case of biological samples.',
           'DATE', NULL, NULL, sd.id, false, 10
    FROM sample_description sd
    RETURNING id
),
child_chemical_formula AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleChemicalFormula', 'Sample Chemical Formula', 'Chemical formula of the sample.',
           'STRING', NULL, NULL, sd.id, false, 20
    FROM sample_description sd
    RETURNING id
),
child_cas_number AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleCASNumber', 'Sample CAS Number', 'CAS number of the sample, if known and applicable.',
           'STRING', NULL, NULL, sd.id, false, 30
    FROM sample_description sd
    RETURNING id
),
child_material_data_sheet AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleMaterialDataSheet', 'Sample Material Data Sheet',
           'Link to the file describing the composition specification, usually called Material Data Sheet, if available.',
           'STRING', NULL, NULL, sd.id, false, 40
    FROM sample_description sd
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleVisibleElements
-- ---------------------------------------------------------------------
sample_visible_elements AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleVisibleElements', 'Sample Visible Elements', NULL, 'GROUP', NULL, NULL, sd.id, false, 50
    FROM sample_description sd
    RETURNING id
),
child_visible_elements_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'visibleElementsOptions', 'Visible Elements Options',
           'One or more elements (if any) useful e.g. for coarse alignment, which are visible by eye or with optical magnification equipment.',
           'MULTI_ENUM', NULL,
           '["none", "pattern", "orientation", "fiducials", "sample ID", "other (please specify in the comment)"]'::jsonb,
           sve.id, false, 10
    FROM sample_visible_elements sve
    RETURNING id
),
child_other_visible_elements AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherVisibleElements', 'Other Visible Elements', NULL, 'STRING', NULL, NULL, sve.id, false, 20,
           '{"attribute": "visibleElementsOptions", "operator": "CONTAINS", "value": "other (please specify in the comment)"}'::jsonb
    FROM sample_visible_elements sve
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleShape
-- ---------------------------------------------------------------------
sample_shape AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleShape', 'Sample Shape', 'Shape of the solid/mixture sample.', 'GROUP', NULL, NULL, sd.id, false, 60
    FROM sample_description sd
    RETURNING id
),
child_shape_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'shapeOptions', 'Shape Options', NULL, 'ENUM', NULL,
           '["bulk material", "filament", "pellet", "powder", "rod/bar"]'::jsonb,
           ss.id, false, 10
    FROM sample_shape ss
    RETURNING id
),

-- sheet ----------------------------------------------------------------
shape_sheet AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sheet', 'Sheet', NULL, 'GROUP', NULL, NULL, ss.id, false, 20
    FROM sample_shape ss
    RETURNING id
),
child_sheet_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sheetType', 'Sheet Type', NULL, 'ENUM', NULL,
           '["not applicable", "foil", "plate", "leaf"]'::jsonb,
           sh.id, false, 10
    FROM shape_sheet sh
    RETURNING id
),
child_sheet_thickness AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sheetThickness', 'Sheet Thickness', NULL, 'QUANTITY', NULL, NULL, sh.id, false, 20,
           '{"attribute": "sheetType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM shape_sheet sh
    RETURNING id
),
child_sheet_aspect_ratio AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sheetAspectRatio', 'Aspect Ratio', 'Ratio of the lateral dimension to sheet thickness.',
           'NUMBER', NULL, NULL, sh.id, false, 30,
           '{"attribute": "sheetType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM shape_sheet sh
    RETURNING id
),

-- layer ------------------------------------------------------------
shape_layer AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'layer', 'Layer', NULL, 'GROUP', NULL, NULL, ss.id, false, 30
    FROM sample_shape ss
    RETURNING id
),
child_layer_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'layerType', 'Layer Type', NULL, 'ENUM', NULL,
           '["not applicable", "monolayer", "thin film", "multilayer"]'::jsonb,
           l.id, false, 10
    FROM shape_layer l
    RETURNING id
),
child_layer_thickness AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'layerThickness', 'Layer Thickness', NULL, 'QUANTITY', NULL, NULL, l.id, false, 20,
           '{"attribute": "layerType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM shape_layer l
    RETURNING id
),
child_interlayer_spacing AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'interlayerSpacing', 'Interlayer Spacing', NULL, 'QUANTITY', NULL, NULL, l.id, false, 30,
           '{"attribute": "layerType", "operator": "EQUALS", "value": "multilayer"}'::jsonb
    FROM shape_layer l
    RETURNING id
),
child_number_of_layers AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'numberOfLayers', 'Number of Layers', NULL, 'NUMBER', NULL, NULL, l.id, false, 40,
           '{"attribute": "layerType", "operator": "EQUALS", "value": "multilayer"}'::jsonb
    FROM shape_layer l
    RETURNING id
),

-- wire ------------------------------------------------------------
shape_wire AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'wire', 'Wire', NULL, 'GROUP', NULL, NULL, ss.id, false, 40,
           '{"attribute": "shapeOptions", "operator": "IN", "value": ["filament", "rod/bar"]}'::jsonb
    FROM sample_shape ss
    RETURNING id
),
child_wire_diameter AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'wireDiameter', 'Diameter', NULL, 'QUANTITY', NULL, NULL, w.id, false, 10
    FROM shape_wire w
    RETURNING id
),
child_wire_aspect_ratio AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'wireAspectRatio', 'Aspect Ratio', 'Ratio of the length to the diameter.',
           'NUMBER', NULL, NULL, w.id, false, 20
    FROM shape_wire w
    RETURNING id
)
SELECT 1;
