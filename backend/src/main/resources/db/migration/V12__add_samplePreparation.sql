WITH sample_preparation AS (
    INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values)
    VALUES ('samplePreparation', 'Sample Preparation',
            NULL,
            'GROUP', NULL, NULL)
    RETURNING id
),
attach_top AS (
    INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
    SELECT c.id, shp.id, false, 110, NULL
    FROM categories c, sample_preparation shp
    WHERE c.code = 'PHYSICALLY'
    RETURNING id
),


-- researchUser

research_user AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, is_repeatable)
    SELECT 'researchUser', 'Research User', '(Recommended). Reseach user(s) involved in the sample preparation. If the sample under handling underwent a previous sample preparation by someone else, that one should be described in an other sample metadata document and mentioned in this document under Parent.',
     'GROUP', NULL, NULL, shp.id, false, 10, true
    FROM sample_preparation shp
    RETURNING id
),

-- userName

user_name as(
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'userName', 'User Name', NULL,
     'STRING', NULL, NULL, ru.id, false, 10
    FROM research_user ru
    RETURNING id
),

-- userRole

user_role as(
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'userRole', 'User Role', NULL,
     'ENUM', NULL, '["Data Curator", "Instrument Scientist", "Researcher", "Team Leader", "Team Member", "Other"]'::jsonb, ru.id, false, 20
    FROM research_user ru
    RETURNING id
),

-- preparationDate

preparation_date AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'preparationDate', 'Preparation Date', 'Optional) - Date of preparation',
     'DATE', NULL, NULL, shp.id, false, 20
    FROM sample_preparation shp
    RETURNING id
),

-- preparationMethod

preparation_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, is_repeatable)
    SELECT 'preparationMethod', 'Preparation Method', NULL, 'GROUP', NULL, NULL, sp.id, false, 30, true
    FROM sample_preparation sp
    RETURNING id
),
preparation_action AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'preparationAction', 'Preparation Action', NULL, 'ENUM', NULL,
           '["Not applicable", "Annealing homogenization", "Deposition coating", "Joining", "Mechanical and surface", "Powder processing", "Cooling", "Reactive", "Other"]'::jsonb,
           pm.id, false, 10
    FROM preparation_method pm
    RETURNING id
),
 
-- Variant 1: Not applicable
prep_na AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationNotApplicable', 'Not applicable', NULL, 'GROUP', NULL, NULL, false, 20,
           pm.id, 'Not applicable'
    FROM preparation_method pm
    RETURNING id
),
prep_na_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'prepNAComments', 'Comments', NULL, 'STRING', NULL, NULL, na.id, false, 10
    FROM prep_na na
    RETURNING id
),
 
-- Variant 2: Annealing homogenization 
prep_annealing AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationAnnealing', 'Annealing homogenization', NULL, 'GROUP', NULL, NULL, false, 30,
           pm.id, 'Annealing homogenization'
    FROM preparation_method pm
    RETURNING id
),
prep_annealing_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'annealingHomogenizationMethod', 'Annealing Homogenization Method', NULL, 'ENUM', NULL,
           '["unspecified annealing and homogenization", "air annealing", "aging", "dry blending", "homogenization", "mechanical mixing", "melt mixing", "normalizing", "recrystallization", "stress relieving", "tempering", "twin screw excrusion", "ultrasonication", "vacuum annealing/heating", "curing/hardening", "other (please add in the comments)"]'::jsonb,
           a.id, false, 10
    FROM prep_annealing a
    RETURNING id
),
prep_annealing_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'annealingComments', 'Comments', NULL, 'STRING', NULL, NULL, a.id, false, 20
    FROM prep_annealing a
    RETURNING id
),
prep_annealing_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'annealingConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, a.id, false, 30
    FROM prep_annealing a
    RETURNING id
),
 
