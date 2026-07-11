# 智能校园助手

中飞院软通实训项目 — 智能校园助手平台

## 模块
1. 课表与教室管理
2. 二手交易与失物招领
3. 校园公告与事件日历
4. AI 智能问答
5. 个人中心与 IM

## 技术栈
- 鸿蒙 App：ArkTS + ArkUI
- Web 后台：Vue 3 + TypeScript
- 后端：Spring Boot 3 + MyBatis-Plus
- AI：Ollama + ChromaDB + RAG
- 数据库：MySQL 8.0

## 数据库 v2.0（2026-07-11 更新）
详见 [docs/schema.sql](docs/schema.sql)

### 主要变更
- 新增班级表、教师表
- 重构课表体系（courses → course_schedules → course_class）
- 新增 student_timetable 学生课表缓存
- 支持单双周交替（week_parity 字段）
- 新增商品标签、推送追踪等字段
