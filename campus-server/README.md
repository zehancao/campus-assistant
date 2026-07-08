# 后端服务 — 智能校园助手

## 技术栈
- Java 17+ / Spring Boot 3
- MyBatis-Plus
- MySQL 8 + Redis + RabbitMQ
- Elasticsearch（商品搜索）
- MinIO（文件存储）
- Netty（WebSocket IM）
- JWT + Spring Security

## 模块结构

campus-server/
├── campus-common/        # 公共模块（工具类、异常处理、统一响应）
├── campus-user/          # 用户服务（登录注册、JWT认证）
├── campus-course/        # 课表服务
├── campus-market/        # 交易服务（二手商品、失物招领）
├── campus-announce/      # 公告服务（公告发布、活动报名）
├── campus-chat/          # IM服务（WebSocket + Netty）
└── campus-gateway/       # 可选：API网关

## API 接口一览

### 用户模块
- POST /api/user/register — 注册
- POST /api/user/login — 登录
- GET /api/user/profile — 个人信息

### 课表模块
- GET /api/course/week?date= — 周课表
- POST /api/course/import — Excel 导入课表
- GET /api/classroom/available — 空教室查询
- GET /api/classroom/{id}/schedule — 教室当日课表

### 交易模块
- GET /api/product/list — 商品列表
- POST /api/product — 发布商品
- POST /api/lostfound — 发布失物招领

### 公告模块
- GET /api/announce/list — 公告列表
- POST /api/announce — 发布公告（管理员）
- POST /api/event/{id}/signup — 活动报名

### IM模块
- WS /ws/chat — WebSocket 聊天

### AI模块（转发）
- POST /api/ai/chat — AI问答（SSE流式）
- POST /api/ai/knowledge/add — 添加知识库文档

## 快速开始

```bash
# 1. 启动基础设施
docker-compose up -d

# 2. 导入数据库
mysql -u root -p < docs/schema.sql

# 3. 启动后端
cd campus-server
mvn spring-boot:run
```

## 接口文档
启动后访问：http://localhost:8080/doc.html
