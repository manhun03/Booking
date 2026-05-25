package com.doan.hotelparking.config;

import com.doan.hotelparking.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.http.HttpMethod;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http, JwtAuthenticationFilter jwtAuthenticationFilter) throws Exception {
        return http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> {})
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers("/api/auth/**", "/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html", "/actuator/health", "/api/ai-chat/health", "/uploads/**", "/ws/**", "/ws-sockjs/**").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/hotels", "/api/hotels/*", "/api/hotels/*/images", "/api/hotels/*/images/ordered").permitAll()
                        .requestMatchers("/api/hotels/search", "/api/hotels/by-province", "/api/hotels/all-with-province", "/api/hotels/*/with-location").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/provinces/**", "/api/wards/**").permitAll()
                        .requestMatchers("/api/recommendations/similar/**", "/api/recommendations/new-user", "/api/recommendations/smart").permitAll()
                        .requestMatchers("/api/rooms/by-hotel", "/api/rooms/by-room-type", "/api/room-types/by-hotel").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/reviews/by-hotel/**", "/api/time-slots/room/**", "/api/time-slots/hotel/**").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/payments/webhook").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/payments/vnpay-return").permitAll()
                        .anyRequest().authenticated())
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        var configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(false);
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
