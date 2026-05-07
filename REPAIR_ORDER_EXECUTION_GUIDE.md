# 报修工单系统执行指南

## ✅ 完成情况

### 1. 数据库 ✅
- ✅ 重新设计了 `repair_order` 表
- ✅ 创建了 `repair_order_log` 表
- ✅ 生成了测试数据

### 2. 后端 ✅
- ✅ 重新实现了所有实体、DTO、Service、Controller
- ✅ 实现了4个角色的完整接口
- ✅ 实现了状态流转控制和日志记录

### 3. 前端 ✅
- ✅ 重新实现了4个角色的前端页面
- ✅ 实现了完整的交互功能

## 🚀 执行步骤

### 第一步：执行数据库迁移（重要！）

**在 Navicat 中：**

1. ✅ 打开 Navicat，连接到 MySQL
2. ✅ 选择 `community_platform` 数据库
3. ✅ 打开查询窗口（`Ctrl+Q`）
4. ✅ 打开文件：`backend/db/repair_order_redesign.sql`
5. ✅ 执行全部SQL（`F5`）
6. ✅ 等待执行完成

**验证：**
```sql
-- 检查表是否存在
SHOW TABLES LIKE 'repair_order';
SHOW TABLES LIKE 'repair_order_log';

-- 检查测试数据
SELECT COUNT(*) FROM repair_order;
SELECT COUNT(*) FROM repair_order_log;
```

### 第二步：重启后端服务

**方法1：IntelliJ IDEA**
1. 停止当前运行的服务（红色停止按钮）
2. 重新运行 `CommunityPlatformApplication.java`（绿色运行按钮）
3. 等待看到 "Started XxxApplication in X seconds"

**方法2：命令行**
```bash
cd bishe_finally/backend
mvn spring-boot:run
```

### 第三步：重启前端服务

```bash
cd bishe_finally/frontend
npm run serve
```

**如果遇到依赖问题：**
```bash
npm install
npm run serve
```

### 第四步：清除浏览器缓存

1. 按 `Ctrl+Shift+Delete` 清除缓存
2. 按 `Ctrl+F5` 强制刷新页面

## 📊 数据库查询示例

### 1. 查看所有工单
```sql
SELECT 
    id,
    order_no AS '工单编号',
    house_address AS '房屋地址',
    description AS '问题描述',
    status AS '状态',
    created_at AS '创建时间'
FROM repair_order
ORDER BY created_at DESC;
```

### 2. 查看待处理工单（物业管理员需要处理的）
```sql
SELECT * FROM repair_order WHERE status = 'PENDING' ORDER BY created_at ASC;
```

### 3. 查看工单日志
```sql
SELECT 
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

### 5. 查看工单详情（包含用户信息）
```sql
SELECT 
    o.id,
    o.order_no AS '工单编号',
    o.house_address AS '房屋地址',
    o.description AS '问题描述',
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

## 🔌 API接口测试

### 居民端测试

1. **提交报修**
```bash
POST /api/repairs/resident
Headers: X-User-Id: 2
Body: {
  "houseId": 1,
  "description": "卫生间水龙头漏水",
  "imageUrls": "http://example.com/image1.jpg"
}
```

2. **查看自己的工单**
```bash
GET /api/repairs/resident?page=1&size=10&status=PENDING
Headers: X-User-Id: 2
```

3. **验收确认**
```bash
POST /api/repairs/resident/confirm
Headers: X-User-Id: 2
Body: {
  "orderId": 1,
  "approved": true,
  "rating": 5,
  "comment": "维修及时，服务态度好"
}
```

### 物业管理员端测试

1. **查看所有工单**
```bash
GET /api/repairs/property?page=1&size=10&status=PENDING
```

2. **指派维修工**
```bash
POST /api/repairs/property/assign
Headers: X-User-Id: 1
Body: {
  "orderId": 1,
  "repairerId": 5,
  "deadline": "2026-02-15T18:00:00",
  "remark": "请尽快处理"
}
```

### 维修工端测试

1. **查看自己的工单**
```bash
GET /api/repairs/repairer?page=1&size=10
Headers: X-User-Id: 5
```

2. **更新进度**
```bash
POST /api/repairs/repairer/progress
Headers: X-User-Id: 5
Body: {
  "orderId": 1,
  "progressNode": "REPAIRING",
  "remark": "开始维修"
}
```

3. **提交完成**
```bash
POST /api/repairs/repairer/complete
Headers: X-User-Id: 5
Body: {
  "orderId": 1,
  "completionProof": "http://example.com/proof.jpg",
  "remark": "维修完成"
}
```

### 系统管理员端测试

1. **查看所有工单**
```bash
GET /api/repairs/admin?page=1&size=10
```

2. **查看工单详情**
```bash
GET /api/repairs/admin/1
Headers: X-User-Id: 1
```

## ✅ 测试清单

- [ ] 数据库表创建成功
- [ ] 测试数据插入成功
- [ ] 后端服务启动成功
- [ ] 前端服务启动成功
- [ ] 居民可以提交报修
- [ ] 物业管理员可以看到待处理工单
- [ ] 物业管理员可以指派维修工
- [ ] 维修工可以看到自己的工单
- [ ] 维修工可以更新进度
- [ ] 维修工可以提交完成
- [ ] 居民可以验收确认
- [ ] 系统管理员可以查看所有工单
- [ ] 工单日志正确记录

## 🐛 常见问题

### Q1: 居民提交报修时提示"房屋未绑定"？

**A**: 确保：
1. 居民已完成房产绑定申请
2. 房产绑定状态为 `APPROVED`
3. 查询接口 `/api/resident/house-binding/approved-houses` 返回了房屋列表

### Q2: 物业管理员看不到工单？

**A**: 检查：
1. 数据库是否有工单数据
2. 后端服务是否正常启动
3. API接口是否正常返回

### Q3: 工单状态不更新？

**A**: 检查：
1. 操作是否符合状态流转规则
2. 后端日志是否有错误
3. 请求头 `X-User-Id` 是否正确传递

## 📞 下一步

1. ✅ 执行数据库迁移
2. ✅ 重启后端和前端服务
3. ✅ 测试完整流程
4. ⏳ 根据实际使用情况优化

祝使用愉快！🎉
