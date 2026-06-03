package com.doan.hotelparking.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.doan.hotelparking.service.AiChatProxyService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/ai-chat")
public class AiChatController {
    private final AiChatProxyService aiChat;

    public AiChatController(AiChatProxyService aiChat) {
        this.aiChat = aiChat;
    }

    @GetMapping("/health")
    public JsonNode health() {
        return aiChat.get("/health", null);
    }

    @PostMapping("/threads")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("isAuthenticated()")
    public JsonNode createThread(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                 @RequestBody(required = false) Map<String, Object> body) {
        return aiChat.post("/threads", authorization, body);
    }

    @GetMapping("/threads")
    @PreAuthorize("isAuthenticated()")
    public JsonNode listThreads(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization) {
        return aiChat.get("/threads", authorization);
    }

    @GetMapping("/threads/{threadId}")
    @PreAuthorize("isAuthenticated()")
    public JsonNode getThread(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                              @PathVariable String threadId) {
        return aiChat.get("/threads/" + aiChat.path(threadId), authorization);
    }

    @DeleteMapping("/threads/{threadId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("isAuthenticated()")
    public void deleteThread(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                             @PathVariable String threadId) {
        aiChat.delete("/threads/" + aiChat.path(threadId), authorization);
    }

    @GetMapping("/threads/{threadId}/messages")
    @PreAuthorize("isAuthenticated()")
    public JsonNode listMessages(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                 @PathVariable String threadId) {
        return aiChat.get("/threads/" + aiChat.path(threadId) + "/messages", authorization);
    }

    @PostMapping("/threads/{threadId}/messages")
    @PreAuthorize("isAuthenticated()")
    public JsonNode sendThreadMessage(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                                      @PathVariable String threadId,
                                      @RequestBody Map<String, Object> body) {
        return aiChat.post("/threads/" + aiChat.path(threadId) + "/messages", authorization, body);
    }

    @PostMapping("/chat")
    @PreAuthorize("isAuthenticated()")
    public JsonNode chat(@RequestHeader(HttpHeaders.AUTHORIZATION) String authorization,
                         @RequestBody Map<String, Object> body) {
        return aiChat.post("/chat", authorization, body);
    }
}
