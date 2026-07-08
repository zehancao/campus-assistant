# 智能校园助手

## 项目简介
面向高校学生的一站式校园生活服务平台。
- **鸿蒙 App**：课表管理、二手交易、AI 问答、校园公告
- **Web 管理后台**：数据大屏、课表导入、公告发布、知识库管理

## 技术栈
| 端 | 技术 |
|---|------|
| 鸿蒙 | ArkTS + ArkUI + FormAbility (API 12+) |
| Web | Vue 3 + TypeScript + Vite |
| 后端 | Spring Boot 3 + MyBatis-Plus |
| AI | Ollama + ChromaDB + FastAPI |
| 基础设施 | MySQL 8 + Redis + RabbitMQ + MinIO + Elasticsearch |

## 模块
1. 课表与教室管理
2. 二手交易与失物招领
3. 校园公告与事件日历
4. AI 智能问答（本地化部署）
5. 个人中心与 IM 聊天

## 团队分工
| 成员 | 负责 | 分支 |
|------|------|------|
| 曹泽涵（组长） | AI知识库 + 后端骨架 + 数据库 | feature/ai |
| 组员A | 鸿蒙：课表教室 + 个人中心 | feature/hm1 |
| 组员B | 鸿蒙：二手交易 + IM聊天 | feature/hm2 |
| 组员C | Web：管理后台 + 数据大屏 | feature/web |
| 组员D | 后端：业务接口 + 消息推送 | feature/server |

## 分支策略
-  — 稳定版本
-  — 开发主分支
- 每人从  拉自己的  分支开发

## 快速开始
见各子目录的 README
