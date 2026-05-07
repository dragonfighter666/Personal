# 快速修复指南 - 一次性解决所有数据库错误

## 🚨 问题说明

您遇到的错误都是因为数据库表或字段缺失导致的。本指南将帮您一次性解决所有问题。

## ✅ 解决方案

### 方法一：使用安全版迁移脚本（推荐）

**优点**：自动检测字段是否存在，不会报错，可以重复执行

#### 执行步骤：

1. **打开 Navicat**
   - 连接到您的 MySQL 数据库

2. **选择数据库**
   - 在左侧数据库列表中，选择 `community_platform` 数据库

3. **打开查询窗口**
   - 点击顶部菜单 "查询" → "新建查询"
   - 或按快捷键 `Ctrl+Q`

4. **打开SQL文件**
   - 点击 "文件" → "打开文件"
   - 选择文件：`backend/db/SAFE_COMPLETE_MIGRATION.sql`

5. **执行SQL**
   - 点击 "运行" 按钮（或按 `F5`）
   - 等待执行完成（可能需要几秒钟）

6. **验证结果**
   - 如果看到 "数据库迁移完成！所有表和字段已安全创建/更新。" 说明成功

### 方法二：使用标准版迁移脚本

如果方法一不可用，可以使用标准版：

1. 打开文件：`backend/db/complete_database_migration.sql`
2. 复制全部内容到 Navicat 查询窗口
3. 执行SQL
4. 如果出现 "Duplicate column name" 错误，这是正常的（说明字段已存在），可以忽略

## 📋 修复内容清单

本次迁移将修复以下问题：

### ✅ 创建缺失的表

- ✅ `security_alert` - 安防告警表（解决安防与门禁错误）
- ✅ `operation_log` - 操作日志表（解决操作日志错误）
- ✅ `facility` - 设备设施表（解决设备设施管理错误）
- ✅ `facility_maintenance_plan` - 设备维护计划表
- ✅ `user_question_ticket` - 用户问题工单表（智能客服）
- ✅ `access_log` - 门禁日志表（如果不存在）

### ✅ 修复缺失的字段

#### repair_order 表（报修工单）
- ✅ `deadline` - 完成时限
- ✅ `progress_node` - 维修进度节点
- ✅ `completion_proof` - 维修完成凭证
- ✅ `resident_reject_reason` - 居民退回理由
- ✅ `completed_at` - 维修完成时间
- ✅ `reject_reason` - 物业驳回理由
- ✅ `resident_rating` - 居民评分
- ✅ `resident_comment` - 居民评价
- ✅ `resident_confirmed_at` - 居民确认时间

#### ai_question 表（智能客服预设问题）
- ✅ `status` - 状态（启用/禁用）
- ✅ `keywords` - 关键词
- ✅ `created_by` - 创建人

#### ai_chat 表（AI对话记录）
- ✅ `answer_type` - 回答类型
- ✅ `manual_reply_id` - 人工答复ID
- ✅ `ai_call_log_id` - AI调用记录ID
- ✅ `is_helpful` - 是否解决

#### ai_api_config 表（AI配置）
- ✅ `system_prompt` - 系统提示词
- ✅ `enable_auto_reply` - 启用AI自动回复

#### ai_manual_reply 表（人工答复）
- ✅ `title` - 问题标题
- ✅ `house_id` - 房屋ID
- ✅ `closed_at` - 关闭时间

#### announcement 表（公告）
- ✅ `is_urgent` - 是否紧急提醒

## 🔍 验证修复

执行完迁移脚本后，运行以下SQL验证：

```sql
-- 1. 检查 security_alert 表是否存在
SHOW TABLES LIKE 'security_alert';

-- 2. 检查 operation_log 表是否存在
SHOW TABLES LIKE 'operation_log';

-- 3. 检查 facility 表是否存在
SHOW TABLES LIKE 'facility';

-- 4. 检查 repair_order 表结构（查看是否有新字段）
DESC repair_order;

-- 5. 检查 ai_question 表结构
DESC ai_question;
```

如果所有表都存在，说明修复成功！

## 🚀 重启服务

修复完成后，请重启后端服务：

1. **停止当前运行的后端服务**
   - 如果使用IDE运行，停止运行
   - 如果使用jar包运行，按 `Ctrl+C` 停止

2. **重新启动后端服务**
   ```bash
   cd backend
   mvn spring-boot:run
   # 或
   java -jar target/community-platform.jar
   ```

3. **刷新前端页面**
   - 清除浏览器缓存
   - 刷新页面（`Ctrl+F5`）

## ❓ 常见问题

### Q1: 执行脚本时提示 "Table 'community_platform.xxx' doesn't exist"？

**A**: 这说明 `community_platform` 数据库不存在。请先创建数据库：
```sql
CREATE DATABASE community_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Q2: 执行脚本时提示 "Access denied"？

**A**: 请检查数据库用户名和密码是否正确，确保有足够的权限。

### Q3: 执行后仍然报错？

**A**: 
1. 检查是否选择了正确的数据库（`community_platform`）
2. 检查MySQL版本是否 >= 5.7
3. 查看错误信息，可能是其他问题

### Q4: 如何备份数据库？

**A**: 在 Navicat 中：
1. 右键点击 `community_platform` 数据库
2. 选择 "转储SQL文件" → "结构和数据"
3. 保存到安全位置

## 📞 需要帮助？

如果按照以上步骤操作后仍有问题，请检查：

1. ✅ MySQL版本 >= 5.7
2. ✅ 数据库连接正常
3. ✅ 有足够的数据库权限
4. ✅ 已选择正确的数据库（`community_platform`）

## ✨ 完成后的效果

修复完成后，以下功能应该可以正常使用：

- ✅ 报修工单管理（物业管理员、系统管理员）
- ✅ 设备设施管理
- ✅ 安防与门禁管理
- ✅ 操作日志查看
- ✅ 智能客服功能
- ✅ 所有其他功能模块

祝您使用愉快！🎉
