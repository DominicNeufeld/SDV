WITH sample_identification AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleIdentification', 'Sample Identification', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, si.id, true, 70, NULL
    FROM categories c, sample_identification si
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),


-- sampleName, sampleVendor

child_sample_name AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleName', 'Sample Name', 'Name of the sample', 'STRING', NULL, NULL, si.id, true, 10
    FROM sample_identification si
    RETURNING id
),
child_sample_vendor AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleVendor', 'Sample Vendor',
           'Vendor of the sample, if the sample has been bought. If produced in the lab, describe under Sample Preparation instead.',
           'STRING', NULL, NULL, si.id, false, 20
    FROM sample_identification si
    RETURNING id
),


-- samplePurpose

sample_purpose AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'samplePurpose', 'Sample Purpose', NULL, 'GROUP', NULL, NULL, si.id, true, 30
    FROM sample_identification si
    RETURNING id
),
child_purpose_options AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'samplePurposeOptions', 'Sample Purpose Options',
           'Tentative purpose of the sample (e.g., for which measurement(s) or subsequent analysis the sample was prepared). Multiple selection allowed.',
           'MULTI_ENUM', NULL,
           '["assessment (to given categories or values)", "completeness check (presence or absence of given properties)", "correlative characterization (dedicated sample treatment to emphasise given features)", "exploratory (routine check of known properties)", "feasibility (quick check, rough estimate)", "high quality measurement (precise, careful treatment)", "test specific hypothesis (focus only on given aspects)", "other (please specify in the comment)"]'::jsonb,
           sp.id, true, 10
    FROM sample_purpose sp
    RETURNING id
),
child_other_purpose AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherSamplePurpose', 'Other Sample Purpose',
           'Free text if "other" was selected in Sample Purpose Options.',
           'STRING', NULL, NULL, sp.id, false, 20,
           '{"attribute": "samplePurposeOptions", "operator": "CONTAINS", "value": "other (please specify in the comment)"}'::jsonb
    FROM sample_purpose sp
    RETURNING id
),


-- sampleID

sample_id_group AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleID', 'Sample ID', NULL, 'GROUP', NULL, NULL, si.id, false, 40
    FROM sample_identification si
    RETURNING id
),
child_sample_id_value AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleIdValue', 'Sample ID',
           'Identifier of the sample. Naming convention differs by laboratory.',
           'STRING', NULL, NULL, sig.id, false, 10
    FROM sample_id_group sig
    RETURNING id
),
child_sample_id_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleIDType', 'Sample ID Type', 'Type of identifier of the sample.', 'ENUM', NULL,
           '["not applicable", "text", "code", "value", "other (please specify in the comment)"]'::jsonb,
           sig.id, false, 20
    FROM sample_id_group sig
    RETURNING id
),
child_other_id_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'otherSampleIDType', 'Other Sample ID Type',
           'Free text if "other" was selected in Sample ID Type.',
           'STRING', NULL, NULL, sig.id, false, 30,
           '{"attribute": "sampleIDType", "operator": "EQUALS", "value": "other (please specify in the comment)"}'::jsonb
    FROM sample_id_group sig
    RETURNING id
),
child_sample_id_position AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'sampleIDPosition', 'Sample ID Position',
           'Position of the printed ID on the sample. Multiple selection allowed.',
           'MULTI_ENUM', NULL,
           '["not applicable", "top", "bottom", "right", "left", "front side", "back side"]'::jsonb,
           sig.id, false, 40,
           '{"attribute": "sampleIDType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
    FROM sample_id_group sig
    RETURNING id
)
SELECT 1;
