package com.example.matschema.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@Entity
@Table(name = "attribute_definitions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AttributeDefinition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 100)
    private String code;

    @Column(nullable = false)
    private String label;

    private String description;

    /** STRING, NUMBER, BOOLEAN, ENUM, DATE, MULTI_ENUM, GROUP */
    @Enumerated(EnumType.STRING)
    @Column(name = "data_type", nullable = false, length = 20)
    private DataType dataType;

    private String unit;

    /** Only relevant when: dataType == ENUM or MULTI_ENUM. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "enum_values")
    private List<String> enumValues;

    // ---------------------------------------------------------------
    // Verschachtelung: dieses Attribut ist ein Kind eines GROUP-Attributs
    // ---------------------------------------------------------------
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_attribute_id")
    private AttributeDefinition parentAttribute;

    /** Nur relevant wenn dataType == GROUP: Gruppe kommt als Array vor (0..n Instanzen). */
    @Column(name = "is_repeatable", nullable = false)
    private boolean repeatable;

    // ---------------------------------------------------------------
    // Varianten / oneOf: dieses (GROUP-)Attribut ist eine von mehreren
    // Alternativen unter einer gemeinsamen GROUP, ausgewaehlt ueber ein
    // Diskriminator-Attribut (ein normales Kind-ENUM derselben GROUP).
    // ---------------------------------------------------------------
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_of_attribute_id")
    private AttributeDefinition variantOf;

    /** Schluessel dieser Variante, z.B. "cartesian". Muss zum Wert des Diskriminators passen. */
    @Column(name = "variant_key", length = 150)
    private String variantKey;

    // ---------------------------------------------------------------
    // Struktur-Metadaten NUR fuer verschachtelte Attribute (parentAttribute
    // oder variantOf gesetzt). Top-Level-Attribute nutzen stattdessen die
    // gleichnamigen Felder auf CategoryAttribute.
    // ---------------------------------------------------------------
    @Column(name = "child_required", nullable = false)
    private boolean childRequired;

    @Column(name = "child_sort_order", nullable = false)
    private int childSortOrder;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "child_visible_when")
    private Map<String, Object> childVisibleWhen;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "child_required_when")
    private Map<String, Object> childRequiredWhen;

    @Column(name = "created_at")
    private Instant createdAt;

    @Column(name = "updated_at")
    private Instant updatedAt;
}
