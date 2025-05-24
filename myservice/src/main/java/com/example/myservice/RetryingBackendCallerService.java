package com.example.myservice;

import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("retry")
public class ResilienceRetryingBackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    public ResilienceRetryingBackendCallerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Retry(name = "backendA", fallbackMethod = "recoverBackendA")
    public String callBackendA() {
        return restTemplate.getForObject(backendAUrl, String.class);
    }

    @Retry(name = "backendB", fallbackMethod = "recoverBackendB")
    public String callBackendB() {
        return restTemplate.getForObject(backendBUrl, String.class);
    }

    @Override
    public String callUnstable() {
        return "ResilienceRetryingBackendCallerService: /unstable wird in diesem Profil nicht verwendet.";
    }

    public String recoverBackendA(Throwable t) {
        return "❌ callBackendA fehlgeschlagen: " + t.getMessage();
    }

    public String recoverBackendB(Throwable t) {
        return "❌ callBackendB fehlgeschlagen: " + t.getMessage();
    }
}
