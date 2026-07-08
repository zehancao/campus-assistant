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
- `main` — 稳定版本（不要直接改）
- `dev` — 开发主分支（所有人代码在这汇合）
- `feature/xxx` — 每人自己的分支（日常开发只改这个）

## 🚀 上手指南（每个人必须做）

### 第一步：安装 Git

下载安装：https://git-scm.com/download

装好后打开终端（Windows 用 Git Bash，Mac 用终端），配一下你的名字：

```bash
git config --global user.name "你的姓名"
git config --global user.email "你的邮箱"
```

### 第二步：拉取仓库

```bash
# 克隆整个项目到本地
git clone git@github.com:zehancao/campus-assistant.git

# 进入项目目录
cd campus-assistant

# 切换到你的分支（每个人不同，看清楚！）
git checkout feature/hm1     # ← 组员A 用这个
git checkout feature/hm2     # ← 组员B 用这个
git checkout feature/web     # ← 组员C 用这个
git checkout feature/server  # ← 组员D 用这个
git checkout feature/ai      # ← 曹老板 用这个
```

### 第三步：在正确的目录下写代码

```
你的分支              你写的目录
─────────────────────────────────────
feature/hm1      →  harmony-app/     （只写课表/教室/个人中心相关文件）
feature/hm2      →  harmony-app/     （只写交易/IM聊天相关文件）
feature/web      →  web-admin/       （整个 Web 后台）
feature/server   →  campus-server/   （整个后端）
feature/ai       →  ai-service/ + campus-server/ + docs/
```

⚠️ 组员A 和组员B 都在 harmony-app/ 下写代码，注意别改对方的文件！

---

## 📤 每日操作流程

### 每天开工第一件事（防止跟别人冲突）

```bash
# 1. 切到 dev 分支，拉最新代码
git checkout dev
git pull origin dev

# 2. 切回你自己的分支
git checkout feature/xxx   # xxx 换成你的分支名

# 3. 把 dev 的最新代码合并到你分支
git merge dev

# 如果合并成功 → 开始写代码
# 如果提示 CONFLICT → 截图发群里，曹老板帮你解决
```

### 每天收工最后一件事（提交你今天写的代码）

```bash
# 1. 看看今天改了什么
git status

# 2. 把所有改动加入暂存
git add .

# 3. 提交，写清楚你做了什么
git commit -m "feat: 完成了课表页面布局"
#                    ↑ 这里写你今天干了啥，别写"改了点东西"

# 4. 推送到 GitHub
git push origin feature/xxx   # xxx 换成你的分支名
```

### 提交信息规范（写清楚，别糊弄）

```bash
git commit -m "feat: 新增了xxx功能"       # 新功能
git commit -m "fix: 修复了xxx的bug"       # 修bug
git commit -m "docs: 更新了xxx文档"       # 改文档
git commit -m "style: 调整了xxx样式"      # 样式调整
```

---

## ⚠️ 记住这四条

```
❌ 不要直接改 main 分支
❌ 不要直接改 dev 分支
❌ 不要改别人的分支
✅ 只在你自己的 feature/xxx 分支上干活
```

出问题了怎么办？
- 推不上去 → 截图发群里
- 合并冲突 → 截图发群里
- 不知道自己在哪个分支 → 敲 `git branch` 看看
- 慌了不知道怎么搞 → 截图发群里 @曹老板

---

## 快速开始
见各子目录的 README
- [鸿蒙 App 开发指南](harmony-app/README.md) — 组员A、组员B 看这个
- [Web 后台开发指南](web-admin/README.md) — 组员C 看这个
- [后端开发指南](campus-server/README.md) — 组员D 看这个
- [AI 服务开发指南](ai-service/README.md) — 曹老板 看这个
