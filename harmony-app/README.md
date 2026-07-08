# 鸿蒙 App — 智能校园助手

## 技术栈
- ArkTS + ArkUI
- DevEco Studio (API 12+)
- 元服务卡片 (FormAbility)

## 目录结构

harmony-app/
├── entry/
│   └── src/main/ets/
│       ├── pages/           # 页面
│       │   ├── Index.ets              # 首页
│       │   ├── SchedulePage.ets       # 课表
│       │   ├── ClassroomScanPage.ets  # 教室扫码
│       │   ├── MarketPage.ets         # 二手交易
│       │   ├── ProductDetailPage.ets  # 商品详情
│       │   ├── ProductPublishPage.ets # 发布商品
│       │   ├── ConversationListPage.ets # 聊天列表
│       │   ├── ChatPage.ets           # 聊天详情
│       │   ├── AIChatPage.ets         # AI问答
│       │   ├── LoginPage.ets          # 登录
│       │   └── ProfilePage.ets        # 个人中心
│       ├── service/         # 网络请求 / WebSocket
│       ├── model/           # 数据模型
│       ├── widget/          # 元服务卡片
│       └── common/          # 公共组件
└── AppScope/

## 开发分工

| 组员 | 负责模块 | 页面 |
|------|----------|------|
| 组员A | 课表教室 + 个人中心 | SchedulePage, ClassroomScanPage, LoginPage, ProfilePage, NotificationsPage, 元服务卡片 |
| 组员B | 二手交易 + IM聊天 | MarketPage, ProductDetailPage, ProductPublishPage, ConversationListPage, ChatPage |

## 后端 API 地址
- 开发环境：`http://localhost:8080`
- 接口文档：`http://localhost:8080/doc.html`

## 快速开始

1. 安装 DevEco Studio
2. 打开 `harmony-app` 目录
3. 配置签名（自动签名即可）
4. 运行到模拟器或真机
