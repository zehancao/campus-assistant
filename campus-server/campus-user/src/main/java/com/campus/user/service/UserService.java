package com.campus.user.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.campus.user.entity.User;

public interface UserService extends IService<User> {

    /**
     * 注册
     */
    void register(String studentId, String name, String password,
                  String college, String major, String grade);

    /**
     * 登录，返回 JWT token
     */
    String login(String studentId, String password);
}
