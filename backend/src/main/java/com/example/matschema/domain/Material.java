package com.example.matschema.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Ein konkreter Materialdatensatz. Die fachlichen Attributwerte liegen
 * NICHT als einzelne Spalten vor (das waeren die ~500 Spalten aus dem
 * Bestandssystem), sondern als generische JSONB-Map:
 * { "materialName": "Argon", "physicalState": "GAS", "gasPressureBar": 200 }
 *
 * Welche Keys erlaubt/erwartet sind, ergibt sich rein aus den
 * category_attributes der jeweiligen Kategorie - nicht aus dem Java-Code.
 */
@Entity
@Table(name = "materials")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Material {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(nullable = false)
    private String name;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false)
    @Builder.Default
    private Map<String, Object> values = new LinkedHashMap<>();

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;
}
