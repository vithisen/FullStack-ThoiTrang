package com.fashion.shop.repository;

import com.fashion.shop.entity.ProductShippingInfo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProductShippingInfoRepository extends JpaRepository<ProductShippingInfo, Long> {
    Optional<ProductShippingInfo> findByProductId(Long productId);
}
