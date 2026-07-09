# 数据库设计文档 — campus_db

## 概述

`campus_db` 是智能校园助手的 MySQL 数据库，服务于鸿蒙 App + Web 管理后台的全部业务。共 **15 张表**，按模块分为 5 大区。

## ER 关系图（文字版）

```
users ──1:N──→ courses
users ──1:N──→ products
users ──1:N──→ favorites
users ──1:N──→ lost_found
users ──1:N──→ event_signups
users ──1:N──→ notifications
users ──1:N──→ chat_messages (sender)
users ──1:N──→ chat_messages (receiver)
users ──1:N──→ offline_messages

products ──1:N──→ favorites
classrooms ──1:N──→ courses (逻辑关联，非外键)
events ──1:N──→ event_signups
announces ──1:N──→ notifications (推送触发)
```

---

## 表结构详细分析

### 一、用户模块（`campus-user`）

#### 1. `users` — 用户表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统自动 | 全局 |
| `student_id` | `VARCHAR(20)` UNIQUE | 学号，登陆凭证 | 注册接口 | 登录/个人信息/IM |
| `name` | `VARCHAR(50)` | 真实姓名 | 注册接口 | 个人信息/商品详情/IM |
| `password` | `VARCHAR(255)` | BCrypt 加密密码 | 注册接口 | 登录校验（不对外返回） |
| `avatar` | `VARCHAR(500)` | 头像 URL（MinIO） | 修改个人信息 | 个人信息/商品详情/IM |
| `college` | `VARCHAR(100)` | 学院 | 注册/修改个人信息 | 个人信息/Web数据分析 |
| `major` | `VARCHAR(100)` | 专业 | 注册/修改个人信息 | 个人信息/Web数据分析 |
| `grade` | `VARCHAR(20)` | 年级（如 2023级） | 注册/修改个人信息 | 个人信息/Web数据分析 |
| `phone` | `VARCHAR(20)` | 手机号 | 注册/修改个人信息 | 个人信息（脱敏）/通知触达 |
| `role` | `VARCHAR(20)` | 角色：`student` / `admin` | 系统初始化 | 权限校验 |
| `credit_score` | `INT` DEFAULT 100 | 信用分，违规扣分 | 后台管理 | 交易限制/个人信息 |
| `status` | `TINYINT` DEFAULT 1 | 状态：0=禁用 1=正常 | 后台管理 | 登录校验 |
| `create_time` | `DATETIME` | 注册时间 | 系统自动填充 | Web数据大屏/统计分析 |
| `update_time` | `DATETIME` | 最后更新时间 | 系统自动填充 | 日志审计 |

**业务规则：**
- 学号唯一，注册时校验
- 密码 BCrypt 加密，不存明文，不返回给前端
- 角色为 `admin` 的用户才能发布公告、管理交易、审核内容
- 信用分低于 60 禁止发布商品
- `deleted` 逻辑删除字段（MyBatis-Plus 全局配置）

---

### 二、课表模块（`campus-course`）

#### 2. `courses` — 课程表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 课表CRUD |
| `user_id` | `BIGINT(20)` FK→users.id | 所属用户（个人课表） | 添加课程时传入 | 按用户查周课表 |
| `semester_id` | `BIGINT(20)` FK→semesters.id | 所属学期 | 添加/导入时指定 | 按学期筛选 |
| `course_name` | `VARCHAR(100)` | 课程名称 | 手动添加/Excel导入 | 课表展示 |
| `teacher` | `VARCHAR(50)` | 授课教师 | 手动添加/Excel导入 | 课表展示 |
| `classroom` | `VARCHAR(50)` | 上课教室名 | 手动添加/Excel导入 | 课表展示 |
| `day_of_week` | `TINYINT(1)` | 星期几：1=周一…7=周日 | 手动添加/Excel导入 | 周课表按天分组 |
| `start_week` | `TINYINT(2)` | 起始教学周 | 手动添加/Excel导入 | 周课表显示 |
| `end_week` | `TINYINT(2)` | 结束教学周 | 手动添加/Excel导入 | 周课表显示/过期过滤 |
| `start_section` | `TINYINT(2)` | 起始节次（如 1=第一节） | 手动添加/Excel导入 | 课表排列/冲突检测 |
| `end_section` | `TINYINT(2)` | 结束节次 | 手动添加/Excel导入 | 课表排列/冲突检测 |
| `color` | `VARCHAR(20)` | 课程块颜色（HEX） | 添加时随机或手动选 | 鸿蒙端课表卡片 |
| `remark` | `VARCHAR(500)` | 备注（教室变更等） | 修改课程时 | 课表详情展示 |
| `create_time` | `DATETIME` | 添加时间 | 系统自动 | 审计 |

