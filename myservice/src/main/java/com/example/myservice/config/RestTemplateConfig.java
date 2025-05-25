package com.example.myservice.config;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;

import java.util.Collections;

@Configuration
public class RestTemplateConfig {

    @Bean
    @LoadBalanced
    @Profile("loadbalancer")
    public RestTemplate loadBalancedRestTemplate(MeterRegistry registry) {
        return createInstrumentedRestTemplate(registry);
    }

    @Bean
    @Profile({"default", "retry", "circuitbreaker", "serverbreaker", "serverdefault"})
    public RestTemplate defaultRestTemplate(MeterRegistry registry) {
        return createInstrumentedRestTemplate(registry);
    }

    private RestTemplate createInstrumentedRestTemplate(MeterRegistry registry) {
        RestTemplate restTemplate = new RestTemplate();
        restTemplate.setInterceptors(Collections.singletonList((request, body, execution) -> {
            Timer.Sample sample = Timer.start(registry);
            try {
                return execution.execute(request, body);
            } finally {
                sample.stop(Timer.builder("http.client.reaktionszeit")
                    .description("Reaktionszeit aus Sicht von myservice")
                    .publishPercentileHistogram()
                    .tag("uri", request.getURI().getPath())
                    .tag("method", request.getMethod().name())
                    .register(registry)
                );
            }
        }));
        return restTemplate;
    }
}