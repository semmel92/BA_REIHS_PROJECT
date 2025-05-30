package com.example.myservice;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("retry")
@EnableRetry
public class RetryingBackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;
    private final RetryWorker retryWorker;
    private final Counter retryUnstableCounter;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    @Value("${backend.a.unstableUrl}")
    private String unstableUrl;

    public RetryingBackendCallerService(RestTemplate restTemplate, RetryWorker retryWorker, MeterRegistry registry) {
        this.restTemplate = restTemplate;
        this.retryWorker = retryWorker;
        this.retryUnstableCounter = Counter.builder("retry_total")
            .description("Zählt fehlgeschlagene Retry-Ketten bei /call-a-unstable")
            .tag("uri", "/call-a-unstable")
            .register(registry);
    }

    @Override
    public String callBackendA() {
        return retryWorker.call(restTemplate, backendAUrl);
    }

    @Override
    public String callBackendB() {
        return retryWorker.call(restTemplate, backendBUrl);
    }

    @Override
    public String callUnstable() {
        try {
            return retryWorker.call(restTemplate, unstableUrl);
        } catch (Exception e) {
            retryUnstableCounter.increment();
            return "Instabiles Backend (A) nicht verfügbar: " + e.getMessage();
        }
    }
}
