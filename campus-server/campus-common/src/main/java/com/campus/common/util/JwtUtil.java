package com.campus.common.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

/**
 * JWT 工具类
 */
public class JwtUtil {

    // ⚠️ 生产环境必须换成复杂密钥 + 配置文件
    private static final String SECRET = "campus-assistant-secret-key-2024-this-is-256-bits-long!!";
    private static final long EXPIRE_MS = 2 * 60 * 60 * 1000; // 2小时

    private static SecretKey getKey() {
        return Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 生成 token
     */
    public static String generate(Long userId, String studentId, String role) {
        return Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("studentId", studentId)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + EXPIRE_MS))
                .signWith(getKey())
                .compact();
    }

    /**
     * 解析 token
     */
    public static Claims parse(String token) {
        return Jwts.parser()
                .verifyWith(getKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * 获取用户ID
     */
    public static Long getUserId(String token) {
        return Long.valueOf(parse(token).getSubject());
    }

    /**
     * 获取角色
     */
    public static String getRole(String token) {
        return parse(token).get("role", String.class);
    }

    /**
     * 验证 token 是否有效
     */
    public static boolean validate(String token) {
        try {
            parse(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}
