package com.doan.hotelparking.security;

import com.doan.hotelparking.service.JwtService;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.stereotype.Component;

@Component
public class WebSocketAuthChannelInterceptor implements ChannelInterceptor {
    private final JwtService jwtService;

    public WebSocketAuthChannelInterceptor(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        var accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if (accessor == null || accessor.getCommand() != StompCommand.CONNECT) {
            return message;
        }

        var token = bearerToken(accessor);
        if (token == null || token.isBlank()) {
            throw new AccessDeniedException("Missing WebSocket Authorization header");
        }

        var jwtPrincipal = jwtService.parse(token);
        var principal = new WebSocketPrincipal(jwtPrincipal.userId(), jwtPrincipal.email(), jwtPrincipal.roles());
        var authorities = principal.roles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role))
                .toList();
        accessor.setUser(new UsernamePasswordAuthenticationToken(principal, null, authorities));
        return message;
    }

    private String bearerToken(StompHeaderAccessor accessor) {
        var authorization = firstNativeHeader(accessor, "Authorization");
        if (authorization == null) {
            authorization = firstNativeHeader(accessor, "authorization");
        }
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return firstNativeHeader(accessor, "access_token");
    }

    private String firstNativeHeader(StompHeaderAccessor accessor, String name) {
        var values = accessor.getNativeHeader(name);
        return values == null || values.isEmpty() ? null : values.get(0);
    }
}
