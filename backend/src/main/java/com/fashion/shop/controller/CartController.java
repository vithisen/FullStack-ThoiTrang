package com.fashion.shop.controller;

import com.fashion.shop.entity.Cart;
import com.fashion.shop.entity.CartItem;
import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.CartItemRepository;
import com.fashion.shop.repository.CartRepository;
import com.fashion.shop.repository.ProductRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customers/{customerId}/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final ApiMapper mapper;

    @GetMapping
    public Map<String, Object> cart(@PathVariable Long customerId) {
        Cart cart = getOrCreateCart(customerId);
        List<CartItem> items = cartItemRepository.findByCartId(cart.getId());
        BigDecimal total = items.stream()
            .map(item -> item.getProduct().getSalePrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<String, Object> data = new HashMap<>();
        data.put("cartId", cart.getId());
        data.put("items", items.stream().map(mapper::cartItem).toList());
        data.put("total", total);
        return data;
    }

    @PostMapping("/items")
    public Map<String, Object> addItem(@PathVariable Long customerId, @RequestBody Map<String, Object> request) {
        Cart cart = getOrCreateCart(customerId);
        Long productId = toLong(request.get("productId"));
        int quantity = request.get("quantity") == null ? 1 : Math.max(1, ((Number) request.get("quantity")).intValue());
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        String size = request.get("size") == null ? "L" : String.valueOf(request.get("size"));
        String color = request.get("color") == null ? "Black" : String.valueOf(request.get("color"));

        CartItem item = cartItemRepository.findByCartIdAndProductIdAndSizeAndColor(cart.getId(), productId, size, color)
            .map(existing -> {
                existing.setQuantity(existing.getQuantity() + quantity);
                existing.setSize(size);
                existing.setColor(color);
                return existing;
            })
            .orElse(CartItem.builder().cart(cart).product(product).quantity(quantity).size(size).color(color).build());

        return mapper.cartItem(cartItemRepository.save(item));
    }

    @PatchMapping("/items/{itemId}")
    public Map<String, Object> updateItem(@PathVariable Long customerId, @PathVariable Long itemId, @RequestBody Map<String, Object> request) {
        CartItem item = cartItemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));
        if (!item.getCart().getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Cart item does not belong to customer");
        }
        int quantity = Math.max(1, ((Number) request.get("quantity")).intValue());
        item.setQuantity(quantity);
        if (request.containsKey("size")) {
            item.setSize(String.valueOf(request.get("size")));
        }
        if (request.containsKey("color")) {
            item.setColor(String.valueOf(request.get("color")));
        }
        return mapper.cartItem(cartItemRepository.save(item));
    }

    @DeleteMapping("/items/{itemId}")
    public Map<String, String> deleteItem(@PathVariable Long customerId, @PathVariable Long itemId) {
        CartItem item = cartItemRepository.findById(itemId)
            .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));
        if (!item.getCart().getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Cart item does not belong to customer");
        }
        cartItemRepository.deleteById(itemId);
        return Map.of("message", "Cart item deleted");
    }

    private Cart getOrCreateCart(Long customerId) {
        return cartRepository.findByCustomerId(customerId).orElseGet(() -> {
            User user = userRepository.findById(customerId)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
            return cartRepository.save(Cart.builder().customer(user).build());
        });
    }

    private Long toLong(Object value) {
        if (value instanceof Number number) {
            return number.longValue();
        }
        return Long.parseLong(String.valueOf(value));
    }
}
