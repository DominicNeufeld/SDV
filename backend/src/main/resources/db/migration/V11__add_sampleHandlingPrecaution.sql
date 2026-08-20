WITH sample_handling_precaution AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleHandlingPrecaution', 'Sample Handling Precaution',
            'Set of features about the sample which are important to know for handling it.',
            'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, shp.id, false, 100, NULL
    FROM categories c, sample_handling_precaution shp
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),


-- sensitivityAgainst

sensitivity_against AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sensitivityAgainst', 'Sensitivity Against', NULL, 'GROUP', NULL, NULL, shp.id, false, 10
    FROM sample_handling_precaution shp
    RETURNING id
),
sensitivity_list AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sensitivityList', 'Sensitivity List', NULL, 'MULTI_ENUM', NULL,
           '["O2", "H2O/moisture", "N2", "organic solvents", "eBeam", "iBeam", "radiation", "shocks", "variations of temperature", "variations of air pressure", "variations of gas concentration", "variations of humidity", "other (please add in the comments)"]'::jsonb,
           sa.id, false, 10
    FROM sensitivity_against sa
    RETURNING id
),
sensitivity_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sensitivityComments', 'Comments', NULL, 'STRING', NULL, NULL, sa.id, false, 20,
           '{"attribute": "sensitivityList", "operator": "CONTAINS", "value": "other (please add in the comments)"}'::jsonb
    FROM sensitivity_against sa
    RETURNING id
),


-- safetyInfo

safety_info AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'safetyInfo', 'Safety Info', NULL, 'GROUP', NULL, NULL, shp.id, false, 20
    FROM sample_handling_precaution shp
    RETURNING id
),
hazard AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'hazard', 'Hazard', NULL, 'MULTI_ENUM', NULL,
           '["reactive", "radioactive", "oxidising", "corrosive", "contaminant", "combustive", "biohazard", "carcinogenic/mutagenic/teratogenic", "inflammable", "toxic or irritant", "explosive", "nanostructured/nanoparticles", "other (please add in the comments)"]'::jsonb,
           si.id, false, 10
    FROM safety_info si
    RETURNING id
),
safety_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'safetyComments', 'Comments', NULL, 'STRING', NULL, NULL, si.id, false, 20,
           '{"attribute": "hazard", "operator": "CONTAINS", "value": "other (please add in the comments)"}'::jsonb
    FROM safety_info si
    RETURNING id
),


-- sampleHandling

