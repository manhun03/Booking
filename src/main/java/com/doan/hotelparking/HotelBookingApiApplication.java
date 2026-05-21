package com.doan.hotelparking;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class HotelBookingApiApplication {
    public static void main(String[] args) {
        SpringApplication.run(HotelBookingApiApplication.class, args);
    }
}
