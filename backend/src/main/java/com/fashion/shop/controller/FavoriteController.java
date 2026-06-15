package com.fashion.shop.controller;

import com.fashion.shop.entity.Favorite;
import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.FavoriteRepository;
import com.fashion.shop.repository.ProductRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customers/{customerId}/favorites")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteRepository favoriteRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final ApiMapper mapper;

    @GetMapping
    public List<Map<String, Object>> favorites(@PathVariable Long customerId) {
        return favoriteRepository.findByCustomerId(customerId).stream()
            .filter(favorite -> Boolean.TRUE.equals(favorite.getProduct().getPublished()))
            .map(favorite -> mapper.product(favorite.getProduct()))
            .toList();
    }

    @PostMapping
    public Map<String, Object> addFavorite(@PathVariable Long customerId, @RequestBody Map<String, Object> request) {
        Long productId = ((Number) request.get("productId")).longValue();
        Favorite favorite = favoriteRepository.findByCustomerIdAndProductId(customerId, productId)
            .orElseGet(() -> {
                User user = userRepository.findById(customerId)
                    .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
                Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new IllegalArgumentException("Product not found"));
                if (!Boolean.TRUE.equals(product.getPublished())) {
                    throw new IllegalArgumentException("Product not available");
                }
                return favoriteRepository.save(Favorite.builder().customer(user).product(product).build());
            });
        return mapper.product(favorite.getProduct());
    }

    @DeleteMapping("/{productId}")
    public Map<String, String> removeFavorite(@PathVariable Long customerId, @PathVariable Long productId) {
        favoriteRepository.findByCustomerIdAndProductId(customerId, productId)
            .ifPresent(favoriteRepository::delete);
        return Map.of("message", "Favorite removed");
    }
}
