package com.example.matschema.web;

import com.example.matschema.dto.CategorySchemaDto;
import com.example.matschema.dto.CategorySummaryDto;
import com.example.matschema.service.SchemaService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class SchemaController {

    private final SchemaService schemaService;

    // Get all categories
    @GetMapping
    public List<CategorySummaryDto> listCategories() {
        return schemaService.listCategories();
    }

    // Get schema by code
    @GetMapping("/{code}/schema")
    public CategorySchemaDto getSchema(@PathVariable String code) {
        return schemaService.getSchema(code);
    }
}
