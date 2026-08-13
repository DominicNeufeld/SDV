-- =====================================================================
-- Sample Reference
-- =====================================================================

WITH parent_reference AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        unit,
        enum_values
    )
    VALUES (
        'sampleReference',
        'Sample Reference',
        'Coordinates of the sample reference system',
        'GROUP',
        NULL,
        NULL
    )
    RETURNING id
),

attach_reference_top AS (
    INSERT INTO category_attributes (
        category_id,
        attribute_definition_id,
        required,
        sort_order,
        visible_when
    )
    SELECT
        c.id,
        p.id,
        false,
        60,
        NULL
    FROM categories c, parent_reference p
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),

-- =====================================================================
-- Discriminator
-- =====================================================================

discriminator AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        enum_values,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'referenceType',
        'Reference type',
        'Type of coordinate system used',
        'ENUM',
        '["cartesian", "polar", "none", "other"]'::jsonb,
        p.id,
        true,
        10
    FROM parent_reference p
    RETURNING id
)

SELECT 1;
WITH parent_reference AS (
    SELECT id
    FROM attribute_definitions
    WHERE code = 'sampleReference'
),

cartesian_variant AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        variant_of_attribute_id,
        variant_key
    )
    SELECT
        'cartesianType',
        'Cartesian coordinates',
        'Cartesian coordinate points',
        'GROUP',
        p.id,
        'cartesian'
    FROM parent_reference p
    RETURNING id
),

cartesian_points AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        is_repeatable,
        parent_attribute_id,
        child_sort_order
    )
    SELECT
        'cartesianPoints',
        'Cartesian points',
        'One or more Cartesian coordinate points',
        'GROUP',
        true,
        v.id,
        10
    FROM cartesian_variant v
    RETURNING id
),

point_name AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'cartesianpointName',
        'Point name',
        'Name of the point',
        'STRING',
        p.id,
        false,
        10
    FROM cartesian_points p
    RETURNING id
),

coordinates AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        parent_attribute_id,
        child_sort_order
    )
    SELECT
        'coordinates',
        'Coordinates',
        'Cartesian x/y/z coordinates',
        'GROUP',
        p.id,
        20
    FROM cartesian_points p
    RETURNING id
),

coord_x AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        data_type,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'x',
        'X',
        'NUMBER',
        c.id,
        false,
        10
    FROM coordinates c
),

coord_y AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        data_type,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'y',
        'Y',
        'NUMBER',
        c.id,
        false,
        20
    FROM coordinates c
),

coord_z AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        data_type,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'z',
        'Z',
        'NUMBER',
        c.id,
        false,
        30
    FROM coordinates c
),

comments AS (
    INSERT INTO attribute_definitions (
        code,
        label,
        description,
        data_type,
        parent_attribute_id,
        child_required,
        child_sort_order
    )
    SELECT
        'cartesianComments',
        'Comments',
        'Additional comments about the point',
        'STRING',
        p.id,
        false,
        30
    FROM cartesian_points p
)

SELECT 1;

-- =====================================================================
-- POLAR COORDINATES
-- =====================================================================

WITH variant_polar AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         variant_of_attribute_id, variant_key)
    SELECT
        'polarCoordinates',
        'Polar coordinates',
        'Polar coordinates of the sample reference system',
        'GROUP',
        NULL,
        NULL,
        p.id,
        'polar'
    FROM attribute_definitions p
    WHERE p.code = 'sampleReference'
    RETURNING id
),
polar_points AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order, is_repeatable)
    SELECT
        'polarPoints',
        'Polar points',
        'One or more points defined in polar coordinates',
        'GROUP',
        NULL,
        NULL,
        v.id,
        false,
        10,
        true
    FROM variant_polar v
    RETURNING id
),
polar_point_name AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'polarpointName',
        'Point name',
        'Name of the point',
        'STRING',
        NULL,
        NULL,
        p.id,
        false,
        10
    FROM polar_points p
    RETURNING id
),
polar_coordinates AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'polarPointCoordinates',
        'Coordinates',
        'Polar coordinates of the point',
        'GROUP',
        NULL,
        NULL,
        p.id,
        false,
        20
    FROM polar_points p
    RETURNING id
),
polar_radius AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'coordRadius',
        'Radius',
        NULL,
        'NUMBER',
        NULL,
        NULL,
        c.id,
        false,
        10
    FROM polar_coordinates c
    RETURNING id
),
polar_theta AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'coordTheta',
        'Theta',
        NULL,
        'NUMBER',
        NULL,
        NULL,
        c.id,
        false,
        20
    FROM polar_coordinates c
    RETURNING id
),
polar_phi AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'coordPhi',
        'Phi',
        NULL,
        'NUMBER',
        NULL,
        NULL,
        c.id,
        false,
        30
    FROM polar_coordinates c
    RETURNING id
),
polar_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         parent_attribute_id, child_required, child_sort_order)
    SELECT
        'polarComments',
        'Comments',
        NULL,
        'STRING',
        NULL,
        NULL,
        p.id,
        false,
        30
    FROM polar_points p
    RETURNING id
)
SELECT 1;


-- =====================================================================
-- NOT APPLICABLE
-- =====================================================================

WITH variant_none AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         variant_of_attribute_id, variant_key)
    SELECT
        'notApplicable',
        'Not Applicable',
        'No coordinate system is applicable',
        'GROUP',
        NULL,
        NULL,
        p.id,
        'none'
    FROM attribute_definitions p
    WHERE p.code = 'sampleReference'
    RETURNING id
)
INSERT INTO attribute_definitions
    (code, label, description, data_type, unit, enum_values,
     parent_attribute_id, child_required, child_sort_order)
SELECT
    'noneComments',
    'Comments',
    NULL,
    'STRING',
    NULL,
    NULL,
    n.id,
    false,
    10
FROM variant_none n;


-- =====================================================================
-- OTHER
-- =====================================================================

WITH variant_other AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values,
         variant_of_attribute_id, variant_key)
    SELECT
        'otherReference',
        'Other',
        'Other coordinate system',
        'GROUP',
        NULL,
        NULL,
        p.id,
        'other'
    FROM attribute_definitions p
    WHERE p.code = 'sampleReference'
    RETURNING id
)
INSERT INTO attribute_definitions
    (code, label, description, data_type, unit, enum_values,
     parent_attribute_id, child_required, child_sort_order)
SELECT
    'otherComments',
    'Comments',
    NULL,
    'STRING',
    NULL,
    NULL,
    o.id,
    true,
    10
FROM variant_other o;