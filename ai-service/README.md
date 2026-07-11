# AI 问答服务 — 智能校园助手

## 概述
本地化部署的校园知识库问答系统，**零外部 API 依赖，全部本地运行**。
基于 RAG（检索增强生成）架构，自己写代码，不用 LangChain。

## 技术栈
- Python 3.10+
- FastAPI（Web 框架）
- Ollama（本地大模型运行平台）
- qwen2.5:7b（对话模型）
- nomic-embed-text（Embedding 模型）
- ChromaDB（向量数据库，轻量级，无需 Docker）

---

## 架构

```
用户问题 → FastAPI
  ↓
向量化（nomic-embed-text）
  ↓
ChromaDB 检索 Top 3 最相关文本块
  ↓
拼接 Prompt（系统提示词 + 检索内容 + 用户问题）
  ↓
Ollama + qwen2.5:7b 流式生成
  ↓
SSE 流式返回前端（打字机效果）
```

---

## 目录结构

```
ai-service/
├── main.py                # FastAPI 主入口 + 接口定义
├── rag_engine.py          # RAG 检索与生成核心逻辑
├── llm_client.py          # Ollama 调用封装
├── knowledge_importer.py  # 知识库批量导入脚本
├── chroma_db/             # ChromaDB 持久化数据（自动生成）
├── requirements.txt       # Python 依赖
└── README.md              # 本文件
```

---

## 负责人：曹泽涵（组长）

### 第一周：AI 服务搭建 + 知识库初始化

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | Ollama 环境确认 | 拉取 qwen2.5:7b + nomic-embed-text，本地测试对话 | 0.5天 |
| P0 | FastAPI 骨架 | main.py 搭好，/health 接口能通 | 0.5天 |
| P0 | LLM 调用封装 | llm_client.py，封装 Ollama chat + embed | 0.5天 |
| P0 | ChromaDB 初始化 | 创建 collection，写增删查方法 | 0.5天 |
| P0 | 知识库文档收集 | 收集至少 10 篇校园相关知识（校规、办事流程、FAQ） | 0.5天 |
| P0 | 文本分段脚本 | 按 500 字分段，重叠 50 字，自动 embedding 存入 ChromaDB | 0.5天 |
| P0 | RAG 检索生成 | rag_engine.py，检索+Prompt拼接+流式生成 | 1天 |
| P0 | /api/ai/chat 接口 | SSE 流式返回，打字机效果 | 0.5天 |

---

### 第二周：知识库管理 + Java 联调

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | /api/ai/knowledge/add | 添加文档→自动分段→embedding→存 ChromaDB | 0.5天 |
| P0 | /api/ai/knowledge/list | 知识库文档列表 | 0.5天 |
| P0 | /api/ai/knowledge/delete | 删除文档及对应所有向量 chunk | 0.5天 |
| P1 | Java 后端对接 | Spring Boot WebClient 转发 SSE 到前端 | 1天 |
| P1 | 知识库扩充 | 文档数量补到 15+ 篇 | 0.5天 |
| P2 | 多轮对话 | Redis 存历史消息，带上下文的多轮问答 | 1天 |

---

### 第三周：优化 + 联调

| 优先级 | 任务 | 说明 | 预估 |
|--------|------|------|------|
| P0 | 全链路联调 | 鸿蒙端→Java→AI服务→返回，全链路通 | 0.5天 |
| P1 | 检索质量优化 | 调整 chunk_size、overlap、topK 参数 | 0.5天 |
| P1 | Prompt 优化 | 优化系统提示词，减少幻觉 | 0.5天 |
| P2 | 性能优化 | Ollama 并发、ChromaDB 查询优化 | 0.5天 |

---

### 第四周：文档 + 答辩准备

| 任务 | 说明 |
|------|------|
| AI 模块技术文档 | 架构图 + 流程图 + 核心代码讲解 |
| 演示脚本 | 准备几个典型问题的演示流程 |
| 答辩话术 | 为什么选本地部署、RAG 原理、技术亮点 |

---

## API 接口

### AI 对话
```
POST /api/ai/chat?question=怎么申请换宿舍
Response: text/event-stream (SSE)
  data: {"content": "申请"}
  data: {"content": "换宿舍"}
  data: {"content": "需要..."}
  data: [DONE]
```

### 知识库管理
```
POST   /api/ai/knowledge/add     {title, content}  → 自动分段+入库
GET    /api/ai/knowledge/list                      → [{id, title, category, chunks}]
DELETE /api/ai/knowledge/{id}                      → 删除文档+向量
```

---

## 快速开始

```bash
cd ai-service

# 1. 安装依赖
pip install -r requirements.txt

# 2. 确保 Ollama 运行中 + 模型已拉取
ollama pull qwen2.5:7b
ollama pull nomic-embed-text

# 3. 导入知识库（第一次运行）
python knowledge_importer.py

# 4. 启动服务（默认 8000 端口）
uvicorn main:app --reload --port 8000

# 5. 测试
curl "http://localhost:8000/api/ai/chat?question=怎么补办学生证"
```

---

## 依赖

```
# requirements.txt
fastapi==0.111.0
uvicorn==0.30.1
chromadb==0.5.0
ollama==0.2.0
```

---

## 知识库文档要求

需要收集的校园知识类型：
- 宿舍管理规定（入住/退宿/调换/报修）
- 学生证补办流程
- 选课指南
- 考试纪律
- 奖学金申请
- 校园卡挂失补办
- 校医院就诊流程
- 图书馆借阅规则
- 体育场馆预约
- 请假流程
- ... 更多

每篇文档格式：标题 + Markdown 正文，按 500 字分段存入 ChromaDB。

---

## 注意事项
- ChromaDB 数据存在 `chroma_db/` 目录，不要删
- 添加文档后不需要重启服务，ChromaDB 即时生效
- Ollama 默认跑在 `localhost:11434`
- 知识库文档是系统的核心数据，内容准确最重要
- 如果 qwen2.5:7b 响应太慢，可以换成 qwen2.5:3b（效果稍差但更快）
