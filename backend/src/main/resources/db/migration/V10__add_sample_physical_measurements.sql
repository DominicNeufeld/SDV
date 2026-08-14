
WITH sample_description AS (
    SELECT id FROM attribute_definitions WHERE code = 'sampleDescription'
),

-- ---------------------------------------------------------------------
-- sampleSize
-- ---------------------------------------------------------------------
sample_size AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sampleSize', 'Sample Size',
           'Size of the sample. Relevant in case of solid/mixture samples. Mainly needed to evaluate whether the sample fits a certain measurement. Not intended to be used for the container of a liquid/gaseous sample (use holder or carrier size in this case).',
           'GROUP', NULL, NULL, sd.id, false, 70,
           '{"attribute": "charPhaseOfMatter", "operator": "IN", "value": ["solid", "mixture"]}'::jsonb
    FROM sample_description sd
    RETURNING id
),
size_x AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sizeX', 'Size X', 'Size of the sample in the x dimension (e.g. the diameter of a cylinder).',
           'QUANTITY', NULL, NULL, ss.id, false, 10
    FROM sample_size ss
    RETURNING id
),
size_y AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sizeY', 'Size Y', 'Size of the sample in the y dimension.',
           'QUANTITY', NULL, NULL, ss.id, false, 20
    FROM sample_size ss
    RETURNING id
),
size_z AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sizeZ', 'Size Z', 'Size of the sample in the z dimension (e.g. the height of a cylinder).',
           'QUANTITY', NULL, NULL, ss.id, false, 30
    FROM sample_size ss
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleMass 
-- ---------------------------------------------------------------------
sample_mass AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleMass', 'Sample Mass', 'Mass of the sample.',
           'QUANTITY', NULL, NULL, sd.id, false, 80
    FROM sample_description sd
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleVolume: gas, liquid oder powder
-- ---------------------------------------------------------------------
sample_volume AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sampleVolume', 'Sample Volume', 'Relevant for gas, liquid and powder.',
           'QUANTITY', NULL, NULL, sd.id, false, 90,
           '{"or": [{"attribute": "charPhaseOfMatter", "operator": "IN", "value": ["gas", "liquid"]}, {"attribute": "shapeOptions", "operator": "EQUALS", "value": "powder"}]}'::jsonb
    FROM sample_description sd
    RETURNING id
),

-- ---------------------------------------------------------------------
-- gasPressure
-- ---------------------------------------------------------------------
gas_pressure AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'gasPressure', 'Gas Pressure', 'Only relevant for gas.', 'GROUP', NULL, NULL, sd.id, false, 100,
           '{"attribute": "charPhaseOfMatter", "operator": "EQUALS", "value": "gas"}'::jsonb
    FROM sample_description sd
    RETURNING id
),
gas_pressure_estimate AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasPressureEstimate', 'Estimate', NULL, 'GROUP', NULL, NULL, gp.id, false, 10
    FROM gas_pressure gp
    RETURNING id
),
gas_pressure_estimate_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasPressureEstimateType', 'Estimate Type', NULL, 'ENUM', NULL,
           '["Not applicable", "quantitative", "qualitative"]'::jsonb,
           gpe.id, false, 10
    FROM gas_pressure_estimate gpe
    RETURNING id
),
gas_pressure_na AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'gasPressureEstimateNotApplicable', 'Not applicable', NULL, 'GROUP', NULL, NULL, gpe.id, false, 20,
           gpe.id, 'Not applicable'
    FROM gas_pressure_estimate gpe
    RETURNING id
),
gas_pressure_na_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasPressureComments', 'Comments', NULL, 'STRING', NULL, NULL, na.id, false, 10
    FROM gas_pressure_na na
    RETURNING id
),
gas_pressure_quant AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'gasPressureEstimateQuantitative', 'Quantitative', NULL, 'GROUP', NULL, NULL, gpe.id, false, 30,
           gpe.id, 'quantitative'
    FROM gas_pressure_estimate gpe
    RETURNING id
),
gas_pressure_quant_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasPressureQuantitativeValue', 'Value', NULL, 'QUANTITY', NULL, NULL, q.id, false, 10
    FROM gas_pressure_quant q
    RETURNING id
),
gas_pressure_qual AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'gasPressureEstimateQualitative', 'Qualitative', NULL, 'GROUP', NULL, NULL, gpe.id, false, 40,
           gpe.id, 'qualitative'
    FROM gas_pressure_estimate gpe
    RETURNING id
),
gas_pressure_qual_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'qualitativeGasPressure', 'Qualitative Gas Pressure', NULL, 'ENUM', NULL,
           '["non applicable", "vacuum", "high vacuum", "ultra high vacuum"]'::jsonb,
           qv.id, false, 10
    FROM gas_pressure_qual qv
    RETURNING id
),

