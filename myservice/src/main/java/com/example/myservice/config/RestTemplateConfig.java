package com.example.myservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;

@Configuration
public class RestTemplateConfig {

    @Bean
    @LoadBalanced
    @Profile("loadbalancer")
    public RestTemplate loadBalancedRestTemplate() {
        return new RestTemplate();
    }

    @Bean
    @Profile({"default", "retry", "circuitbreaker"})
    public RestTemplate defaultRestTemplate() {
        return new RestTemplate();
    }
}
