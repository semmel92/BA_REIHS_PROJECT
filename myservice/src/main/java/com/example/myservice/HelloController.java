package com.example.myservice;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

    private final BackendCaller backendCaller;

    public HelloController(BackendCaller backendCaller) {
        this.backendCaller = backendCaller;
    }

    @GetMapping("/hello")
    public String hello() {
        return "Hello from MyService!";
    }

    @GetMapping("/unstable")
    public ResponseEntity<String> unstable() {
        String result = backendCaller.callUnstable();

        if (result.startsWith("Circuit Breaker aktiv")) {
            return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE).body(result);
        }

        return ResponseEntity.ok(result);
    }
}