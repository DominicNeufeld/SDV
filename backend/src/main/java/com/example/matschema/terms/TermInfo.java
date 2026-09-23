package com.example.matschema.terms;

import java.util.List;

public record TermInfo(String title, String description, String pageUrl, List<String> narrower) {}