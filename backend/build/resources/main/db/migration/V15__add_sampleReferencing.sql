
CREATE OR REPLACE FUNCTION _create_coordinate_reference(
    p_parent_id BIGINT,
    p_code TEXT,
    p_label TEXT,
    p_description TEXT,
    p_child_prefix TEXT,
    p_sort_order INT
) RETURNS BIGINT AS $$
DECLARE
    v_group_id BIGINT;
    v_cartesian_id BIGINT;
    v_cartesian_points_id BIGINT;
    v_coordinates_id BIGINT;
    v_polar_id BIGINT;
    v_polar_points_id BIGINT;
    v_polar_coordinates_id BIGINT;
    v_none_id BIGINT;
    v_other_id BIGINT;
BEGIN
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_code, p_label, p_description, 'GROUP', NULL, NULL, p_parent_id, false, p_sort_order)
    RETURNING id INTO v_group_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, enum_values, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'ReferenceType', 'Reference Type', 'Type of coordinate system used', 'ENUM',
            '["cartesian", "polar", "none", "other"]'::jsonb, v_group_id, true, 10);

    -- Variante: cartesian
    INSERT INTO attribute_definitions (code, label, description, data_type, variant_of_attribute_id, variant_key)
    VALUES (p_child_prefix || 'CartesianType', 'Cartesian coordinates', 'Cartesian coordinate points', 'GROUP', v_group_id, 'cartesian')
    RETURNING id INTO v_cartesian_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, is_repeatable, parent_attribute_id, child_sort_order)
    VALUES (p_child_prefix || 'CartesianPoints', 'Cartesian points', 'One or more Cartesian coordinate points', 'GROUP', true, v_cartesian_id, 10)
    RETURNING id INTO v_cartesian_points_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'CartesianPointName', 'Point name', 'Name of the point', 'STRING', v_cartesian_points_id, false, 10);

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_sort_order)
    VALUES (p_child_prefix || 'Coordinates', 'Coordinates', 'Cartesian x/y/z coordinates', 'GROUP', v_cartesian_points_id, 20)
    RETURNING id INTO v_coordinates_id;

    INSERT INTO attribute_definitions (code, label, data_type, parent_attribute_id, child_required, child_sort_order) VALUES
        (p_child_prefix || 'X', 'X', 'NUMBER', v_coordinates_id, false, 10),
        (p_child_prefix || 'Y', 'Y', 'NUMBER', v_coordinates_id, false, 20),
        (p_child_prefix || 'Z', 'Z', 'NUMBER', v_coordinates_id, false, 30);

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'CartesianComments', 'Comments', 'Additional comments about the point', 'STRING', v_cartesian_points_id, false, 30);

    -- Variante: polar
    INSERT INTO attribute_definitions (code, label, description, data_type, variant_of_attribute_id, variant_key)
    VALUES (p_child_prefix || 'PolarCoordinates', 'Polar coordinates', 'Polar coordinates', 'GROUP', v_group_id, 'polar')
    RETURNING id INTO v_polar_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, is_repeatable, parent_attribute_id, child_sort_order)
    VALUES (p_child_prefix || 'PolarPoints', 'Polar points', 'One or more points defined in polar coordinates', 'GROUP', true, v_polar_id, 10)
    RETURNING id INTO v_polar_points_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'PolarPointName', 'Point name', 'Name of the point', 'STRING', v_polar_points_id, false, 10);

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_sort_order)
    VALUES (p_child_prefix || 'PolarPointCoordinates', 'Coordinates', 'Polar coordinates of the point', 'GROUP', v_polar_points_id, 20)
    RETURNING id INTO v_polar_coordinates_id;

    INSERT INTO attribute_definitions (code, label, data_type, parent_attribute_id, child_required, child_sort_order) VALUES
        (p_child_prefix || 'CoordRadius', 'Radius', 'NUMBER', v_polar_coordinates_id, false, 10),
        (p_child_prefix || 'CoordTheta', 'Theta', 'NUMBER', v_polar_coordinates_id, false, 20),
        (p_child_prefix || 'CoordPhi', 'Phi', 'NUMBER', v_polar_coordinates_id, false, 30);

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'PolarComments', 'Comments', NULL, 'STRING', v_polar_points_id, false, 30);

    -- Variante: none
    INSERT INTO attribute_definitions (code, label, description, data_type, variant_of_attribute_id, variant_key)
    VALUES (p_child_prefix || 'NotApplicable', 'Not Applicable', 'No coordinate system is applicable', 'GROUP', v_group_id, 'none')
    RETURNING id INTO v_none_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'NoneComments', 'Comments', NULL, 'STRING', v_none_id, false, 10);

    -- Variante: other
    INSERT INTO attribute_definitions (code, label, description, data_type, variant_of_attribute_id, variant_key)
    VALUES (p_child_prefix || 'OtherReference', 'Other', 'Other coordinate system', 'GROUP', v_group_id, 'other')
    RETURNING id INTO v_other_id;

    INSERT INTO attribute_definitions (code, label, description, data_type, parent_attribute_id, child_required, child_sort_order)
    VALUES (p_child_prefix || 'OtherComments', 'Comments', NULL, 'STRING', v_other_id, true, 10);

    RETURN v_group_id;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------
