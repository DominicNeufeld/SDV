package com.example.matschema.service;

import com.example.matschema.domain.AttributeDefinition;
import com.example.matschema.domain.Category;
import com.example.matschema.domain.CategoryAttribute;
import com.example.matschema.dto.ValidationErrorDto;
import com.example.matschema.repository.CategoryAttributeRepository;
import com.example.matschema.rule.RuleEngine;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.*;


@Service
@RequiredArgsConstructor
public class MaterialValidationService {

    private final CategoryAttributeRepository categoryAttributeRepository;
    private final RuleEngine ruleEngine;

    /**
     * Validates the submitted values against the schema of the category.
     * @return a cleaned map of values that are valid and visible according to the schema and rules
     * @throws MaterialValidationException if there are validation errors
     */
    public Map<String, Object> validateAndClean(Category category, Map<String, Object> submittedValues) {
        List<CategoryAttribute> schema = categoryAttributeRepository
                .findByCategoryIdOrderBySortOrderAsc(category.getId());

        Set<String> knownCodes = new HashSet<>();
        for (CategoryAttribute ca : schema) {
            knownCodes.add(ca.getAttributeDefinition().getCode());
        }

        List<ValidationErrorDto> errors = new ArrayList<>();
        Map<String, Object> cleaned = new LinkedHashMap<>();

        for (String submittedCode : submittedValues.keySet()) {
            if (!knownCodes.contains(submittedCode)) {
                errors.add(new ValidationErrorDto(submittedCode,
                        "Attribute is not defined in this category."));
            }
        }


        for (CategoryAttribute ca : schema) {
            AttributeDefinition def = ca.getAttributeDefinition();
            String code = def.getCode();

            boolean visible = ruleEngine.evaluate(ca.getVisibleWhen(), submittedValues);
            Object value = submittedValues.get(code);

            if (!visible) {
                continue;
            }

            if (value == null || (value instanceof String s && s.isBlank())) {
                if (ca.isRequired()) {
                    errors.add(new ValidationErrorDto(code, "Mandatory field '" + def.getLabel() + "' is missing"));
                }
                continue;
            }

            Optional<String> typeError = validateType(def, value);
            if (typeError.isPresent()) {
                errors.add(new ValidationErrorDto(code, typeError.get()));
                continue;
            }

            cleaned.put(code, value);
        }

        if (!errors.isEmpty()) {
            throw new MaterialValidationException(errors);
        }

        return cleaned;
    }

    private Optional<String> validateType(AttributeDefinition def, Object value) {
        return switch (def.getDataType()) {
            case STRING -> (value instanceof String)
                    ? Optional.empty()
                    : Optional.of("'" + def.getLabel() + "' has to be a string");

            case NUMBER -> (value instanceof Number || isNumericString(value))
                    ? Optional.empty()
                    : Optional.of("'" + def.getLabel() + "' has to be a number");

            case BOOLEAN -> (value instanceof Boolean)
                    ? Optional.empty()
                    : Optional.of("'" + def.getLabel() + "' has to be true/false)");

            case ENUM -> {
                List<String> allowed = def.getEnumValues() == null ? List.of() : def.getEnumValues();
                yield allowed.contains(String.valueOf(value))
                        ? Optional.empty()
                        : Optional.of("'" + def.getLabel() + "' has to be one of" + allowed);
            }

            case DATE -> {
                try {
                    LocalDate.parse(String.valueOf(value));
                    yield Optional.empty();
                } catch (DateTimeParseException e) {
                    yield Optional.of("'" + def.getLabel() + "' has to be YYYY-MM-DD form");
                }
            }

            case MULTI_ENUM -> {
                if (!(value instanceof List<?> list)) {
                    yield Optional.of("'" + def.getLabel() + "' has to be a list of values");
                }
                List<String> allowed = def.getEnumValues() == null ? List.of() : def.getEnumValues();
                boolean allValid = list.stream().allMatch(v -> allowed.contains(String.valueOf(v)));
                yield allValid ? Optional.empty()
                        : Optional.of("'" + def.getLabel() + "' has to be a subset of " + allowed);
            }

            // GROUP-Attribute besitzen selbst keinen Wert (nur Kind-Attribute) und werden
            // hier noch nicht flach validiert - verschachtelte/wiederholte Werte werden
            // aktuell durchgereicht, ohne Typprüfung. TODO: rekursive Validierung ergänzen,
            // sobald das Speichern verschachtelter Werte implementiert ist.
            case GROUP -> Optional.empty();
        };
    }

    private boolean isNumericString(Object value) {
        if (!(value instanceof String s)) {
            return false;
        }
        try {
            Double.parseDouble(s);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
