package com.example.backend_a;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class BackendAController {

    @GetMapping("/data")
    public String getData() {
        return "Antwort von Backend A";
    }
}
