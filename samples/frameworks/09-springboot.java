package frameworktour.springboot;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import java.util.Optional;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

/**
 * Spring Boot framework tour.
 *
 * Covers auto-configuration, REST controllers, dependency injection,
 * JPA repositories, validation, transactions and exception handling.
 */
@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}

/** A validated request payload. */
record CreateArticleRequest(@NotBlank String title, @Min(0) int likeCount) {}

interface ArticleRepository extends JpaRepository<ArticleEntity, Long> {
    /**
     * Finds the most liked articles.
     *
     * @param limit maximum rows to return
     * @return the matching entities
     */
    @Query("SELECT a FROM ArticleEntity a WHERE a.likeCount >= :min ORDER BY a.likeCount DESC")
    List<ArticleEntity> findPopular(@org.springframework.data.repository.query.Param("min") int min);
}

@Service
class ArticleService {
    private final ArticleRepository repository;

    @Value("${app.default-limit:20}")
    private int defaultLimit;

    ArticleService(ArticleRepository repository) {
        this.repository = repository; // constructor injection
    }

    @Transactional(readOnly = true)
    Optional<ArticleEntity> findById(Long id) {
        return repository.findById(id);
    }

    @Transactional
    ArticleEntity create(CreateArticleRequest request) {
        var entity = new ArticleEntity(request.title(), request.likeCount());
        return repository.save(entity);
    }
}

@RestController
@RequestMapping("/api/articles")
class ArticleController {
    private final ArticleService service;

    ArticleController(ArticleService service) {
        this.service = service;
    }

    @GetMapping("/{id}")
    ResponseEntity<ArticleEntity> findOne(@PathVariable Long id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(org.springframework.http.HttpStatus.CREATED)
    ArticleEntity create(@Valid @RequestBody CreateArticleRequest request) {
        return service.create(request);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<String> handleBadRequest(IllegalArgumentException ex) {
        return ResponseEntity.badRequest().body(ex.getMessage());
    }
}

@jakarta.persistence.Entity
class ArticleEntity {
    @jakarta.persistence.Id
    @jakarta.persistence.GeneratedValue
    private Long id;

    private String title;
    private int likeCount;

    protected ArticleEntity() {}

    ArticleEntity(String title, int likeCount) {
        this.title = title;
        this.likeCount = likeCount;
    }
}
