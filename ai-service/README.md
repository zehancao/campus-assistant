# AI 问答服务 — 智能校园助手

## 概述
本地化部署的校园知识库问答系统，不依赖任何外部 API。
基于 RAG（检索增强生成）架构。

## 技术栈
- Python 3.10+
- FastAPI
- Ollama（qwen2.5:7b + nomic-embed-text）
- ChromaDB（向量数据库）
- 不使用 LangChain（自己写 RAG，更轻量）

## 目录结构

ai-service/
├── main.py              # FastAPI 主入口
├── rag_engine.py        # RAG 检索与生成
├── llm_client.py        # Ollama 调用封装
├── import_knowledge.py  # 知识库导入脚本
├── chroma_db/           # ChromaDB 持久化数据
├── requirements.txt
└── README.md

## 接口

### AI 对话
POST /api/ai/chat?question=怎么申请换宿舍
→ SSE 流式返回

### 知识库管理
POST /api/ai/knowledge/add    — 添加文档
GET  /api/ai/knowledge/list   — 知识库列表
DELETE /api/ai/knowledge/{id} — 删除文档

## 快速开始

```bash
# 1. 安装依赖
pip install -r requirements.txt

# 2. 确保 Ollama 运行中 + 模型已拉取
ollama pull qwen2.5:7b
ollama pull nomic-embed-text

# 3. 导入知识库
python import_knowledge.py

# 4. 启动服务（默认 8000 端口）
uvicorn main:app --reload --port 8000
```

## 架构

用户问题 → FastAPI
  → 向量化（nomic-embed-text）
  → ChromaDB 检索 Top 3 相关文本
  → 拼接 Prompt
  → Ollama qwen2.5:7b 流式生成
  → SSE 返回前端
