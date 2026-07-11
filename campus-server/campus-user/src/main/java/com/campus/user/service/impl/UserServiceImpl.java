package com.campus.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.campus.common.exception.BusinessException;
import com.campus.common.util.JwtUtil;
import com.campus.user.entity.User;
import com.campus.user.mapper.UserMapper;
import com.campus.user.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public void register(String studentId, String name, String password,
                         String college, String major, String grade) {
        long count = count(new LambdaQueryWrapper<User>()
                .eq(User::getStudentId, studentId));
        if (count > 0) {
            throw new BusinessException(400, "该学号已被注册");
        }

        User user = new User();
        user.setStudentId(studentId);
        user.setName(name);
        user.setPassword(passwordEncoder.encode(password));
        user.setCollege(college);
        user.setMajor(major);
        user.setGrade(grade);
        user.setRole("student");
        user.setCreditScore(100);
        user.setStatus(1);

        save(user);
        log.info("用户注册成功: {} ({})", name, studentId);
    }

    @Override
    public String login(String studentId, String password) {
        User user = getOne(new LambdaQueryWrapper<User>()
                .eq(User::getStudentId, studentId));

        if (user == null) {
            throw new BusinessException(400, "学号或密码错误");
        }
        if (user.getStatus() == 0) {
            throw new BusinessException(403, "账号已被禁用");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BusinessException(400, "学号或密码错误");
        }

        String token = JwtUtil.generate(user.getId(), user.getStudentId(), user.getRole());
        log.info("用户登录成功: {} ({})", user.getName(), studentId);
        return token;
    }
}
