# 后端服务 — 智能校园助手

## 技术栈
- Java 17+
- Spring Boot 3
- MyBatis-Plus（ORM）
- MySQL 8
- Redis（缓存 + Token）
- RabbitMQ（异步消息/推送）
- Elasticsearch（商品搜索）
- MinIO（文件/图片存储）
- Netty（WebSocket IM）
- JWT + Spring Security（认证鉴权）
- Knife4j（接口文档/Swagger）

---

## 模块结构

```
campus-server/
├── campus-common/              # 公共模块
│   ├── config/                 # 全局配置
│   ├── exception/              # 全局异常处理
│   ├── result/                 # 统一响应 R.java
│   └── util/                   # 工具类（JwtUtil等）
├── campus-user/                # 用户服务
│   ├── controller/
│   ├── service/
│   ├── mapper/
│   └── entity/
├── campus-course/              # 课表服务
├── campus-market/              # 交易服务（二手商品+失物招领）
├── campus-announce/            # 公告服务（公告+活动+通知）
├── campus-chat/                # IM服务（Netty WebSocket）
└── campus-gateway/             # API 网关（可选，后期加）
```

---

## 负责人：组员D

### 第一周：工程搭建 + 用户模块

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 工程搭建 | 基于曹老板脚手架建多模块项目，能跑通 | 0.5天 |
| P0 | 统一响应封装 | `R<T>` 类，`{code, message, data}` 格式，全局异常拦截 | 0.5天 |
| P0 | 数据库连接 | MySQL + Redis 配置，MyBatis-Plus 配置 | 0.5天 |
| P0 | 用户注册接口 | `POST /api/user/register`，学号唯一校验，密码 BCrypt 加密 | 0.5天 |
| P0 | 用户登录接口 | `POST /api/user/login`，验证学号密码，生成 JWT token（2h过期） | 0.5天 |
| P1 | 个人信息接口 | `GET /api/user/profile`，`PUT /api/user/profile` | 0.5天 |
| P1 | JWT 拦截器 | 所有非登录接口校验 token，解析 userId 注入请求上下文 | 0.5天 |
| P1 | Knife4j 文档 | 接口分组、参数注解，生成 Swagger 文档 | 0.5天 |

---

### 第二周：课表模块 + 公告模块

#### 课表模块

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 查周课表 | `GET /api/course/week?date=`，返回7天课程数据 | 1天 |
| P0 | 课程 CRUD | `POST/PUT/DELETE /api/course` | 1天 |
| P0 | Excel 导入 | `POST /api/course/import`，Apache POI 解析，冲突检测 | 1.5天 |
| P1 | 空教室查询 | `GET /api/classroom/available?date=&start=&end=&building=` | 1天 |
| P1 | 教室当日课表 | `GET /api/classroom/{id}/schedule?date=` | 0.5天 |

#### 公告模块

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 公告列表 | `GET /api/announce/list`，分页+分类筛选+置顶优先 | 0.5天 |
| P0 | 发布公告 | `POST /api/announce`，富文本内容存储，分类+标签+定时发布 | 1天 |
| P0 | 公告详情 | `GET /api/announce/{id}` | 0.5天 |
| P1 | 活动报名 | `POST /api/event/{id}/signup`，人数限制校验 | 0.5天 |
| P1 | 扫码签到 | `POST /api/event/{id}/signin`，动态二维码校验+GPS校验 | 1天 |
| P1 | 消息通知列表 | `GET /api/notification/list`，`PUT /api/notification/{id}/read` | 0.5天 |

---

### 第三周：交易模块 + IM 模块

#### 交易模块

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 商品列表 | `GET /api/product/list`，分页+分类筛选+关键词搜索（ES） | 1天 |
| P0 | 发布商品 | `POST /api/product`，图片上传到 MinIO | 1天 |
| P0 | 商品详情 | `GET /api/product/{id}`，含卖家信息 | 0.5天 |
| P1 | 修改/下架商品 | `PUT/DELETE /api/product/{id}`，校验 owner | 0.5天 |
| P1 | 收藏/取消收藏 | `POST /api/product/{id}/favorite` | 0.5天 |
| P1 | 失物招领 | `GET/POST /api/lostfound` | 1天 |
| P2 | ES 索引同步 | 商品上架时同步到 ES，下架时删除索引 | 1天 |

