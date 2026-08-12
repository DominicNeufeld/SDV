-- =====================================================================
-- V4 - Add Coordinates Type Attribute
-- =====================================================================

---

-- 1) Global Attribute Definition

---

INSERT INTO attribute_definitions (
code,
label,
description,
data_type,
unit,
enum_values
) VALUES (
'coordinatesType',
'Coordinates type',
'Type of coordinates used for the measurement.',
'ENUM',
NULL,
'["CARTESIAN", "POLAR", "NOT_APPLICABLE", "OTHER"]'::jsonb
);

---

-- 2) Physically Category Attribute

---

INSERT INTO category_attributes (
category_id,
attribute_definition_id,
required,
sort_order,
visible_when
)
SELECT
c.id,
a.id,
true,
40,
NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY'
AND a.code = 'coordinatesType';
