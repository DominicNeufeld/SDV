package com.example.matschema.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.Map;

public record MaterialRequest(
        @NotBlank String categoryCode,
        String name,
        @NotNull Map<String, Object> values
) {
}
