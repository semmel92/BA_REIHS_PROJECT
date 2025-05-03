package com.example.myservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("default")
public class BackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    @Value("${backend.a.unstableUrl}")
    private String unstableUrl;
    
    public BackendCallerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String callBackendA() {
        return restTemplate.getForObject(backendAUrl, String.class);
    }

    public String callBackendB() {
        return restTemplate.getForObject(backendBUrl, String.class);
    }

    public String callUnstable() {
    return restTemplate.getForObject(unstableUrl, String.class);
}
}
