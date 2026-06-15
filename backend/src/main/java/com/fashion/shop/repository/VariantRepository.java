package com.fashion.shop.repository;

import com.fashion.shop.entity.Variant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VariantRepository extends JpaRepository<Variant, Long> {
    List<Variant> findByProductId(Long productId);
}
