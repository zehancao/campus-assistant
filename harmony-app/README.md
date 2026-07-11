# 鸿蒙 App — 智能校园助手

## 技术栈
- ArkTS + ArkUI
- DevEco Studio (API 12+)
- 元服务卡片 (FormAbility)
- RelationalStore（本地存储）
- @ohos.net.http（网络请求）
- @ohos.net.webSocket（IM 通信）
- Scan Kit（扫码）
- Push Kit（推送通知）

---

## 目录结构

```
harmony-app/
├── entry/
│   └── src/main/ets/
│       ├── pages/
│       │   ├── Index.ets                # 首页仪表盘
│       │   ├── SchedulePage.ets         # 课表页
│       │   ├── ClassroomScanPage.ets    # 教室扫码
│       │   ├── MarketPage.ets           # 二手交易首页
│       │   ├── ProductDetailPage.ets    # 商品详情
│       │   ├── ProductPublishPage.ets   # 发布商品
│       │   ├── ConversationListPage.ets # 聊天列表
│       │   ├── ChatPage.ets             # 聊天详情
│       │   ├── AIChatPage.ets           # AI 问答
│       │   ├── LoginPage.ets            # 登录
│       │   └── ProfilePage.ets          # 个人中心
│       ├── service/
│       │   ├── ApiService.ets           # HTTP 请求封装
│       │   └── WebSocketService.ets     # WebSocket 管理
│       ├── model/                       # 数据模型
│       ├── widget/                      # 元服务卡片
│       └── common/                      # 公共组件
└── AppScope/
```

---

## 开发分工

### 组员A：课表与教室管理 + 个人中心

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 工程搭建 | DevEco 新建项目，跑通 Hello World | 0.5天 |
| P0 | 登录注册页面 | 学号+密码输入框，调用 `/api/user/login`，token 存 RelationalStore | 1天 |
| P0 | 课表周视图 | 7天网格布局，课程卡片按节次定位，不同颜色区分，左右滑动换周 | 2天 |
| P0 | 课表日视图 | 当天课程列表，显示时间+教室+教师 | 0.5天 |
| P1 | 教室扫码 | ScanKit 扫码→获取教室ID→查当日课表→显示占用状态 | 1天 |
| P1 | 元服务卡片 2x2 | 显示下一节课名称+教室+倒计时，30分钟自动刷新 | 1天 |
| P1 | 元服务卡片 2x4 | 显示今日全部课程 | 0.5天 |
| P1 | 个人中心 | 头像/姓名/学号/学院展示，收藏列表入口，消息入口 | 1天 |
| P2 | 消息通知列表 | 系统通知+私信列表，已读/未读状态 | 1天 |
| P2 | 设置页面 | 退出登录、推送偏好、关于 | 0.5天 |
| P2 | 空教室查询 | 按教学楼+节次筛选空闲教室列表 | 0.5天 |

**交付页面**：LoginPage、SchedulePage（周+日）、ClassroomScanPage、ProfilePage、NotificationsPage、CourseWidget（2个尺寸）

---

### 组员B：二手交易 + IM 聊天

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 工程搭建 | DevEco 新建项目，跑通 Hello World | 0.5天 |
| P0 | 登录注册页面 | 学号+密码输入框，调用 `/api/user/login`，token 存 RelationalStore | 1天 |
| P0 | 市场首页 | 分类标签切换+商品瀑布流/列表+下拉刷新+上拉加载 | 2天 |
| P0 | 搜索框 | 关键词搜索，调用后端 Elasticsearch 接口 | 0.5天 |
| P0 | 发布商品页 | 图片选择(最多9张)+分类标签选择器+标题/描述/价格/成色/交易地点 | 1.5天 |
| P1 | 商品详情页 | 图片轮播+卖家信息+「联系卖家」按钮+收藏按钮 | 1天 |
| P1 | 我的发布列表 | 我发布的商品，显示状态（在售/已售） | 0.5天 |
| P1 | 我的收藏列表 | 收藏的商品列表 | 0.5天 |
| P1 | 聊天会话列表 | 显示最后一条消息+时间+未读红点 | 1天 |
| P1 | 聊天详情页 | 消息列表（文本+图片）+输入框+发送按钮 | 1.5天 |
| P1 | WebSocket 管理 | 连接/心跳(30s)/断线重连(指数退避)/消息收发 | 1天 |
| P2 | 图片消息 | 聊天中发送图片 | 0.5天 |
| P2 | 已读状态 | 消息已读标记+对方已读提示 | 0.5天 |

**交付页面**：MarketPage、ProductPublishPage、ProductDetailPage、ConversationListPage、ChatPage、LoginPage

---

## 后端 API 地址
- 开发环境：`http://localhost:8080`
- 接口文档：`http://localhost:8080/doc.html`

---

## 快速开始

1. 安装 DevEco Studio
2. Clone 仓库后，用 DevEco 打开 `harmony-app/` 目录
3. 配置自动签名（File → Project Structure → Signing Configs）
4. 运行到模拟器或真机

---

## 注意事项
- 两人都在 `harmony-app/` 下开发，注意不要动对方的文件
- 组员A 只写课表/教室/个人中心相关的页面
- 组员B 只写交易/聊天相关的页面
- HomePage（Index.ets）可以一起商量，各自写自己的入口卡片
- token 持久化用 RelationalStore，不要用 Preferences（安全性要求）
- 所有网络请求统一走 `service/ApiService.ets`，不要各自写 http 调用
