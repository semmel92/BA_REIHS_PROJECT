package com.example.myservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("loadbalancer") 
public class LoadBalancedBackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;

    @Value("${backend.a.url}")
    private String backendAUrl;

    @Value("${backend.b.url}")
    private String backendBUrl;

    public LoadBalancedBackendCallerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public String callBackendA() {
        return restTemplate.getForObject("http://backend-a/data", String.class);
    }

    @Override
    public String callBackendB() {
        return restTemplate.getForObject(backendBUrl, String.class);
    }
}
