package com.example.myservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.EnableRetry;
import org.springframework.retry.annotation.Recover;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("retry") 
@EnableRetry
public class RetryingBackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    public RetryingBackendCallerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Retryable(maxAttempts = 3, backoff = @Backoff(delay = 1000))
    public String callBackendA() {
        return restTemplate.getForObject(backendAUrl, String.class);
    }

    @Retryable(maxAttempts = 3, backoff = @Backoff(delay = 1000))
    public String callBackendB() {
        return restTemplate.getForObject(backendBUrl, String.class);
    }

    @Override
    public String callUnstable() {
        return "RetryingBackendCallerService: /unstable wird in diesem Profil nicht verwendet.";
    }

    @Recover
    public String recoverBackend(Exception e) {
        return "❌ Backend konnte nicht erreicht werden: " + e.getMessage();
    }
}
