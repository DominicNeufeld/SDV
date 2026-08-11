package de.arbeit.material.web;

import de.arbeit.material.model.Material;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/api/materials")
// Für den Prototyp erlauben wir den lokalen Vite-Dev-Server.
@CrossOrigin(origins = {"http://localhost:5173", "http://127.0.0.1:5173"})
public class MaterialController {

    private final Map<Long, Material> speicher = new ConcurrentHashMap<>();
    private final AtomicLong idGenerator = new AtomicLong(1);

    @GetMapping
    public List<Material> alleMaterialien() {
        return speicher.values().stream()
                .sorted((a, b) -> Long.compare(a.getId(), b.getId()))
                .toList();
    }

    @PostMapping
    public Material anlegen(@Valid @RequestBody Material material) {
        // Serverseitige Konsistenzregel: Gasdruck nur bei Aggregatzustand GAS speichern
        if (material.getAggregatzustand() != de.arbeit.material.model.Aggregatzustand.GAS) {
            material.setGasDruckBar(null);
        }
        long id = idGenerator.getAndIncrement();
        material.setId(id);
        speicher.put(id, material);
        return material;
    }

    @DeleteMapping("/{id}")
    public void loeschen(@PathVariable Long id) {
        speicher.remove(id);
    }
}
