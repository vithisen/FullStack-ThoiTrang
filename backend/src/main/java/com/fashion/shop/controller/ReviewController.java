package com.fashion.shop.controller;

import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.ProductReview;
import com.fashion.shop.entity.ReviewImage;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.ProductRepository;
import com.fashion.shop.repository.ProductReviewRepository;
import com.fashion.shop.repository.ReviewImageRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/products/{productId}/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ProductReviewRepository reviewRepository;
    private final ReviewImageRepository reviewImageRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final ApiMapper mapper;

    @GetMapping
    public List<Map<String, Object>> reviews(@PathVariable Long productId) {
        return reviewRepository.findByProductId(productId).stream().map(mapper::review).toList();
    }

    @PostMapping
    public Map<String, Object> createReview(
        @PathVariable Long productId,
        @RequestBody Map<String, Object> request
    ) {
        Long customerId = ((Number) request.getOrDefault("customerId", 2)).longValue();
        Product product = productRepository.findById(productId)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        User customer = userRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found"));

        ProductReview review = reviewRepository.findByCustomerIdAndProductId(customerId, productId)
            .orElse(ProductReview.builder().customer(customer).product(product).createdAt(LocalDateTime.now()).build());
        review.setRating(((Number) request.get("rating")).intValue());
        review.setComment((String) request.get("comment"));
        ProductReview saved = reviewRepository.save(review);

        Object images = request.get("images");
        if (images instanceof List<?> imageList) {
            reviewImageRepository.findByReviewId(saved.getId()).forEach(reviewImageRepository::delete);
            imageList.stream()
                .map(String::valueOf)
                .filter(image -> !image.isBlank())
                .forEach(image -> reviewImageRepository.save(ReviewImage.builder().review(saved).image(image).build()));
        }

        return mapper.review(saved);
    }
}
