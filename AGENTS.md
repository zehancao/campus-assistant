# AGENTS.md — 智能校园助手

你正在参与「智能校园助手」实训项目。这是一个小组合作项目，你在团队里有明确的角色和任务。

## 项目背景
- **项目名称**：智能校园助手平台
- **目标**：面向高校学生的一站式校园生活服务平台
- **交付物**：鸿蒙 App + Web 管理后台
- **周期**：4 周
- **团队**：5 人

## 五大模块
1. 课表与教室管理
2. 二手交易与失物招领
3. 校园公告与事件日历
4. AI 智能问答（本地化部署：Ollama + ChromaDB + RAG）
5. 个人中心与 IM 聊天

## 技术栈
- 鸿蒙：ArkTS + ArkUI + FormAbility (API 12+)
- Web：Vue 3 + TypeScript + Vite + Naive UI + ECharts
- 后端：Java 17 + Spring Boot 3 + MyBatis-Plus + MySQL + Redis + RabbitMQ + Elasticsearch
- AI：Python + FastAPI + Ollama(qwen2.5:7b) + ChromaDB

## 关键决策
- 不做商城，做校园助手
- 不做地图导航（太复杂，性价比低）
- 不做 AI 图片分类（改为手动标签）
- AI 全部本地化部署，不调外部 API

## 角色识别

检查你当前打开的工作目录，找到对应子目录，然后按你的角色执行任务。

**如果你是组员A（鸿蒙一号）**：
- 你的目录是 `harmony-app/`
- 你负责：课表与教室管理 + 个人中心
- 你要写的页面：LoginPage、SchedulePage（周+日）、ClassroomScanPage、ProfilePage、NotificationsPage
- 你要写的组件：元服务卡片（2x2 + 2x4）
- 技术栈：ArkTS + ArkUI + FormAbility + RelationalStore + ScanKit
- 详细任务清单见 `harmony-app/README.md`

**如果你是组员B（鸿蒙二号）**：
- 你的目录是 `harmony-app/`
- 你负责：二手交易 + IM 聊天
- 你要写的页面：MarketPage、ProductPublishPage、ProductDetailPage、ConversationListPage、ChatPage、LoginPage
- 技术栈：ArkTS + ArkUI + WebSocket + HTTP
- ⚠️ 跟组员A 在同一个目录下开发，注意别改对方的文件
- 详细任务清单见 `harmony-app/README.md`

**如果你是组员C（Web 前端）**：
- 你的目录是 `web-admin/`
- 你负责：Web 管理后台 + 数据大屏
- 你要写的页面：登录、Dashboard（数据大屏）、课表管理、公告管理、交易管理、知识库管理、用户管理
- 技术栈：Vue 3 + TypeScript + Vite + Naive UI + ECharts + Tiptap + Axios + Pinia
- 详细任务清单见 `web-admin/README.md`

**如果你是组员D（后端）**：
- 你的目录是 `campus-server/`
- 你负责：全部业务接口 + WebSocket IM + RabbitMQ 推送
- 你要写的模块：用户、课表、交易、公告、IM（Netty）、推送
- 技术栈：Java 17 + Spring Boot 3 + MyBatis-Plus + MySQL + Redis + Elasticsearch + Netty
- 详细接口清单见 `campus-server/README.md`

**如果你是曹老板（组长）**：
- 你的目录是 `ai-service/` + `campus-server/` + `docs/`
- 你负责：AI 知识库本地化部署 + 后端骨架 + 数据库 + 基础设施
- 详细任务清单见 `ai-service/README.md`

## 开发规则

### Git 操作
- **只在你自己分支上写代码**：feature/hm1, feature/hm2, feature/web, feature/server, feature/ai
- 不要直接改 main 或 dev
- 每天开工：`git checkout dev && git pull origin dev && git checkout 你自己的分支 && git merge dev`
- 每天收工：`git add . && git commit -m "feat: xxx" && git push origin 你自己的分支`

### 代码规范
- 接口调用统一走封装的请求层，不要各自写 http 调用
- 所有接口响应格式：`{code, message, data}`
- token 用 JWT，过期时间 2 小时
- 不要写假数据凑数——能对接后端就对接，暂时对接不了就用 TypeScript interface 定义好数据结构

### 注意事项
- 遇到不确定的事（接口格式、页面设计、技术方案），先看 README，再在群里问
- 代码提交前确保能跑，不要推运行不了的代码
- 每天交代码，别攒到最后一天

## 后端 API 地址
- 开发环境：http://localhost:8080
- 接口文档：http://localhost:8080/doc.html
- AI 服务：http://localhost:8000
