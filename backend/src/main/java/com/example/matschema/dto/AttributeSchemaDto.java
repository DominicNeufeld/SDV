package com.example.matschema.dto;

import com.example.matschema.domain.DataType;

import java.util.List;
import java.util.Map;

/**
 * Alles, was der generische Form-Renderer im Frontend braucht, um EIN
 * Formularfeld darzustellen - unabhaengig davon, um welches konkrete
 * Attribut es sich handelt.
 */
public record AttributeSchemaDto(
        String code,
        String label,
        String description,
        DataType dataType,
        String unit,
        List<String> enumValues,
        boolean required,
        int sortOrder,
        Map<String, Object> visibleWhen,
        String defaultValue
) {
}