**业务规则：**
- 同一用户同一时间（dayOfWeek + startSection）不能有重叠课程
- Excel 导入时自动检测冲突，返回冲突列表
- 周课表查询只返回当前周所在学期的课程
- `color` 用于鸿蒙 App 课表卡片配色，默认随机生成

#### 3. `classrooms` — 教室表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `building` | `VARCHAR(50)` | 教学楼名称（如 一教） | 管理员导入 | 按教学楼筛选空教室 |
| `room_no` | `VARCHAR(20)` | 教室编号（如 101） | 管理员导入 | 教室详情 |
| `capacity` | `INT` | 容纳人数 | 管理员导入 | 空教室查询/教室详情 |
| `has_projector` | `TINYINT(1)` | 是否有投影仪：0=无 1=有 | 管理员导入 | 教室筛选 |
| `has_ac` | `TINYINT(1)` | 是否有空调：0=无 1=有 | 管理员导入 | 教室筛选 |
| `type` | `VARCHAR(30)` | 教室类型：普通/多媒体/阶梯/实验室 | 管理员导入 | 教室筛选 |
| `status` | `VARCHAR(20)` | 状态：available/occupied/maintenance | 系统+管理员 | 空教室查询 |

**业务规则：**
- 空教室查询 = 当前时间没有课程记录的教室
- 教室状态可由管理员手动标为 `maintenance`（维修中）
- `building + room_no` 联合唯一

#### 4. `semesters` — 学期表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `name` | `VARCHAR(50)` | 学期名称（如 2025-2026-1） | 管理员 | 课表/选课 |
| `start_date` | `DATE` | 学期第一天 | 管理员 | 课表周数计算 |
| `end_date` | `DATE` | 学期最后一天 | 管理员 | 课表周数计算 |
| `is_current` | `TINYINT(1)` DEFAULT 0 | 是否当前学期 | 管理员切换 | 默认查询当前学期 |

**说明**：当前代码中 `courses` 表引用了 `semesterId` 但课程实体未强制外键，此表由后台管理员管理。

---

### 三、交易模块（`campus-market`）

#### 5. `products` — 二手商品表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `user_id` | `BIGINT(20)` FK→users.id | 发布者 ID | 发布商品时绑定 | 商品详情（查卖家信息） |
| `title` | `VARCHAR(200)` | 商品标题 | 发布商品 | 商品列表/搜索 |
| `description` | `TEXT` | 商品描述（富文本） | 发布商品 | 商品详情 |
| `category` | `VARCHAR(30)` | 分类：书籍/电子/生活/运动/其他 | 发布商品 | 列表筛选 |
| `price` | `DECIMAL(10,2)` | 售价（元） | 发布商品 | 列表/详情 |
| `original_price` | `DECIMAL(10,2)` | 原价（选填） | 发布商品 | 详情展示 |
| `images` | `VARCHAR(2000)` | 图片 URL 列表（JSON数组） | 发布商品→MinIO | 列表缩略图/详情轮播 |
| `condition` | `TINYINT(1)` | 成色：1=全新 2=几乎全新 3=轻微使用 4=明显使用 | 发布商品 | 列表/详情 |
| `status` | `TINYINT(1)` DEFAULT 1 | 状态：1=在售 2=已售 3=已下架 | 卖家/系统 | 列表过滤 |
| `view_count` | `INT` DEFAULT 0 | 浏览次数 | 系统自增 | 详情展示/热门排序 |
| `favorite_count` | `INT` DEFAULT 0 | 收藏数 | 收藏/取消时更新 | 列表排序因子 |
| `create_time` | `DATETIME` | 发布时间 | 系统自动 | 列表排序/时长展示 |
| `update_time` | `DATETIME` | 最后更新时间 | 系统自动 | 审计 |

**业务规则：**
- 发布商品时校验用户信用分 ≥ 60
- 商品同步到 Elasticsearch 索引（供关键词全文搜索）
- `images` 为 MinIO URL 的 JSON 数组，最多 9 张
- 已售/已下架商品不出现在列表中
- 收藏计数定期同步，避免实时锁表

#### 6. `favorites` — 收藏表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `user_id` | `BIGINT(20)` FK→users.id | 收藏者 ID | 点击收藏 | 我的收藏列表 |
| `product_id` | `BIGINT(20)` FK→products.id | 被收藏商品 ID | 点击收藏 | 我的收藏列表 |
| `create_time` | `DATETIME` | 收藏时间 | 系统自动 | 按时间排序 |

