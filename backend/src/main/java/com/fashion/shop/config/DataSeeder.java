package com.fashion.shop.config;

import com.fashion.shop.entity.AttributeValue;
import com.fashion.shop.entity.Brand;
import com.fashion.shop.entity.Category;
import com.fashion.shop.entity.Coupon;
import com.fashion.shop.entity.GalleryImage;
import com.fashion.shop.entity.OrderStatus;
import com.fashion.shop.entity.Product;
import com.fashion.shop.entity.ProductAttribute;
import com.fashion.shop.entity.ProductCategory;
import com.fashion.shop.entity.ProductTag;
import com.fashion.shop.entity.ShippingMethod;
import com.fashion.shop.entity.Slideshow;
import com.fashion.shop.entity.Tag;
import com.fashion.shop.entity.User;
import com.fashion.shop.repository.AttributeValueRepository;
import com.fashion.shop.repository.BrandRepository;
import com.fashion.shop.repository.CategoryRepository;
import com.fashion.shop.repository.CouponRepository;
import com.fashion.shop.repository.GalleryImageRepository;
import com.fashion.shop.repository.OrderStatusRepository;
import com.fashion.shop.repository.ProductAttributeRepository;
import com.fashion.shop.repository.ProductCategoryRepository;
import com.fashion.shop.repository.ProductRepository;
import com.fashion.shop.repository.ProductTagRepository;
import com.fashion.shop.repository.ShippingMethodRepository;
import com.fashion.shop.repository.SlideshowRepository;
import com.fashion.shop.repository.TagRepository;
import com.fashion.shop.repository.UserRepository;
import com.fashion.shop.service.AuthService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final AuthService authService;
    private final UserRepository userRepository;
    private final BrandRepository brandRepository;
    private final CategoryRepository categoryRepository;
    private final ProductRepository productRepository;
    private final ProductCategoryRepository productCategoryRepository;
    private final ProductTagRepository productTagRepository;
    private final GalleryImageRepository galleryImageRepository;
    private final ProductAttributeRepository productAttributeRepository;
    private final AttributeValueRepository attributeValueRepository;
    private final TagRepository tagRepository;
    private final SlideshowRepository slideshowRepository;
    private final CouponRepository couponRepository;
    private final ShippingMethodRepository shippingMethodRepository;
    private final OrderStatusRepository orderStatusRepository;
    private final ObjectMapper objectMapper;

    @Override
    public void run(String... args) {
        seedCustomer();
        seedOrderStatuses();
        seedShippingMethods();
        seedCoupons();
        seedCatalog();
    }

    private void seedCustomer() {
        if (!userRepository.existsByEmail("demo@fashion.test")) {
            authService.register(User.builder()
                .firstName("Demo")
                .lastName("User")
                .email("demo@fashion.test")
                .passwordHash("123456")
                .phoneNumber("0900000000")
                .build());
        }
    }

    private void seedOrderStatuses() {
        if (orderStatusRepository.count() > 0) {
            return;
        }
        orderStatusRepository.save(OrderStatus.builder().statusName("Delivered").color("#2AA952").build());
        orderStatusRepository.save(OrderStatus.builder().statusName("Processing").color("#DB3022").build());
        orderStatusRepository.save(OrderStatus.builder().statusName("Cancelled").color("#9B9B9B").build());
    }

    private void seedShippingMethods() {
        if (shippingMethodRepository.count() > 0) {
            return;
        }
        shippingMethodRepository.save(ShippingMethod.builder().name("fedex").displayName("FedEx").price(new BigDecimal("15")).active(true).build());
        shippingMethodRepository.save(ShippingMethod.builder().name("usps").displayName("USPS").price(new BigDecimal("10")).active(true).build());
        shippingMethodRepository.save(ShippingMethod.builder().name("dhl").displayName("DHL").price(new BigDecimal("20")).active(true).build());
    }

    private void seedCoupons() {
        if (couponRepository.count() > 0) {
            return;
        }
        couponRepository.save(Coupon.builder()
            .code("mypromocode2020")
            .discountType("PERCENT")
            .discountValue(new BigDecimal("10"))
            .maxUsage(100)
            .couponStartDate(LocalDateTime.now().minusDays(1))
            .couponEndDate(LocalDateTime.now().plusDays(30))
            .build());
        couponRepository.save(Coupon.builder()
            .code("summer2020")
            .discountType("PERCENT")
            .discountValue(new BigDecimal("15"))
            .maxUsage(100)
            .couponStartDate(LocalDateTime.now().minusDays(1))
            .couponEndDate(LocalDateTime.now().plusDays(60))
            .build());
    }

    private void seedCatalog() {
        ProductAttribute size = attribute("Size");
        ProductAttribute color = attribute("Color");
        if (attributeValueRepository.findByAttributeId(size.getId()).isEmpty()) {
            List.of("XS", "S", "M", "L", "XL").forEach(value ->
                attributeValueRepository.save(AttributeValue.builder().attribute(size).attributeValue(value).build()));
        }
        if (attributeValueRepository.findByAttributeId(color.getId()).isEmpty()) {
            attributeValueRepository.save(AttributeValue.builder().attribute(color).attributeValue("Black").color("#000000").build());
            attributeValueRepository.save(AttributeValue.builder().attribute(color).attributeValue("White").color("#FFFFFF").build());
            attributeValueRepository.save(AttributeValue.builder().attribute(color).attributeValue("Red").color("#DB3022").build());
        }

        CatalogSeed seed = readCatalogSeed();
        for (CategorySeed item : seed.categories()) {
            Category parent = item.parent() == null ? null : categoryRepository.findByCategoryName(item.parent()).orElse(null);
            category(item.name(), parent, item.image());
        }

        Tag saleTag = tag("Sale");
        Tag newTag = tag("New");
        for (ProductSeed item : seed.products()) {
            Product product = saveProduct(
                brand(item.brand()),
                item.slug(),
                item.name(),
                item.sku(),
                item.salePrice(),
                item.comparePrice(),
                item.shortDescription(),
                item.description(),
                item.quantity()
            );
            productCategoryRepository.deleteAll(productCategoryRepository.findByProductId(product.getId()));
            categoryRepository.findByCategoryName(item.category()).ifPresent(category -> linkCategory(product, category));
            if (item.tags().contains("Sale")) {
                linkTag(product, saleTag);
            }
            if (item.tags().contains("New")) {
                linkTag(product, newTag);
            }
            saveImages(product, item.images());
        }

        for (SlideshowSeed item : seed.slideshows()) {
            Slideshow slideshow = slideshowRepository.findByPublishedTrueOrderByDisplayOrderAsc().stream()
                .filter(existing -> item.title().equals(existing.getTitle()))
                .findFirst()
                .orElseGet(() -> Slideshow.builder().title(item.title()).build());
            slideshow.setDescription(item.description());
            slideshow.setButtonLabel(item.buttonLabel());
            slideshow.setImage(item.image());
            slideshow.setDestinationUrl(item.destinationUrl());
            slideshow.setDisplayOrder(item.displayOrder());
            slideshow.setPublished(true);
            slideshowRepository.save(slideshow);
        }

        List.of("pullover", "light-blouse", "t-shirt-spanish", "sport-dress").forEach(slug ->
            productRepository.findBySlug(slug).ifPresent(product -> {
                product.setPublished(false);
                productRepository.save(product);
            }));
    }

    private CatalogSeed readCatalogSeed() {
        try {
            return objectMapper.readValue(
                new ClassPathResource("seed/products.json").getInputStream(),
                new TypeReference<>() {
                }
            );
        } catch (IOException exception) {
            throw new IllegalStateException("Cannot read seed/products.json", exception);
        }
    }

    private Product saveProduct(Brand brand, String slug, String name, String sku, String salePrice, String comparePrice,
                                String shortDescription, String description, int quantity) {
        Product product = productRepository.findBySlug(slug)
            .orElseGet(() -> Product.builder().slug(slug).createdAt(LocalDateTime.now()).build());
        product.setBrand(brand);
        product.setProductName(name);
        product.setSku(sku);
        product.setSalePrice(new BigDecimal(salePrice));
        product.setComparePrice(comparePrice == null ? null : new BigDecimal(comparePrice));
        product.setQuantity(quantity);
        product.setShortDescription(shortDescription);
        product.setProductDescription(description);
        product.setProductType("fashion");
        product.setPublished(true);
        product.setDisableOutOfStock(false);
        product.setUpdatedAt(LocalDateTime.now());
        return productRepository.save(product);
    }

    private void linkCategory(Product product, Category category) {
        productCategoryRepository.findByProductIdAndCategoryId(product.getId(), category.getId())
            .orElseGet(() -> productCategoryRepository.save(ProductCategory.builder().product(product).category(category).build()));
    }

    private void linkTag(Product product, Tag tag) {
        productTagRepository.findByProductIdAndTagId(product.getId(), tag.getId())
            .orElseGet(() -> productTagRepository.save(ProductTag.builder().product(product).tag(tag).build()));
    }

    private void saveImages(Product product, List<String> productImages) {
        List<GalleryImage> images = galleryImageRepository.findByProductId(product.getId());
        galleryImageRepository.deleteAll(images);
        for (int index = 0; index < productImages.size(); index++) {
            galleryImageRepository.save(GalleryImage.builder()
                .product(product)
                .image(productImages.get(index))
                .thumbnail(index == 0)
                .createdAt(LocalDateTime.now())
                .build());
        }
    }

    private Brand brand(String brandName) {
        return brandRepository.findByBrandName(brandName)
            .orElseGet(() -> brandRepository.save(Brand.builder().brandName(brandName).active(true).build()));
    }

    private Category category(String categoryName, Category parent, String image) {
        Category category = categoryRepository.findByCategoryName(categoryName)
            .orElseGet(() -> categoryRepository.save(Category.builder()
                .parent(parent)
                .categoryName(categoryName)
                .active(true)
                .createdAt(LocalDateTime.now())
                .build()));
        category.setParent(parent);
        category.setImage(image);
        category.setActive(true);
        return categoryRepository.save(category);
    }

    private ProductAttribute attribute(String attributeName) {
        return productAttributeRepository.findByAttributeName(attributeName)
            .orElseGet(() -> productAttributeRepository.save(ProductAttribute.builder()
                .attributeName(attributeName)
                .createdAt(LocalDateTime.now())
                .build()));
    }

    private Tag tag(String tagName) {
        return tagRepository.findByTagName(tagName)
            .orElseGet(() -> tagRepository.save(Tag.builder().tagName(tagName).build()));
    }

    private record CatalogSeed(List<CategorySeed> categories, List<SlideshowSeed> slideshows, List<ProductSeed> products) {
    }

    private record CategorySeed(String name, String parent, String image) {
    }

    private record SlideshowSeed(String title, String description, String buttonLabel, String image, String destinationUrl,
                                 Integer displayOrder) {
    }

    private record ProductSeed(String slug, String sku, String name, String brand, String salePrice, String comparePrice,
                               String shortDescription, String description, String category, List<String> tags,
                               List<String> images, Integer quantity) {
    }
}
