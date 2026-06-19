package com.fashion.shop.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/client-events")
@CrossOrigin(origins = "*", maxAge = 3600)
public class ClientEventController {
    private static final Logger log = LoggerFactory.getLogger(ClientEventController.class);

    @PostMapping
    public ResponseEntity<Void> logEvent(@RequestBody Map<String, Object> payload) {
        log.info("[CLIENT_EVENT] Action: {} | Reason: {} | UserId: {}", 
            payload.get("action"), payload.get("reason"), payload.get("userId"));
        return ResponseEntity.ok().build();
    }
}
