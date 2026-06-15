package com.fashion.shop.repository;

import com.fashion.shop.entity.Slideshow;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SlideshowRepository extends JpaRepository<Slideshow, Long> {
    List<Slideshow> findByPublishedTrueOrderByDisplayOrderAsc();
}