sample_handling AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleHandling', 'Sample Handling', NULL, 'GROUP', NULL, NULL, shp.id, false, 30
    FROM sample_handling_precaution shp
    RETURNING id
),
handling_gloves AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gloves', 'Gloves', 'The sample must be handled using gloves.', 'BOOLEAN', NULL, NULL, sh.id, false, 10
    FROM sample_handling sh
    RETURNING id
),
handling_shock_protection AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'shockProtection', 'Shock Protection', 'The sample must be protected against shocks.', 'BOOLEAN', NULL, NULL, sh.id, false, 20
    FROM sample_handling sh
    RETURNING id
),
handling_no_tweezers_regions AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'noTweezersRegions', 'No Tweezers Regions', 'Regions on the sample which cannot be touched or reached by tweezers.', 'STRING', NULL, NULL, sh.id, false, 30
    FROM sample_handling sh
    RETURNING id
),
handling_clean_room_conditions AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'cleanRoomConditions', 'Clean Room Conditions', 'Specific clean room conditions under which the sample should be treated.', 'STRING', NULL, NULL, sh.id, false, 40
    FROM sample_handling sh
    RETURNING id
),
handling_min_humidity AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'minHumidity', 'Min. Humidity', 'Minimal humidity at which the sample should be handled.', 'QUANTITY', NULL, NULL, sh.id, false, 50
    FROM sample_handling sh
    RETURNING id
),
handling_max_humidity AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'maxHumidity', 'Max. Humidity', 'Maximal humidity at which the sample should be handled.', 'QUANTITY', NULL, NULL, sh.id, false, 60
    FROM sample_handling sh
    RETURNING id
),
gas_atmosphere AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasAtmosphere', 'Gas Atmosphere',
           'Type of inert gas required around the sample due e.g. to the presence of a reactive top layer.',
           'GROUP', NULL, NULL, sh.id, false, 70
    FROM sample_handling sh
    RETURNING id
),
gas_atmosphere_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'gasAtmosphereOptions', 'Gas Atmosphere Options',
           'Type of inert gas required around the sample to handle it, due e.g. to the presence of a reactive top layer.',
           'ENUM', NULL,
           '["Not applicable", "air", "dry air", "vacuum", "Ar", "N", "other (please add in the comments)"]'::jsonb,
           ga.id, false, 10
    FROM gas_atmosphere ga
    RETURNING id
),
other_gas_atmosphere AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherGasAtmosphere', 'Other Gas Atmosphere', NULL, 'STRING', NULL, NULL, ga.id, false, 20,
           '{"attribute": "gasAtmosphereOptions", "operator": "EQUALS", "value": "other (please add in the comments)"}'::jsonb
    FROM gas_atmosphere ga
    RETURNING id
),
handling_additional_notes AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'handlingAdditionalNotes', 'Additional Notes', 'Any additional notes which might be relevant for sample handling.',
           'STRING', NULL, NULL, sh.id, false, 80
    FROM sample_handling sh
    RETURNING id
),


-- storageConditions

storage_conditions AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageConditions', 'Storage Conditions', NULL, 'GROUP', NULL, NULL, shp.id, false, 40
    FROM sample_handling_precaution shp
    RETURNING id
),
storage_min_temperature AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'minStorageTemperature', 'Min. Storage Temperature', 'Minimal temperature at which the sample should be stored.',
           'QUANTITY', NULL, NULL, sc.id, false, 10
    FROM storage_conditions sc
    RETURNING id
),
storage_max_temperature AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'maxStorageTemperature', 'Max. Storage Temperature', 'Maximal temperature at which the sample should be stored.',
           'QUANTITY', NULL, NULL, sc.id, false, 20
    FROM storage_conditions sc
    RETURNING id
),

-- storagePressure: oneOf-Struktur (Not applicable / quantitative / qualitative)
storage_pressure AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storagePressure', 'Storage Pressure',
           'Storage pressure, to be indicated only if different from gas pressure.',
           'GROUP', NULL, NULL, sc.id, false, 30
    FROM storage_conditions sc
    RETURNING id
),
storage_pressure_estimate AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storagePressureEstimate', 'Estimate', NULL, 'GROUP', NULL, NULL, sp.id, false, 10
    FROM storage_pressure sp
    RETURNING id
),
storage_pressure_estimate_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storagePressureEstimateType', 'Estimate Type', NULL, 'ENUM', NULL,
           '["Not applicable", "quantitative", "qualitative"]'::jsonb,
           spe.id, false, 10
    FROM storage_pressure_estimate spe
    RETURNING id
),

storage_pressure_na AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'storagePressureEstimateNotApplicable', 'Not applicable', NULL, 'GROUP', NULL, NULL, false, 20,
           spe.id, 'Not applicable'
    FROM storage_pressure_estimate spe
    RETURNING id
),
storage_pressure_na_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storagePressureComments', 'Comments', NULL, 'STRING', NULL, NULL, na.id, false, 10
    FROM storage_pressure_na na
    RETURNING id
),
storage_pressure_quant AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'storagePressureEstimateQuantitative', 'Quantitative', NULL, 'GROUP', NULL, NULL, false, 30,
           spe.id, 'quantitative'
    FROM storage_pressure_estimate spe
    RETURNING id
),
storage_pressure_quant_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storagePressureQuantitativeValue', 'Value', NULL, 'QUANTITY', NULL, NULL, q.id, false, 10
    FROM storage_pressure_quant q
    RETURNING id
),
storage_pressure_qual AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'storagePressureEstimateQualitative', 'Qualitative', NULL, 'GROUP', NULL, NULL, false, 40,
           spe.id, 'qualitative'
    FROM storage_pressure_estimate spe
    RETURNING id
),
storage_pressure_qual_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'qualitativeStoragePressure', 'Qualitative Storage Pressure', NULL, 'ENUM', NULL,
           '["non applicable", "vacuum", "high vacuum", "ultra high vacuum"]'::jsonb,
           qv.id, false, 10
    FROM storage_pressure_qual qv
    RETURNING id
),

