# 数据库设计文档

**项目**：智能校园助手
**数据库**：`campus_db`（MySQL 8.0+）
**版本**：v2.0
**更新日期**：2026-07-11
**维护人**：曹泽涵

---

## 目录

1. [表总览](#1-表总览)
2. [用户与认证](#2-用户与认证)
3. [课表与教室](#3-课表与教室)
4. [交易与失物招领](#4-交易与失物招领)
5. [公告与活动](#5-公告与活动)
6. [IM 聊天](#6-im-聊天)
7. [AI 知识库](#7-ai-知识库)
8. [索引说明](#8-索引说明)
9. [ER 关系说明](#9-er-关系说明)
10. [更新记录](#10-更新记录)

---

## 1. 表总览

| 序号 | 表名 | 所属模块 | 说明 | 数据量预估 |
|------|------|---------|------|-----------|
| 1 | `classes` | 用户 | 班级 | ~500 |
| 2 | `teachers` | 用户 | 教师 | ~2000 |
| 3 | `users` | 用户 | 学生用户 | ~20000 |
| 4 | `user_favorites` | 用户 | 收藏 | ~50000 |
| 5 | `user_subscriptions` | 用户 | 推送订阅 | ~30000 |
| 6 | `semesters` | 课表 | 学期 | ~20 |
| 7 | `courses` | 课表 | 课程基础信息 | ~5000 |
| 8 | `course_schedules` | 课表 | 课程安排 | ~20000 |
| 9 | `course_class` | 课表 | 课程-班级关联 | ~50000 |
| 10 | `student_timetable` | 课表 | 学生课表缓存 | ~200000 |
| 11 | `classrooms` | 课表 | 教室 | ~500 |
| 12 | `room_occupancy` | 课表 | 教室占用 | ~100000 |
| 13 | `section_times` | 课表 | 节次时间 | 10（固定） |
| 14 | `product_categories` | 交易 | 商品分类 | ~20 |
| 15 | `products` | 交易 | 二手商品 | ~5000 |
| 16 | `lost_founds` | 交易 | 失物招领 | ~2000 |
| 17 | `announcements` | 公告 | 公告 | ~2000 |
| 18 | `events` | 公告 | 活动事件 | ~1000 |
| 19 | `event_registrations` | 公告 | 活动报名 | ~10000 |
| 20 | `notifications` | 公告 | 消息通知 | ~100000 |
| 21 | `chat_conversations` | IM | 聊天会话 | ~10000 |
| 22 | `chat_messages` | IM | 聊天消息 | ~500000 |
| 23 | `offline_messages` | IM | 离线消息 | ~50000 |
| 24 | `knowledge_docs` | AI | 知识文档 | ~200 |
| 25 | `knowledge_chunks` | AI | 文档分段 | ~5000 |

**总计**：25 张表

---

## 2. 用户与认证

### 2.1 classes — 班级表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 班级ID |
| name | VARCHAR(50) | NOT NULL | 班级名称，如"物联网2301" |
| college | VARCHAR(50) | | 所属学院 |
| major | VARCHAR(50) | | 专业 |
| grade | VARCHAR(10) | | 年级，如"2023" |
| head_teacher | VARCHAR(50) | | 班主任姓名 |
| student_count | INT | DEFAULT 0 | 学生人数 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**唯一索引**：`uk_name_grade` → (name, grade)

**说明**：班级是课表匹配的核心桥梁——学生属于班级，课程安排给班级。课表导入时，根据 Excel 中的班级名找到对应的 `class_id`，再批量生成 `student_timetable`。

---

### 2.2 teachers — 教师表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 教师ID |
| teacher_no | VARCHAR(20) | NOT NULL, UNIQUE | 工号 |
| name | VARCHAR(50) | NOT NULL | 姓名 |
| title | VARCHAR(30) | | 职称：教授/副教授/讲师 |
| college | VARCHAR(50) | | 所属学院 |
| phone | VARCHAR(20) | | 联系电话 |
| email | VARCHAR(100) | | 邮箱 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

**唯一索引**：`uk_teacher_no` → (teacher_no)

**说明**：教师独立存储，与 `users`（学生）分离，因为教师角色不同（不需要登录 App 做二手交易等操作）。管理员导入课表时通过教师姓名或工号匹配。

---

### 2.3 users — 用户表（学生）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 用户ID |
| student_id | VARCHAR(20) | NOT NULL, UNIQUE | 学号 |
| name | VARCHAR(50) | NOT NULL | 姓名 |
| password | VARCHAR(200) | NOT NULL | BCrypt 加密密码 |
| avatar | VARCHAR(500) | | 头像URL |
| college | VARCHAR(50) | | 学院 |
| major | VARCHAR(50) | | 专业 |
| grade | VARCHAR(10) | | 年级，如"2023" |
| class_id | BIGINT | → classes.id | 所属班级ID |
| phone | VARCHAR(20) | | 手机号 |
| role | VARCHAR(20) | DEFAULT 'student' | 角色：student/admin |
| credit_score | INT | DEFAULT 100 | 信用分（二手交易用） |
| status | TINYINT | DEFAULT 1 | 状态：1正常 / 0禁用 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

**唯一索引**：`uk_student_id` → (student_id)
**普通索引**：`idx_class_id` → (class_id)，`idx_college` → (college)

**说明**：学生通过 `class_id` 关联班级，一键同步课表时根据班级→课程安排→课程缓存。

---

### 2.4 user_favorites — 收藏表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 用户ID |
| target_type | VARCHAR(20) | NOT NULL | 类型：product/event |
| target_id | BIGINT | NOT NULL | 收藏对象ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**唯一索引**：`uk_fav` → (user_id, target_type, target_id)

---

### 2.5 user_subscriptions — 推送订阅标签

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 用户ID |
| tag | VARCHAR(50) | NOT NULL | 标签：教务/社团/计算机学院 等 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**唯一索引**：`uk_user_tag` → (user_id, tag)

---

## 3. 课表与教室

### 3.1 semesters — 学期表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| name | VARCHAR(50) | NOT NULL | 学期名称 |
| start_date | DATE | NOT NULL | 学期开始日期 |
| end_date | DATE | NOT NULL | 学期结束日期 |
| week_count | INT | NOT NULL | 总周数 |
| is_current | TINYINT | DEFAULT 0 | 是否当前学期 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

---

### 3.2 courses — 课程基础信息表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 课程ID |
| semester_id | BIGINT | NOT NULL | 所属学期 |
| course_name | VARCHAR(100) | NOT NULL | 课程名称 |
| course_code | VARCHAR(30) | | 课程编号 |
| total_hours | INT | | 总学时 |
| credits | DECIMAL(3,1) | | 学分 |
| exam_type | VARCHAR(20) | DEFAULT '考试' | 考核方式：考试/考查 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**设计思路**：`courses` 只存课程的静态属性（名称、学分等），不绑定具体时间地点。一门课可以有多个开课安排（如高数周一1-2节在301、周三3-4节在302）。

---

### 3.3 course_schedules — 课程安排表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| course_id | BIGINT | NOT NULL | 课程ID → courses.id |
| semester_id | BIGINT | NOT NULL | 学期ID |
| teacher_id | BIGINT | | 教师ID → teachers.id |
| classroom | VARCHAR(100) | | 教室名称（冗余，用于快速展示） |
| day_of_week | TINYINT | NOT NULL | 星期几：1-7 |
| start_section | TINYINT | NOT NULL | 起始节次：1-12 |
| end_section | TINYINT | NOT NULL | 结束节次：1-12 |
| start_week | TINYINT | NOT NULL | 起始教学周 |
| end_week | TINYINT | NOT NULL | 结束教学周 |
| week_parity | VARCHAR(10) | DEFAULT 'all' | 周次奇偶：all全部 / odd单周 / even双周 |
| remark | VARCHAR(200) | | 备注 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**核心设计**：
- 一门课可能有 **多条** 安排记录（周一高数在301 + 周三高数在302）
- `week_parity` 解决中飞院常见的单双周排课问题
- 前端渲染课表时的过滤逻辑：`当前周 BETWEEN start_week AND end_week AND (week_parity='all' OR 当前周%2=week_parity条件)`

---

### 3.4 course_class — 课程-班级关联表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| course_schedule_id | BIGINT | NOT NULL | 课程安排ID |
| class_id | BIGINT | NOT NULL | 班级ID → classes.id |

**唯一索引**：`uk_schedule_class` → (course_schedule_id, class_id)

**说明**：解决合班上课场景——同一门课开给物联网2301和物联网2302两个班。

---

### 3.5 student_timetable — 学生课表缓存表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 学生ID → users.id |
| course_schedule_id | BIGINT | NOT NULL | 课程安排ID |
| semester_id | BIGINT | NOT NULL | 学期ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**唯一索引**：`uk_user_schedule` → (user_id, course_schedule_id)

**说明**：
- 当管理员导入课表后，系统会根据"学生 → 班级 → 课程安排"自动生成此表数据
- 学生点击"同步课表"时直接查此表，无需实时联表计算
- 这就是 **课表一同步、最快** 的来源

---

### 3.6 classrooms — 教室表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| building | VARCHAR(50) | NOT NULL | 教学楼名 |
| room_no | VARCHAR(20) | NOT NULL | 房间号 |
| capacity | INT | DEFAULT 60 | 容量 |
| has_projector | TINYINT | DEFAULT 1 | 是否有投影 |
| has_ac | TINYINT | DEFAULT 1 | 是否有空调 |
| type | VARCHAR(20) | DEFAULT '普通教室' | 教室类型 |
| status | VARCHAR(20) | DEFAULT '空闲' | 状态：空闲/上课/维修 |

**唯一索引**：`uk_room` → (building, room_no)

---

### 3.7 room_occupancy — 教室占用记录

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| classroom_id | BIGINT | NOT NULL | 教室ID |
| course_name | VARCHAR(100) | | 课程/活动名称 |
| occupy_date | DATE | NOT NULL | 占用日期 |
| start_section | TINYINT | NOT NULL | 起始节次 |
| end_section | TINYINT | NOT NULL | 结束节次 |
| occupy_type | VARCHAR(20) | DEFAULT '课程' | 类型：课程/考试/活动/临时 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：学生通过扫码查教室占用情况，查询逻辑 `WHERE classroom_id=? AND occupy_date=? AND start_section<=? AND end_section>=?`。

---

### 3.8 section_times — 节次时间映射

固定数据表，记录中飞院作息时间：

| 节次 | 开始 | 结束 |
|------|------|------|
| 1 | 08:30 | 09:15 |
| 2 | 09:20 | 10:05 |
| 3 | 10:25 | 11:10 |
| 4 | 11:15 | 12:00 |
| 5 | 14:30 | 15:15 |
| 6 | 15:20 | 16:05 |
| 7 | 16:25 | 17:10 |
| 8 | 17:15 | 18:00 |
| 9 | 19:00 | 19:45 |
| 10 | 19:50 | 20:35 |

---

## 4. 交易与失物招领

### 4.1 product_categories — 商品分类

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| name | VARCHAR(50) | NOT NULL | 分类名 |
| icon | VARCHAR(100) | | 图标 |
| parent_id | BIGINT | DEFAULT 0 | 父分类ID（0=顶级） |
| sort_order | INT | DEFAULT 0 | 排序 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：二级分类结构。顶级分类有：教材/教辅、电子产品、生活用品、运动户外、其他。

---

### 4.2 products — 二手商品表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| seller_id | BIGINT | NOT NULL | 卖家ID |
| category_id | BIGINT | NOT NULL | 分类ID |
| title | VARCHAR(200) | NOT NULL | 标题 |
| description | TEXT | | 描述 |
| price | DECIMAL(10,2) | NOT NULL | 售价 |
| original_price | DECIMAL(10,2) | | 原价 |
| condition_level | TINYINT | NOT NULL | 成色：1全新 / 2几乎全新 / 3有使用痕迹 |
| images | JSON | NOT NULL | 图片URL数组 |
| tags | JSON | | 自定义标签，如["高数","考研"] |
| status | TINYINT | DEFAULT 1 | 状态：1在售 / 2已售 / 3下架 |
| view_count | INT | DEFAULT 0 | 浏览量 |
| favorite_count | INT | DEFAULT 0 | 收藏数 |
| campus_location | VARCHAR(100) | | 交易地点偏好 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |
| update_time | DATETIME | ON UPDATE CURRENT_TIMESTAMP | |

**说明**：`tags` 字段用于增强搜索精度，用户可以通过自定义标签搜索（如搜"考研"能找到标记了考研的任意分类商品）。`images` 字段存储多张图片URL的JSON数组。

---

### 4.3 lost_founds — 失物招领

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 发布者ID |
| type | TINYINT | NOT NULL | 1寻物 / 2招领 |
| title | VARCHAR(200) | NOT NULL | 标题 |
| description | TEXT | | 描述 |
| images | JSON | | 图片URL数组 |
| location_desc | VARCHAR(200) | | 位置描述 |
| category | VARCHAR(50) | | 物品分类 |
| status | TINYINT | DEFAULT 1 | 1寻找中 / 2已找到或已归还 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

---

## 5. 公告与活动

### 5.1 announcements — 公告表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| title | VARCHAR(200) | NOT NULL | 标题 |
| content | TEXT | NOT NULL | 富文本内容（HTML） |
| summary | VARCHAR(500) | | 摘要 |
| category | VARCHAR(30) | NOT NULL | 分类：教务/学工/社团/后勤/紧急 |
| publisher_id | BIGINT | NOT NULL | 发布者（admin用户） |
| is_top | TINYINT | DEFAULT 0 | 是否置顶 |
| is_published | TINYINT | DEFAULT 0 | 0草稿 / 1已发布 |
| publish_time | DATETIME | | 发布时间（支持定时） |
| expire_time | DATETIME | | 过期时间 |
| target_tags | JSON | | 推送目标标签 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：`target_tags` 用于精准推送——比如只推给"计算机学院"+"大三"标签的学生。

---

### 5.2 events — 活动事件表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| title | VARCHAR(200) | NOT NULL | 活动标题 |
| description | TEXT | | 描述 |
| cover_image | VARCHAR(500) | | 封面图 |
| event_type | VARCHAR(30) | | 类型：讲座/比赛/社团/演出/志愿 |
| location | VARCHAR(200) | | 地点 |
| start_time | DATETIME | NOT NULL | 开始时间 |
| end_time | DATETIME | NOT NULL | 结束时间 |
| max_participants | INT | DEFAULT 0 | 人数上限（0=不限） |
| current_participants | INT | DEFAULT 0 | 当前报名人数 |
| organizer | VARCHAR(100) | | 主办方 |
| status | VARCHAR(20) | DEFAULT '报名中' | 报名中/进行中/已结束 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

---

### 5.3 event_registrations — 活动报名

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| event_id | BIGINT | NOT NULL | 活动ID |
| user_id | BIGINT | NOT NULL | 用户ID |
| sign_in_time | DATETIME | | 签到时间 |
| sign_in_method | VARCHAR(20) | | 签到方式：扫码/手动 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**唯一索引**：`uk_event_user` → (event_id, user_id)

---

### 5.4 notifications — 消息通知

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 接收者 |
| type | VARCHAR(30) | NOT NULL | announcement/chat/event/system |
| title | VARCHAR(200) | | 标题 |
| content | TEXT | | 内容 |
| related_id | BIGINT | | 关联对象ID |
| is_read | TINYINT | DEFAULT 0 | 是否已读 |
| push_status | TINYINT | DEFAULT 0 | 推送状态：0未推送 / 1已推 / 2已送达 / 3已读 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：`push_status` 追踪推送链路，便于排查推送失败。

---

## 6. IM 聊天

### 6.1 chat_conversations — 会话

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user1_id | BIGINT | NOT NULL | 用户1（小ID） |
| user2_id | BIGINT | NOT NULL | 用户2（大ID） |
| product_id | BIGINT | | 关联商品ID（从商品详情发起的聊天） |
| last_message | TEXT | | 最后一条消息 |
| last_time | DATETIME | | 最后消息时间 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**唯一索引**：`uk_users_product` → (user1_id, user2_id, product_id)

**说明**：`user1_id < user2_id` 约束，避免重复会话。

---

### 6.2 chat_messages — 消息

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| conversation_id | BIGINT | NOT NULL | 会话ID |
| sender_id | BIGINT | NOT NULL | 发送者 |
| content | TEXT | | 消息内容 |
| msg_type | VARCHAR(20) | DEFAULT 'text' | text/image |
| is_read | TINYINT | DEFAULT 0 | 已读 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

---

### 6.3 offline_messages — 离线消息

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| user_id | BIGINT | NOT NULL | 接收者 |
| message_json | JSON | NOT NULL | 完整消息JSON |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：用户离线时，WebSocket 消息存入此表，用户上线后推送并清理。

---

## 7. AI 知识库

### 7.1 knowledge_docs — 知识文档

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| title | VARCHAR(200) | NOT NULL | 文档标题 |
| content | TEXT | NOT NULL | Markdown 原文 |
| category | VARCHAR(50) | NOT NULL | 分类：校规/办事流程/选课指南/FAQ等 |
| source | VARCHAR(100) | | 来源文件名 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

---

### 7.2 knowledge_chunks — 文档分段

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | |
| doc_id | BIGINT | NOT NULL | 关联文档ID |
| chunk_index | INT | NOT NULL | 分段序号 |
| content | TEXT | NOT NULL | 分段文本 |
| vector_id | VARCHAR(100) | | ChromaDB 向量ID |
| token_count | INT | | 分段 token 数 |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | |

**说明**：`vector_id` 关联 ChromaDB 中的向量数据，实现 RAG 检索。

---

## 8. 索引说明

### 8.1 索引统计

**总计**：25 张表，含 15 个唯一索引 + 30+ 个普通索引。

### 8.2 高频查询 & 对应索引

| 查询场景 | 涉及表 | 关键索引 |
|----------|--------|---------|
| 学生同步课表 | student_timetable | idx_user_semester(user_id, semester_id) |
| 课程安排查询 | course_schedules | idx_weekday_section(day_of_week, start_section) |
| 教室占用查询 | room_occupancy | idx_classroom_date(classroom_id, occupy_date) |
| 学生课表查看 | user_subscriptions | idx_user_id(user_id) |
| 欢迎页面显示 | notifications | idx_user_read(user_id, is_read) |
| 座位查询 | room_occupancy | idx_date_section(occupy_date, start_section) |

### 8.3 唯一索引

主要用于防止数据重复：学号唯一、教师工号唯一、教室去重、用户收藏去重、活动报名去重等。

---

## 9. ER 关系说明

### 9.1 核心关系图（课表体系）

```
classes ──┬──< course_class >── course_schedules ──> courses
          │                              │
          │                              └──> teachers
          │
users ────┘──< student_timetable >── course_schedules
```

**课表同步流程**：
1. 管理员导入 Excel → 写入 `courses` + `course_schedules` + `course_class`
2. 批量脚本：`student_timetable` 根据 `users.class_id` → `course_class.class_id` → `course_schedules` 生成
3. 学生端 "同步课表" → `SELECT * FROM student_timetable WHERE user_id=?`

### 9.2 其他关系

```
users ──< products          # 一个用户多个商品
users ──< lost_founds       # 一个用户多个失物招领
users ──< event_registrations ──> events   # 用户报名活动
users ──< notifications     # 用户接收通知
users ──< user_favorites    # 用户收藏（多态）
users ──< user_subscriptions  # 用户订阅标签
users ──< chat_conversations   # 参与聊天
users ──< chat_messages     # 发送消息
events ──< event_registrations  # 活动有多人报名
course_schedules ──< course_class ──> classes  # 安排→班级（多对多）
```

---

## 10. 更新记录

| 日期 | 版本 | 变更 | 负责人 |
|------|------|------|--------|
| 2026-07-08 | v1.0 | 初始设计 | 曹泽涵 |
| 2026-07-11 | v2.0 | 新增班级/教师表，重构课表体系，支持单双周，新增索引及字段 | 曹泽涵 |
