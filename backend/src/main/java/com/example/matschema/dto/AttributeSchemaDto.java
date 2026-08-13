package com.example.matschema.dto;

import com.example.matschema.domain.DataType;

import java.util.List;
import java.util.Map;

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
        Map<String, Object> requiredWhen,
        String defaultValue,

        String parentCode,

        boolean repeatable,

        String variantOfCode,

        String variantKey
) {
}
