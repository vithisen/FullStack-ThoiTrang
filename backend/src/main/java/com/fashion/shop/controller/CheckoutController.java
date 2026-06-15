package com.fashion.shop.controller;

import com.fashion.shop.entity.Coupon;
import com.fashion.shop.repository.CouponRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/coupons")
@RequiredArgsConstructor
public class CheckoutController {

    private final CouponRepository couponRepository;

    @GetMapping
    public List<Map<String, Object>> coupons() {
        return couponRepository.findAll().stream().map(this::coupon).toList();
    }

    @GetMapping("/{code}")
    public Map<String, Object> coupon(@PathVariable String code) {
        Coupon coupon = couponRepository.findByCode(code)
            .orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
        return coupon(coupon);
    }

    private Map<String, Object> coupon(Coupon coupon) {
        boolean active = coupon.getCouponStartDate() == null || coupon.getCouponStartDate().isBefore(LocalDateTime.now());
        active = active && (coupon.getCouponEndDate() == null || coupon.getCouponEndDate().isAfter(LocalDateTime.now()));

        Map<String, Object> data = new HashMap<>();
        data.put("id", coupon.getId());
        data.put("code", coupon.getCode());
        data.put("discountValue", coupon.getDiscountValue());
        data.put("discountType", coupon.getDiscountType());
        data.put("maxUsage", coupon.getMaxUsage());
        data.put("couponStartDate", coupon.getCouponStartDate());
        data.put("couponEndDate", coupon.getCouponEndDate());
        data.put("active", active);
        return data;
    }
}