storage_min_humidity AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'minStorageHumidity', 'Min. Storage Humidity',
           'Minimal storage humidity, to be indicated only if different from the humidity required for sample handling.',
           'QUANTITY', NULL, NULL, sc.id, false, 40
    FROM storage_conditions sc
    RETURNING id
),
storage_max_humidity AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'maxStorageHumidity', 'Max. Storage Humidity',
           'Maximal storage humidity, to be indicated only if different from the humidity required for sample handling.',
           'QUANTITY', NULL, NULL, sc.id, false, 50
    FROM storage_conditions sc
    RETURNING id
),

storage_gas_atmosphere AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageGasAtmosphere', 'Storage Gas Atmosphere',
           'Storage gas atmosphere, to be indicated only if different from the gas atmosphere required for sample handling.',
           'GROUP', NULL, NULL, sc.id, false, 60
    FROM storage_conditions sc
    RETURNING id
),
storage_gas_atmosphere_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageGasAtmosphereOptions', 'Storage Gas Atmosphere Options',
           'Storage gas atmosphere, to be indicated only if different from the gas atmosphere required for sample handling.',
           'MULTI_ENUM', NULL,
           '["Not applicable", "air", "dry air", "vacuum", "Ar", "N", "other (please add in the comments)"]'::jsonb,
           sga.id, false, 10
    FROM storage_gas_atmosphere sga
    RETURNING id
),
other_storage_gas_atmosphere AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherStorageGasAtmosphere', 'Other Storage Gas Atmosphere', NULL, 'STRING', NULL, NULL, sga.id, false, 20,
           '{"attribute": "storageGasAtmosphereOptions", "operator": "CONTAINS", "value": "other (please add in the comments)"}'::jsonb
    FROM storage_gas_atmosphere sga
    RETURNING id
),

storage_equipment AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageEquipment', 'Storage Equipment', 'One or more pieces of equipment used for storing the sample.',
           'GROUP', NULL, NULL, sc.id, false, 70
    FROM storage_conditions sc
    RETURNING id
),
storage_equipment_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageEquipmentOptions', 'Storage Equipment Options',
           'One or more pieces of equipment used for storing the sample.',
           'MULTI_ENUM', NULL,
           '["None", "glove box", "fume hood", "dessicator", "open bench", "refrigerator", "freezer", "cryostat", "liquid N dewar", "drying oven", "UHV chamber", "other (please add in the comments)"]'::jsonb,
           se.id, false, 10
    FROM storage_equipment se
    RETURNING id
),
other_storage_equipment AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherStorageEquipment', 'Other Storage Equipment', NULL, 'STRING', NULL, NULL, se.id, false, 20,
           '{"attribute": "storageEquipmentOptions", "operator": "CONTAINS", "value": "other (please add in the comments)"}'::jsonb
    FROM storage_equipment se
    RETURNING id
),

storage_additional_notes AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'storageAdditionalNotes', 'Additional Notes', 'Any additional notes which might be relevant for storage conditions.',
           'STRING', NULL, NULL, sc.id, false, 80
    FROM storage_conditions sc
    RETURNING id
)
SELECT 1;