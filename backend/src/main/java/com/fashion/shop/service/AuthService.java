package com.fashion.shop.service;

import com.fashion.shop.entity.User;

public interface AuthService {
    User register(User user);

    User login(String email, String password);

    String hashPassword(String rawPassword);

    boolean passwordMatches(String rawPassword, User user);
}
