package com.example.myservice;

import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@Profile("loadbalancer") 
public class LoadBalancedBackendCallerService implements BackendCaller {

    private final RestTemplate restTemplate;



    public LoadBalancedBackendCallerService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Override
    public String callBackendA() {
        System.out.println("➡️ LoadBalancer ruft auf: http://backend-a/data");
        return restTemplate.getForObject("http://backend-a/data", String.class);
    }
    
    @Override
    public String callBackendB() {
        return restTemplate.getForObject("http://backend-b/data", String.class);
    }
    
    @Override
    public String callUnstable() {
        return "RetryingBackendCallerService: /unstable wird in diesem Profil nicht verwendet.";
    }
}
