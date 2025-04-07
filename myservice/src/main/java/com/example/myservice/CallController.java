package com.example.myservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CallController {

    private final BackendCaller backendCaller;
    private static final Logger log = LoggerFactory.getLogger(CallController.class);

    public CallController(BackendCaller backendCaller) {
        this.backendCaller = backendCaller;
    }

    @GetMapping("/call-a")
    public String callBackendA() {
        log.info("➡️ Anfrage an Backend A");
        return backendCaller.callBackendA();
    }

    @GetMapping("/call-b")
    public String callBackendB() {
        log.info("➡️ Anfrage an Backend B");
        return backendCaller.callBackendB();
    }
}
