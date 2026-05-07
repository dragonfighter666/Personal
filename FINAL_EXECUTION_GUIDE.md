# 报修工单系统重新设计 - 最终执行指南

## 📋 概述

报修工单系统已完全重新设计，支持4个角色的完整交互流程：
- **居民**：提交报修（关联房产绑定）、验收确认
- **物业管理员**：接收工单、指派维修工
- **维修工**：接收任务、更新进度、提交完成
- **系统管理员**：查看所有工单状态

## ✅ 已完成的工作

### 1. 数据库
- ✅ 重新设计了 `repair_order` 表（删除旧表，创建新表）
- ✅ 创建了 `repair_order_log` 表（记录状态变更历史）
- ✅ 生成了测试数据（6条工单，包含各种状态）

### 2. 后端
- ✅ 重新实现了所有实体、DTO、Service、Controller
- ✅ 实现了4个角色的完整接口
- ✅ 实现了状态流转控制和日志记录
- ✅ 实现了工单编号自动生成

### 3. 前端
- ✅ 重新实现了4个角色的前端页面
- ✅ 实现了完整的交互功能

## 🚀 执行步骤

### 第一步：执行数据库迁移（最重要！）

**在 Navicat 中：**

1. ✅ 打开 Navicat，连接到 MySQL
2. ✅ **在左侧选中 `community_platform` 数据库**（必须选中！）
3. ✅ 点击菜单 "查询" → "新建查询"（或按 `Ctrl+Q`）
4. ✅ 点击 "文件" → "打开文件"
5. ✅ 选择文件：`bishe_finally/backend/db/repair_order_redesign.sql`
6. ✅ **点击 "运行" 按钮**（或按 `F5`）
7. ✅ 等待执行完成（底部会显示执行结果）

**验证是否成功：**
```sql
-- 检查表是否存在
SHOW TABLES LIKE 'repair_order';
SHOW TABLES LIKE 'repair_order_log';

-- 检查测试数据
SELECT COUNT(*) FROM repair_order;
-- 应该返回 6

SELECT COUNT(*) FROM repair_order_log;
-- 应该返回多条日志记录
```

**如果出现错误：**
- "Table 'repair_order' doesn't exist" - 这是正常的，脚本会先删除旧表
- "Duplicate column name" - 忽略，继续执行
- 其他错误 - 检查数据库连接和权限

---

### 第二步：重启后端服务

**方法1：IntelliJ IDEA（推荐）**

1. ✅ 找到 `CommunityPlatformApplication.java` 文件
2. ✅ 如果之前在运行，点击红色的 "停止" 按钮
3. ✅ 等待完全停止（控制台没有输出）
4. ✅ 重新点击绿色的 "运行" 按钮
5. ✅ 等待启动完成（看到 "Started XxxApplication in X seconds"）

**方法2：命令行**

```bash
# 1. 进入后端目录
cd bishe_finally/backend

# 2. 如果之前在运行，先停止（按 Ctrl+C）

# 3. 重新编译并运行
mvn clean package
mvn spring-boot:run

# 或者直接运行 jar 包
java -jar target/community-platform.jar
```

**验证后端是否启动成功：**
- 查看控制台，应该看到 "Started XxxApplication"
- 访问 `http://localhost:8080` 应该能访问（如果有健康检查接口）

---

### 第三步：重启前端服务

**在 VS Code 或命令行中：**

```bash
# 1. 进入前端目录
cd bishe_finally/frontend

# 2. 如果之前在运行，按 Ctrl+C 停止

# 3. 重新安装依赖（如果需要）
npm install

# 4. 启动开发服务器
npm run serve
```

**验证前端是否启动成功：**
- 应该看到类似 "App running at: http://localhost:8080" 的提示
- 浏览器访问该地址应该能看到登录页面

---

### 第四步：清除浏览器缓存并刷新

1. **清除浏览器缓存**
   - Chrome：`Ctrl+Shift+Delete` → 选择"清除缓存" → 清除
   - 或按 `Ctrl+F5` 强制刷新

2. **重新登录系统测试**

---

## 📊 数据库查询示例

### 1. 查看所有工单
```sql
SELECT 
    id,
    order_no AS '工单编号',
    house_address AS '房屋地址',
    description AS '问题描述',
    status AS '状态',
    repairer_id AS '维修工ID',
    created_at AS '创建时间'
FROM repair_order
ORDER BY created_at DESC;
```

### 2. 查看待处理工单（物业管理员需要处理的）
```sql
SELECT * FROM repair_order WHERE status = 'PENDING' ORDER BY created_at ASC;
```

### 3. 查看工单日志（查看完整操作历史）
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

