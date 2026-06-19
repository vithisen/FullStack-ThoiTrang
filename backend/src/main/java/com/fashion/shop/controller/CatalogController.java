package com.fashion.shop.controller;

import com.fashion.shop.entity.AttributeValue;
import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.ProductAttribute;
import com.fashion.shop.repository.AttributeValueRepository;
import com.fashion.shop.repository.BrandRepository;
import com.fashion.shop.repository.CategoryRepository;
import com.fashion.shop.repository.GalleryImageRepository;
import com.fashion.shop.repository.ProductAttributeRepository;
import com.fashion.shop.repository.ProductCategoryRepository;
import com.fashion.shop.repository.ProductRepository;
import com.fashion.shop.repository.ProductTagRepository;
import com.fashion.shop.repository.ShippingMethodRepository;
import com.fashion.shop.repository.SlideshowRepository;
import com.fashion.shop.util.ApiMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.math.BigDecimal;
import java.util.Comparator;
import java.util.Set;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class CatalogController {

    private final ProductRepository productRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final ProductTagRepository productTagRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final GalleryImageRepository galleryImageRepository;
    private final ProductAttributeRepository productAttributeRepository;
    private final AttributeValueRepository attributeValueRepository;
    private final SlideshowRepository slideshowRepository;
    private final ShippingMethodRepository shippingMethodRepository;
    private final ApiMapper mapper;

    @GetMapping("/products")
    public List<Map<String, Object>> products(
        @RequestParam(required = false) Long categoryId,
        @RequestParam(required = false) Long brandId,
        @RequestParam(required = false) String q,
        @RequestParam(required = false) BigDecimal minPrice,
        @RequestParam(required = false) BigDecimal maxPrice,
        @RequestParam(required = false) String size,
        @RequestParam(required = false) String color,
        @RequestParam(required = false) Boolean saleOnly,
        @RequestParam(required = false, defaultValue = "newest") String sort
    ) {
        Set<Long> categoryIds = categoryId == null ? Set.of() : categoryAndDescendantIds(categoryId);
        return productRepository.findByPublishedTrue().stream()
            .filter(product -> categoryId == null || productCategoryRepository.findByProductId(product.getId()).stream()
                .anyMatch(productCategory -> categoryIds.contains(productCategory.getCategory().getId())))
            .filter(product -> brandId == null || (product.getBrand() != null && product.getBrand().getId().equals(brandId)))
            .filter(product -> matchesQuery(product, q))
            .filter(product -> minPrice == null || product.getSalePrice().compareTo(minPrice) >= 0)
            .filter(product -> maxPrice == null || product.getSalePrice().compareTo(maxPrice) <= 0)
            .filter(product -> size == null || size.isBlank() || attributeValueExists("Size", size))
            .filter(product -> color == null || color.isBlank() || attributeValueExists("Color", color))
            .filter(product -> !Boolean.TRUE.equals(saleOnly) || isSale(product))
            .sorted(productComparator(sort))
            .map(mapper::product)
            .toList();
    }

    private boolean matchesQuery(Product product, String q) {
        if (q == null || q.isBlank()) {
            return true;
        }
        String query = q.trim().toLowerCase();
        if (product.getProductName() != null && product.getProductName().toLowerCase().contains(query)) {
            return true;
        }
        return galleryImageRepository.findByProductId(product.getId()).stream()
            .anyMatch(image -> image.getImage() != null && image.getImage().toLowerCase().contains(query));
    }

    @GetMapping("/products/{id}")
    public Map<String, Object> productDetail(@PathVariable Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        return mapper.product(product);
    }

    @GetMapping("/products/{id}/related")
    public List<Map<String, Object>> relatedProducts(@PathVariable Long id) {
        Product product = productRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Product not found"));
        List<Long> categoryIds = productCategoryRepository.findByProductId(product.getId()).stream()
            .map(item -> item.getCategory().getId())
            .toList();

        return productRepository.findByPublishedTrue().stream()
            .filter(item -> !item.getId().equals(product.getId()))
            .filter(item -> productCategoryRepository.findByProductId(item.getId()).stream()
                .anyMatch(productCategory -> categoryIds.contains(productCategory.getCategory().getId())))
            .limit(6)
            .map(mapper::product)
            .toList();
    }

    @GetMapping("/categories")
    public List<Map<String, Object>> categories() {
        return categoryRepository.findByActiveTrue().stream().map(mapper::category).toList();
    }

    @GetMapping("/brands")
    public List<Map<String, Object>> brands() {
        return brandRepository.findByActiveTrue().stream().map(mapper::brand).toList();
    }

    @GetMapping("/attributes")
    public List<Map<String, Object>> attributes() {
        return productAttributeRepository.findAll().stream().map(this::attributeWithValues).toList();
    }

    @GetMapping("/slideshows")
    public List<Map<String, Object>> slideshows() {
        return slideshowRepository.findByPublishedTrueOrderByDisplayOrderAsc().stream()
            .map(mapper::slideshow)
            .toList();
    }

    @GetMapping("/shipping-methods")
    public List<Map<String, Object>> shippingMethods() {
        return shippingMethodRepository.findByActiveTrue().stream().map(method -> {
            Map<String, Object> data = new HashMap<>();
            data.put("id", method.getId());
            data.put("name", method.getName());
            data.put("displayName", method.getDisplayName());
            data.put("price", method.getPrice());
            return data;
        }).toList();
    }

    private Map<String, Object> attributeWithValues(ProductAttribute attribute) {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("id", attribute.getId());
        data.put("attributeName", attribute.getAttributeName());
        data.put("values", attributeValueRepository.findByAttributeId(attribute.getId()).stream()
            .filter(Objects::nonNull)
            .map(this::attributeValue)
            .toList());
        return data;
    }

    private Map<String, Object> attributeValue(AttributeValue value) {
        Map<String, Object> data = new HashMap<>();
        data.put("id", value.getId());
        data.put("attributeValue", value.getAttributeValue());
        data.put("color", value.getColor());
        return data;
    }

    private boolean attributeValueExists(String attributeName, String value) {
        return productAttributeRepository.findByAttributeName(attributeName)
            .map(attribute -> attributeValueRepository.findByAttributeId(attribute.getId()).stream()
                .anyMatch(attributeValue -> attributeValue.getAttributeValue().equalsIgnoreCase(value.trim())))
            .orElse(false);
    }

    private Set<Long> categoryAndDescendantIds(Long categoryId) {
        Set<Long> ids = new HashSet<>();
        collectCategoryIds(categoryId, ids);
        return ids;
    }

    private void collectCategoryIds(Long categoryId, Set<Long> ids) {
        if (!ids.add(categoryId)) {
            return;
        }
        categoryRepository.findByParentId(categoryId)
            .forEach(category -> collectCategoryIds(category.getId(), ids));
    }

    private boolean isSale(Product product) {
        return product.getComparePrice() != null || productTagRepository.findByProductId(product.getId()).stream()
            .anyMatch(productTag -> "Sale".equalsIgnoreCase(productTag.getTag().getTagName()));
    }

    private Comparator<Product> productComparator(String sort) {
        return switch (sort == null ? "newest" : sort) {
            case "price_asc" -> Comparator.comparing(Product::getSalePrice);
            case "price_desc" -> Comparator.comparing(Product::getSalePrice).reversed();
            default -> Comparator.comparing(Product::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())).reversed();
        };
    }
}
