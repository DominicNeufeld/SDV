package com.example.matschema.terms;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.MissingNode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponents;
import org.springframework.web.util.UriComponentsBuilder;
import org.springframework.web.util.UriUtils;

import java.net.URI;
import java.net.http.HttpClient;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;

@Service
public class SkosmosTermResolver {

    private static final Logger log = LoggerFactory.getLogger(SkosmosTermResolver.class);

    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    private final RestClient restClient;

    public SkosmosTermResolver() {

        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(3))
                .build();

        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(Duration.ofSeconds(5));

        this.restClient = RestClient.builder()
                .requestFactory(requestFactory)
                .build();
    }

    // Resolve a term
    @Cacheable(value = "terms", key = "#termUrl + '|' + #lang", unless = "#result == null")
    public Optional<TermInfo> resolve(String termUrl, String lang) {
        try {

            // Read the term URI 
            String termUri = readTermUri(termUrl);
            if (termUri == null) {
                log.warn("Term URL has no uri parameter: {}", termUrl);
                return Optional.empty();
            }

            // Load all concepts and find the requested one
            JsonNode graph = fetchGraph(termUrl);
            JsonNode concept = findConcept(graph, termUri);
            if (concept.isMissingNode()) {
                log.warn("Term {} not found in Skosmos answer ({})", termUri, termUrl);
                return Optional.empty();
            }

            // Read the values of the term
            String title = readText(concept.path("prefLabel"), lang);
            String description = readText(concept.path("skos:definition"), lang);
            List<String> narrower = readNarrowerLabels(concept, graph, lang);
            String pageUrl = buildPageUrl(termUrl, termUri, lang);

            return Optional.of(new TermInfo(title, description, pageUrl, narrower));

        } catch (Exception e) {
            // Skosmos not reachable
            log.warn("Term could not be resolved: {} ({})", termUrl, e.toString());
            return Optional.empty();
        }
    }

    // Read the term URI 
    private String readTermUri(String termUrl) {
        UriComponents parts = UriComponentsBuilder.fromUriString(termUrl).build();
        String rawUri = parts.getQueryParams().getFirst("uri");

        if (rawUri == null) {
            return null;
        }

        // Decode again (for example %3 -> :)
        return UriUtils.decode(rawUri, StandardCharsets.UTF_8);
    }

    // Load the Skosmos answer 
    private JsonNode fetchGraph(String termUrl) throws Exception {


        String body = restClient.get()
                .uri(URI.create(termUrl))
                .accept(MediaType.APPLICATION_JSON)
                .retrieve()
                .body(String.class);

        if (body == null || body.isBlank()) {
            return MissingNode.getInstance();
        }

        return OBJECT_MAPPER.readTree(body).path("graph");
    }

    // Find one concept in the graph
    private JsonNode findConcept(JsonNode graph, String uri) 
    {
        for (JsonNode concept : graph)
        {
            if (uri.equals(concept.path("uri").asText())) 
            {
                return concept;
            }
        }
        return MissingNode.getInstance();
    }

    // Read the labels of all narrower terms 
    private List<String> readNarrowerLabels(JsonNode concept, JsonNode graph, String lang) {
        List<String> labels = new ArrayList<>();

        for (JsonNode narrowerRef : toList(concept.path("narrower"))) 
        {
            String narrowerUri = narrowerRef.path("uri").asText();
            JsonNode narrowerConcept = findConcept(graph, narrowerUri);

            String label = readText(narrowerConcept.path("prefLabel"), lang);
            if (label != null) 
            {
                labels.add(label);
            }
        }

        labels.sort(String.CASE_INSENSITIVE_ORDER);
        return labels;
    }

    // Build the link to the Skosmos page of the term
    private String buildPageUrl(String termUrl, String termUri, String lang)
    {
        UriComponents parts = UriComponentsBuilder.fromUriString(termUrl).build();

        int lastSeparator = Math.max(termUri.lastIndexOf('/'), termUri.lastIndexOf('#'));
        String localName = termUri.substring(lastSeparator + 1);

        String pagePath = parts.getPath().replaceFirst(
                "/rest/v1/([^/]+)/data$",
                "/$1/" + lang + "/page/" + Matcher.quoteReplacement(localName));

        return UriComponentsBuilder.newInstance()
                .scheme(parts.getScheme())
                .host(parts.getHost())
                .port(parts.getPort())
                .path(pagePath)
                .build()
                .encode()
                .toUriString();  
    }

    private String readText(JsonNode node, String lang) 
    {
        String firstValue = null;

        for (JsonNode entry : toList(node))
        {

            String value = entry.isTextual() ? entry.asText() : entry.path("value").asText(null);
            if (value == null)
            {
                continue;
            }

            // Prefer the wanted language
            if (lang.equals(entry.path("lang").asText())) 
            {
                return value;
            }

            if (firstValue == null)
            {
                firstValue = value;
            }
        }

        return firstValue;
    }

    private List<JsonNode> toList(JsonNode node) 
    {
        List<JsonNode> result = new ArrayList<>();

        if (node == null || node.isMissingNode() || node.isNull())
        {
            return result;
        }

        if (node.isArray())
        {
            for (JsonNode item : node)
            {
                result.add(item);
            }

        } else
        {
            result.add(node);
        }

        return result;
    }
}