# Web 管理后台 — 智能校园助手

## 技术栈
- Vue 3 + TypeScript
- Vite
- Naive UI / Arco Design
- ECharts 5（数据大屏）
- Tiptap（富文本编辑器）

## 目录结构

web-admin/
├── src/
│   ├── views/
│   │   ├── dashboard/       # 数据大屏
│   │   ├── course/          # 课表管理
│   │   ├── announce/        # 公告管理
│   │   ├── market/          # 交易审核
│   │   ├── knowledge/       # 知识库管理
│   │   ├── user/            # 用户管理
│   │   └── login/           # 登录
│   ├── api/                # 接口封装
│   ├── router/             # 路由
│   └── components/         # 公共组件
├── package.json
└── vite.config.ts

## 页面清单

| 页面 | 功能 |
|------|------|
| Dashboard | 教室利用率热力图、交易数据、用户活跃度折线图 |
| CourseManage | 课表 Excel 导入、手动增删改、冲突检测 |
| AnnounceManage | 富文本编辑公告、分类标签、定时发布 |
| MarketManage | 商品审核列表、分类管理 |
| KnowledgeManage | AI 知识库文档增删查 |
| UserManage | 用户列表、角色管理 |
| Login | 后台登录 |

## 后端 API 地址
- 开发环境：`http://localhost:8080`
- 接口文档：`http://localhost:8080/doc.html`

## 快速开始

```bash
cd web-admin
npm install
npm run dev
```
