# 报修工单系统完整指南

## ✅ 已完成的工作

### 1. 数据库设计
- ✅ 重新设计了 `repair_order` 表结构
- ✅ 创建了 `repair_order_log` 表（记录状态变更历史）
- ✅ 生成了测试数据（6条工单）

### 2. 后端实现
- ✅ 重新设计了 `RepairOrder` 实体
- ✅ 创建了 `RepairOrderLog` 实体
- ✅ 重新实现了 `RepairOrderService` 和 `RepairOrderServiceImpl`
- ✅ 重新实现了 `RepairOrderController`（4个角色的完整接口）
- ✅ 创建了所有必需的 DTO

### 3. 前端实现
- ✅ 重新实现了 `ResidentRepairs.vue`（居民端）
- ✅ 重新实现了 `PropertyRepairs.vue`（物业管理员端）
- ⏳ `RepairerRepairs.vue`（维修工端）- 需要实现
- ⏳ `AdminRepairs.vue`（系统管理员端）- 需要实现

## 🚀 执行步骤

### 第一步：执行数据库迁移

**在 Navicat 中：**

1. 打开 Navicat，连接到 MySQL
2. 选择 `community_platform` 数据库
3. 打开查询窗口（`Ctrl+Q`）
4. 打开文件：`backend/db/repair_order_redesign.sql`
5. 执行全部SQL（`F5`）
6. （可选）执行 `backend/db/repair_order_test_data.sql` 添加更多测试数据

### 第二步：重启后端服务

**在 IntelliJ IDEA 中：**
1. 停止当前运行的服务
2. 重新运行 `CommunityPlatformApplication.java`

**或在命令行中：**
```bash
cd bishe_finally/backend
mvn spring-boot:run
```

### 第三步：重启前端服务

```bash
cd bishe_finally/frontend
npm run serve
```

### 第四步：清除浏览器缓存

按 `Ctrl+Shift+Delete` 清除缓存，然后 `Ctrl+F5` 强制刷新。

## 📊 数据库查询示例

### 查看所有工单
```sql
SELECT * FROM repair_order ORDER BY created_at DESC;
```

### 查看待处理工单（物业管理员需要处理的）
```sql
SELECT * FROM repair_order WHERE status = 'PENDING' ORDER BY created_at ASC;
```

### 查看工单日志
```sql
SELECT * FROM repair_order_log WHERE order_id = 1 ORDER BY created_at ASC;
```

### 统计各状态工单数量
```sql
SELECT status, COUNT(*) AS count FROM repair_order GROUP BY status;
```

### 查看维修工的工作统计
```sql
SELECT 
    repairer_id,
    COUNT(*) AS total,
    SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed,
    AVG(resident_rating) AS avg_rating
FROM repair_order
WHERE repairer_id IS NOT NULL
GROUP BY repairer_id;
```

## 🔌 API接口列表

### 居民端
- `POST /api/repairs/resident` - 提交报修
- `GET /api/repairs/resident` - 查看自己的工单列表
- `GET /api/repairs/resident/{orderId}` - 查看工单详情
- `POST /api/repairs/resident/confirm` - 验收确认

### 物业管理员端
- `GET /api/repairs/property` - 查看所有工单
- `POST /api/repairs/property/assign` - 指派维修工
- `GET /api/repairs/property/{orderId}` - 查看工单详情

### 维修工端
- `GET /api/repairs/repairer` - 查看自己的工单
- `POST /api/repairs/repairer/progress` - 更新进度
- `POST /api/repairs/repairer/complete` - 提交完成
- `GET /api/repairs/repairer/{orderId}` - 查看工单详情

### 系统管理员端
- `GET /api/repairs/admin` - 查看所有工单
- `GET /api/repairs/admin/{orderId}` - 查看工单详情

## 📝 工单状态说明

| 状态 | 说明 | 可操作角色 |
|------|------|------------|
| PENDING | 待处理 | 物业管理员（指派） |
| ASSIGNED | 已指派 | 维修工（开始维修） |
| PROCESSING | 处理中 | 维修工（更新进度/提交完成） |
| WAITING_CONFIRM | 待验收 | 居民（验收确认） |
| COMPLETED | 已完成 | - |
| REJECTED | 已退回 | 维修工（重新处理） |

## ✅ 测试清单

- [ ] 居民可以提交报修（选择房产、描述、上传图片）
- [ ] 物业管理员可以看到待处理工单
- [ ] 物业管理员可以指派维修工
- [ ] 维修工可以看到自己的工单
- [ ] 维修工可以更新进度
- [ ] 维修工可以提交完成
- [ ] 居民可以验收确认（通过/退回）
- [ ] 系统管理员可以查看所有工单
- [ ] 工单日志正确记录

## 🐛 常见问题

### Q1: 居民提交报修时提示"房屋未绑定"？

**A**: 确保：
1. 居民已完成房产绑定申请
2. 房产绑定状态为 `APPROVED`（已审核通过）
3. 查询接口 `/api/resident/house-bindings` 返回了已审核的房屋

### Q2: 物业管理员看不到工单？

**A**: 检查：
1. 数据库是否有工单数据（`SELECT * FROM repair_order`）
2. 后端服务是否正常启动
3. API接口 `/api/repairs/property` 是否正常返回

### Q3: 工单状态不更新？

**A**: 检查：
1. 操作是否符合状态流转规则
2. 后端日志是否有错误
3. 数据库中的状态是否正确更新

## 📞 下一步

1. ✅ 执行数据库迁移
2. ✅ 重启后端和前端服务
3. ⏳ 实现维修工端页面（`RepairerRepairs.vue`）
4. ⏳ 实现系统管理员端页面（`AdminRepairs.vue`）
5. ⏳ 测试完整流程

祝使用愉快！🎉
