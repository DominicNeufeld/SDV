package com.example.matschema.domain;

public enum DataType {
    STRING,
    NUMBER,
    BOOLEAN,
    ENUM,
    DATE,
    /** Mehrfachauswahl aus enumValues; Wert wird als Array gespeichert statt als Scalar. */
    MULTI_ENUM,
    /** Zahl + Einheit als EIN Leaf-Attribut, Wert = {"value": ..., "unit": ...}. */
    QUANTITY,
    /** Container-Attribut ohne eigenen Wert; besitzt Kind-Attribute (siehe parentAttribute). */
    GROUP
}