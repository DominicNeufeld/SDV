package com.example.matschema.repository;

import com.example.matschema.domain.AttributeDefinition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AttributeDefinitionRepository extends JpaRepository<AttributeDefinition, Long> {
    Optional<AttributeDefinition> findByCode(String code);

    List<AttributeDefinition> findByParentAttribute_IdOrderByChildSortOrderAsc(Long parentAttributeId);

    List<AttributeDefinition> findByVariantOf_Id(Long variantOfAttributeId);
}
