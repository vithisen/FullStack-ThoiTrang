package com.fashion.shop.repository;

import com.fashion.shop.entity.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderRepository extends JpaRepository<Order, Long> {
    List<Order> findByCustomerId(Long customerId);

    List<Order> findByShippingAddressId(Long shippingAddressId);
}
