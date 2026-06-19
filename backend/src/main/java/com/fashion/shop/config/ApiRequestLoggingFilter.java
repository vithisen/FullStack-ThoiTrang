package com.fashion.shop.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.util.ContentCachingRequestWrapper;
import org.springframework.web.util.ContentCachingResponseWrapper;

@Component
public class ApiRequestLoggingFilter extends OncePerRequestFilter {
    private static final Logger log = LoggerFactory.getLogger(ApiRequestLoggingFilter.class);
    private static final Pattern SENSITIVE_FIELD = Pattern.compile(
        "(\"(?:password|passwordHash|oldPassword|newPassword|idToken|token|secret)\"\\s*:\\s*\")([^\"]*)(\")",
        Pattern.CASE_INSENSITIVE
    );

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getRequestURI().startsWith("/api/");
    }

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        ContentCachingRequestWrapper wrappedRequest = new ContentCachingRequestWrapper(request);
        ContentCachingResponseWrapper wrappedResponse = new ContentCachingResponseWrapper(response);
        long startedAt = System.currentTimeMillis();
        String action = actionLabel(request.getMethod(), request.getRequestURI());
        String query = request.getQueryString() == null ? "" : "?" + request.getQueryString();

        try {
            filterChain.doFilter(wrappedRequest, wrappedResponse);
        } finally {
            long elapsedMs = System.currentTimeMillis() - startedAt;
            String body = requestBody(wrappedRequest);
            String responseSummary = responseSummary(wrappedResponse);

            log.info(
                "[API][{}] {} {}{} status={} durationMs={} clientIp={} body={} response={}",
                action,
                request.getMethod(),
                request.getRequestURI(),
                query,
                wrappedResponse.getStatus(),
                elapsedMs,
                clientIp(request),
                body,
                responseSummary
            );
            wrappedResponse.copyBodyToResponse();
        }
    }

    private String actionLabel(String method, String path) {
        if (path.contains("/auth/login")) return "LOGIN";
        if (path.contains("/auth/register")) return "REGISTER";
        if (path.contains("/auth/google")) return "GOOGLE_LOGIN";
        if (path.contains("/auth/facebook")) return "FACEBOOK_LOGIN";
        if (path.contains("/auth/forgot-password")) return "FORGOT_PASSWORD";
        if (path.contains("/cart/items") && method.equals("POST")) return "ADD_CART";
        if (path.contains("/cart/items") && method.equals("PATCH")) return "UPDATE_CART";
        if (path.contains("/cart/items") && method.equals("DELETE")) return "DELETE_CART";
        if (path.contains("/favorites") && method.equals("POST")) return "ADD_FAVORITE";
        if (path.contains("/favorites") && method.equals("DELETE")) return "REMOVE_FAVORITE";
        if (path.contains("/favorites")) return "LIST_FAVORITES";
        if (path.contains("/orders") && path.contains("/reorder")) return "REORDER";
        if (path.contains("/orders") && method.equals("POST")) return "CREATE_ORDER";
        if (path.contains("/orders")) return "ORDERS";
        if (path.contains("/reviews") && method.equals("POST")) return "ADD_REVIEW";
        if (path.contains("/reviews")) return "REVIEWS";
        if (path.contains("/addresses") && method.equals("POST")) return "ADD_ADDRESS";
        if (path.contains("/addresses") && method.equals("PATCH")) return "UPDATE_ADDRESS";
        if (path.contains("/addresses") && method.equals("DELETE")) return "DELETE_ADDRESS";
        if (path.contains("/addresses")) return "ADDRESSES";
        if (path.contains("/password")) return "CHANGE_PASSWORD";
        if (path.contains("/customers") && method.equals("PATCH")) return "UPDATE_PROFILE";
        if (path.contains("/customers")) return "CUSTOMER";
        if (path.contains("/products")) return "PRODUCTS";
        if (path.contains("/coupons")) return "COUPONS";
        if (path.contains("/shipping-methods")) return "SHIPPING";
        return "REQUEST";
    }

    private String requestBody(ContentCachingRequestWrapper request) {
        byte[] content = request.getContentAsByteArray();
        if (content.length == 0) return "-";
        String body = new String(content, StandardCharsets.UTF_8);
        return limit(maskSensitive(body), 600);
    }

    private String responseSummary(ContentCachingResponseWrapper response) {
        byte[] content = response.getContentAsByteArray();
        if (content.length == 0) return "-";
        String body = new String(content, StandardCharsets.UTF_8);
        return limit(maskSensitive(body), 600);
    }

    private String maskSensitive(String value) {
        Matcher matcher = SENSITIVE_FIELD.matcher(value);
        return matcher.replaceAll("$1***$3");
    }

    private String limit(String value, int maxLength) {
        String compact = value.replaceAll("\\s+", " ").trim();
        if (compact.length() <= maxLength) return compact;
        return compact.substring(0, maxLength) + "...";
    }

    private String clientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
