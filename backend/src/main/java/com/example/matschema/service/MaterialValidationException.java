package com.example.matschema.service;

import com.example.matschema.dto.ValidationErrorDto;

import java.util.List;

public class MaterialValidationException extends RuntimeException {

    private final List<ValidationErrorDto> errors;

    public MaterialValidationException(List<ValidationErrorDto> errors) {
        super("Validation failed: " + errors.size() + " error/s");
        this.errors = errors;
    }

    public List<ValidationErrorDto> getErrors() {
        return errors;
    }
}
