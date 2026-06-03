package com.doan.hotelparking.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    @Bean
    public OpenAPI hotelBookingOpenApi() {
        var bearerScheme = new SecurityScheme()
                .name("Authorization")
                .type(SecurityScheme.Type.HTTP)
                .scheme("bearer")
                .bearerFormat("JWT");
        return new OpenAPI()
                .info(new Info()
                        .title("Hotel Booking API")
                        .version("v1")
                        .description("Spring Boot API compatible with the original .NET hotel booking backend."))
                .components(new Components().addSecuritySchemes("Bearer", bearerScheme))
                .addSecurityItem(new SecurityRequirement().addList("Bearer"));
    }
}
