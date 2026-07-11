package com.campus.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * JWT 配置（可从 application.yml 读取）
 */
@Configuration
@ConfigurationProperties(prefix = "campus.jwt")
public class JwtConfig {

    private String secret = "campus-assistant-secret-key-2024-this-is-256-bits-long!!";
    private long expireMs = 2 * 60 * 60 * 1000;

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }
    public long getExpireMs() { return expireMs; }
    public void setExpireMs(long expireMs) { this.expireMs = expireMs; }
}
