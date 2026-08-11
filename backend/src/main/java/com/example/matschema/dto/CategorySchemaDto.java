package com.example.matschema.dto;

import java.util.List;

public record CategorySchemaDto(
        String categoryCode,
        String categoryName,
        List<AttributeSchemaDto> attributes
) {
}
