# Material Entry
Form for the quick entry of materials.


## Setup

```
bash
git clone <https://github.com/DominicNeufeld/SDV.git>
cd SDV
```
```
gradle wrapper
```

```
bash
docker compose up -d     
./gradlew bootRun         
```

→ `http://localhost:8080`


## Starting Server
### Backend
```bash
docker start matschema-postgres

cd SDV/backend
./gradlew bootRun
```

Backend: `http://localhost:8080`

### Frontend
```bash
cd SDV/frontend
npm install  
npm run dev
```

Frontend: `http://localhost:5173`

## Add a new Attribut

1. Create new Data: `SDV/backend/src/main/resources/db/migration/V4__add_xyz.sql`
2. Schema:
   ```sql
   INSERT INTO attribute_definitions (code, label, description, data_type, unit, enum_values) VALUES
       ('meinAttribut', 'Mein Attribut', 'Beschreibung', 'STRING', NULL, NULL);

   INSERT INTO category_attributes (category_id, attribute_definition_id, required, sort_order, visible_when)
   SELECT c.id, a.id, true, 40, NULL
   FROM categories c, attribute_definitions a
   WHERE c.code = 'CHEMICAL' AND a.code = 'meinAttribut';
   ```
3. Restart the Backend: `./gradlew bootRun` 


## Restart/Delete Container
```
docker stop matschema-postgres
docker rm -v matschema-postgres   

docker volume ls
docker volume rm <name-des-volumes>

docker run -d \
  --name matschema-postgres \
  -e POSTGRES_USER=matschema \
  -e POSTGRES_PASSWORD=matschema \
  -e POSTGRES_DB=matschema \
  -p 5432:5432 \
  postgres:16

sleep 3
docker exec -it matschema-postgres psql -U matschema -d matschema -c "\dt"   

cd backend                    
rm -rf build                                     
./gradlew clean build --refresh-dependencies
./gradlew bootRun       
```