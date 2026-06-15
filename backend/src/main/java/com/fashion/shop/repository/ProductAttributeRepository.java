package com.fashion.shop.repository;

import com.fashion.shop.entity.ProductAttribute;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProductAttributeRepository extends JpaRepository<ProductAttribute, Long> {
    Optional<ProductAttribute> findByAttributeName(String attributeName);
}
