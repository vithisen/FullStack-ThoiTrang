package com.fashion.shop.repository;

import com.fashion.shop.entity.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {
    List<ProductReview> findByProductId(Long productId);

    Optional<ProductReview> findByCustomerIdAndProductId(Long customerId, Long productId);
}