-- holderReferencing (sort_order 140)
-- ---------------------------------------------------------------------
WITH holder_referencing AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('holderReferencing', 'Holder Referencing', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_holder_referencing AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, hr.id, false, 130, NULL
    FROM categories c, holder_referencing hr
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
holder_axis_orientation AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'holderAxisOrientation', 'Axis Orientation', NULL, 'STRING', NULL, NULL, hr.id, false, 10
    FROM holder_referencing hr
    RETURNING id
),
sample_on_holder AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'sampleOnHolder', 'Sample On Holder', NULL, 'GROUP', NULL, NULL, hr.id, false, 20
    FROM holder_referencing hr
    RETURNING id
),
marker_on_holder AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'markerOnHolder', 'Marker On Holder', NULL, 'GROUP', NULL, NULL, hr.id, false, 30
    FROM holder_referencing hr
    RETURNING id
),
build_sample_position AS (
    SELECT _create_coordinate_reference(
        soh.id, 'samplePositionOnHolder', 'Sample Position On Holder',
        'Sample position in the holder reference system.', 'holderPos', 10
    ) AS id
    FROM sample_on_holder soh
),
build_holder_reference AS (
    SELECT _create_coordinate_reference(
        moh.id, 'holderReference', 'Holder Reference',
        'Coordinates of the markers in the holder reference system.', 'holderMarker', 10
    ) AS id
    FROM marker_on_holder moh
)
SELECT 1 FROM build_sample_position, build_holder_reference;

-- ---------------------------------------------------------------------
-- carrierReferencing (sort_order 150)
-- ---------------------------------------------------------------------
WITH carrier_referencing AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('carrierReferencing', 'Carrier Referencing', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_carrier_referencing AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, cr.id, false, 140, NULL
    FROM categories c, carrier_referencing cr
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
carrier_axis_orientation AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'carrierAxisOrientation', 'Axis Orientation', NULL, 'STRING', NULL, NULL, cr.id, false, 10
    FROM carrier_referencing cr
    RETURNING id
),
holder_on_carrier AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'holderOnCarrier', 'Holder On Carrier', NULL, 'GROUP', NULL, NULL, cr.id, false, 20
    FROM carrier_referencing cr
    RETURNING id
),
marker_on_carrier AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'markerOnCarrier', 'Marker On Carrier', NULL, 'GROUP', NULL, NULL, cr.id, false, 30
    FROM carrier_referencing cr
    RETURNING id
),
build_holder_position AS (
    SELECT _create_coordinate_reference(
        hoc.id, 'holderPositionOnCarrier', 'Holder Position On Carrier',
        'Holder position in the carrier reference system.', 'carrierPos', 10
    ) AS id
    FROM holder_on_carrier hoc
),
build_carrier_reference AS (
    SELECT _create_coordinate_reference(
        moc.id, 'carrierReference', 'Carrier Reference',
        'Coordinates of the markers in the carrier reference system.', 'carrierMarker', 10
    ) AS id
    FROM marker_on_carrier moc
)
SELECT 1 FROM build_holder_position, build_carrier_reference;

-- ---------------------------------------------------------------------
-- ROI (sort_order 160)
-- ---------------------------------------------------------------------
WITH roi AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('ROI', 'ROI', NULL, 'GROUP', NULL, NULL)
    RETURNING id
),
attach_roi AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, r.id, false, 150, NULL
    FROM categories c, roi r
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),
roi_axis_orientation AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'roiAxisOrientation', 'Axis Orientation', NULL, 'STRING', NULL, NULL, r.id, false, 10
    FROM roi r
    RETURNING id
),
build_roi_reference AS (
    SELECT _create_coordinate_reference(
        r.id, 'ROIReference', 'ROI Reference',
        'Coordinates of the points defining the sample ROI (Region of Interest) in the sample reference system.', 'roi', 20
    ) AS id
    FROM roi r
)
SELECT 1 FROM build_roi_reference;


DROP FUNCTION _create_coordinate_reference(BIGINT, TEXT, TEXT, TEXT, TEXT, INT);