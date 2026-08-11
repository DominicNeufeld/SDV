package com.example.matschema.dto;

import java.util.Map;

public record MaterialResponse(
        Long id,
        String categoryCode,
        String name,
        Map<String, Object> values
) {
}
