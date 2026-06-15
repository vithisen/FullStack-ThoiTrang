package com.fashion.shop.repository;

import com.fashion.shop.entity.Brand;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface BrandRepository extends JpaRepository<Brand, Long> {
    List<Brand> findByActiveTrue();

    Optional<Brand> findByBrandName(String brandName);
}
