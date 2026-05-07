# 社区一体化融合服务平台

## 项目简介

社区一体化融合服务平台是一个面向社区居民、物业管理员、维修工和系统管理员的综合性社区管理平台。系统提供报修工单、费用缴费、访客管理、智能客服、社区活动等核心功能。

## 技术栈

### 后端
- **框架**: Spring Boot 2.x
- **ORM**: MyBatis-Plus
- **数据库**: MySQL 5.7+
- **Java版本**: JDK 8+

### 前端
- **框架**: Vue 2/3
- **UI组件**: Element UI / Element Plus
- **构建工具**: Webpack / Vite

## 快速开始

### 启动顺序（避免前端报 Proxy error / ECONNREFUSED）

前端请求会代理到后端 `http://localhost:8080`。**必须先启动后端，再访问前端**，否则会报「Proxy error / ECONNREFUSED」或「后端服务未启动」。

1. **启动 MySQL**，并确保已创建数据库、执行过迁移脚本。
2. **启动后端**（在项目根目录下执行）：
   ```bash
   cd backend
   mvn spring-boot:run
   ```
   看到 `Started ... Application` 且无报错后，后端已在 8080 端口运行。
3. **启动前端**（新开一个终端）：
   ```bash
   cd frontend
   npm run serve
   ```
4. 浏览器访问 **http://localhost:8082**（管理端）或居民端对应地址。若仍提示「后端服务未启动」，请确认后端已成功启动在 8080 端口后再刷新页面。

### 1. 环境要求

- JDK 8+
- Maven 3.6+
- MySQL 5.7+
- Node.js 14+（前端）

### 2. 数据库配置

#### 步骤1：创建数据库

