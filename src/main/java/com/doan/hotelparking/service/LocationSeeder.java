package com.doan.hotelparking.service;

import com.doan.hotelparking.domain.entity.Province;
import com.doan.hotelparking.domain.entity.Ward;
import com.doan.hotelparking.repository.ProvinceRepository;
import com.doan.hotelparking.repository.WardRepository;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.Arrays;

@Component
public class LocationSeeder implements ApplicationRunner {
    private final ProvinceRepository provinces;
    private final WardRepository wards;
    private final ObjectMapper objectMapper;

    public LocationSeeder(ProvinceRepository provinces, WardRepository wards, ObjectMapper objectMapper) {
        this.provinces = provinces;
        this.wards = wards;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (provinces.count() > 0 && wards.count() > 0) {
            return;
        }
        try {
            var client = HttpClient.newHttpClient();
            var response = client.send(HttpRequest.newBuilder(URI.create("https://provinces.open-api.vn/api/v2/p/")).GET().build(),
                    HttpResponse.BodyHandlers.ofString());
            var provinceResponses = Arrays.asList(objectMapper.readValue(response.body(), ProvinceApiResponse[].class));
            for (var provinceResponse : provinceResponses) {
                var province = provinces.findAll().stream()
                        .filter(p -> provinceResponse.code().equals(p.getCode()))
                        .findFirst()
                        .orElseGet(() -> {
                            var created = new Province();
                            created.setName(provinceResponse.name());
                            created.setCode(provinceResponse.code());
                            created.setActive(true);
                            return provinces.save(created);
                        });
                seedWards(client, province, provinceResponse.code());
            }
        } catch (Exception ignored) {
            // Startup should not fail when the public location API is unavailable.
        }
    }

    private void seedWards(HttpClient client, Province province, String provinceCode) {
        try {
            var response = client.send(HttpRequest.newBuilder(
                            URI.create("https://provinces.open-api.vn/api/v2/p/" + provinceCode + "?depth=2")).GET().build(),
                    HttpResponse.BodyHandlers.ofString());
            var detail = objectMapper.readValue(response.body(), ProvinceDetailApiResponse.class);
            for (var wardResponse : detail.wards()) {
                var exists = wards.findByProvinceId(province.getId()).stream()
                        .anyMatch(w -> wardResponse.code().equals(w.getCode()));
                if (!exists) {
                    var ward = new Ward();
                    ward.setProvince(province);
                    ward.setName(wardResponse.name());
                    ward.setCode(wardResponse.code());
                    ward.setActive(true);
                    wards.save(ward);
                }
            }
        } catch (Exception ignored) {
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record ProvinceApiResponse(String code, String name) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record WardApiResponse(String code, String name) {
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record ProvinceDetailApiResponse(WardApiResponse[] wards) {
    }
}
