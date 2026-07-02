# Atlas — PrimeAtlas 个人AI效能与认知闭环系统

## 项目简介

PrimeAtlas 是一个有灵魂的个人效能系统——AI 训练伙伴陪你变强，不只是工具，更是陪伴。融合"专项健身训练 + AI 英语听说 + AI 读书伙伴"三大模块。

## 技术栈

- **前端**: React Native (Android/iOS) + 微信小程序
- **后端**: Go + Python (AI 服务)
- **数据库**: PostgreSQL + pgvector + TimescaleDB
- **AI**: DeepSeek-V3 + GPT-4o-mini
- **本地存储**: SQLite + SQLCipher

## 项目结构

```
Atlas/
├── apps/                   # 前端应用
│   ├── android/           # Android (React Native)
│   ├── ios/               # iOS (React Native)
│   └── miniapp/           # 微信小程序
├── services/              # 后端服务
│   ├── api/               # Go API 服务
│   └── ai/                # Python AI 服务
├── docs/                  # 产品文档
├── prototype/             # HTML 交互原型
└── .github/               # CI/CD 配置
```

## 快速开始

```bash
# 安装依赖
cd apps && npm install

# 启动开发服务器
npm start

# 启动后端
cd services/api && go run main.go
cd services/ai && python main.py
```

## 文档

- [完整功能蓝图](docs/PrimeAtlas_完整功能蓝图.md)
- [全量交互原型规格](docs/PrimeAtlas_全量交互原型规格.md)
- [可执行优先级任务清单](docs/PrimeAtlas_可执行优先级任务清单.md)
- [PRD V2.0](docs/PrimeAtlas_PRD_V2.0.md)
