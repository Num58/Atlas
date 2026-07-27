# PrimeAtlas 开发进度

> 更新：2026-07-27
> 集成线：`develop`
> HEAD：见仓库最新 commit
> 结论：**NOT DEV READY**

## 分支

- `main`：保护发布线
- `develop`：唯一日更集成线

## 大阶段

| 阶段 | 状态 | 说明 |
|---|---|---|
| M0 | 完成 | 产品/V6/合同冻结 |
| M1 | 检查点 | 双入口壳 + SQLite 基础 |
| M2 | 检查点 | 真持久化 + 恢复（局部测试绿） |
| M3 | 进行中 | 多域≤3、第4域建议、pause/resume |
| M4 | 未开始 | 审计/容错矩阵 |
| M5 | 未开始 | 55 Test ID / 设备 / 无障碍 |
| M6 | 禁止 | 合 main / 发布 |

## 最近检查点

- multi-domain selection + focus suggestion
- domain pause/resume + pure lifecycle module
- 诊断 txt 清理、`develop` 单线运营

## 测试

- `dart analyze`（相关路径）：PASS
- `flutter test test/app test/application`：PASS

## 下一步

1. 目标列表/详情路由（仍在 develop 直线推进）
2. FULL/BUSY 注入测试
3. 网络恢复后独立 QA 二次核验
