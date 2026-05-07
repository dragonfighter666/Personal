# 报修工单系统重新设计指南

## 📋 概述

报修工单系统已完全重新设计，支持4个角色的完整交互流程：
1. **居民**：提交报修（关联房产绑定）
2. **物业管理员**：接收工单、指派维修工
3. **维修工**：接收任务、更新进度、提交完成
4. **系统管理员**：查看所有工单状态

## 🔄 工单状态流转

```
PENDING（待处理）
    ↓ [物业指派]
ASSIGNED（已指派）
    ↓ [维修工开始]
PROCESSING（处理中）
    ↓ [维修工提交完成]
WAITING_CONFIRM（待验收）
    ↓ [居民验收]
    ├─→ COMPLETED（已完成）✅
    └─→ REJECTED（已退回）→ PROCESSING（重新处理）
```

## 🗄️ 数据库执行步骤

### 第一步：执行表结构脚本

**在 Navicat 中执行：**

1. 打开 Navicat，连接到 MySQL
2. 选择 `community_platform` 数据库
3. 打开查询窗口（`Ctrl+Q`）
4. 打开文件：`backend/db/repair_order_redesign.sql`
5. 执行全部SQL（`F5`）

**这会：**
- ✅ 删除旧的 `repair_order` 表
- ✅ 创建新的 `repair_order` 表（包含所有必需字段）
- ✅ 创建 `repair_order_log` 表（记录状态变更历史）
- ✅ 插入6条测试工单数据

### 第二步：执行测试数据脚本（可选）

如果需要更多测试数据：

1. 打开文件：`backend/db/repair_order_test_data.sql`
2. 执行全部SQL

## 🚀 重启服务

### 重启后端

**方法1：IntelliJ IDEA**
1. 点击红色的 "停止" 按钮
2. 等待完全停止
3. 重新点击绿色的 "运行" 按钮
4. 等待看到 "Started XxxApplication"

**方法2：命令行**
```bash
cd bishe_finally/backend
mvn spring-boot:run
```

### 重启前端

```bash
cd bishe_finally/frontend
npm run serve
```

## 📊 数据库查询示例

### 1. 查看所有工单

```sql
SELECT 
    id,
    order_no AS '工单编号',
    house_address AS '房屋地址',
    description AS '报修描述',
    status AS '状态',
    created_at AS '创建时间'
FROM repair_order
ORDER BY created_at DESC;
```

### 2. 按状态筛选工单

```sql
-- 查看待处理工单
SELECT * FROM repair_order WHERE status = 'PENDING';

-- 查看处理中工单
SELECT * FROM repair_order WHERE status = 'PROCESSING';

-- 查看待验收工单
SELECT * FROM repair_order WHERE status = 'WAITING_CONFIRM';

-- 查看已完成工单
SELECT * FROM repair_order WHERE status = 'COMPLETED';
```

### 3. 查看工单日志

```sql
SELECT 
    l.id,
    l.order_id AS '工单ID',
    l.operator_role AS '操作人角色',
    l.action AS '操作',
    l.old_status AS '原状态',
    l.new_status AS '新状态',
    l.remark AS '备注',
    l.created_at AS '操作时间'
FROM repair_order_log l
WHERE l.order_id = 1
ORDER BY l.created_at ASC;
```

### 4. 统计各状态工单数量

```sql
SELECT 
    status AS '状态',
    COUNT(*) AS '数量'
FROM repair_order
GROUP BY status;
```

### 5. 查看工单详情（包含关联信息）

```sql
SELECT 
    o.id,
    o.order_no AS '工单编号',
    o.house_address AS '房屋地址',
    o.description AS '报修描述',
    o.status AS '状态',
    u1.name AS '居民姓名',
    u2.name AS '物业管理员',
    u3.name AS '维修工',
    o.created_at AS '创建时间',
    o.completed_at AS '完成时间',
    o.resident_rating AS '评分',
    o.resident_comment AS '评价'
FROM repair_order o
LEFT JOIN user u1 ON o.resident_id = u1.id
LEFT JOIN user u2 ON o.property_admin_id = u2.id
LEFT JOIN user u3 ON o.repairer_id = u3.id
ORDER BY o.created_at DESC;
```

