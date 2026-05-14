package com.example.bookstore.services;

import com.example.bookstore.tables.Books;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Map;

@Service
public class BookintService {
    private final RestTemplate restTemplate = new RestTemplate();
    private final String API_KEY = "c2e982a7-3b9c-4c96-a4b6-b656eb2d6e74";
    private final String BASE_URL = "https://api.nytimes.com/svc/books/v3/lists/current/hardcover-fiction.json?api-key=" ;
    private final String URL = BASE_URL+API_KEY;
    private final String SEARCH_URL = "https://openlibrary.org/search.json?q=";
    private final String WORK_URL = "https://openlibrary.org"; // for descriptions

    public Books fetchBookDetails(String query) {
        // 1. Search for the book
        OpenLibraryResponse response = restTemplate.getForObject(SEARCH_URL + query, OpenLibraryResponse.class);

        if (response != null && !response.getDocs().isEmpty()) {
            OpenLibraryResponse.Doc doc = response.getDocs().get(0);

            Books book = new Books();
            book.setTitle(doc.getTitle());
            book.setAuthor(doc.getAuthorName() != null ? doc.getAuthorName().get(0) : "Unknown");
            if (doc.getSubjects() != null && !doc.getSubjects().isEmpty()) {
                // Take the first subject as the primary genre
                book.setGenre(doc.getSubjects().get(0));
            } else {
                book.setGenre("General");
            }

            // 2. Construct Cover Image URL (Size L for Large)
            if (doc.getCoverId() != null) {
                book.setCoverUrl("https://covers.openlibrary.org/b/id/" + doc.getCoverId() + "-S.jpg");
            }

            // 3. Fetch Description (Requires a second call to the 'Work' key)
            book.setDescription(fetchDescription(doc.getKey()));

            return book;
        }
        return null;
    }

    private String fetchDescription(String workKey) {
        try {
            // URL looks like: https://openlibrary.org/works/OL123W.json
            String url = WORK_URL + workKey + ".json";
            Map<String, Object> workData = restTemplate.getForObject(url, Map.class);

            Object descriptionObj = workData.get("description");
            if (descriptionObj instanceof String) {
                return (String) descriptionObj;
            } else if (descriptionObj instanceof Map) {
                // Sometimes description is a nested object { "value": "..." }
                return (String) ((Map<?, ?>) descriptionObj).get("value");
            }
        } catch (Exception e) {
            return "No description available.";
        }
        return "No description available.";
    }
}