**业务规则：**
- `user_id + product_id` 联合唯一（一个用户不能重复收藏同一商品）
- 再次请求即取消收藏（toggle 模式）
- 收藏/取消时同步更新 `products.favorite_count`

#### 7. `lost_found` — 失物招领表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `user_id` | `BIGINT(20)` FK→users.id | 发布者 ID | 发布失物招领 | 详情页查看发布者 |
| `type` | `TINYINT(1)` | 类型：1=失物 2=招领 | 发布时指定 | 列表分类 |
| `title` | `VARCHAR(200)` | 标题 | 发布时填写 | 列表/详情 |
| `description` | `TEXT` | 详细描述（物品特征、地点、时间） | 发布时填写 | 详情 |
| `category` | `VARCHAR(30)` | 物品分类：证件/电子/生活/其他 | 发布时选择 | 列表筛选 |
| `images` | `VARCHAR(1000)` | 物品图片（JSON数组，MinIO URL） | 发布时上传 | 列表/详情 |
| `location` | `VARCHAR(200)` | 遗失/拾取地点 | 发布时填写 | 列表/详情 |
| `contact` | `VARCHAR(50)` | 联系方式 | 发布时填写 | 详情 |
| `status` | `TINYINT(1)` DEFAULT 1 | 状态：1=寻找中 2=已找到/已归还 | 发布者关闭 | 列表过滤 |
| `create_time` | `DATETIME` | 发布时间 | 系统自动 | 列表排序 |

**业务规则：**
- 发布者可以标记已找到/已归还，关闭该条目
- 隐私考虑：`contact` 在列表页不返回完整信息，需进入详情页

---

### 四、公告模块（`campus-announce`）

#### 8. `announces` — 公告表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `title` | `VARCHAR(200)` | 公告标题 | 管理员发布 | 公告列表/通知 |
| `content` | `LONGTEXT` | 公告正文（富文本 HTML） | 管理员发布（Tiptap） | 公告详情 |
| `category` | `VARCHAR(30)` | 分类：通知/学术/活动/行政/紧急 | 管理员选择 | 列表分类筛选 |
| `tags` | `VARCHAR(500)` | 标签（JSON数组，如 ["考试","教务处"]） | 管理员填写 | 列表搜索筛选 |
| `is_pinned` | `TINYINT(1)` DEFAULT 0 | 是否置顶 | 管理员设置 | 列表排序（置顶优先） |
| `publish_time` | `DATETIME` | 定时发布时间（NULL=立即发布） | 管理员设置 | 列表过滤 |
| `is_published` | `TINYINT(1)` DEFAULT 0 | 发布状态：0=草稿 1=已发布 | 管理员 | 列表过滤 |
| `view_count` | `INT` DEFAULT 0 | 阅读数 | 系统自增 | 详情展示/Web数据 |
| `create_by` | `BIGINT(20)` FK→users.id | 发布人 ID | 系统绑定 | 后台审计 |
| `create_time` | `DATETIME` | 创建时间 | 系统自动 | 列表排序 |
| `update_time` | `DATETIME` | 最后修改时间 | 系统自动 | 后台审计 |

**业务规则：**
- 只有 `admin` 角色可以发布/管理公告
- 支持定时发布：`publish_time` 不为空时，到点自动切换 `is_published=1`
- RabbitMQ 推送：公告发布后写入 MQ → Web 后台 + 鸿蒙 App 通知
- 置顶公告始终排在列表最前

#### 9. `events` — 活动/事件表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | 全局 |
| `title` | `VARCHAR(200)` | 活动名称 | 管理员 | 活动列表/详情 |
| `description` | `TEXT` | 活动介绍 | 管理员 | 活动详情 |
| `cover_image` | `VARCHAR(500)` | 封面图（MinIO URL） | 管理员 | 活动列表 |
| `location` | `VARCHAR(200)` | 活动地点 | 管理员 | 活动详情/签到 |
| `start_time` | `DATETIME` | 开始时间 | 管理员 | 列表排序/日程 |
| `end_time` | `DATETIME` | 结束时间 | 管理员 | 列表/日程 |
| `signup_limit` | `INT` DEFAULT 0 | 报名人数上限（0=不限） | 管理员设置 | 报名校验 |
| `signed_count` | `INT` DEFAULT 0 | 当前已报名人数 | 报名/取消报名时更新 | 详情展示 |
| `check_in_code` | `VARCHAR(100)` | 签到动态码（定时刷新） | 系统生成 | 扫码签到验签 |
| `status` | `TINYINT(1)` | 状态：1=报名中 2=进行中 3=已结束 4=已取消 | 管理员+系统 | 列表过滤 |
| `create_by` | `BIGINT(20)` FK→users.id | 发布人 | 系统 | 后台审计 |
| `create_time` | `DATETIME` | 创建时间 | 系统 | 列表 |

