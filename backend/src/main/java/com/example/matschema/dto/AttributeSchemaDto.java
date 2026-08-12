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
        /** Code des Eltern-GROUP-Attributs, falls dieses Attribut verschachtelt ist. Sonst null. */
        String parentCode,
        /** Nur bei dataType == GROUP relevant: kann die Gruppe mehrfach vorkommen (Array)? */
        boolean repeatable,
        /** Code der GROUP, deren Variante dieses Attribut ist (oneOf). Sonst null. */
        String variantOfCode,
        /** Schluessel dieser Variante, z.B. "cartesian". Nur gesetzt wenn variantOfCode != null. */
        String variantKey
) {
}
