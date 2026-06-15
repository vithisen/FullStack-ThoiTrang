package com.fashion.shop.util;

import com.fashion.shop.entity.Brand;
import com.fashion.shop.entity.CartItem;
import com.fashion.shop.entity.Category;
import com.fashion.shop.entity.CustomerAddress;
import com.fashion.shop.entity.GalleryImage;
import com.fashion.shop.entity.Order;
import com.fashion.shop.entity.OrderItem;
import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.ProductAttribute;
import com.fashion.shop.entity.ProductReview;
import com.fashion.shop.entity.Slideshow;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.AttributeValueRepository;
import com.fashion.shop.repository.GalleryImageRepository;
import com.fashion.shop.repository.OrderItemRepository;
import com.fashion.shop.repository.ProductAttributeRepository;
import com.fashion.shop.repository.ProductCategoryRepository;
import com.fashion.shop.repository.ProductReviewRepository;
import com.fashion.shop.repository.ProductTagRepository;
import com.fashion.shop.repository.ReviewImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class ApiMapper {

    private final GalleryImageRepository galleryImageRepository;
    private final ReviewImageRepository reviewImageRepository;
    private final OrderItemRepository orderItemRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final ProductAttributeRepository productAttributeRepository;
    private final AttributeValueRepository attributeValueRepository;
    private final ProductReviewRepository productReviewRepository;
    private final ProductTagRepository productTagRepository;

    public Map<String, Object> user(User user) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("firstName", user.getFirstName());
        data.put("lastName", user.getLastName());
        data.put("email", user.getEmail());
        data.put("phoneNumber", user.getPhoneNumber());
        data.put("active", user.getActive());
        data.put("salesNotify", user.getSalesNotify());
        data.put("newArrivalsNotify", user.getNewArrivalsNotify());
        data.put("deliveryNotify", user.getDeliveryNotify());
        return data;
    }

    public Map<String, Object> category(Category category) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", category.getId());
        data.put("parentId", category.getParent() == null ? null : category.getParent().getId());
        data.put("categoryName", category.getCategoryName());
        data.put("categoryDescription", category.getCategoryDescription());
        data.put("icon", category.getIcon());
        data.put("image", category.getImage());
        return data;
    }

    public Map<String, Object> brand(Brand brand) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", brand.getId());
        data.put("brandName", brand.getBrandName());
        data.put("logo", brand.getLogo());
        return data;
    }

    public Map<String, Object> product(Product product) {
        List<GalleryImage> images = galleryImageRepository.findByProductId(product.getId());
        String thumbnail = images.stream()
            .filter(image -> Boolean.TRUE.equals(image.getThumbnail()))
            .findFirst()
            .or(() -> images.stream().findFirst())
            .map(GalleryImage::getImage)
            .orElse(null);

        Map<String, Object> data = new HashMap<>();
        data.put("id", product.getId());
        data.put("slug", product.getSlug());
        data.put("productName", product.getProductName());
        data.put("brandId", product.getBrand() == null ? null : product.getBrand().getId());
        data.put("brandName", product.getBrand() == null ? null : product.getBrand().getBrandName());
        data.put("sku", product.getSku());
        data.put("salePrice", product.getSalePrice());
        data.put("comparePrice", product.getComparePrice());
        data.put("quantity", product.getQuantity());
        data.put("shortDescription", product.getShortDescription());
        data.put("productDescription", product.getProductDescription());
        data.put("productType", product.getProductType());
        data.put("published", product.getPublished());
        data.put("thumbnail", thumbnail);
        data.put("images", images.stream().map(GalleryImage::getImage).toList());
        data.put("categoryIds", productCategoryRepository.findByProductId(product.getId()).stream()
            .map(item -> item.getCategory().getId())
            .toList());
        List<String> tags = productTagRepository.findByProductId(product.getId()).stream()
            .map(item -> item.getTag().getTagName())
            .toList();
        data.put("tags", tags);
        data.put("isSale", product.getComparePrice() != null || tags.stream().anyMatch(tag -> "Sale".equalsIgnoreCase(tag)));
        List<ProductReview> reviews = productReviewRepository.findByProductId(product.getId());
        double ratingAverage = reviews.stream()
            .map(ProductReview::getRating)
            .filter(rating -> rating != null)
            .mapToInt(Integer::intValue)
            .average()
            .orElse(0);
        data.put("reviewCount", reviews.size());
        data.put("ratingAverage", ratingAverage);
        data.put("attributes", productAttributeRepository.findAll().stream()
            .map(this::attributeWithValues)
            .toList());
        return data;
    }

    private Map<String, Object> attributeWithValues(ProductAttribute attribute) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", attribute.getId());
        data.put("attributeName", attribute.getAttributeName());
        data.put("values", attributeValueRepository.findByAttributeId(attribute.getId()).stream().map(value -> {
            Map<String, Object> item = new HashMap<>();
            item.put("id", value.getId());
            item.put("attributeValue", value.getAttributeValue());
            item.put("color", value.getColor());
            return item;
        }).toList());
        return data;
    }

    public Map<String, Object> cartItem(CartItem item) {
        Map<String, Object> product = product(item.getProduct());
        BigDecimal price = item.getProduct().getSalePrice();
        int quantity = item.getQuantity() == null ? 0 : item.getQuantity();

        Map<String, Object> data = new HashMap<>();
        data.put("id", item.getId());
        data.put("product", product);
        data.put("size", item.getSize());
        data.put("color", item.getColor());
        data.put("quantity", quantity);
        data.put("lineTotal", price.multiply(BigDecimal.valueOf(quantity)));
        return data;
    }

    public Map<String, Object> address(CustomerAddress address) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", address.getId());
        data.put("customerId", address.getCustomer().getId());
        data.put("fullName", address.getFullName());
        data.put("addressLine1", address.getAddressLine1());
        data.put("addressLine2", address.getAddressLine2());
        data.put("phoneNumber", address.getPhoneNumber());
        data.put("country", address.getCountry());
        data.put("postalCode", address.getPostalCode());
        data.put("city", address.getCity());
        data.put("defaultAddress", address.getDefaultAddress());
        return data;
    }

    public Map<String, Object> review(ProductReview review) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", review.getId());
        data.put("customer", user(review.getCustomer()));
        data.put("productId", review.getProduct().getId());
        data.put("rating", review.getRating());
        data.put("comment", review.getComment());
        data.put("createdAt", review.getCreatedAt());
        data.put("images", reviewImageRepository.findByReviewId(review.getId()).stream()
            .map(image -> image.getImage())
            .toList());
        return data;
    }

    public Map<String, Object> slideshow(Slideshow slideshow) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", slideshow.getId());
        data.put("title", slideshow.getTitle());
        data.put("destinationUrl", slideshow.getDestinationUrl());
        data.put("image", slideshow.getImage());
        data.put("description", slideshow.getDescription());
        data.put("buttonLabel", slideshow.getButtonLabel());
        data.put("displayOrder", slideshow.getDisplayOrder());
        return data;
    }

    public Map<String, Object> order(Order order) {
        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        Map<String, Object> data = new HashMap<>();
        data.put("id", order.getId());
        data.put("orderNumber", order.getOrderNumber());
        data.put("customerId", order.getCustomer().getId());
        data.put("status", order.getOrderStatus() == null ? null : order.getOrderStatus().getStatusName());
        data.put("trackingNumber", order.getTrackingNumber());
        data.put("subtotal", order.getSubtotal() == null ? BigDecimal.ZERO : order.getSubtotal());
        data.put("discountAmount", order.getDiscountAmount() == null ? BigDecimal.ZERO : order.getDiscountAmount());
        data.put("shippingFee", order.getShippingFee() == null ? BigDecimal.ZERO : order.getShippingFee());
        data.put("orderTotal", order.getOrderTotal());
        data.put("couponCode", order.getCoupon() == null ? null : order.getCoupon().getCode());
        if (order.getShippingMethod() == null) {
            data.put("shippingMethod", null);
        } else {
            Map<String, Object> shippingMethod = new HashMap<>();
            shippingMethod.put("id", order.getShippingMethod().getId());
            shippingMethod.put("name", order.getShippingMethod().getName());
            shippingMethod.put("displayName", order.getShippingMethod().getDisplayName());
            shippingMethod.put("price", order.getShippingMethod().getPrice());
            data.put("shippingMethod", shippingMethod);
        }
        data.put("createdAt", order.getCreatedAt());
        data.put("shippingAddress", order.getShippingAddress() == null ? null : address(order.getShippingAddress()));
        data.put("items", items.stream().map(this::orderItem).toList());
        return data;
    }

    public Map<String, Object> orderItem(OrderItem item) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", item.getId());
        data.put("product", product(item.getProduct()));
        data.put("price", item.getPrice());
        data.put("size", item.getSize());
        data.put("color", item.getColor());
        data.put("quantity", item.getQuantity());
        return data;
    }
}
