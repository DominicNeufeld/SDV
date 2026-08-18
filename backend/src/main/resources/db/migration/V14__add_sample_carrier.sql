WITH sample_carrier AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('sampleCarrier', 'Sample Carrier', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, sh.id, false, 130, NULL
    FROM categories c, sample_carrier sh
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
-- ---------------------------------------------------------------------
-- sampleCarrierType
-- ---------------------------------------------------------------------
sample_carrier_type AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleCarrierType', 'Sample Carrier Type', '(Optional) - Type of sample carrier. It may include the substrate, in case it is used as sample carrier.',
           'STRING', NULL,
           NULL,
           sh.id, false, 10
    FROM sample_carrier sh
    RETURNING id
),
sample_carrier_size AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleCarrierSize', 'Sample Carrier Size',
           '(Optional) - Size of the sample carrier. Relevant especially in case of a liquid/gasous sample. Mainly needed to evaluate whether the sample fits a certain measurement. Regardless of the shape, the sample carrier size can be approximated (e.g. the diameter of a cylinder can be indicated as sizeX and sizeY).',
           'GROUP', NULL, NULL, sh.id, false, 20
    FROM sample_carrier sh
    RETURNING id
),
carrier_size_x AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'carrierSizeX', 'Size X', '(Optional) - Size of the sample carrier in the x dimension. Relevant especially in case of a liquid/gasous sample. Regardless of the shape, the sample carrier size can be approximated (e.g. the diameter of a cylinder can be indicated as sizeX).',
           'QUANTITY', NULL, NULL, shs.id, false, 10
    FROM sample_carrier_size shs
    RETURNING id
),
carrier_size_y AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'carrierSizeY', 'Size Y', '(Optional) - Size of the sample carrier in the y dimension. Relevant especially in case of a liquid/gasous sample. Regardless of the shape, the sample carrier size can be approximated (e.g. the diameter of a cylinder can be indicated as sizeY).',
           'QUANTITY', NULL, NULL, shs.id, false, 20
    FROM sample_carrier_size shs
    RETURNING id
),
carrier_size_z AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'carrierSizeZ', 'Size Z', '(Optional) - Size of the sample carrier in the z dimension. Relevant especially in case of a liquid/gasous sample. Regardless of the shape, the sample carrier size can be approximated (e.g. the hight of a cylinder can be indicated as sizeZ).',
           'QUANTITY', NULL, NULL, shs.id, false, 30
    FROM sample_carrier_size shs
    RETURNING id
),
sample_carrier_description AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleCarrierDescription', 'Sample Carrier Description', '(Optional) - Any additional description which might be useful to identify the sample carrier.',
           'STRING', NULL,
           NULL,
           sh.id, false, 30
    FROM sample_carrier sh
    RETURNING id
)
SELECT 1;