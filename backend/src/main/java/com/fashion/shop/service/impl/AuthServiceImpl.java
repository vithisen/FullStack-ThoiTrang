package com.fashion.shop.service.impl;

import com.fashion.shop.entity.Cart;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.CartRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final CartRepository cartRepository;

    @Override
    public User register(User user) {
        if (user.getEmail() == null || user.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (user.getPasswordHash() == null || user.getPasswordHash().isBlank()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        user.setEmail(user.getEmail().trim().toLowerCase());
        user.setPasswordHash(hashPassword(user.getPasswordHash()));
        user.setActive(true);
        user.setSalesNotify(user.getSalesNotify() == null ? true : user.getSalesNotify());
        user.setNewArrivalsNotify(user.getNewArrivalsNotify() == null ? false : user.getNewArrivalsNotify());
        user.setDeliveryNotify(user.getDeliveryNotify() == null ? false : user.getDeliveryNotify());
        user.setRegisteredAt(LocalDateTime.now());

        User savedUser = userRepository.save(user);
        cartRepository.save(Cart.builder().customer(savedUser).build());

        return savedUser;
    }

    @Override
    public User login(String email, String password) {
        if (email == null || password == null) {
            throw new IllegalArgumentException("Email and password are required");
        }

        User user = userRepository.findByEmail(email.trim().toLowerCase())
            .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        if (!passwordMatches(password, user)) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        if (Boolean.FALSE.equals(user.getActive())) {
            throw new IllegalArgumentException("Account is disabled");
        }

        return user;
    }

    @Override
    public boolean passwordMatches(String rawPassword, User user) {
        return user != null && hashPassword(rawPassword).equals(user.getPasswordHash());
    }

    @Override
    public String hashPassword(String rawPassword) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedHash = digest.digest(rawPassword.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder();
            for (byte value : encodedHash) {
                String hexValue = Integer.toHexString(0xff & value);
                if (hexValue.length() == 1) {
                    hex.append('0');
                }
                hex.append(hexValue);
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("Cannot hash password", exception);
        }
    }
}
