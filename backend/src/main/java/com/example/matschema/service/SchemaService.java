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
import com.example.matschema.domain.DataType;
import com.example.matschema.terms.SkosmosTermResolver;
import com.example.matschema.terms.TermInfo;
import org.springframework.beans.factory.annotation.Value;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SchemaService {

    private final CategoryRepository categoryRepository;
    private final CategoryAttributeRepository categoryAttributeRepository;
    private final AttributeDefinitionRepository attributeDefinitionRepository;
    private final SkosmosTermResolver termResolver;

    @Value("${app.terms.lang:en}")
    private String termLang = "en";

    @Value("${app.terms.rest-base:}")
    private String termRestBase = "";

     @Value("${app.terms.uri-space:}")
    private String termUriSpace = "";

     // Display values after the term URI has been resolved
    private record Resolved(String label, String description, String link, List<String> enumValues) {}

    // Get all categories
    public List<CategorySummaryDto> listCategories() {

        List<CategorySummaryDto> result = new ArrayList<>();
        List<Category> categories = categoryRepository.findAll();

        for (Category category : categories) {
            CategorySummaryDto dto = new CategorySummaryDto(category.getCode(), category.getName());

            result.add(dto);
        }

        return result;
    }

    // Get schema for category
    public CategorySchemaDto getSchema(String categoryCode) {

        // Find category by code
        Category category = categoryRepository.findByCode(categoryCode)
                .orElseThrow(() -> new EntityNotFoundException("Category not found " + categoryCode));

        List<AttributeSchemaDto> attributes = new ArrayList<>();

        // Collect top-level attributes and their descendants
        for (CategoryAttribute ca : categoryAttributeRepository.findByCategoryIdOrderBySortOrderAsc(category.getId())) {
            AttributeDefinition def = ca.getAttributeDefinition();
            attributes.add(toTopLevelDto(ca));
            attributes.addAll(collectDescendants(def));
        }

        return new CategorySchemaDto(category.getCode(), category.getName(), attributes);
    }

     // Resolve label, description, link and enum values 
     private Resolved resolve(AttributeDefinition def) {
        TermInfo term = null;
 
        // Load the term from the vocabulary
        String termUrl = buildTermUrl(def);
        if (termUrl != null) {
            term = termResolver.resolve(termUrl, termLang).orElse(null);
        }
 
        String label = def.getLabel();
        String description = def.getDescription();
        String link = def.getLink();
        List<String> enumValues = def.getEnumValues();
 
        if (term != null) {
 
            // Fill empty values from the vocabulary
            if (isBlank(label)) {
                label = term.title();
            }
            if (isBlank(description)) {
                description = term.description();
            }
            if (isBlank(link)) {
                link = term.pageUrl();
            }
 
            // Use narrower terms as enum values
            boolean isEnum = def.getDataType() == DataType.ENUM || def.getDataType() == DataType.MULTI_ENUM;
            if (isEnum && (enumValues == null || enumValues.isEmpty())) {
                enumValues = term.narrower();
            }
        }
 
        
        if (isBlank(label)) {
            label = def.getCode();
        }
 
        return new Resolved(label, description, link, enumValues);
    }
 
    // Check for null or empty text
    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
 
    // Build the Skosmos REST URL of the term 
    private String buildTermUrl(AttributeDefinition def) {
        String termUri = def.getTermUri();
 
        // Gets full REST URL
        if (!isBlank(termUri) && termUri.contains("/rest/v1/")) {
            return termUri;
        }
 
        // Null
        if (isBlank(termRestBase) || isBlank(termUriSpace)) {
            return null;
        }
 
        String conceptUri;
 
        if (!isBlank(termUri)) {
            if (termUri.startsWith("http")) {
                // Full term URI
                conceptUri = termUri;
            } else {
                // A short name was entered
                conceptUri = termUriSpace + termUri;
            }
        } else if (isBlank(def.getLabel())) {
            // No label and no term URI
            conceptUri = termUriSpace + capitalize(def.getCode());
        } else {
            // No vocabulary lookup
            return null;
        }
 
        return termRestBase + "/data?uri=" + conceptUri + "&format=application%2Fjson";
    }
 
    // Make the first letter uppercase
    private String capitalize(String text) {
        return text.substring(0, 1).toUpperCase() + text.substring(1);
    }

    // Convert to DTO
    private AttributeSchemaDto toTopLevelDto(CategoryAttribute ca) 
    {
        var def = ca.getAttributeDefinition();

        Resolved r = resolve(def);

        return new AttributeSchemaDto(
                def.getCode(),
                r.label(),
                r.description(),
                def.getDataType(),
                def.getUnit(),
                r.enumValues(),
                ca.isRequired(),
                ca.getSortOrder(),
                ca.getVisibleWhen(),
                ca.getRequiredWhen(),
                ca.getDefaultValue(),
                null,
                def.isRepeatable(),
                null,
                null,
                r.link(),
                def.getUnitOptions());
    }

    // Convert child attribute to DTO
    private AttributeSchemaDto toChildDto(AttributeDefinition def) 
    {
        Resolved r = resolve(def);

        return new AttributeSchemaDto(
                def.getCode(),
                r.label(),
                r.description(),
                def.getDataType(),
                def.getUnit(),
                r.enumValues(),
                def.isChildRequired(),
                def.getChildSortOrder(),
                def.getChildVisibleWhen(),
                def.getChildRequiredWhen(),
                null,
                def.getParentAttribute().getCode(),
                def.isRepeatable(),
                null,
                null,
                r.link(),
                def.getUnitOptions());
    }

    // Convert variant attribute to DTO
    private AttributeSchemaDto toVariantDto(AttributeDefinition def) 
    {
        Resolved r = resolve(def);
        return new AttributeSchemaDto(
                def.getCode(),
                r.label(),
                r.description(),
                def.getDataType(),
                def.getUnit(),
                r.enumValues(),
                def.isChildRequired(),
                def.getChildSortOrder(),
                def.getChildVisibleWhen(),
                def.getChildRequiredWhen(),
                null,
                null,
                def.isRepeatable(),
                def.getVariantOf().getCode(),
                def.getVariantKey(),
                r.link(),
                def.getUnitOptions());
    }

    // Collect child and variant attributes
    private List<AttributeSchemaDto> collectDescendants(AttributeDefinition parent) {
        List<AttributeSchemaDto> result = new ArrayList<>();

        // Add Child
        for (AttributeDefinition child : attributeDefinitionRepository
                .findByParentAttribute_IdOrderByChildSortOrderAsc(parent.getId())) {
            result.add(toChildDto(child));
            result.addAll(collectDescendants(child));
        }

        // Add Variants
        for (AttributeDefinition variant : attributeDefinitionRepository.findByVariantOf_Id(parent.getId())) {
            result.add(toVariantDto(variant));
            result.addAll(collectDescendants(variant));
        }

        return result;
    }
}
