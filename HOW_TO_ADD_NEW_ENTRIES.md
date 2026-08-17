# Adding New Attributes

New attributes are added in a Flyway SQL migration.

## Main Properties

- `code` - unique technical name
- `label` – name shown to the user
- `description` – optional description
- `data_type` – `STRING`, `NUMBER`, `BOOLEAN`, `ENUM`, `MULTI_ENUM`, `DATE`, `GROUP`, `QUANTITY`
- `unit` – optional unit, e.g. `mm`
- `enum_values` – allowed values for `ENUM` / `MULTI_ENUM`
- `parent_attribute_id` – parent attribute for child attributes
- `child_required` – whether a child is required
- `child_sort_order` – order of child attributes
- `child_visible_when` – condition for visibility
- `child_required_when` – condition for being required
- `is_repeatable` – allows multiple instances
- `variant_of_attribute_id` – attribute this is a variant of
- `variant_key` – name of the variant

## Top-Level Attribute

Create it in `attribute_definitions` and attach it to a category using `category_attributes`.

```sql
WITH my_attribute AS (
    INSERT INTO attribute_definitions (...)
    VALUES (...)
    RETURNING id
)
INSERT INTO category_attributes (...)
SELECT ...
FROM my_attribute;
```

End with 
```
SELECT 1;
```