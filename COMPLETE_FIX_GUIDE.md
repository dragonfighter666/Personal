# 完整修复指南

## 🚨 问题说明

你遇到的错误都是因为数据库表或字段缺失导致的。本指南将帮你**一次性解决所有问题**。

---

## ✅ 解决方案（按顺序执行）

### 第一步：执行数据库迁移（重要！）

**在 Navicat 中执行以下操作：**

1. **打开 Navicat**
2. **连接到 MySQL 数据库**
3. **在左侧找到并选中 `community_platform` 数据库**（必须先选中数据库）
4. **点击菜单栏 "查询" → "新建查询"**（快捷键 `Ctrl+Q`）
5. **点击 "文件" → "打开文件"**
6. **选择文件：`bishe_finally/backend/db/FINAL_MIGRATION.sql`**
7. **点击 "运行" 按钮**（或按 `F5`）
8. **等待执行完成**（底部会显示执行结果）

**如果出现 "Duplicate column name" 错误：**
- 这是正常的，说明该字段已存在
- 直接忽略，继续执行下一条
- 或者直接关闭，重新打开文件再运行一次（脚本用了 `IF NOT EXISTS`）

**验证是否成功：**
```sql
-- 执行以下查询检查
SHOW TABLES LIKE 'security_alert';
SHOW TABLES LIKE 'operation_log';
SHOW TABLES LIKE 'facility';
-- 如果都返回结果，说明成功
```

---

### 第二步：重启后端服务

**方法1：使用 IntelliJ IDEA（推荐）**
1. 找到 `CommunityPlatformApplication.java` 文件
2. 如果之前在运行，点击红色的 "停止" 按钮
3. 等待完全停止
4. 再次点击绿色的 "运行" 按钮
5. 等待启动完成（看到 "Started XxxApplication in X seconds"）

**方法2：使用命令行**
```bash
# 1. 进入后端目录
cd bishe_finally/backend

# 2. 如果之前在运行，先停止（按 Ctrl+C）

# 3. 重新编译并运行
mvn spring-boot:run
```

**或者直接运行 jar 包：**
```bash
cd bishe_finally/backend/target
java -jar community-platform.jar
```

---

### 第三步：重启前端服务

**在 VS Code 或命令行中：**

```bash
# 进入前端目录
cd bishe_finally/frontend

# 如果之前在运行，按 Ctrl+C 停止

# 重新安装依赖（如果需要）
npm install

# 启动开发服务器
npm run serve
```

**或者运行生产版本：**
```bash
cd bishe_finally/frontend

# 构建生产版本
npm run build

# 启动（取决于你的配置）
# 通常使用 nginx 或其他服务器
```

---

### 第四步：清理浏览器缓存并刷新

1. **清除浏览器缓存**
   - Chrome：`Ctrl+Shift+Delete` → 选择"清除缓存"
   - 或按 `Ctrl+F5` 强制刷新

2. **重新登录系统测试**

---

## 📋 修复内容清单

本次迁移修复了以下问题：

### ✅ 创建的新表

| 表名 | 说明 | 解决的问题 |
|------|------|------------|
| `security_alert` | 安防告警表 | 安防与门禁管理报错 |
| `operation_log` | 操作日志表 | 操作日志报错 |
| `facility` | 设备设施表 | 设备设施管理报错 |
| `facility_maintenance_plan` | 设备维护计划表 | 设备维护功能 |
| `access_log` | 门禁日志表 | 门禁记录功能 |
| `user_question_ticket` | 用户问题工单表 | 智能客服问题提交 |

### ✅ 修复的字段

#### `repair_order` 表新增字段：
- `deadline` - 完成时限
- `progress_node` - 维修进度节点
- `completion_proof` - 维修完成凭证
- `resident_reject_reason` - 居民退回理由
- `completed_at` - 维修完成时间
- `reject_reason` - 物业驳回理由
- `resident_rating` - 居民评分
- `resident_comment` - 居民评价
- `resident_confirmed_at` - 居民确认时间

#### `ai_question` 表新增字段：
- `status` - 状态（启用/禁用）
- `keywords` - 关键词
- `created_by` - 创建人ID

#### `ai_chat` 表新增字段：
- `answer_type` - 回答类型
- `manual_reply_id` - 人工答复ID
- `ai_call_log_id` - AI调用记录ID
- `is_helpful` - 是否解决

#### 其他表：
- `ai_manual_reply` - 新增 title, house_id, closed_at
- `ai_api_config` - 新增 system_prompt, enable_auto_reply
- `announcement` - 新增 is_urgent

---

## 🔍 验证修复是否成功

执行完迁移脚本后，运行以下 SQL 验证：

```sql
-- 1. 检查 security_alert 表是否存在
SHOW TABLES LIKE 'security_alert';

-- 2. 检查 operation_log 表是否存在
SHOW TABLES LIKE 'operation_log';

-- 3. 检查 facility 表是否存在
SHOW TABLES LIKE 'facility';

-- 4. 检查 repair_order 表结构
DESC repair_order;
-- 检查是否有新字段：deadline, progress_node, completion_proof 等

-- 5. 检查 ai_chat 表结构
DESC ai_chat;
-- 检查是否有新字段：answer_type, manual_reply_id 等
```

**预期结果：**
- 所有 `SHOW TABLES` 都返回 1 行结果
- `DESC` 命令显示所有字段（包括新增的）

---

## ❓ 常见问题

### Q1: 执行 SQL 时提示 "Table 'community_platform.xxx' doesn't exist"？

**A**: 说明 `community_platform` 数据库不存在。请先创建：
```sql
CREATE DATABASE community_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Q2: 执行 SQL 时提示权限不足？

**A**: 请检查数据库用户名和密码是否有建表权限。建议使用 `root` 用户。

### Q3: 后端启动失败，提示找不到表？

**A**: 
1. 检查是否选中了正确的数据库（`community_platform`）
2. 检查 SQL 是否全部执行完成
3. 重启后端服务

### Q4: 前端还是报错？

**A**: 
1. 清除浏览器缓存（`Ctrl+Shift+Delete`）
2. 刷新页面（`Ctrl+F5`）
3. 检查前端 API 配置是否正确

### Q5: 如何备份当前数据库？

**A**: 在 Navicat 中：
1. 右键点击 `community_platform` 数据库
2. 选择 "转储SQL文件" → "结构和数据"
3. 保存到安全位置

---

## 🎯 测试清单

修复完成后，测试以下功能：

- [ ] 报修工单管理（物业管理员）
- [ ] 报修工单列表（系统管理员）
- [ ] 设备设施管理
- [ ] 安防与门禁
- [ ] 操作日志查看
- [ ] 智能客服 FAQ 管理
- [ ] 智能客服问题工单

---

## 📞 如果还有问题

如果按照以上步骤操作后仍有问题：

1. **截图保留错误信息**
2. **检查 Navicat 执行结果**（底部是否有错误提示）
3. **重新执行 SQL**（有时网络问题会导致执行失败）
4. **联系技术支持**

---

## ✅ 完成后的效果

修复完成后，以下功能应该可以正常使用：

- ✅ 报修工单管理（4个角色交互）
- ✅ 设备设施管理
- ✅ 安防与门禁管理
- ✅ 操作日志
- ✅ 智能客服功能
- ✅ 所有其他功能模块

祝使用愉快！🎉