### 6. 查看维修工的工作统计

```sql
SELECT 
    repairer_id AS '维修工ID',
    u.name AS '维修工姓名',
    COUNT(*) AS '总工单数',
    SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS '已完成',
    SUM(CASE WHEN status = 'PROCESSING' THEN 1 ELSE 0 END) AS '处理中',
    AVG(resident_rating) AS '平均评分'
FROM repair_order o
LEFT JOIN user u ON o.repairer_id = u.id
WHERE repairer_id IS NOT NULL
GROUP BY repairer_id, u.name;
```

## 🔌 API接口说明

### 居民端接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/repairs/resident` | POST | 提交报修工单 |
| `/api/repairs/resident` | GET | 分页查看自己的工单 |
| `/api/repairs/resident/{orderId}` | GET | 查看工单详情 |
| `/api/repairs/resident/confirm` | POST | 验收确认（通过/退回） |

### 物业管理员端接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/repairs/property` | GET | 分页查看所有工单 |
| `/api/repairs/property/assign` | POST | 指派维修工 |
| `/api/repairs/property/{orderId}` | GET | 查看工单详情 |

### 维修工端接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/repairs/repairer` | GET | 分页查看自己的工单 |
| `/api/repairs/repairer/progress` | POST | 更新进度节点 |
| `/api/repairs/repairer/complete` | POST | 提交完成 |
| `/api/repairs/repairer/{orderId}` | GET | 查看工单详情 |

### 系统管理员端接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/repairs/admin` | GET | 分页查看所有工单 |
| `/api/repairs/admin/{orderId}` | GET | 查看工单详情 |

### 通用接口

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/repairs/upload-image` | POST | 上传单张图片 |
| `/api/repairs/upload-images` | POST | 上传多张图片 |
| `/api/repairs/{orderId}/logs` | GET | 获取工单日志 |

## 📝 前端页面说明

前端页面需要重新实现，主要页面：

1. **居民端**：`ResidentRepairs.vue`
   - 提交报修表单（选择房产、描述、上传图片）
   - 工单列表（状态筛选）
   - 工单详情（查看进度、验收）

2. **物业端**：`PropertyRepairs.vue`
   - 工单列表（状态筛选）
   - 指派维修工（选择维修工、设置时限）
   - 工单详情（查看完整流程）

3. **维修工端**：`RepairerRepairs.vue`
   - 工单列表（状态筛选）
   - 更新进度（已出发/维修中）
   - 提交完成（上传凭证）

4. **系统管理员端**：`AdminRepairs.vue`
   - 所有工单列表（状态筛选）
   - 工单详情（查看完整流程和日志）

## ✅ 验证清单

执行完数据库迁移后，验证：

- [ ] `repair_order` 表存在且结构正确
- [ ] `repair_order_log` 表存在
- [ ] 测试数据已插入（6条工单）
- [ ] 后端服务启动成功
- [ ] API接口可以正常调用
- [ ] 前端页面可以正常访问

## 🐛 常见问题

### Q1: 执行SQL时提示表不存在？

**A**: 确保先执行了 `repair_order_redesign.sql`，它会创建表。

### Q2: 居民提交报修时提示"房屋未绑定"？

**A**: 确保居民已通过房产绑定审核（`resident_house_binding` 表中 `status='APPROVED'`）。

### Q3: 工单编号重复？

**A**: 工单编号自动生成，格式为 `RO+日期+序号`，理论上不会重复。如果重复，检查数据库中的最大序号。

## 📞 下一步

1. ✅ 执行数据库迁移脚本
2. ✅ 重启后端服务
3. ✅ 重启前端服务
4. 🔄 实现前端页面（如果需要）
5. 🔄 测试完整流程

祝使用愉快！🎉
