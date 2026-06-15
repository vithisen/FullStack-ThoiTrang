package com.fashion.shop.repository;

import com.fashion.shop.entity.ProductCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductCategoryRepository extends JpaRepository<ProductCategory, Long> {
    List<ProductCategory> findByCategoryId(Long categoryId);

    List<ProductCategory> findByProductId(Long productId);

    Optional<ProductCategory> findByProductIdAndCategoryId(Long productId, Long categoryId);
}