```sql
CREATE DATABASE community_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 步骤2：执行数据库迁移脚本

**推荐使用安全版迁移脚本**（自动检测字段是否存在，避免重复错误）：

```bash
# 在 Navicat 中执行
backend/db/SAFE_COMPLETE_MIGRATION.sql
```

或者使用标准版：

```bash
backend/db/complete_database_migration.sql
```

**执行方式**：
1. 打开 Navicat
2. 连接到 MySQL 数据库
3. 选择 `community_platform` 数据库
4. 打开查询窗口
5. 打开 SQL 文件并执行全部内容

#### 步骤3：验证数据库

```sql
-- 检查关键表是否存在
SHOW TABLES LIKE 'security_alert';
SHOW TABLES LIKE 'operation_log';
SHOW TABLES LIKE 'facility';
SHOW TABLES LIKE 'repair_order';
SHOW TABLES LIKE 'user_question_ticket';
```

### 3. 后端配置

#### 步骤1：修改数据库连接配置

编辑 `backend/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/community_platform?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver
```

#### 步骤2：编译运行

**开发时推荐**（先启动后端再启动前端）：

```bash
cd backend
mvn spring-boot:run
```

或打包后运行：

```bash
cd backend
mvn clean package
java -jar target/community-platform-backend-1.0.0.jar
```

也可在 IDE 中直接运行 Spring Boot 主类。

### 4. 前端配置

#### 步骤1：安装依赖

```bash
cd frontend
npm install
```

#### 步骤2：配置API地址

编辑 `frontend/src/utils/request.js` 或相关配置文件，设置后端API地址：

```javascript
const baseURL = 'http://localhost:8080/api'
```

#### 步骤3：运行开发服务器

```bash
npm run serve
```

前端开发服务器运行在 **http://localhost:8082**，API 请求会代理到后端 8080 端口。请确保后端已启动后再访问前端。

## 项目结构

```
bishe_finally/
├── backend/                    # 后端项目
│   ├── src/main/java/         # Java源码
│   ├── src/main/resources/    # 配置文件
│   └── db/                    # 数据库脚本
│       ├── SAFE_COMPLETE_MIGRATION.sql    # 安全版迁移脚本（推荐）
│       ├── complete_database_migration.sql # 标准版迁移脚本
│       └── ...                # 其他SQL脚本
│
├── frontend/                   # 前端项目
│   ├── src/
│   │   ├── views/            # 页面组件
│   │   ├── components/       # 公共组件
│   │   ├── router/           # 路由配置
│   │   └── utils/           # 工具函数
│   └── package.json
│
├── docs/                      # 项目文档
│   ├── PROJECT_STRUCTURE_OPTIMIZATION.md  # 项目结构说明
│   ├── AI_SERVICE_REDESIGN_SUMMARY.md     # 智能客服重构总结
│   └── ...
│
└── 参考.txt                   # 项目需求文档
```

详细结构说明请参考：[PROJECT_STRUCTURE_OPTIMIZATION.md](docs/PROJECT_STRUCTURE_OPTIMIZATION.md)

## 核心功能模块

### 1. 用户角色

- **居民**: 使用移动端/小程序，提交报修、缴费、访客申请等
- **物业管理员**: 使用Web管理后台，处理工单、审核申请、数据统计
- **维修工**: 使用移动端，接收维修任务、提交完成报告
- **系统管理员**: 使用Web管理后台，用户管理、权限配置、系统设置

### 2. 主要功能

- ✅ **报修工单**: 居民提交 → 物业指派 → 维修工处理 → 居民验收
- ✅ **费用缴费**: 账单生成 → 居民缴费 → 物业审核
- ✅ **访客管理**: 访客申请 → 物业审核 → 通行码生成
- ✅ **智能客服**: 预设问题 → AI解答 → 人工客服
- ✅ **社区活动**: 活动发布 → 居民报名
- ✅ **设备设施**: 设备管理 → 维护计划
- ✅ **安防管理**: 门禁日志 → 异常告警
- ✅ **数据统计**: 各类数据看板

## 数据库迁移说明

### 重要提示

⚠️ **执行迁移脚本前，请务必备份数据库！**

### 迁移脚本说明

1. **SAFE_COMPLETE_MIGRATION.sql**（推荐）
   - 使用存储过程自动检测字段是否存在
   - 避免 "Duplicate column name" 错误
   - 可以重复执行，不会报错

2. **complete_database_migration.sql**（标准版）
   - 标准SQL语句
   - 如果字段已存在会报错（可忽略）

### 迁移内容

- ✅ 创建缺失的表：`security_alert`、`operation_log`、`facility`、`facility_maintenance_plan`、`user_question_ticket`
- ✅ 修复 `repair_order` 表：添加缺失字段
- ✅ 修复 `ai_question`、`ai_chat`、`ai_api_config` 等表：添加缺失字段
- ✅ 创建索引优化查询性能

## 常见问题

### Q1: 执行迁移脚本时出现 "Duplicate column name" 错误？

**A**: 这是正常的，说明该字段已存在。可以：
- 使用 `SAFE_COMPLETE_MIGRATION.sql`（推荐，自动检测）
- 或手动注释掉已存在的字段添加语句

### Q2: 后端启动失败，提示表不存在？

**A**: 请确保已执行数据库迁移脚本。检查：
```sql
SHOW TABLES LIKE 'security_alert';
SHOW TABLES LIKE 'operation_log';
```

### Q3: 前端无法连接后端？

**A**: 检查：
1. 后端是否正常启动（默认端口8080）
2. 前端API配置是否正确
3. 跨域配置是否正确

### Q4: 如何查看数据库表结构？

**A**: 
```sql
DESC table_name;
-- 或
SHOW CREATE TABLE table_name;
```

## 开发规范

### 后端规范

- 统一使用 `ApiResponse<T>` 封装返回结果
- 统一异常处理：`GlobalExceptionHandler`
- 标准分层架构：Controller → Service → Mapper → Entity
- 使用 MyBatis-Plus 进行数据库操作

### 前端规范

- 组件化开发
- 统一API调用封装
- 统一错误处理
- 遵循 Vue 官方风格指南

详细规范请参考：[PROJECT_STRUCTURE_OPTIMIZATION.md](docs/PROJECT_STRUCTURE_OPTIMIZATION.md)

## 文档索引

- [项目结构优化文档](docs/PROJECT_STRUCTURE_OPTIMIZATION.md)
- [智能客服重构总结](docs/AI_SERVICE_REDESIGN_SUMMARY.md)
- [数据库查询示例](backend/db/QUERY_EXAMPLES_AI_SERVICE.md)
- [项目需求文档](参考.txt)

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请查看文档或提交Issue。
