package com.campus.user;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

/**
 * 启动类
 */
@SpringBootApplication
@ComponentScan(basePackages = "com.campus")
@MapperScan("com.campus.**.mapper")
public class CampusApplication {
    public static void main(String[] args) {
        SpringApplication.run(CampusApplication.class, args);
    }
}
