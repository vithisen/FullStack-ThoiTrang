package com.fashion.shop.controller;

import com.fashion.shop.entity.Cart;
import com.fashion.shop.entity.CartItem;
import com.fashion.shop.entity.CustomerAddress;
import com.fashion.shop.entity.Coupon;
import com.fashion.shop.entity.Order;
import com.fashion.shop.entity.OrderItem;
import com.fashion.shop.entity.OrderStatus;
import com.fashion.shop.entity.ShippingMethod;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.CartItemRepository;
import com.fashion.shop.repository.CartRepository;
import com.fashion.shop.repository.CouponRepository;
import com.fashion.shop.repository.CustomerAddressRepository;
import com.fashion.shop.repository.OrderItemRepository;
import com.fashion.shop.repository.OrderRepository;
import com.fashion.shop.repository.OrderStatusRepository;
import com.fashion.shop.repository.ShippingMethodRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class OrderController {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final UserRepository userRepository;
    private final CustomerAddressRepository addressRepository;
    private final CouponRepository couponRepository;
    private final ShippingMethodRepository shippingMethodRepository;
    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ApiMapper mapper;

    @GetMapping("/customers/{customerId}/orders")
    public List<Map<String, Object>> orders(@PathVariable Long customerId) {
        return orderRepository.findByCustomerId(customerId).stream().map(mapper::order).toList();
    }

    @GetMapping("/orders/{orderId}")
    public Map<String, Object> order(@PathVariable Long orderId) {
        return mapper.order(orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found")));
    }

    @PostMapping("/customers/{customerId}/orders")
    public Map<String, Object> createOrder(@PathVariable Long customerId, @RequestBody Map<String, Object> request) {
        User customer = userRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
        Long addressId = request.get("addressId") == null ? null : ((Number) request.get("addressId")).longValue();
        CustomerAddress address = addressId == null ? null : addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found"));
        if (address != null && !address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }
        String couponCode = request.get("couponCode") == null ? null : String.valueOf(request.get("couponCode")).trim();
        Coupon coupon = couponCode == null || couponCode.isBlank() ? null : couponRepository.findByCode(couponCode)
            .orElseThrow(() -> new IllegalArgumentException("Coupon not found"));
        if (coupon != null && !couponActive(coupon)) {
            throw new IllegalArgumentException("Coupon is not active");
        }
        Long shippingMethodId = request.get("shippingMethodId") == null ? null : ((Number) request.get("shippingMethodId")).longValue();
        ShippingMethod shippingMethod = shippingMethodId == null ? null : shippingMethodRepository.findById(shippingMethodId)
            .orElseThrow(() -> new IllegalArgumentException("Shipping method not found"));
        if (shippingMethod != null && Boolean.FALSE.equals(shippingMethod.getActive())) {
            throw new IllegalArgumentException("Shipping method is inactive");
        }
        OrderStatus status = orderStatusRepository.findAll().stream()
            .filter(item -> "Processing".equalsIgnoreCase(item.getStatusName()))
            .findFirst()
            .orElseGet(() -> orderStatusRepository.save(OrderStatus.builder().statusName("Processing").color("#DB3022").build()));

        Cart cart = cartRepository.findByCustomerId(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Cart not found"));
        List<CartItem> cartItems = cartItemRepository.findByCartId(cart.getId());
        if (cartItems.isEmpty()) {
            throw new IllegalArgumentException("Cart is empty");
        }

        BigDecimal subtotal = cartItems.stream()
            .map(item -> item.getProduct().getSalePrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal discountAmount = calculateDiscount(subtotal, coupon);
        BigDecimal shippingFee = shippingMethod == null ? BigDecimal.ZERO : shippingMethod.getPrice();
        BigDecimal total = subtotal.subtract(discountAmount).add(shippingFee);

        Order order = orderRepository.save(Order.builder()
            .orderNumber("ORD-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
            .customer(customer)
            .orderStatus(status)
            .shippingAddress(address)
            .coupon(coupon)
            .shippingMethod(shippingMethod)
            .trackingNumber("TRK" + System.currentTimeMillis())
            .subtotal(subtotal)
            .discountAmount(discountAmount)
            .shippingFee(shippingFee)
            .orderTotal(total)
            .createdAt(LocalDateTime.now())
            .build());

        cartItems.forEach(item -> orderItemRepository.save(OrderItem.builder()
            .order(order)
            .product(item.getProduct())
            .price(item.getProduct().getSalePrice())
            .size(item.getSize())
            .color(item.getColor())
            .quantity(item.getQuantity())
            .build()));
        cartItemRepository.deleteAll(cartItems);

        return mapper.order(order);
    }

    @PostMapping("/customers/{customerId}/orders/{orderId}/reorder")
    public Map<String, Object> reorder(@PathVariable Long customerId, @PathVariable Long orderId) {
        User customer = userRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
        Order order = orderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        if (!order.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Order does not belong to customer");
        }
        Cart cart = cartRepository.findByCustomerId(customerId)
            .orElseGet(() -> cartRepository.save(Cart.builder().customer(customer).build()));

        orderItemRepository.findByOrderId(orderId).forEach(orderItem -> {
            String size = orderItem.getSize() == null ? "L" : orderItem.getSize();
            String color = orderItem.getColor() == null ? "Black" : orderItem.getColor();
            CartItem cartItem = cartItemRepository.findByCartIdAndProductIdAndSizeAndColor(
                    cart.getId(),
                    orderItem.getProduct().getId(),
                    size,
                    color
                )
                .map(existing -> {
                    existing.setQuantity(existing.getQuantity() + orderItem.getQuantity());
                    return existing;
                })
                .orElse(CartItem.builder()
                    .cart(cart)
                    .product(orderItem.getProduct())
                    .size(size)
                    .color(color)
                    .quantity(orderItem.getQuantity())
                    .build());
            cartItemRepository.save(cartItem);
        });

        return mapper.order(order);
    }

    private boolean couponActive(Coupon coupon) {
        LocalDateTime now = LocalDateTime.now();
        boolean active = coupon.getCouponStartDate() == null || coupon.getCouponStartDate().isBefore(now);
        return active && (coupon.getCouponEndDate() == null || coupon.getCouponEndDate().isAfter(now));
    }

    private BigDecimal calculateDiscount(BigDecimal subtotal, Coupon coupon) {
        if (coupon == null) {
            return BigDecimal.ZERO;
        }
        if ("PERCENT".equalsIgnoreCase(coupon.getDiscountType())) {
            return subtotal.multiply(coupon.getDiscountValue()).divide(BigDecimal.valueOf(100));
        }
        return coupon.getDiscountValue().min(subtotal);
    }
}
