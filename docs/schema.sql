-- ============================================
-- 智能校园助手 — 数据库建表脚本（v2.0）
-- 数据库：campus_db
-- MySQL 8.0+
-- 修正内容：新增班级/教师/开课结构，重构课表体系
-- 修正日期：2026-07-11
-- ============================================

-- ============================================
-- 1. 用户与认证相关
-- ============================================

-- 班级表
DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT '班级名称，如物联网2301',
  `college` VARCHAR(50) COMMENT '所属学院',
  `major` VARCHAR(50) COMMENT '专业',
  `grade` VARCHAR(10) COMMENT '年级，如2023',
  `head_teacher` VARCHAR(50) COMMENT '班主任',
  `student_count` INT DEFAULT 0 COMMENT '学生人数',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_name_grade` (`name`, `grade`),
  KEY `idx_college` (`college`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='班级表';

-- 教师表
DROP TABLE IF EXISTS `teachers`;
CREATE TABLE `teachers` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `teacher_no` VARCHAR(20) NOT NULL COMMENT '工号',
  `name` VARCHAR(50) NOT NULL COMMENT '姓名',
  `title` VARCHAR(30) COMMENT '职称：教授/副教授/讲师',
  `college` VARCHAR(50) COMMENT '学院',
  `phone` VARCHAR(20) COMMENT '联系电话',
  `email` VARCHAR(100) COMMENT '邮箱',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_teacher_no` (`teacher_no`),
  KEY `idx_college` (`college`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教师表';

-- 用户表
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
  `student_id` VARCHAR(20) NOT NULL COMMENT '学号',
  `name` VARCHAR(50) NOT NULL COMMENT '姓名',
  `password` VARCHAR(200) NOT NULL COMMENT '密码（BCrypt加密）',
  `avatar` VARCHAR(500) COMMENT '头像URL',
  `college` VARCHAR(50) COMMENT '学院',
  `major` VARCHAR(50) COMMENT '专业',
  `grade` VARCHAR(10) COMMENT '年级，如2023',
  `class_id` BIGINT COMMENT '所属班级ID',
  `phone` VARCHAR(20) COMMENT '手机号',
  `role` VARCHAR(20) DEFAULT 'student' COMMENT '角色：student/admin',
  `credit_score` INT DEFAULT 100 COMMENT '信用分',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1正常 0禁用',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `uk_student_id` (`student_id`),
  KEY `idx_class_id` (`class_id`),
  KEY `idx_college` (`college`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- 收藏表
DROP TABLE IF EXISTS `user_favorites`;
CREATE TABLE `user_favorites` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `target_type` VARCHAR(20) NOT NULL COMMENT '收藏类型：product/event',
  `target_id` BIGINT NOT NULL COMMENT '收藏对象ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_fav` (`user_id`, `target_type`, `target_id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='收藏表';

-- 用户订阅标签表
DROP TABLE IF EXISTS `user_subscriptions`;
CREATE TABLE `user_subscriptions` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `tag` VARCHAR(50) NOT NULL COMMENT '订阅标签：教务/社团/学工/计算机学院等',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_user_tag` (`user_id`, `tag`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户推送订阅标签';

-- ============================================
-- 2. 课表与教室相关（重构版）
-- ============================================

-- 学期表
DROP TABLE IF EXISTS `semesters`;
CREATE TABLE `semesters` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT '学期名称，如2026-2027学年第一学期',
  `start_date` DATE NOT NULL COMMENT '学期开始日期',
  `end_date` DATE NOT NULL COMMENT '学期结束日期',
  `week_count` INT NOT NULL COMMENT '总周数',
  `is_current` TINYINT DEFAULT 0 COMMENT '是否当前学期',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学期表';

-- 课程基础信息表
DROP TABLE IF EXISTS `courses`;
CREATE TABLE `courses` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `semester_id` BIGINT NOT NULL COMMENT '学期ID',
  `course_name` VARCHAR(100) NOT NULL COMMENT '课程名称',
  `course_code` VARCHAR(30) COMMENT '课程编号（教务系统编号）',
  `total_hours` INT COMMENT '总学时',
  `credits` DECIMAL(3,1) COMMENT '学分',
  `exam_type` VARCHAR(20) DEFAULT '考试' COMMENT '考核方式：考试/考查',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_semester` (`semester_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程基础信息表';

-- 开课安排（一门课可有多个上课安排，比如周一1-2节+周三3-4节）
DROP TABLE IF EXISTS `course_schedules`;
CREATE TABLE `course_schedules` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `course_id` BIGINT NOT NULL COMMENT '课程ID',
  `semester_id` BIGINT NOT NULL COMMENT '学期ID',
  `teacher_id` BIGINT COMMENT '授课教师ID',
  `classroom` VARCHAR(100) COMMENT '教室名称，如致远楼301',
  `day_of_week` TINYINT NOT NULL COMMENT '星期几：1-7',
  `start_section` TINYINT NOT NULL COMMENT '起始节次',
  `end_section` TINYINT NOT NULL COMMENT '结束节次',
  `start_week` TINYINT NOT NULL COMMENT '起始教学周',
  `end_week` TINYINT NOT NULL COMMENT '结束教学周',
  `week_parity` VARCHAR(10) DEFAULT 'all' COMMENT '周次奇偶：all全部/odd单周/even双周',
  `remark` VARCHAR(200) COMMENT '备注',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_course_semester` (`course_id`, `semester_id`),
  KEY `idx_teacher` (`teacher_id`),
  KEY `idx_classroom` (`classroom`),
  KEY `idx_weekday_section` (`day_of_week`, `start_section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程安排表';

-- 课程-班级关联（一门开课安排对应多个班级，多对多）
DROP TABLE IF EXISTS `course_class`;
CREATE TABLE `course_class` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `course_schedule_id` BIGINT NOT NULL COMMENT '课程安排ID',
  `class_id` BIGINT NOT NULL COMMENT '班级ID',
  UNIQUE KEY `uk_schedule_class` (`course_schedule_id`, `class_id`),
  KEY `idx_class` (`class_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='课程-班级关联表';

-- 学生课表缓存（从导入数据生成，用于学生一键同步和个人视图）
DROP TABLE IF EXISTS `student_timetable`;
CREATE TABLE `student_timetable` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '学生ID',
  `course_schedule_id` BIGINT NOT NULL COMMENT '课程安排ID',
  `semester_id` BIGINT NOT NULL COMMENT '学期ID',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_user_schedule` (`user_id`, `course_schedule_id`),
  KEY `idx_user_semester` (`user_id`, `semester_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生课表缓存表';

-- 教室表
DROP TABLE IF EXISTS `classrooms`;
CREATE TABLE `classrooms` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `building` VARCHAR(50) NOT NULL COMMENT '教学楼',
  `room_no` VARCHAR(20) NOT NULL COMMENT '房间号',
  `capacity` INT DEFAULT 60 COMMENT '容量',
  `has_projector` TINYINT DEFAULT 1 COMMENT '有无投影',
  `has_ac` TINYINT DEFAULT 1 COMMENT '有无空调',
  `type` VARCHAR(20) DEFAULT '普通教室' COMMENT '类型：普通教室/实验室/阶梯教室/机房',
  `status` VARCHAR(20) DEFAULT '空闲' COMMENT '状态：空闲/上课/维修',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_room` (`building`, `room_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教室表';

-- 教室占用记录
DROP TABLE IF EXISTS `room_occupancy`;
CREATE TABLE `room_occupancy` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `classroom_id` BIGINT NOT NULL COMMENT '教室ID',
  `course_name` VARCHAR(100) COMMENT '占用课程/活动名称',
  `occupy_date` DATE NOT NULL COMMENT '占用日期',
  `start_section` TINYINT NOT NULL COMMENT '起始节次',
  `end_section` TINYINT NOT NULL COMMENT '结束节次',
  `occupy_type` VARCHAR(20) DEFAULT '课程' COMMENT '类型：课程/考试/活动/临时',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_classroom_date` (`classroom_id`, `occupy_date`),
  KEY `idx_date_section` (`occupy_date`, `start_section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='教室占用记录';

-- 节次时间映射（初始化数据见下方）
DROP TABLE IF EXISTS `section_times`;
CREATE TABLE `section_times` (
  `section_no` TINYINT PRIMARY KEY COMMENT '节次编号',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='节次时间映射';

-- ============================================
-- 3. 交易与失物招领相关
-- ============================================

-- 商品分类
DROP TABLE IF EXISTS `product_categories`;
CREATE TABLE `product_categories` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL COMMENT '分类名称',
  `icon` VARCHAR(100) COMMENT '图标',
  `parent_id` BIGINT DEFAULT 0 COMMENT '父分类ID，0为顶级',
  `sort_order` INT DEFAULT 0 COMMENT '排序',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品分类';

-- 商品表
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `seller_id` BIGINT NOT NULL COMMENT '卖家ID',
  `category_id` BIGINT NOT NULL COMMENT '分类ID',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `description` TEXT COMMENT '描述',
  `price` DECIMAL(10,2) NOT NULL COMMENT '售价',
  `original_price` DECIMAL(10,2) COMMENT '原价',
  `condition_level` TINYINT NOT NULL COMMENT '成色：1全新 2几乎全新 3有使用痕迹',
  `images` JSON NOT NULL COMMENT '图片URL数组',
  `tags` JSON COMMENT '自定义标签，如["高数","考研"]，支持搜索',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1在售 2已售 3下架',
  `view_count` INT DEFAULT 0 COMMENT '浏览量',
  `favorite_count` INT DEFAULT 0 COMMENT '收藏数',
  `campus_location` VARCHAR(100) COMMENT '交易地点偏好',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY `idx_seller_id` (`seller_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='二手商品表';

-- 失物招领
DROP TABLE IF EXISTS `lost_founds`;
CREATE TABLE `lost_founds` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '发布者ID',
  `type` TINYINT NOT NULL COMMENT '类型：1寻物 2招领',
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `description` TEXT COMMENT '描述',
  `images` JSON COMMENT '图片URL数组',
  `location_desc` VARCHAR(200) COMMENT '文字位置描述',
  `category` VARCHAR(50) COMMENT '物品分类：电子产品/证件/钥匙/衣物/其他',
  `status` TINYINT DEFAULT 1 COMMENT '状态：1寻找中 2已找到/已归还',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='失物招领表';

-- ============================================
-- 4. 公告与活动相关
-- ============================================

-- 公告表
DROP TABLE IF EXISTS `announcements`;
CREATE TABLE `announcements` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '富文本内容（HTML）',
  `summary` VARCHAR(500) COMMENT '摘要',
  `category` VARCHAR(30) NOT NULL COMMENT '分类：教务/学工/社团/后勤/紧急',
  `publisher_id` BIGINT NOT NULL COMMENT '发布者ID（关联users表）',
  `is_top` TINYINT DEFAULT 0 COMMENT '是否置顶',
  `is_published` TINYINT DEFAULT 0 COMMENT '是否发布：0草稿 1已发布',
  `publish_time` DATETIME COMMENT '发布时间（可定时）',
  `expire_time` DATETIME COMMENT '过期时间',
  `target_tags` JSON COMMENT '推送目标标签，如["计算机学院","大三"]',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_category` (`category`),
  KEY `idx_publish_time` (`publish_time`),
  KEY `idx_is_published` (`is_published`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';

-- 活动事件表
DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL COMMENT '活动标题',
  `description` TEXT COMMENT '活动描述',
  `cover_image` VARCHAR(500) COMMENT '封面图',
  `event_type` VARCHAR(30) COMMENT '类型：讲座/比赛/社团/演出/志愿',
  `location` VARCHAR(200) COMMENT '活动地点',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME NOT NULL COMMENT '结束时间',
  `max_participants` INT DEFAULT 0 COMMENT '人数上限，0=不限',
  `current_participants` INT DEFAULT 0 COMMENT '当前报名人数',
  `organizer` VARCHAR(100) COMMENT '主办方',
  `status` VARCHAR(20) DEFAULT '报名中' COMMENT '状态：报名中/进行中/已结束',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_start_time` (`start_time`),
  KEY `idx_status` (`status`),
  KEY `idx_type_time` (`event_type`, `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动事件表';

-- 活动报名
DROP TABLE IF EXISTS `event_registrations`;
CREATE TABLE `event_registrations` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT NOT NULL COMMENT '活动ID',
  `user_id` BIGINT NOT NULL COMMENT '用户ID',
  `sign_in_time` DATETIME COMMENT '签到时间',
  `sign_in_method` VARCHAR(20) COMMENT '签到方式：扫码/手动',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_event_user` (`event_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='活动报名记录';

-- 消息通知
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '接收用户ID',
  `type` VARCHAR(30) NOT NULL COMMENT '类型：announcement/chat/event/system',
  `title` VARCHAR(200) COMMENT '通知标题',
  `content` TEXT COMMENT '通知内容',
  `related_id` BIGINT COMMENT '关联对象ID',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读',
  `push_status` TINYINT DEFAULT 0 COMMENT '推送状态：0未推送 1已推 2已送达 3已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_user_read` (`user_id`, `is_read`),
  KEY `idx_create_time` (`create_time`),
  KEY `idx_user_type` (`user_id`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息通知表';

-- ============================================
-- 5. IM 聊天
-- ============================================

-- 会话表
DROP TABLE IF EXISTS `chat_conversations`;
CREATE TABLE `chat_conversations` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user1_id` BIGINT NOT NULL COMMENT '用户1',
  `user2_id` BIGINT NOT NULL COMMENT '用户2',
  `product_id` BIGINT COMMENT '关联商品ID（从商品详情发起聊天）',
  `last_message` TEXT COMMENT '最后一条消息内容',
  `last_time` DATETIME COMMENT '最后消息时间',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_users_product` (`user1_id`, `user2_id`, `product_id`),
  KEY `idx_user1` (`user1_id`),
  KEY `idx_user2` (`user2_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天会话表';

-- 消息表
DROP TABLE IF EXISTS `chat_messages`;
CREATE TABLE `chat_messages` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `conversation_id` BIGINT NOT NULL COMMENT '会话ID',
  `sender_id` BIGINT NOT NULL COMMENT '发送者ID',
  `content` TEXT COMMENT '消息内容',
  `msg_type` VARCHAR(20) DEFAULT 'text' COMMENT '消息类型：text/image',
  `is_read` TINYINT DEFAULT 0 COMMENT '是否已读',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_conversation` (`conversation_id`),
  KEY `idx_sender` (`sender_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天消息表';

-- 离线消息表
DROP TABLE IF EXISTS `offline_messages`;
CREATE TABLE `offline_messages` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL COMMENT '接收者ID',
  `message_json` JSON NOT NULL COMMENT '完整消息JSON',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='离线消息表';

-- ============================================
-- 6. AI 知识库
-- ============================================

-- 知识文档
DROP TABLE IF EXISTS `knowledge_docs`;
CREATE TABLE `knowledge_docs` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL COMMENT '文档标题',
  `content` TEXT NOT NULL COMMENT 'Markdown原文',
  `category` VARCHAR(50) NOT NULL COMMENT '分类：校规/办事流程/选课指南/FAQ等',
  `source` VARCHAR(100) COMMENT '来源文件名',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='AI知识库文档';

-- 知识文档分段（存ChromaDB向量ID引用）
DROP TABLE IF EXISTS `knowledge_chunks`;
CREATE TABLE `knowledge_chunks` (
  `id` BIGINT PRIMARY KEY AUTO_INCREMENT,
  `doc_id` BIGINT NOT NULL COMMENT '关联文档ID',
  `chunk_index` INT NOT NULL COMMENT '分段序号',
  `content` TEXT NOT NULL COMMENT '分段文本内容',
  `vector_id` VARCHAR(100) COMMENT 'ChromaDB中的向量ID',
  `token_count` INT COMMENT '分段token数',
  `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_doc_id` (`doc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='知识库文档分段';

-- ============================================
-- 7. 初始化数据
-- ============================================

-- 节次时间（中飞院作息）
INSERT INTO `section_times` (`section_no`, `start_time`, `end_time`) VALUES
(1, '08:30', '09:15'),
(2, '09:20', '10:05'),
(3, '10:25', '11:10'),
(4, '11:15', '12:00'),
(5, '14:30', '15:15'),
(6, '15:20', '16:05'),
(7, '16:25', '17:10'),
(8, '17:15', '18:00'),
(9, '19:00', '19:45'),
(10, '19:50', '20:35');

-- 商品分类
INSERT INTO `product_categories` (`id`, `name`, `parent_id`, `sort_order`) VALUES
(1, '教材/教辅', 0, 1),
(2, '公共课教材', 1, 1),
(3, '专业课教材', 1, 2),
(4, '考研/考公资料', 1, 3),
(5, '电子产品', 0, 2),
(6, '手机/平板', 5, 1),
(7, '电脑/配件', 5, 2),
(8, '耳机/音箱', 5, 3),
(9, '其他数码', 5, 4),
(10, '生活用品', 0, 3),
(11, '宿舍日用', 10, 1),
(12, '收纳/家具', 10, 2),
(13, '个护/美妆', 10, 3),
(14, '运动户外', 0, 4),
(15, '球类/器械', 14, 1),
(16, '骑行/滑板', 14, 2),
(17, '户外装备', 14, 3),
(18, '其他', 0, 99),
(19, '免费赠送', 18, 1);

-- ============================================
-- 完成
-- ============================================
SELECT '数据库建表完成 ✅' AS status;
SELECT COUNT(*) AS table_count FROM information_schema.TABLES WHERE table_schema = 'campus_db';
