package com.example.matschema.rule;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * null -> always visible
 * {"attribute": X, "operator": OP, "value": V} -> Condition
 * {"and": [rule, rule, ...]} -> AND
 * {"or": [rule, rule, ...]} -> OR
 *
 * EQUALS, NOT_EQUALS, IN, NOT_IN, IS_EMPTY, IS_NOT_EMPTY, CONTAINS,
 * NOT_CONTAINS.
 *
 * CONTAINS / NOT_CONTAINS: fuer MULTI_ENUM-Felder (Mehrfachauswahl). Prueft,
 * ob "value" als Element in der Werteliste des Attributs enthalten ist -
 * im Unterschied zu EQUALS/IN, die den Gesamtwert vergleichen und bei einer
 * Liste als "actual" nie sinnvoll matchen.
 */
@Component
public class RuleEngine {

    @SuppressWarnings("unchecked")
    public boolean evaluate(Map<String, Object> rule, Map<String, Object> currentValues) {
        if (rule == null || rule.isEmpty()) {
            return true;
        }

        if (rule.containsKey("and")) {
            List<Map<String, Object>> subRules = (List<Map<String, Object>>) rule.get("and");
            return subRules.stream().allMatch(r -> evaluate(r, currentValues));
        }

        if (rule.containsKey("or")) {
            List<Map<String, Object>> subRules = (List<Map<String, Object>>) rule.get("or");
            return subRules.stream().anyMatch(r -> evaluate(r, currentValues));
        }

        // Blatt-Bedingung: {"attribute": ..., "operator": ..., "value": ...}
        String attribute = (String) rule.get("attribute");
        String operator = (String) rule.getOrDefault("operator", "EQUALS");
        Object expected = rule.get("value");
        Object actual = currentValues.get(attribute);

        return switch (operator) {
            case "EQUALS" -> equalsLoose(actual, expected);
            case "NOT_EQUALS" -> !equalsLoose(actual, expected);
            case "IN" -> expected instanceof List<?> list && list.stream().anyMatch(v -> equalsLoose(actual, v));
            case "NOT_IN" -> !(expected instanceof List<?> list && list.stream().anyMatch(v -> equalsLoose(actual, v)));
            case "IS_EMPTY" -> isEmptyValue(actual);
            case "IS_NOT_EMPTY" -> !isEmptyValue(actual);
            case "CONTAINS" -> actual instanceof List<?> list && list.stream().anyMatch(v -> equalsLoose(v, expected));
            case "NOT_CONTAINS" ->
                !(actual instanceof List<?> list && list.stream().anyMatch(v -> equalsLoose(v, expected)));
            default -> throw new IllegalArgumentException("Unknown operator in visibleWhen: " + operator);
        };
    }

    private boolean isEmptyValue(Object actual) {
        if (actual == null) {
            return true;
        }
        if (actual instanceof String s) {
            return s.isBlank();
        }
        if (actual instanceof List<?> list) {
            return list.isEmpty();
        }
        return false;
    }

    private boolean equalsLoose(Object actual, Object expected) {
        if (actual == null || expected == null) {
            return Objects.equals(actual, expected);
        }
        return String.valueOf(actual).equals(String.valueOf(expected));
    }
}
