package com.example.myservice;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Recover;
import org.springframework.retry.annotation.Retryable;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class RetryWorker {

    private final Counter retryFailureCounter;

    public RetryWorker(MeterRegistry registry) {
        this.retryFailureCounter = Counter.builder("retry_failures_total")
            .description("Zählt interne Fehler (vor Retry) bei /call-a-unstable")
            .tag("uri", "/call-a-unstable")
            .register(registry);
    }

    @Retryable(
        value = { Exception.class },
        maxAttempts = 3,
        backoff = @Backoff(delay = 1000)
    )
    public String call(RestTemplate restTemplate, String url) {
        System.out.println("🔁 Versuch: " + url);
        return restTemplate.getForObject(url, String.class);
    }

    @Recover
    public String recover(Exception e) {
        System.out.println("🛑 Recover ausgelöst: " + e.getMessage());
        retryFailureCounter.increment(); // Jetzt zählt’s!
        return "❌ Retry gescheitert: " + e.getMessage();
    }
}
