
-- Global Attribut Definitions
CREATE TABLE attribute_definitions (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(100) NOT NULL UNIQUE,    
    label         VARCHAR(255) NOT NULL,            
    description   VARCHAR(1000),
    data_type     VARCHAR(20)  NOT NULL,              
    unit          VARCHAR(50),                        
    enum_values   JSONB,
    link          VARCHAR(500),                       
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);


-- Material Categories

CREATE TABLE categories (
    id            BIGSERIAL PRIMARY KEY,
    code          VARCHAR(100) NOT NULL UNIQUE,      
    name          VARCHAR(255) NOT NULL,
    created_at    TIMESTAMP NOT NULL DEFAULT now()
);


-- Material Restrictions / Category Attributes

CREATE TABLE category_attributes (
    id                       BIGSERIAL PRIMARY KEY,
    category_id              BIGINT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    attribute_definition_id  BIGINT NOT NULL REFERENCES attribute_definitions(id) ON DELETE CASCADE,
    required                 BOOLEAN NOT NULL DEFAULT false,
    sort_order                INT NOT NULL DEFAULT 0,
    visible_when              JSONB,
    default_value             VARCHAR(255),
    created_at                 TIMESTAMP NOT NULL DEFAULT now(),

    CONSTRAINT uq_category_attribute UNIQUE (category_id, attribute_definition_id)
);

CREATE INDEX idx_category_attributes_category ON category_attributes(category_id);

 
-- Material data records

CREATE TABLE materials (
    id            BIGSERIAL PRIMARY KEY,
    category_id   BIGINT NOT NULL REFERENCES categories(id),
    name          VARCHAR(255) NOT NULL,
    values        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at    TIMESTAMP NOT NULL DEFAULT now(),
    updated_at    TIMESTAMP NOT NULL DEFAULT now()
);

CREATE INDEX idx_materials_category ON materials(category_id);
CREATE INDEX idx_materials_values_gin ON materials USING GIN (values);
