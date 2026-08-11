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

/**
 * DER generische Validator. Er kennt KEIN einziges konkretes Attribut
 * (kein "if code.equals(gasPressureBar)"), sondern liest ausschliesslich
 * aus den category_attributes / attribute_definitions, welche Regeln
 * gelten. Neues Attribut = neue Zeile in der DB, NICHT neuer Code hier.
 *
 * Gleichzeitig ist das Backend die Source of Truth: das Frontend darf
 * Felder aus Komfortgruenden verstecken/pruefen, aber jede Anfrage wird
 * hier nochmal vollstaendig geprueft, bevor irgendetwas gespeichert wird.
 */
@Service
@RequiredArgsConstructor
public class MaterialValidationService {

    private final CategoryAttributeRepository categoryAttributeRepository;
    private final RuleEngine ruleEngine;

    /**
     * Validiert die übergebenen Werte gegen das Schema der Kategorie.
     *
     * @return die bereinigte Werte-Map: nur Attribute, die zur Kategorie
     *         gehoeren UND gemaess visibleWhen tatsaechlich sichtbar sind.
     *         Werte fuer ausgeblendete/unbekannte Attribute werden verworfen,
     *         damit keine "toten" Altwerte in der DB landen.
     * @throws MaterialValidationException wenn Pflichtfelder fehlen oder
     *         Werte nicht zum Datentyp passen.
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

        // 1) unbekannte Attribute im Request abweisen (Tippfehler etc.)
        for (String submittedCode : submittedValues.keySet()) {
            if (!knownCodes.contains(submittedCode)) {
                errors.add(new ValidationErrorDto(submittedCode,
                        "Attribut ist in dieser Kategorie nicht definiert"));
            }
        }

        // 2) jedes Schema-Attribut pruefen
        for (CategoryAttribute ca : schema) {
            AttributeDefinition def = ca.getAttributeDefinition();
            String code = def.getCode();

            boolean visible = ruleEngine.evaluate(ca.getVisibleWhen(), submittedValues);
            Object value = submittedValues.get(code);

            if (!visible) {
                // ausgeblendete Felder werden ignoriert, auch wenn ein Wert mitgeschickt wurde
                continue;
            }

            if (value == null || (value instanceof String s && s.isBlank())) {
                if (ca.isRequired()) {
                    errors.add(new ValidationErrorDto(code, "Pflichtfeld '" + def.getLabel() + "' fehlt"));
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
                    : Optional.of("'" + def.getLabel() + "' muss Text sein");

            case NUMBER -> (value instanceof Number || isNumericString(value))
                    ? Optional.empty()
                    : Optional.of("'" + def.getLabel() + "' muss eine Zahl sein");

            case BOOLEAN -> (value instanceof Boolean)
                    ? Optional.empty()
                    : Optional.of("'" + def.getLabel() + "' muss true/false sein");

            case ENUM -> {
                List<String> allowed = def.getEnumValues() == null ? List.of() : def.getEnumValues();
                yield allowed.contains(String.valueOf(value))
                        ? Optional.empty()
                        : Optional.of("'" + def.getLabel() + "' muss einer von " + allowed + " sein");
            }

            case DATE -> {
                try {
                    LocalDate.parse(String.valueOf(value));
                    yield Optional.empty();
                } catch (DateTimeParseException e) {
                    yield Optional.of("'" + def.getLabel() + "' muss ein Datum im Format YYYY-MM-DD sein");
                }
            }
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
