package com.example.matschema.service;

import com.example.matschema.domain.AttributeDefinition;
import com.example.matschema.domain.Category;
import com.example.matschema.domain.CategoryAttribute;
import com.example.matschema.dto.AttributeSchemaDto;
import com.example.matschema.dto.CategorySchemaDto;
import com.example.matschema.dto.CategorySummaryDto;
import com.example.matschema.repository.AttributeDefinitionRepository;
import com.example.matschema.repository.CategoryAttributeRepository;
import com.example.matschema.repository.CategoryRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SchemaService {

    private final CategoryRepository categoryRepository;
    private final CategoryAttributeRepository categoryAttributeRepository;
    private final AttributeDefinitionRepository attributeDefinitionRepository;

    public List<CategorySummaryDto> listCategories() {
        return categoryRepository.findAll().stream()
                .map(c -> new CategorySummaryDto(c.getCode(), c.getName()))
                .toList();
    }

    public CategorySchemaDto getSchema(String categoryCode) {
        Category category = categoryRepository.findByCode(categoryCode)
                .orElseThrow(() -> new EntityNotFoundException("Category not found " + categoryCode));

        List<AttributeSchemaDto> attributes = new ArrayList<>();

        for (CategoryAttribute ca : categoryAttributeRepository.findByCategoryIdOrderBySortOrderAsc(category.getId())) {
            AttributeDefinition def = ca.getAttributeDefinition();
            attributes.add(toTopLevelDto(ca));
            attributes.addAll(collectDescendants(def));
        }

        return new CategorySchemaDto(category.getCode(), category.getName(), attributes);
    }

    private AttributeSchemaDto toTopLevelDto(CategoryAttribute ca) {
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
                ca.getRequiredWhen(),
                ca.getDefaultValue(),
                null,   
                def.isRepeatable(),
                null,   
                null    
        );
    }


    private AttributeSchemaDto toChildDto(AttributeDefinition def) {
        return new AttributeSchemaDto(
                def.getCode(),
                def.getLabel(),
                def.getDescription(),
                def.getDataType(),
                def.getUnit(),
                def.getEnumValues(),
                def.isChildRequired(),
                def.getChildSortOrder(),
                def.getChildVisibleWhen(),
                def.getChildRequiredWhen(),
                null,   
                def.getParentAttribute().getCode(),
                def.isRepeatable(),
                null, 
                null   
        );
    }

    private AttributeSchemaDto toVariantDto(AttributeDefinition def) {
        return new AttributeSchemaDto(
                def.getCode(),
                def.getLabel(),
                def.getDescription(),
                def.getDataType(),
                def.getUnit(),
                def.getEnumValues(),
                def.isChildRequired(),
                def.getChildSortOrder(),
                def.getChildVisibleWhen(),
                def.getChildRequiredWhen(),
                null,
                null,   
                def.isRepeatable(),
                def.getVariantOf().getCode(),
                def.getVariantKey()
        );
    }

    private List<AttributeSchemaDto> collectDescendants(AttributeDefinition parent) {
        List<AttributeSchemaDto> result = new ArrayList<>();

        for (AttributeDefinition child : attributeDefinitionRepository
                .findByParentAttribute_IdOrderByChildSortOrderAsc(parent.getId())) {
            result.add(toChildDto(child));
            result.addAll(collectDescendants(child));
        }

        for (AttributeDefinition variant : attributeDefinitionRepository.findByVariantOf_Id(parent.getId())) {
            result.add(toVariantDto(variant));
            result.addAll(collectDescendants(variant));
        }

        return result;
    }
}
