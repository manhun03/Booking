package com.doan.hotelparking.security;

import java.security.Principal;
import java.util.List;

public record WebSocketPrincipal(Integer userId, String email, List<String> roles) implements Principal {
    @Override
    public String getName() {
        return userId.toString();
    }
}
