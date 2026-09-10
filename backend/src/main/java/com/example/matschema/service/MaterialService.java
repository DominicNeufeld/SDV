package com.example.matschema.service;

import com.example.matschema.domain.Category;
import com.example.matschema.domain.Material;
import com.example.matschema.dto.MaterialRequest;
import com.example.matschema.dto.MaterialResponse;
import com.example.matschema.repository.CategoryRepository;
import com.example.matschema.repository.MaterialRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MaterialService {

    private final CategoryRepository categoryRepository;
    private final MaterialRepository materialRepository;
    private final MaterialValidationService validationService;

    //Create a new material
    @Transactional
    public MaterialResponse create(MaterialRequest request) {

        //Find category by code
        Category category = categoryRepository.findByCode(request.categoryCode())
                .orElseThrow(() -> new EntityNotFoundException("Category not found: " + request.categoryCode()));

        //Validate and clean the values
        Map<String, Object> cleanValues = validationService.validateAndClean(category, request.values());

        //Create the material
        Material material = Material.builder()
                .category(category)
                .name(request.name())
                .values(cleanValues)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        //Save the material
        Material saved = materialRepository.save(material);
        return toResponse(saved);
    }

    //Get a material by id
    public MaterialResponse getById(Long id) {
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Material not found " + id));
        return toResponse(material);
    }

    //Convert Material to MaterialResponse
    private MaterialResponse toResponse(Material m) {
        return new MaterialResponse(m.getId(), m.getCategory().getCode(), m.getName(), m.getValues());
    }
}
