package com.example.myservice;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
@Profile("circuitbreaker")
public class CircuitBreakerBackendCallerService implements BackendCaller {

    private static final Logger log = LoggerFactory.getLogger(CircuitBreakerBackendCallerService.class);

    private final RestTemplate restTemplate;
    private final Counter fallbackUnstableCounter;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    @Value("${backend.a.unstableUrl}")
    private String unstableUrl;

    public CircuitBreakerBackendCallerService(RestTemplate restTemplate, MeterRegistry registry) {
        this.restTemplate = restTemplate;
        this.fallbackUnstableCounter = Counter.builder("fallback_total")
            .description("Zählt Fallbacks bei /call-a-unstable")
            .tag("uri", "/call-a-unstable")
            .register(registry);
    }

    @Override
    @CircuitBreaker(name = "backendA", fallbackMethod = "fallbackA")
    public String callBackendA() {
        return restTemplate.getForObject(backendAUrl, String.class);
    }

    @Override
    @CircuitBreaker(name = "backendB", fallbackMethod = "fallbackB")
    public String callBackendB() {
        return restTemplate.getForObject(backendBUrl, String.class);
    }

    @Override
    @CircuitBreaker(name = "backendA", fallbackMethod = "fallbackUnstable")
    public String callUnstable() {
        return restTemplate.getForObject(unstableUrl, String.class);
    }

    public String fallbackA(Throwable t) {
        return "Circuit Breaker aktiv: Backend A ist nicht erreichbar.";
    }

    public String fallbackB(Throwable t) {
        return "Circuit Breaker aktiv: Backend B ist nicht erreichbar.";
    }

    public String fallbackUnstable(Throwable t) {
        // ZÄHLER ERHÖHEN:
        fallbackUnstableCounter.increment();

        log.warn("⚠️ Circuit Breaker aktiv: Weiterleitung an Backend B.");
        return restTemplate.getForObject(backendBUrl, String.class);
    }
}
