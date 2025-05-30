package com.example.backend_a.resilience;

import org.springframework.context.annotation.Profile;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@Profile("serverbreaker")
@RequestMapping("/unstable")
public class ServerBreakerController {

    private final ServerSideCircuitBreaker circuitBreaker;

    public ServerBreakerController(ServerSideCircuitBreaker circuitBreaker) {
        this.circuitBreaker = circuitBreaker;
    }

    @GetMapping
    public ResponseEntity<String> getData() {
        if (circuitBreaker.isOpen()) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                    .body("🚫 Serverseitiger Circuit Breaker aktiv");
        }

        try {
            double randomValue = Math.random();
            System.out.println("Zufallswert: " + randomValue);
            if (randomValue < 1.0) {
                throw new RuntimeException("Simulierter Fehler");
            }

            circuitBreaker.recordSuccess();
            return ResponseEntity.ok("✅ Erfolgreiche Antwort von backend-a mit serverseitigem Circuit Breaker");

        } catch (Exception e) {
            circuitBreaker.recordFailure();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("❌ Fehler im Service: " + e.getMessage());
        }
    }
}
