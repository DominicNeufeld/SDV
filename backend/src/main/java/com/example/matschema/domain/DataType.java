package com.example.matschema.domain;

/**
 * Alle unterstuetzten Datentypen fuer Attribute.
 * Neuer Datentyp = neuer Enum-Wert + Behandlung im generischen
 * Validator (MaterialValidationService) und im Frontend-Renderer (app.js).
 * Das ist bewusst der EINZIGE Punkt, an dem tatsaechlich Code fuer einen
 * neuen "Attribut-Typ" (nicht: neues Attribut!) angefasst werden muss.
 */
public enum DataType {
    STRING,
    NUMBER,
    BOOLEAN,
    ENUM,
    DATE
}