-- ---------------------------------------------------------------------
-- sampleSurfaceRoughness
-- ---------------------------------------------------------------------
surface_roughness AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sampleSurfaceRoughness', 'Sample Surface Roughness', 'Quality of a surface of not being smooth.',
           'GROUP', NULL, NULL, sd.id, false, 110,
           '{"attribute": "charPhaseOfMatter", "operator": "IN", "value": ["solid", "mixture"]}'::jsonb
    FROM sample_description sd
    RETURNING id
),
surface_roughness_estimate AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'surfaceRoughnessEstimate', 'Estimate', NULL, 'GROUP', NULL, NULL, sr.id, false, 10
    FROM surface_roughness sr
    RETURNING id
),
surface_roughness_estimate_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'surfaceRoughnessEstimateType', 'Estimate Type', NULL, 'ENUM', NULL,
           '["Not applicable", "quantitative", "qualitative"]'::jsonb,
           sre.id, false, 10
    FROM surface_roughness_estimate sre
    RETURNING id
),
surface_roughness_na AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'surfaceRoughnessEstimateNotApplicable', 'Not applicable', NULL, 'GROUP', NULL, NULL, sre.id, false, 20,
           sre.id, 'Not applicable'
    FROM surface_roughness_estimate sre
    RETURNING id
),
surface_roughness_na_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'surfaceRoughnessComments', 'Comments', NULL, 'STRING', NULL, NULL, na.id, false, 10
    FROM surface_roughness_na na
    RETURNING id
),
surface_roughness_quant AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'surfaceRoughnessEstimateQuantitative', 'Quantitative', NULL, 'GROUP', NULL, NULL, sre.id, false, 30,
           sre.id, 'quantitative'
    FROM surface_roughness_estimate sre
    RETURNING id
),
surface_roughness_amplitude_parameter AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'amplitudeParameter', 'Amplitude Parameter',
           'Parameter characterizing the surface based on the vertical deviations of the roughness profile from the mean line.',
           'ENUM', NULL, '["not applicable", "Ra", "Rq", "Rz"]'::jsonb,
           q.id, false, 10
    FROM surface_roughness_quant q
    RETURNING id
),
surface_roughness_quant_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'surfaceRoughnessQuantitativeValue', 'Value', NULL, 'QUANTITY', NULL, NULL, q.id, false, 20
    FROM surface_roughness_quant q
    RETURNING id
),
surface_roughness_qual AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'surfaceRoughnessEstimateQualitative', 'Qualitative', NULL, 'GROUP', NULL, NULL, sre.id, false, 40,
           sre.id, 'qualitative'
    FROM surface_roughness_estimate sre
    RETURNING id
),
surface_roughness_qual_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'qualitativeSurfaceRoughness', 'Qualitative Surface Roughness', NULL, 'ENUM', NULL,
           '["not applicable", "rough", "smooth", "polished"]'::jsonb,
           qv.id, false, 10
    FROM surface_roughness_qual qv
    RETURNING id
)
SELECT 1;
