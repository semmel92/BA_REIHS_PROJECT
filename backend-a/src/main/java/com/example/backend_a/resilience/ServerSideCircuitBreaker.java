package com.example.backend_a.resilience;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.concurrent.atomic.AtomicInteger;

@Component
@Profile("serverbreaker")
public class ServerSideCircuitBreaker {

    private final AtomicInteger failureCount = new AtomicInteger(0);
    private final int threshold = 5;
    private final Duration openDuration = Duration.ofSeconds(10);
    private volatile Instant lastFailureTime = Instant.EPOCH;
    private volatile boolean open = false;

    public synchronized boolean isOpen() {
        if (open && Duration.between(lastFailureTime, Instant.now()).compareTo(openDuration) > 0) {
            open = false;
            failureCount.set(0);
        }
        return open;
    }

    public synchronized void recordFailure() {
        lastFailureTime = Instant.now();
        if (failureCount.incrementAndGet() >= threshold) {
            open = true;
        }
    }

    public synchronized void recordSuccess() {
        failureCount.set(0);
        open = false;
    }
}
