package com.example.bookstore.services;

import com.example.bookstore.repositories.BookRepository;
import com.example.bookstore.tables.Books;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.time.LocalDate;

@Service
public class BookImportService {
    private final BookRepository bookRepository;
    private final RestTemplate restTemplate;

    public BookImportService(BookRepository bookRepository, RestTemplate restTemplate) {
        this.bookRepository = bookRepository;
        this.restTemplate = restTemplate;
    }

    public void importBooksBySubject(String subject) {
       
        String url = "https://openlibrary.org/subjects/" + subject.toLowerCase() + ".json?limit=2";

        try {
            String jsonString = restTemplate.getForObject(url, String.class);
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(jsonString);
            JsonNode works = root.path("works");

            if (works.isArray()) {
                for (JsonNode work : works) {
                    Books book = new Books();
                    book.setTitle(work.path("title").asText());
                    
                    String workKey = work.path("key").asText();

                    String description = fetchDescription(workKey);
                    book.setDescription(description);

                    if (work.has("authors") && work.get("authors").isArray()) {
                        book.setAuthor(work.path("authors").get(0).path("name").asText("Unknown"));

                    }

                    book.setGenre(subject.substring(0, 1).toUpperCase() + subject.substring(1));

                    String coverId = work.path("cover_id").asText();
                    if (!coverId.isEmpty()) {
                        book.setCoverUrl("https://covers.openlibrary.org/b/id/" + coverId + "-L.jpg");
                    }

                    book.setPrice(14.99 + (Math.random() * 10));
                    book.setRatings(4);
                    book.setStock(15);
                    book.setReleaseDate(LocalDate.now());

                    bookRepository.save(book);
                }
                System.out.println(" Successfully imported: " + subject);
            }
        } catch (Exception e) {
            System.err.println(" Open Library Error: " + e.getMessage());
        }

    }
    private String fetchDescription(String workKey) {
        try {
            String workUrl = "https://openlibrary.org" + workKey + ".json";
            JsonNode workDetails = new ObjectMapper().readTree(restTemplate.getForObject(workUrl, String.class));


            JsonNode descNode = workDetails.path("description");
            if (descNode.isObject()) {
                return descNode.path("value").asText("No description available.");
            }
            return descNode.asText("No description available.");
        } catch (Exception e) {
            return "Description currently unavailable.";
        }
    }
}