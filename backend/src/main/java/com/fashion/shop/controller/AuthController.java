package com.fashion.shop.controller;

import com.fashion.shop.entity.User;
import com.fashion.shop.entity.Cart;
import com.fashion.shop.repository.CartRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody User user) {
        User savedUser = authService.register(user);
        return ResponseEntity.status(HttpStatus.CREATED).body(toAuthResponse(savedUser, "Register successfully"));
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody User user) {
        User loggedInUser = authService.login(user.getEmail(), user.getPasswordHash());
        return ResponseEntity.ok(toAuthResponse(loggedInUser, "Login successfully"));
    }

    @PostMapping("/google")
    public ResponseEntity<Map<String, Object>> googleLogin(@RequestBody Map<String, Object> request) {
        User user = socialLogin(request, "GOOGLE", true);
        return ResponseEntity.ok(toAuthResponse(user, "Google login successfully"));
    }

    @PostMapping("/facebook")
    public ResponseEntity<Map<String, Object>> facebookLogin(@RequestBody Map<String, Object> request) {
        User user = socialLogin(request, "FACEBOOK", false);
        return ResponseEntity.ok(toAuthResponse(user, "Facebook login successfully"));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, Object> request) {
        String email = request.get("email") == null ? "" : String.valueOf(request.get("email")).trim().toLowerCase();
        if (email.isBlank() || !email.contains("@")) {
            throw new IllegalArgumentException("Valid email is required");
        }
        if (!userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email not found");
        }
        return ResponseEntity.ok(Map.of(
            "message", "Password reset link sent",
            "email", email
        ));
    }

    private String stringValue(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private String[] splitName(String displayName) {
        if (displayName == null || displayName.isBlank()) {
            return new String[] {"Google", "User"};
        }
        String[] parts = displayName.trim().split("\\s+");
        if (parts.length == 1) {
            return new String[] {parts[0], ""};
        }
        String firstName = parts[0];
        String lastName = String.join(" ", java.util.Arrays.copyOfRange(parts, 1, parts.length));
        return new String[] {firstName, lastName};
    }

    private User socialLogin(Map<String, Object> request, String provider, boolean requireEmail) {
        String email = stringValue(request.get("email")).trim().toLowerCase();
        String displayName = stringValue(request.get("displayName")).trim();
        String firebaseUid = stringValue(request.get("firebaseUid")).trim();

        if ((email.isBlank() || !email.contains("@")) && requireEmail) {
            throw new IllegalArgumentException("Valid " + provider.toLowerCase() + " email is required");
        }
        if (email.isBlank() || !email.contains("@")) {
            if (firebaseUid.isBlank()) {
                throw new IllegalArgumentException(provider + " account id is required");
            }
            email = firebaseUid + "@" + provider.toLowerCase() + ".local";
        }

        String normalizedEmail = email;
        User user = userRepository.findByEmail(normalizedEmail).orElseGet(() -> {
            String[] nameParts = splitName(displayName);
            User socialUser = User.builder()
                .firstName(nameParts[0])
                .lastName(nameParts[1])
                .email(normalizedEmail)
                .passwordHash(authService.hashPassword(provider + ":" + (firebaseUid.isBlank() ? normalizedEmail : firebaseUid)))
                .active(true)
                .salesNotify(true)
                .newArrivalsNotify(false)
                .deliveryNotify(false)
                .registeredAt(java.time.LocalDateTime.now())
                .build();
            User saved = userRepository.save(socialUser);
            cartRepository.save(Cart.builder().customer(saved).build());
            return saved;
        });

        if (Boolean.FALSE.equals(user.getActive())) {
            throw new IllegalArgumentException("Account is disabled");
        }

        cartRepository.findByCustomerId(user.getId())
            .orElseGet(() -> cartRepository.save(Cart.builder().customer(user).build()));
        return user;
    }

    private Map<String, Object> toAuthResponse(User user, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", message);
        response.put("id", user.getId());
        response.put("firstName", user.getFirstName());
        response.put("lastName", user.getLastName());
        response.put("email", user.getEmail());
        response.put("phoneNumber", user.getPhoneNumber());
        return response;
    }
}