#### IM 模块（Netty WebSocket）

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | WebSocket 服务 | Netty 启动 WebSocket 服务，`ws://localhost:8080/ws/chat` | 1天 |
| P0 | 连接鉴权 | 连接时验证 token，绑定 userId→Channel 映射 | 0.5天 |
| P0 | 消息收发 | 私聊消息转发，文本消息持久化到 MySQL | 1天 |
| P1 | 离线消息 | 对方不在线时存离线表，上线后批量推送 | 1天 |
| P1 | 心跳检测 | 30秒 ping/pong，超时断开 | 0.5天 |

---

### 第四周：推送 + 联调 + Bug 修复

| 任务 | 说明 |
|------|------|
| RabbitMQ 公告推送 | 公告发布→MQ→消费者→匹配订阅用户→写通知表 |
| Elasticsearch 搜索优化 | 中文分词（IK）+ 搜索高亮 |
| 全流程联调 | 跟前端（鸿蒙+Web）逐一接口对数据 |
| Bug 修复 | 参数校验、边界情况、性能问题 |
| 接口文档完善 | 确保 Knife4j 文档与实际一致 |

---

## API 接口总览

### 用户模块
| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| POST | `/api/user/register` | 注册 | 否 |
| POST | `/api/user/login` | 登录，返回 JWT | 否 |
| GET | `/api/user/profile` | 个人信息 | 是 |
| PUT | `/api/user/profile` | 修改个人信息 | 是 |

### 课表模块
| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| GET | `/api/course/week?date=` | 周课表 | 是 |
| POST | `/api/course` | 添加课程 | 管理员 |
| PUT | `/api/course/{id}` | 修改课程 | 管理员 |
| DELETE | `/api/course/{id}` | 删除课程 | 管理员 |
| POST | `/api/course/import` | Excel批量导入 | 管理员 |
| GET | `/api/classroom/available` | 空教室查询 | 是 |
| GET | `/api/classroom/{id}/schedule` | 教室当日课表 | 是 |

### 交易模块
| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| GET | `/api/product/list` | 商品列表 | 是 |
| GET | `/api/product/{id}` | 商品详情 | 是 |
| POST | `/api/product` | 发布商品 | 是 |
| PUT | `/api/product/{id}` | 修改商品 | 是 |
| DELETE | `/api/product/{id}` | 下架商品 | 是 |
| POST | `/api/product/{id}/favorite` | 收藏/取消 | 是 |
| GET | `/api/lostfound/list` | 失物招领列表 | 是 |
| POST | `/api/lostfound` | 发布失物招领 | 是 |

### 公告模块
| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| GET | `/api/announce/list` | 公告列表 | 是 |
| GET | `/api/announce/{id}` | 公告详情 | 是 |
| POST | `/api/announce` | 发布公告 | 管理员 |
| POST | `/api/event/{id}/signup` | 活动报名 | 是 |
| POST | `/api/event/{id}/signin` | 扫码签到 | 是 |
| GET | `/api/notification/list` | 消息列表 | 是 |
| PUT | `/api/notification/{id}/read` | 标记已读 | 是 |

### IM 模块
| 协议 | 路径 | 说明 |
|------|------|------|
| WS | `/ws/chat` | WebSocket 实时聊天 |

---

## 接口统一规范

**响应格式**：
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**分页格式**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "records": [ ... ],
    "total": 100,
    "page": 1,
    "pageSize": 20
  }
}
```

**错误格式**：
```json
{
  "code": 401,
  "message": "token已过期，请重新登录",
  "data": null
}
```

**状态码约定**：
- 200：成功
- 400：参数错误
- 401：未登录/token过期
- 403：无权限
- 404：资源不存在
- 500：服务器内部错误

---

## 快速开始

```bash
# 1. 启动基础设施（曹老板提供 docker-compose.yml）
docker-compose up -d

# 2. 导入数据库
mysql -u root -p < docs/schema.sql

# 3. 修改 application.yml 中的数据库连接信息

# 4. 启动后端
cd campus-server
mvn spring-boot:run
```

---

## 注意事项
- 所有接口先写 Controller，返回模拟数据，保证前端能联调
- 接口写完立刻更新 Knife4j 注解，接口文档就是联调依据
- 商品搜索用 Elasticsearch，不要用 MySQL LIKE（性能差）
- 图片上传走 MinIO，不要存本地（不利于部署）
- WebSocket 和 HTTP 共用 8080 端口（Spring Boot 天然支持）
- 敏感接口（删除、管理操作）必须校验权限
- 和组员C（Web前端）保持接口格式同步，有问题群里沟通
