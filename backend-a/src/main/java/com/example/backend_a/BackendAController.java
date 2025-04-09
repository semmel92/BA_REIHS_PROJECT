package com.example.backend_a;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class BackendAController {

    @Value("${info.instance}")
    private String instance;

    @GetMapping("/data")
    public String getData() {
        return "Antwort von " + instance;
    }
}
