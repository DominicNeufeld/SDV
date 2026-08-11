package de.arbeit.material.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

/**
 * Prototyp-Datenmodell. Aktuell nur zwei Testfelder:
 *  - bezeichnung: Freitext (Testfeld 1)
 *  - aggregatzustand: Radiobutton FEST / GAS
 *  - gasDruckBar: nur relevant, wenn aggregatzustand == GAS
 */
public class Material {

    private Long id;

    @NotBlank(message = "Bezeichnung darf nicht leer sein")
    private String bezeichnung;

    @NotNull(message = "Aggregatzustand muss ausgewählt werden")
    private Aggregatzustand aggregatzustand;

    // Nur gesetzt, wenn aggregatzustand == GAS
    private Double gasDruckBar;

    public Material() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getBezeichnung() {
        return bezeichnung;
    }

    public void setBezeichnung(String bezeichnung) {
        this.bezeichnung = bezeichnung;
    }

    public Aggregatzustand getAggregatzustand() {
        return aggregatzustand;
    }

    public void setAggregatzustand(Aggregatzustand aggregatzustand) {
        this.aggregatzustand = aggregatzustand;
    }

    public Double getGasDruckBar() {
        return gasDruckBar;
    }

    public void setGasDruckBar(Double gasDruckBar) {
        this.gasDruckBar = gasDruckBar;
    }
}