### 7. 查看某个居民的报修记录
```sql
SELECT * FROM repair_order WHERE resident_id = 2 ORDER BY created_at DESC;
```

### 8. 查看某个维修工的工单
```sql
SELECT * FROM repair_order WHERE repairer_id = 5 ORDER BY created_at DESC;
```

### 9. 查看已完成且评分>=4的工单
```sql
SELECT * FROM repair_order 
WHERE status = 'COMPLETED' AND resident_rating >= 4 
ORDER BY resident_rating DESC;
```

### 10. 查看被退回的工单（需要重新处理）
```sql
SELECT * FROM repair_order WHERE status = 'REJECTED' ORDER BY created_at DESC;
```

## 🔄 工单状态流转

```
PENDING（待处理）
    ↓ [物业管理员指派维修工]
ASSIGNED（已指派）
    ↓ [维修工开始维修]
PROCESSING（处理中）
    ↓ [维修工提交完成]
WAITING_CONFIRM（待验收）
    ↓ [居民验收]
    ├─→ COMPLETED（已完成）✅
    └─→ REJECTED（已退回）→ 回到 PROCESSING（重新处理）
```

## ✅ 测试清单

### 居民端测试
- [ ] 可以提交报修（选择房产、描述、上传图片）
- [ ] 可以查看自己的工单列表
- [ ] 可以查看工单详情
- [ ] 可以验收确认（通过/退回）

### 物业管理员端测试
- [ ] 可以看到所有工单列表
- [ ] 可以筛选不同状态的工单
- [ ] 可以指派维修工（选择维修工、设置时限）
- [ ] 可以查看工单详情和日志

### 维修工端测试
- [ ] 可以看到自己的工单列表
- [ ] 可以更新进度（已出发/维修中）
- [ ] 可以提交完成（上传凭证）
- [ ] 可以看到退回理由

### 系统管理员端测试
- [ ] 可以看到所有工单
- [ ] 可以查看工单详情和完整日志
- [ ] 可以统计工单数据

## 🐛 常见问题

### Q1: 执行SQL时提示表不存在？

**A**: 确保：
1. 已选中 `community_platform` 数据库
2. 数据库连接正常
3. 有足够的权限

### Q2: 居民提交报修时提示"房屋未绑定"？

**A**: 确保：
1. 居民已完成房产绑定申请
2. 房产绑定状态为 `APPROVED`
3. 查询接口 `/api/resident/house-binding/approved-houses` 返回了房屋列表

**检查方法：**
```sql
-- 查看居民的房产绑定
SELECT * FROM resident_house_binding WHERE user_id = 2 AND status = 'APPROVED';
```

### Q3: 物业管理员看不到工单？

**A**: 检查：
1. 数据库是否有工单数据：`SELECT * FROM repair_order;`
2. 后端服务是否正常启动
3. API接口 `/api/repairs/property` 是否正常返回
4. 浏览器控制台是否有错误

### Q4: 工单状态不更新？

**A**: 检查：
1. 操作是否符合状态流转规则
2. 后端日志是否有错误
3. 请求头 `X-User-Id` 是否正确传递
4. 数据库中的状态是否正确更新

### Q5: 前端页面报错？

**A**: 检查：
1. 后端服务是否启动
2. API接口是否正常
3. 浏览器控制台错误信息
4. 网络请求是否成功（F12 → Network）

## 📞 需要帮助？

如果按照以上步骤操作后仍有问题：

1. **截图保留错误信息**
2. **检查 Navicat 执行结果**（底部是否有错误提示）
3. **检查后端日志**（控制台输出）
4. **检查浏览器控制台**（F12 → Console）
5. **检查网络请求**（F12 → Network）

## 📄 相关文件

- `backend/db/repair_order_redesign.sql` - 数据库表结构脚本
- `backend/db/repair_order_test_data.sql` - 测试数据脚本
- `backend/src/main/java/com/community/platform/repair/` - 后端代码目录
- `frontend/src/views/ResidentRepairs.vue` - 居民端页面
- `frontend/src/views/PropertyRepairs.vue` - 物业端页面
- `frontend/src/views/RepairerRepairs.vue` - 维修工端页面
- `frontend/src/views/AdminRepairs.vue` - 系统管理员端页面

## ✨ 完成后的效果

修复完成后，以下功能应该可以正常使用：

- ✅ 报修工单管理（4个角色完整交互）
- ✅ 工单状态流转（自动记录日志）
- ✅ 房产绑定关联（居民选择已审核的房产）
- ✅ 工单编号自动生成
- ✅ 完整的操作日志记录

祝使用愉快！🎉
