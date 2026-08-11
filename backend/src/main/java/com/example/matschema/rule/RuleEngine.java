package com.example.matschema.rule;

import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.Objects;

/**
 * Generische Regel-Engine. Wertet Regeln aus, die rein als Daten
 * (Map/JSON, siehe {@link com.example.matschema.domain.CategoryAttribute#getVisibleWhen()})
 * hinterlegt sind - es gibt fuer eine konkrete fachliche Regel (z.B.
 * "gasPressureBar nur bei physicalState = GAS") KEINEN eigenen Java-Code.
 *
 * Unterstuetzte Regel-Formen:
 *   null                                            -> immer sichtbar (true)
 *   {"attribute": X, "operator": OP, "value": V}     -> Blatt-Bedingung
 *   {"and": [rule, rule, ...]}                       -> Verknuepfung UND
 *   {"or":  [rule, rule, ...]}                       -> Verknuepfung ODER
 *
 * Unterstuetzte Operatoren: EQUALS, NOT_EQUALS, IN, NOT_IN, IS_EMPTY, IS_NOT_EMPTY.
 * Neuer Operator = neuer case im switch weiter unten (einziger Code-Ort).
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
            case "IS_EMPTY" -> actual == null || (actual instanceof String s && s.isBlank());
            case "IS_NOT_EMPTY" -> !(actual == null || (actual instanceof String s && s.isBlank()));
            default -> throw new IllegalArgumentException("Unbekannter Operator in visibleWhen: " + operator);
        };
    }

    /** Vergleicht z.B. String "GAS" mit Enum-Wert "GAS" oder Zahl 1 mit "1" robust. */
    private boolean equalsLoose(Object actual, Object expected) {
        if (actual == null || expected == null) {
            return Objects.equals(actual, expected);
        }
        return String.valueOf(actual).equals(String.valueOf(expected));
    }
}