-- Variant 3: Deposition coating 
prep_deposition AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationDeposition', 'Deposition coating', NULL, 'GROUP', NULL, NULL, false, 40,
           pm.id, 'Deposition coating'
    FROM preparation_method pm
    RETURNING id
),
prep_deposition_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'depositionCoatingMethod', 'Deposition Coating Method', NULL, 'ENUM', NULL,
           '["unspecified deposition and coating", "chemical vapour deposition", "atomic layer deposition", "gas dosing/gas exposure", "x-ray exposure", "sputter coating", "ion implantation", "electrodeposition", "evaporation/physical vapor deposition", "electron beam deposition", "ion beam deposition", "beam epitaxy", "ink-jet deposition", "pulsed laser deposition", "Langmuir-Blodgett film deposition", "plasma spraying", "carbon evaporation coating", "spin coating", "other (please add in the comments)"]'::jsonb,
           d.id, false, 10
    FROM prep_deposition d
    RETURNING id
),
prep_deposition_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'depositionComments', 'Comments', NULL, 'STRING', NULL, NULL, d.id, false, 20
    FROM prep_deposition d
    RETURNING id
),
prep_deposition_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'depositionConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, d.id, false, 30
    FROM prep_deposition d
    RETURNING id
),
 
-- Variant 4: Joining
prep_joining AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationJoining', 'Joining', NULL, 'GROUP', NULL, NULL, false, 50,
           pm.id, 'Joining'
    FROM preparation_method pm
    RETURNING id
),
prep_joining_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'joiningMethod', 'Joining Method', NULL, 'ENUM', NULL,
           '["unspecified joining", "adhesive bonding", "soldering/brazing/wire bonding", "resistance welding", "mechanical clamping", "metal clamping", "other (please add in the comments)"]'::jsonb,
           j.id, false, 10
    FROM prep_joining j
    RETURNING id
),
prep_joining_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'joiningComments', 'Comments', NULL, 'STRING', NULL, NULL, j.id, false, 20
    FROM prep_joining j
    RETURNING id
),
prep_joining_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'joiningConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, j.id, false, 30
    FROM prep_joining j
    RETURNING id
),
 
-- Variant 5: Mechanical and surface 
prep_mechanical AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationMechanical', 'Mechanical and surface', NULL, 'GROUP', NULL, NULL, false, 60,
           pm.id, 'Mechanical and surface'
    FROM preparation_method pm
    RETURNING id
),
prep_mechanical_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'mechanicalAndSurfaceMethod', 'Mechanical And Surface Method', NULL, 'ENUM', NULL,
           '["unspecified mechanical and surface", "focused ion beam", "lithography", "polishing", "sectioning/cutting", "sputtering", "thermal plasma processing", "exfoliation/cleavage/decapping", "grinding", "etching", "exposure to atomic oxygen", "x-ray exposure", "grit blasting", "sterilization", "Laser Surface Texturing (LST)", "dimpling", "other (please add in the comments)"]'::jsonb,
           m.id, false, 10
    FROM prep_mechanical m
    RETURNING id
),
prep_mechanical_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'mechanicalComments', 'Comments', NULL, 'STRING', NULL, NULL, m.id, false, 20
    FROM prep_mechanical m
    RETURNING id
),
prep_mechanical_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'mechanicalConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, m.id, false, 30
    FROM prep_mechanical m
    RETURNING id
),
 
-- Variant 6: Powder processing
prep_powder AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationPowder', 'Powder processing', NULL, 'GROUP', NULL, NULL, false, 70,
           pm.id, 'Powder processing'
    FROM preparation_method pm
    RETURNING id
),
prep_powder_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'powderProcessingMethod', 'Powder Processing Method', NULL, 'ENUM', NULL,
           '["unspecified powder processing", "sieve fraction preparation", "pressing", "other (please add in the comments)"]'::jsonb,
           p.id, false, 10
    FROM prep_powder p
    RETURNING id
),
prep_powder_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'powderComments', 'Comments', NULL, 'STRING', NULL, NULL, p.id, false, 20
    FROM prep_powder p
    RETURNING id
),
prep_powder_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'powderConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, p.id, false, 30
    FROM prep_powder p
    RETURNING id
),
 
