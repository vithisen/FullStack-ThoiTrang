package com.fashion.shop.controller;

import com.fashion.shop.entity.CustomerAddress;
import com.fashion.shop.entity.Notification;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.CustomerAddressRepository;
import com.fashion.shop.repository.NotificationRepository;
import com.fashion.shop.repository.OrderRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.service.AuthService;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/customers")
@RequiredArgsConstructor
public class CustomerController {

    private final UserRepository userRepository;
    private final CustomerAddressRepository addressRepository;
    private final NotificationRepository notificationRepository;
    private final OrderRepository orderRepository;
    private final AuthService authService;
    private final ApiMapper mapper;

    @GetMapping("/{customerId}")
    public Map<String, Object> customer(@PathVariable Long customerId) {
        return mapper.user(findCustomer(customerId));
    }

    @PatchMapping("/{customerId}")
    public Map<String, Object> updateCustomer(@PathVariable Long customerId, @RequestBody Map<String, Object> request) {
        User user = findCustomer(customerId);
        if (request.containsKey("firstName")) {
            user.setFirstName((String) request.get("firstName"));
        }
        if (request.containsKey("lastName")) {
            user.setLastName((String) request.get("lastName"));
        }
        if (request.containsKey("phoneNumber")) {
            user.setPhoneNumber((String) request.get("phoneNumber"));
        }
        if (request.containsKey("salesNotify")) {
            user.setSalesNotify(toBoolean(request.get("salesNotify")));
        }
        if (request.containsKey("newArrivalsNotify")) {
            user.setNewArrivalsNotify(toBoolean(request.get("newArrivalsNotify")));
        }
        if (request.containsKey("deliveryNotify")) {
            user.setDeliveryNotify(toBoolean(request.get("deliveryNotify")));
        }
        user.setUpdatedAt(LocalDateTime.now());
        return mapper.user(userRepository.save(user));
    }

    @PatchMapping("/{customerId}/password")
    public Map<String, Object> updatePassword(@PathVariable Long customerId, @RequestBody Map<String, Object> request) {
        User user = findCustomer(customerId);
        String oldPassword = request.get("oldPassword") == null ? "" : String.valueOf(request.get("oldPassword"));
        String newPassword = request.get("newPassword") == null ? "" : String.valueOf(request.get("newPassword"));
        if (newPassword.isBlank()) {
            throw new IllegalArgumentException("New password is required");
        }
        if (!authService.passwordMatches(oldPassword, user)) {
            throw new IllegalArgumentException("Old password is incorrect");
        }
        user.setPasswordHash(authService.hashPassword(newPassword));
        user.setUpdatedAt(LocalDateTime.now());
        userRepository.save(user);
        return Map.of("message", "Password updated");
    }

    @GetMapping("/{customerId}/addresses")
    public List<Map<String, Object>> addresses(@PathVariable Long customerId) {
        return addressRepository.findByCustomerId(customerId).stream().map(mapper::address).toList();
    }

    @PostMapping("/{customerId}/addresses")
    public Map<String, Object> addAddress(@PathVariable Long customerId, @RequestBody CustomerAddress address) {
        User user = findCustomer(customerId);
        address.setCustomer(user);
        if (Boolean.TRUE.equals(address.getDefaultAddress())) {
            clearDefaultAddresses(customerId, null);
        }
        return mapper.address(addressRepository.save(address));
    }

    @PatchMapping("/{customerId}/addresses/{addressId}")
    public Map<String, Object> updateAddress(@PathVariable Long customerId, @PathVariable Long addressId, @RequestBody CustomerAddress request) {
        CustomerAddress address = addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found"));
        if (!address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }
        address.setFullName(request.getFullName());
        address.setAddressLine1(request.getAddressLine1());
        address.setAddressLine2(request.getAddressLine2());
        address.setPhoneNumber(request.getPhoneNumber());
        address.setCountry(request.getCountry());
        address.setPostalCode(request.getPostalCode());
        address.setCity(request.getCity());
        address.setDefaultAddress(request.getDefaultAddress());
        if (Boolean.TRUE.equals(request.getDefaultAddress())) {
            clearDefaultAddresses(customerId, addressId);
        }
        return mapper.address(addressRepository.save(address));
    }

    @DeleteMapping("/{customerId}/addresses/{addressId}")
    public Map<String, String> deleteAddress(@PathVariable Long customerId, @PathVariable Long addressId) {
        CustomerAddress address = addressRepository.findById(addressId)
            .orElseThrow(() -> new IllegalArgumentException("Address not found"));
        if (!address.getCustomer().getId().equals(customerId)) {
            throw new IllegalArgumentException("Address does not belong to customer");
        }
        orderRepository.findByShippingAddressId(addressId).forEach(order -> {
            order.setShippingAddress(null);
            orderRepository.save(order);
        });
        addressRepository.deleteById(addressId);
        return Map.of("message", "Address deleted");
    }

    @GetMapping("/{customerId}/notifications")
    public List<Map<String, Object>> notifications(@PathVariable Long customerId) {
        return notificationRepository.findByCustomerIdOrderByCreatedAtDesc(customerId).stream()
            .map(this::notification)
            .toList();
    }

    private Map<String, Object> notification(Notification notification) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", notification.getId());
        data.put("title", notification.getTitle());
        data.put("content", notification.getContent());
        data.put("seen", notification.getSeen());
        data.put("createdAt", notification.getCreatedAt());
        return data;
    }

    private User findCustomer(Long customerId) {
        return userRepository.findById(customerId)
            .orElseThrow(() -> new IllegalArgumentException("Customer not found"));
    }

    private Boolean toBoolean(Object value) {
        if (value instanceof Boolean bool) {
            return bool;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }

    private void clearDefaultAddresses(Long customerId, Long exceptAddressId) {
        List<CustomerAddress> addresses = addressRepository.findByCustomerId(customerId);
        addresses.stream()
            .filter(address -> exceptAddressId == null || !address.getId().equals(exceptAddressId))
            .forEach(address -> address.setDefaultAddress(false));
        addressRepository.saveAll(addresses);
    }
}
