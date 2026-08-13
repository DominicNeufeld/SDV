-- =====================================================================
-- V11__add_features_of_interest.sql
-- =====================================================================
-- featuresOfInterest: functionalTest, defects, interfaces, dominantStructures
-- (9 Untergruppen: reinforcementStructures, clusters, alignedStructures,
-- grains, lamellarStructures, particles, porousStructures,
-- crystalStructures, nanostructures{nanoparticles, nanowires, nanosheets}).
--
-- Ab hier: einfachere, flache INSERT-Statements statt CTE-Ketten (jede
-- Zeile referenziert ihren Parent per WHERE code = '...', da Flyway alle
-- Statements einer Datei sequentiell in EINER Transaktion ausfuehrt -
-- vorherige INSERTs sind fuer nachfolgende Statements bereits sichtbar).
--
-- Hinweis: "specifiedElements" ist im Original ein Array aus freiem Text
-- ohne enum (Tag-Liste). Dafuer gibt es aktuell keinen eigenen Datentyp -
-- als STRING (kommagetrennt) abgebildet.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Top-Level: featuresOfInterest
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
VALUES ('featuresOfInterest', 'Features of Interest', NULL, 'GROUP', NULL, NULL);

INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
SELECT c.id, a.id, false, 90, NULL
FROM categories c, attribute_definitions a
WHERE c.code = 'PHYSICALLY' AND a.code = 'featuresOfInterest';

-- ---------------------------------------------------------------------
-- functionalTest
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'functionalTest', 'Functional Test', NULL, 'GROUP', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'featuresOfInterest';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'specifiedElements', 'Specified Elements', 'Comma-separated list.', 'STRING', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'functionalTest';

-- ---------------------------------------------------------------------
-- defects
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'defects', 'Defects', NULL, 'GROUP', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'featuresOfInterest';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'defectsOptions', 'Defects Options', NULL, 'MULTI_ENUM', NULL,
       '["cracks", "crazes", "inclusions", "pores", "voids", "dislocations", "antisite defects", "interstitial defects", "topological defects", "vacancies", "other (please specify in the comment)"]'::jsonb,
       p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'defects';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'defectsComment', 'Comment', NULL, 'STRING', NULL, NULL, p.id, false, 20,
       '{"attribute": "defectsOptions", "operator": "CONTAINS", "value": "other (please specify in the comment)"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'defects';

-- ---------------------------------------------------------------------
-- interfaces
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'interfaces', 'Interfaces', NULL, 'GROUP', NULL, NULL, p.id, false, 30
FROM attribute_definitions p WHERE p.code = 'featuresOfInterest';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'interfacesOptions', 'Interfaces Options',
       'Bidimensional region through which a discontinuity occurs in one or more parameter of the material.',
       'MULTI_ENUM', NULL,
       '["antiphase boundaries", "grain boundaries", "magnetic domain walls", "matrix-fiber interfaces", "matrix-particle interfaces", "phase boundaries", "stacking faults", "surfaces", "twin boundaries", "other (please specify in the comment)"]'::jsonb,
       p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'interfaces';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'interfacesComment', 'Comment', NULL, 'STRING', NULL, NULL, p.id, false, 20,
       '{"attribute": "interfacesOptions", "operator": "CONTAINS", "value": "other (please specify in the comment)"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'interfaces';

-- ---------------------------------------------------------------------
-- dominantStructures (Container fuer die 9 Untergruppen)
-- ---------------------------------------------------------------------
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'dominantStructures', 'Dominant Structures', NULL, 'GROUP', NULL, NULL, p.id, false, 40
FROM attribute_definitions p WHERE p.code = 'featuresOfInterest';

-- reinforcementStructures
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'reinforcementStructures', 'Reinforcement Structures',
       'Constituent of a composite material which increases its stiffness and tensile strength.',
       'GROUP', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'reinforcingMaterial', 'Reinforcing Material', 'Material supplied as reinforcement.', 'STRING', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'reinforcementStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'reinforcementScale', 'Scale', NULL, 'ENUM', NULL,
       '["not applicable", "atomic/molecular", "nanoscopic", "microscopic", "mesoscopic", "macroscopic"]'::jsonb,
       p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'reinforcementStructures';

-- clusters
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'clusters', 'Clusters',
       'Aggregates of atoms, molecules, ions which adhere together, whose properties differ from those of the corresponding bulk.',
       'GROUP', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'clusterComponents', 'Cluster Components', 'Constituent of the clusters.', 'STRING', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'clusters';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'clusterSize', 'Cluster Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'clusters';

-- alignedStructures
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'alignedStructures', 'Aligned Structures',
       'Arrangement where constituent elements are organized in a specific direction or orientation.',
       'GROUP', NULL, NULL, p.id, false, 30
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'alignedElements', 'Aligned Elements', 'Constituent of the aligned structure.', 'STRING', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'alignedStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'alignedScale', 'Scale', NULL, 'ENUM', NULL,
       '["not applicable", "atomic/molecular", "nanoscopic", "microscopic", "mesoscopic", "macroscopic"]'::jsonb,
       p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'alignedStructures';

