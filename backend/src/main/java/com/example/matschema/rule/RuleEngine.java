package com.example.matschema.rule;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@Component
public class RuleEngine {

    @SuppressWarnings("unchecked")
    public boolean evaluate(Map<String, Object> rule, Map<String, Object> currentValues) {

        //Check for Empty
        if (rule == null || rule.isEmpty()) {
            return true;
        }

        //Check for AND Rule
        if (rule.containsKey("and")) {
            List<Map<String, Object>> subRules = (List<Map<String, Object>>) rule.get("and");

            for (Map<String, Object> subRule : subRules) {
                if (!evaluate(subRule, currentValues)) {
                    return false;
                }
            }
            return true;
        }

        //Check for OR Rule
        if (rule.containsKey("or")) {
            List<Map<String, Object>> subRules = (List<Map<String, Object>>) rule.get("or");
            for (Map<String, Object> subRule : subRules) {
                if (evaluate(subRule, currentValues)) {
                    return true;
                }
            }

            return false;
        }

        String attribute = (String) rule.get("attribute");
        String operator = (String) rule.getOrDefault("operator", "EQUALS");
        Object expected = rule.get("value");
        Object actual = currentValues.get(attribute);

        // Check operator and evaluate it
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
        //Null check
        if (actual == null || expected == null) {
            return Objects.equals(actual, expected);
        }
        //Converts to string and compares
        return String.valueOf(actual).equals(String.valueOf(expected));
    }
}
