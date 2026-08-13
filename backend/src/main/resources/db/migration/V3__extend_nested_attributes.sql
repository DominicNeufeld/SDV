

ALTER TABLE attribute_definitions
    ADD COLUMN parent_attribute_id      BIGINT REFERENCES attribute_definitions(id) ON DELETE CASCADE,
    ADD COLUMN is_repeatable            BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN variant_of_attribute_id  BIGINT REFERENCES attribute_definitions(id) ON DELETE CASCADE,
    ADD COLUMN variant_key              VARCHAR(150),
    ADD COLUMN child_required           BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN child_sort_order         INT NOT NULL DEFAULT 0,
    ADD COLUMN child_visible_when       JSONB,
    ADD COLUMN child_required_when      JSONB;

CREATE INDEX idx_attribute_definitions_parent      ON attribute_definitions(parent_attribute_id);
CREATE INDEX idx_attribute_definitions_variant_of  ON attribute_definitions(variant_of_attribute_id);

ALTER TABLE category_attributes
    ADD COLUMN required_when JSONB;