**业务规则：**
- `signup_limit > 0` 时，报名人数到上限后拒绝新报名
- 签到码每分钟刷新，防止截图代签
- 签到需校验 GPS（在活动地点 100m 范围内）

#### 10. `event_signups` — 活动报名表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `event_id` | `BIGINT(20)` FK→events.id | 活动 ID | 报名接口 | 报名列表 |
| `user_id` | `BIGINT(20)` FK→users.id | 报名用户 ID | 报名接口 | 我的报名/签到核验 |
| `is_signed_in` | `TINYINT(1)` DEFAULT 0 | 是否已签到 | 扫码签到 | 签到统计 |
| `sign_in_time` | `DATETIME` | 签到时间 | 系统自动 | 签到记录 |
| `create_time` | `DATETIME` | 报名时间 | 系统自动 | 排序 |

**业务规则：**
- `event_id + user_id` 联合唯一（一个用户只能报一次）
- 取消报名时删除记录（或标记取消），释放名额

#### 11. `notifications` — 消息通知表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `user_id` | `BIGINT(20)` FK→users.id | 接收用户 ID | RabbitMQ消费者 | 我的通知列表 |
| `title` | `VARCHAR(200)` | 通知标题 | 公告发布/活动提醒/系统 | 通知列表 |
| `content` | `VARCHAR(1000)` | 通知内容摘要 | 同上 | 通知详情 |
| `type` | `VARCHAR(30)` | 类型：announce/event/system/chat | 同上 | 分类筛选 |
| `ref_id` | `BIGINT(20)` | 关联业务 ID（公告ID/活动ID等） | 同上 | 点击跳转对应页面 |
| `is_read` | `TINYINT(1)` DEFAULT 0 | 是否已读 | 用户点击/MARK_READ | 未读数统计 |
| `create_time` | `DATETIME` | 通知时间 | 系统自动 | 列表排序 |

**业务规则：**
- RabbitMQ 异步写入，不阻塞公告发布
- 用户点击通知时标记已读 + 跳转到关联页面（通过 `ref_id`）
- 鸿蒙端角标显示未读数量

---

### 五、IM 模块（`campus-chat`）

#### 12. `chat_messages` — 聊天消息表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `msg_id` | `VARCHAR(64)` UNIQUE | 消息唯一 ID（雪花算法/UUID） | Netty生成 | 消息去重/多端同步 |
| `sender_id` | `BIGINT(20)` FK→users.id | 发送者 ID | WebSocket消息 | 消息列表/未读计数 |
| `receiver_id` | `BIGINT(20)` FK→users.id | 接收者 ID | WebSocket消息 | 消息列表 |
| `content` | `TEXT` | 消息内容（文本） | 前端发送 | 聊天记录展示 |
| `msg_type` | `TINYINT(1)` | 消息类型：1=文本 2=图片 3=商品卡片 | 前端指定 | 消息渲染 |
| `is_read` | `TINYINT(1)` DEFAULT 0 | 是否已读 | 接收者打开会话时更新 | 未读数统计 |
| `create_time` | `DATETIME` | 发送时间 | 系统自动 | 消息排序/时间戳 |

**业务规则：**
- 通过 Netty WebSocket 实时收发，持久化到 MySQL
- 图片消息先上传 MinIO，content 存图片 URL
- 商品卡片消息 `content` 存商品 ID JSON

#### 13. `offline_messages` — 离线消息表

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `msg_id` | `VARCHAR(64)` UNIQUE | 对应 chat_messages 的消息 ID | Netty | 上线推送 |
| `receiver_id` | `BIGINT(20)` FK→users.id | 接收者 ID | Netty | 上线时查询 |
| `msg_json` | `TEXT` | 消息完整 JSON（含 sender/content/type/time） | Netty | 批量推送后序列化返回 |
| `is_pushed` | `TINYINT(1)` DEFAULT 0 | 是否已推送给用户 | 上线推送后标记 | 查询未推送消息 |
| `create_time` | `DATETIME` | 消息原发送时间 | 系统 | 排序 |

**业务规则：**
- 消息发送时接收者不在线 → 存入此表
- 接收者上线后批量推送 + 标记已推送
- 已推送的离线消息可定期清理

#### 14. `conversations` — 会话表（可选，后期优化）

