package com.example.matschema.repository;

import com.example.matschema.domain.AttributeDefinition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AttributeDefinitionRepository extends JpaRepository<AttributeDefinition, Long> {
    Optional<AttributeDefinition> findByCode(String code);

    /** Direkte Kind-Attribute einer GROUP (normale Verschachtelung, keine Varianten). */
    List<AttributeDefinition> findByParentAttribute_IdOrderByChildSortOrderAsc(Long parentAttributeId);

    /** Alternative Varianten (oneOf) einer GROUP. */
    List<AttributeDefinition> findByVariantOf_Id(Long variantOfAttributeId);
}
