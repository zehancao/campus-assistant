package com.campus.user.controller;

import com.campus.common.result.R;
import com.campus.common.util.JwtUtil;
import com.campus.user.entity.User;
import com.campus.user.service.UserService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 注册
     */
    @PostMapping("/register")
    public R<?> register(@Valid @RequestBody RegisterRequest req) {
        userService.register(
                req.getStudentId(), req.getName(), req.getPassword(),
                req.getCollege(), req.getMajor(), req.getGrade()
        );
        return R.ok();
    }

    /**
     * 登录
     */
    @PostMapping("/login")
    public R<Map<String, String>> login(@Valid @RequestBody LoginRequest req) {
        String token = userService.login(req.getStudentId(), req.getPassword());
        return R.ok(Map.of("token", token));
    }

    /**
     * 个人信息
     */
    @GetMapping("/profile")
    public R<User> profile(@RequestHeader("Authorization") String authHeader) {
        String token = authHeader.replace("Bearer ", "");
        Long userId = JwtUtil.getUserId(token);
        User user = userService.getById(userId);
        user.setPassword(null);
        return R.ok(user);
    }

    // ========== 请求体 ==========

    public static class RegisterRequest {
        @NotBlank
        private String studentId;
        @NotBlank
        private String name;
        @NotBlank
        private String password;
        private String college;
        private String major;
        private String grade;

        public String getStudentId() { return studentId; }
        public void setStudentId(String studentId) { this.studentId = studentId; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
        public String getCollege() { return college; }
        public void setCollege(String college) { this.college = college; }
        public String getMajor() { return major; }
        public void setMajor(String major) { this.major = major; }
        public String getGrade() { return grade; }
        public void setGrade(String grade) { this.grade = grade; }
    }

    public static class LoginRequest {
        @NotBlank
        private String studentId;
        @NotBlank
        private String password;

        public String getStudentId() { return studentId; }
        public void setStudentId(String studentId) { this.studentId = studentId; }
        public String getPassword() { return password; }
        public void setPassword(String password) { this.password = password; }
    }
}