| 字段 | 类型 | 说明 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `id` | `BIGINT(20)` PK | 自增主键 | 系统 | — |
| `user_a_id` | `BIGINT(20)` FK→users.id | 用户A ID | 首次聊天创建 | 会话列表 |
| `user_b_id` | `BIGINT(20)` FK→users.id | 用户B ID | 首次聊天创建 | 会话列表 |
| `last_msg` | `VARCHAR(500)` | 最后一条消息摘要 | 每次发消息更新 | 会话列表展示 |
| `last_msg_time` | `DATETIME` | 最后消息时间 | 每次发消息更新 | 会话列表排序 |
| `unread_a` | `INT` DEFAULT 0 | 用户A 未读数 | 接收者读取后清零 | 角标 |
| `unread_b` | `INT` DEFAULT 0 | 用户B 未读数 | 接收者读取后清零 | 角标 |

**说明**：此表用于鸿蒙端"消息列表"页快速查询，避免每次 JOIN 两张用户表。一期可选，二期补上。

---

### 六、AI 模块（Python 端独立存储）

AI 向量数据存在本地 ChromaDB（`ai-service/chroma_db/`），不走 MySQL，无需建表。文档元数据（标题、分类、上传时间等）可以通过 `ai-service` 的 ChromaDB metadata 管理，不在此文档范围。

---

## 附录

### 索引建议

| 表 | 索引 | 类型 | 原因 |
|----|------|------|------|
| users | `idx_student_id` | UNIQUE | 学号唯一查询 |
| courses | `idx_user_semester` | 联合索引 | 查某人某学期课表 |
| courses | `idx_classroom_week_day` | 联合索引 | 教室占用查询 |
| products | `idx_category_status` | 联合索引 | 列表分类筛选 |
| products | `idx_user_id` | 普通索引 | 我发布的商品 |
| favorites | `idx_user_product` | UNIQUE | 查是否已收藏 + toggle |
| announces | `idx_pinned_publish` | 联合索引 | 公告列表排序 |
| notifications | `idx_user_read` | 联合索引 | 查某用户未读通知 |
| chat_messages | `idx_sender_receiver` | 联合索引 | 查两人聊天记录 |
| offline_messages | `idx_receiver_pushed` | 联合索引 | 查某用户待推送消息 |

### MyBatis-Plus 全局配置

```yaml
# campus-server/campus-user/src/main/resources/application.yml
mybatis-plus:
  global-config:
    db-config:
      id-type: auto                      # 自增主键
      logic-delete-field: deleted        # 逻辑删除字段
      logic-delete-value: 1              # 删除标记
      logic-not-delete-value: 0          # 未删除标记
      table-prefix: ""                   # 无统一前缀
  configuration:
    map-underscore-to-camel-case: true   # 下划线→驼峰
```

**注意**：`deleted` 逻辑删除字段为 MyBatis-Plus 默认行为，所有表都会被影响。当前 3 个 Java 实体中未显式声明 `deleted` 字段，但配置中已启用逻辑删除 — 如不需要逻辑删除特性，建表时可忽略该字段。

### 谁用哪个表

| 表 | 鸿蒙 App | Web 后台 | AI 服务 | Java 后端 |
|----|----------|----------|---------|-----------|
| users | ✅ 注册/登录/个人信息 | ✅ 用户管理/数据统计 | ❌ | ✅ 全部 |
| courses | ✅ 周课表/日课表 | ✅ Excel导入/管理 | ❌ | ✅ 全部 |
| classrooms | ✅ 空教室查询 | ✅ 教室管理 | ❌ | ✅ 全部 |
| semesters | ❌ | ✅ 学期管理 | ❌ | ✅ 全部 |
| products | ✅ 浏览/发布/收藏 | ✅ 审核/管理 | ❌ | ✅ 全部 |
| favorites | ✅ 我的收藏 | ❌ | ❌ | ✅ 全部 |
| lost_found | ✅ 浏览/发布 | ✅ 管理 | ❌ | ✅ 全部 |
| announces | ✅ 公告列表/详情 | ✅ 发布/管理 | ❌ | ✅ 全部 |
| events | ✅ 浏览/报名/签到 | ✅ 发布/管理 | ❌ | ✅ 全部 |
| event_signups | ✅ 我的报名/签到 | ✅ 报名统计 | ❌ | ✅ 全部 |
| notifications | ✅ 消息中心 | ✅ 推送管理 | ❌ | ✅ RabbitMQ消费者 |
| chat_messages | ✅ IM聊天 | ❌ | ❌ | ✅ Netty服务 |
| offline_messages | ✅ 上线拉取 | ❌ | ❌ | ✅ Netty服务 |
| conversations | ✅ 会话列表 | ❌ | ❌ | ✅ 会话服务 |