-- grains
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'grains', 'Grains', 'Also referred as crystallites. Small crystals within a polycrystalline material.',
       'GROUP', NULL, NULL, p.id, false, 40
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'minGrainSize', 'Min. Grain Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'grains';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'maxGrainSize', 'Max. Grain Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'grains';

-- lamellarStructures
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'lamellarStructures', 'Lamellar Structures',
       'Structures composed of fine, alternating layers of different materials (lamellae).',
       'GROUP', NULL, NULL, p.id, false, 50
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'lamellarScale', 'Scale', NULL, 'ENUM', NULL,
       '["not applicable", "atomic/molecular", "nanoscopic", "microscopic", "mesoscopic", "macroscopic"]'::jsonb,
       p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'lamellarStructures';

-- particles
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'particles', 'Particles', 'Small localized units of matter.', 'GROUP', NULL, NULL, p.id, false, 60
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'particleType', 'Particle Type', NULL, 'ENUM', NULL,
       '["not applicable", "solid (fleks)", "liquid (droplets)", "gaseous (bubbles)"]'::jsonb,
       p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'particles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'particleShape', 'Particle Shape', NULL, 'STRING', NULL, NULL, p.id, false, 20,
       '{"attribute": "particleType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'particles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'minParticleSize', 'Min. Particle Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 30,
       '{"attribute": "particleType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'particles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'maxParticleSize', 'Max. Particle Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 40,
       '{"attribute": "particleType", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'particles';

-- porousStructures
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'porousStructures', 'Porous Structures', NULL, 'GROUP', NULL, NULL, p.id, false, 70
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'porosity', 'Porosity',
       'Fraction of the volume of voids over the total volume, between 0 (no voids) and 1 (all voids).',
       'NUMBER', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'porousStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'percolated', 'Percolated', 'A substance passes through a porous material or medium.', 'BOOLEAN', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'porousStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'minPoreSize', 'Min. Pore Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 30
FROM attribute_definitions p WHERE p.code = 'porousStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'maxPoreSize', 'Max. Pore Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 40
FROM attribute_definitions p WHERE p.code = 'porousStructures';

-- crystalStructures
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'crystalStructures', 'Crystal Structures', NULL, 'GROUP', NULL, NULL, p.id, false, 80
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'crystallinity', 'Crystallinity', 'Degree of structural order in a solid.', 'ENUM', NULL,
       '["not applicable", "crystalline/single crystal", "polycrystalline", "semicrystalline", "non-crystalline/amorphous"]'::jsonb,
       p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'crystalStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'twinned', 'Twinned',
       'Two separate crystal domains share some of the same crystal lattice points in a symmetrical manner.',
       'BOOLEAN', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'crystalStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
SELECT 'crystalScale', 'Scale', NULL, 'ENUM', NULL,
       '["not applicable", "atomic/molecular", "nanoscopic", "microscopic", "mesoscopic", "macroscopic"]'::jsonb,
       p.id, false, 30,
       '{"attribute": "crystallinity", "operator": "NOT_EQUALS", "value": "not applicable"}'::jsonb
FROM attribute_definitions p WHERE p.code = 'crystalStructures';

-- nanostructures (Container fuer nanoparticles / nanowires / nanosheets)
INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanostructures', 'Nanostructures', NULL, 'GROUP', NULL, NULL, p.id, false, 90
FROM attribute_definitions p WHERE p.code = 'dominantStructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanoparticles', 'Nanoparticles', NULL, 'GROUP', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'nanostructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanoparticleShape', 'Particle Shape', NULL, 'STRING', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'nanoparticles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanoparticleMinSize', 'Min. Particle Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'nanoparticles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanoparticleMaxSize', 'Max. Particle Size', NULL, 'QUANTITY', NULL, NULL, p.id, false, 30
FROM attribute_definitions p WHERE p.code = 'nanoparticles';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanowires', 'Nanowires', NULL, 'GROUP', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'nanostructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanowireDiameter', 'Diameter', NULL, 'QUANTITY', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'nanowires';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanowireAspectRatio', 'Aspect Ratio', 'Ratio of the length to the diameter.', 'NUMBER', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'nanowires';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanosheets', 'Nanosheets', NULL, 'GROUP', NULL, NULL, p.id, false, 30
FROM attribute_definitions p WHERE p.code = 'nanostructures';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanosheetThickness', 'Thickness', NULL, 'QUANTITY', NULL, NULL, p.id, false, 10
FROM attribute_definitions p WHERE p.code = 'nanosheets';

INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
SELECT 'nanosheetAspectRatio', 'Aspect Ratio', 'Ratio of the lateral dimension to sheet thickness.', 'NUMBER', NULL, NULL, p.id, false, 20
FROM attribute_definitions p WHERE p.code = 'nanosheets';