-- Variant 7: Cooling
prep_cooling AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationCooling', 'Cooling', NULL, 'GROUP', NULL, NULL, false, 80,
           pm.id, 'Cooling'
    FROM preparation_method pm
    RETURNING id
),
prep_cooling_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coolingMethod', 'Cooling Method', NULL, 'ENUM', NULL,
           '["unspecified cooling", "gas cooling", "vacuum cooling", "other (please add in the comments)"]'::jsonb,
           co.id, false, 10
    FROM prep_cooling co
    RETURNING id
),
prep_cooling_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coolingComments', 'Comments', NULL, 'STRING', NULL, NULL, co.id, false, 20
    FROM prep_cooling co
    RETURNING id
),
prep_cooling_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'coolingConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, co.id, false, 30
    FROM prep_cooling co
    RETURNING id
),
 
-- Variant 8: Reactive 
prep_reactive AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationReactive', 'Reactive', NULL, 'GROUP', NULL, NULL, false, 90,
           pm.id, 'Reactive'
    FROM preparation_method pm
    RETURNING id
),
prep_reactive_method AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'reactiveMethod', 'Reactive Method', NULL, 'ENUM', NULL,
           '["unspecified reactive", "addition polymerization", "condensation polymerization", "curing", "dissolving/etching", "drying", "in-situ polymerization", "post-polymerization modification", "reductive roasting", "solution processing", "reactive ion etching (RIE/IBE)", "other (please specify in the comments)"]'::jsonb,
           r.id, false, 10
    FROM prep_reactive r
    RETURNING id
),
prep_reactive_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'reactiveComments', 'Comments', NULL, 'STRING', NULL, NULL, r.id, false, 20
    FROM prep_reactive r
    RETURNING id
),
prep_reactive_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'reactiveConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, r.id, false, 30
    FROM prep_reactive r
    RETURNING id
),
 
-- Variant 9: Other
prep_other AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, child_required, child_sort_order, variant_of_attribute_id, variant_key)
    SELECT 'preparationOther', 'Other', NULL, 'GROUP', NULL, NULL, false, 100,
           pm.id, 'Other'
    FROM preparation_method pm
    RETURNING id
),
prep_other_comments AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'otherPreparationComments', 'Comments', NULL, 'STRING', NULL, NULL, o.id, true, 10
    FROM prep_other o
    RETURNING id
),
prep_other_consumables AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'otherPreparationConsumables', 'Consumables',
           'Auxiliary entity used during Fabrication, Sample Preparation or Measurement which has a limited time capacity or is limited in its number of uses before it is disposed of, necessary to the process itself and normally bought from third party manufacturers. Examples are: gloves, syringes, wipes, etching solutions, glass slides, spatulas, weighing paper, two-sided tape.',
           'STRING', NULL, NULL, o.id, false, 20
    FROM prep_other o
    RETURNING id
),
-- Rest
additional_description AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'additionalDescription', 'Additional Description',
           'Additional short description to keep track of the preparation procedures and treatments required to obtain the Sample.',
           'STRING', NULL, NULL, sp.id, false, 40
    FROM sample_preparation sp
    RETURNING id
),
preparation_history_file AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order)
    SELECT 'preparationHistoryFile', 'Preparation History File',
           'Location of the file, if any, where the complete Sample Preparation history is described.',
           'ENUM', NULL,
           '["Not Applicable", "ELN", "Data Repository", "Included in the Raw Data file", "Paper log book"]'::jsonb,
           sp.id, false, 50
    FROM sample_preparation sp
    RETURNING id
),
preparation_history_file_reference AS (
    INSERT INTO attribute_definitions
        (code, label, description, data_type, unit, enum_values, parent_attribute_id, child_required, child_sort_order, child_visible_when)
    SELECT 'preparationHistoryFileReference', 'Preparation History File Reference',
           'Reference to the location of the file where the complete Sample Preparation history is described. Ideally, the unique identifier to the ELN or to a data repository.',
           'STRING', NULL, NULL, sp.id, false, 60,
           '{"attribute": "preparationHistoryFile", "operator": "NOT_IN", "value": ["Not Applicable", "Paper log book"]}'::jsonb
    FROM sample_preparation sp
    RETURNING id
)
SELECT 1;