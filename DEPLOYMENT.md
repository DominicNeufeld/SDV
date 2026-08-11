# Deployment Guide

## 1. Build

```bash
./gradlew clean bootJar
```

Erzeugt `build/libs/material-schema-prototype-0.1.0.jar`.

## 2. Konfiguration (per Umgebungsvariablen, kein Code-/File-Edit nötig)

| Variable                | Beispiel                                   |
|--------------------------|---------------------------------------------|
| `SPRING_DATASOURCE_URL`  | `jdbc:postgresql://db-host:5432/matschema`  |
| `SPRING_DATASOURCE_USERNAME` | `matschema`                             |
| `SPRING_DATASOURCE_PASSWORD` | `<secret>`                              |
| `SERVER_PORT`            | `8080`                                      |

Flyway führt die Migrationen (`db/migration/V*.sql`) beim Start automatisch aus.

## 3. Starten

```bash
java -jar build/libs/material-schema-prototype-0.1.0.jar
```

## 4. Alternativ: Docker

```dockerfile
FROM eclipse-temurin:17-jre
COPY build/libs/material-schema-prototype-0.1.0.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

```bash
docker build -t material-schema-prototype .
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:postgresql://db-host:5432/matschema \
  -e SPRING_DATASOURCE_USERNAME=matschema \
  -e SPRING_DATASOURCE_PASSWORD=<secret> \
  material-schema-prototype
```

## 5. Neues Attribut/Kategorie in Produktion ausrollen

Neue Migration (`V3__...sql`, siehe `EXTENSION_EXAMPLE_...`) in `db/migration/`
legen, neu bauen und deployen — kein Anwendungscode ändert sich, nur die
SQL-Datei. Flyway wendet sie beim nächsten Start automatisch an.
