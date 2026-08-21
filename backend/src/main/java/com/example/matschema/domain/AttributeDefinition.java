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


    @Enumerated(EnumType.STRING)
    @Column(name = "data_type", nullable = false, length = 20)
    private DataType dataType;

    private String unit;

    @Column(name = "link", length = 500)
    private String link;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "enum_values")
    private List<String> enumValues;

 
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_attribute_id")
    private AttributeDefinition parentAttribute;

    @Column(name = "is_repeatable", nullable = false)
    private boolean repeatable;


    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variant_of_attribute_id")
    private AttributeDefinition variantOf;


    @Column(name = "variant_key", length = 150)
    private String variantKey;


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
