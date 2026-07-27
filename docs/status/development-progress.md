# PrimeAtlas 开发进度

> 更新：2026-07-27
> 集成线：`develop`
> 结论：**NOT DEV READY**

## 分支

- `main`：保护发布线
- `develop`：唯一日更集成线

## 大阶段

| 阶段 | 状态 | 说明 |
|---|---|---|
| M0 | 完成 | 产品/V6/合同冻结 |
| M1 | 检查点 | 双入口壳 + SQLite 基础 |
| M2 | 检查点 | 真持久化 + 恢复 |
| M3 | 进行中 | 多域、pause/resume、目标列表/详情路由 |
| M4 | 未开始 | 审计/容错矩阵 |
| M5 | 未开始 | 55 Test ID / 设备 / 无障碍 |
| M6 | 禁止 | 合 main / 发布 |

## 最近检查点

- domain multi-select + 4th focus suggestion
- domain pause/resume
- goal list / create / detail routes (legacy `/journey/goal` redirect)

## 测试

- `dart analyze`：PASS
- `flutter test test/app test/application`：PASS

## 下一步

1. 目标确认与里程碑规则完善
2. FULL/BUSY 注入
3. 网络恢复后独立 QA
