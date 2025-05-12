package com.example.myservice;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CircuitBreakerTestController {

    private final BackendCaller caller;

    public CircuitBreakerTestController(BackendCaller caller) {
        this.caller = caller;
    }

    @GetMapping("/test/fallback")
    public String testFallback() {
        return caller.callUnstable();
    }
}
