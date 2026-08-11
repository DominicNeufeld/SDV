package com.example.matschema.service;

import com.example.matschema.domain.Category;
import com.example.matschema.domain.CategoryAttribute;
import com.example.matschema.dto.AttributeSchemaDto;
import com.example.matschema.dto.CategorySchemaDto;
import com.example.matschema.dto.CategorySummaryDto;
import com.example.matschema.repository.CategoryAttributeRepository;
import com.example.matschema.repository.CategoryRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * Liest das Schema (welche Attribute gehoeren zu einer Kategorie, in
 * welcher Reihenfolge, mit welchen Regeln) aus attribute_definitions +
 * category_attributes und stellt es als DTO bereit. Dieses DTO ist die
 * einzige Grundlage, die der generische Formular-Renderer im Frontend
 * braucht.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SchemaService {

    private final CategoryRepository categoryRepository;
    private final CategoryAttributeRepository categoryAttributeRepository;

    public List<CategorySummaryDto> listCategories() {
        return categoryRepository.findAll().stream()
                .map(c -> new CategorySummaryDto(c.getCode(), c.getName()))
                .toList();
    }

    public CategorySchemaDto getSchema(String categoryCode) {
        Category category = categoryRepository.findByCode(categoryCode)
                .orElseThrow(() -> new EntityNotFoundException("Kategorie nicht gefunden: " + categoryCode));

        List<AttributeSchemaDto> attributes = categoryAttributeRepository
                .findByCategoryIdOrderBySortOrderAsc(category.getId())
                .stream()
                .map(this::toDto)
                .toList();

        return new CategorySchemaDto(category.getCode(), category.getName(), attributes);
    }

    private AttributeSchemaDto toDto(CategoryAttribute ca) {
        var def = ca.getAttributeDefinition();
        return new AttributeSchemaDto(
                def.getCode(),
                def.getLabel(),
                def.getDescription(),
                def.getDataType(),
                def.getUnit(),
                def.getEnumValues(),
                ca.isRequired(),
                ca.getSortOrder(),
                ca.getVisibleWhen(),
                ca.getDefaultValue()
        );
    }
}
