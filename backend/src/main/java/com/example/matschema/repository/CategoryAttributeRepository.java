package com.example.matschema.repository;

import com.example.matschema.domain.CategoryAttribute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CategoryAttributeRepository extends JpaRepository<CategoryAttribute, Long> {

    /**
     * Laedt category_attributes inkl. der zugehoerigen attribute_definitions
     * in EINER Query (JOIN FETCH). Wichtig bei ~500 Attributen: verhindert
     * sowohl N+1-Queries als auch LazyInitializationException, falls die
     * Methode ausserhalb einer offenen Transaktion aufgerufen wird.
     */
    @Query("""
            SELECT ca FROM CategoryAttribute ca
            JOIN FETCH ca.attributeDefinition
            WHERE ca.category.id = :categoryId
            ORDER BY ca.sortOrder ASC
            """)
    List<CategoryAttribute> findByCategoryIdOrderBySortOrderAsc(@Param("categoryId") Long categoryId);
}
