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

    @Transactional
    public MaterialResponse create(MaterialRequest request) {
        Category category = categoryRepository.findByCode(request.categoryCode())
                .orElseThrow(() -> new EntityNotFoundException("Kategorie nicht gefunden: " + request.categoryCode()));

        // Backend bleibt Source of Truth: unabhaengig davon, was das
        // Frontend geschickt/versteckt hat, wird hier vollstaendig geprueft.
        Map<String, Object> cleanValues = validationService.validateAndClean(category, request.values());

        Material material = Material.builder()
                .category(category)
                .name(request.name())
                .values(cleanValues)
                .createdAt(Instant.now())
                .updatedAt(Instant.now())
                .build();

        Material saved = materialRepository.save(material);
        return toResponse(saved);
    }

    public MaterialResponse getById(Long id) {
        Material material = materialRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Material nicht gefunden: " + id));
        return toResponse(material);
    }

    private MaterialResponse toResponse(Material m) {
        return new MaterialResponse(m.getId(), m.getCategory().getCode(), m.getName(), m.getValues());
    }
}
