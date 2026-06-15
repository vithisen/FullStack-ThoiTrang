package com.fashion.shop.repository;

import com.fashion.shop.entity.ProductTag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ProductTagRepository extends JpaRepository<ProductTag, Long> {
    List<ProductTag> findByProductId(Long productId);

    Optional<ProductTag> findByProductIdAndTagId(Long productId, Long tagId);
}
