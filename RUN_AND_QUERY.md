# 社区一体化平台 - 启动与数据库说明（最终版）

本文档说明：**数据库如何执行**、**后端/前端如何启动**、**改动后如何用 SQL 做查询**。  
数据库与测试数据以 `backend/db/00_schema_final.sql` 与 `backend/db/01_test_data_final.sql` 为准，替代此前所有迁移与测试数据脚本。

---

## 一、数据库执行

### 1. 环境要求

- MySQL 5.7+ 或 8.x
- 字符集建议：`utf8mb4`

### 2. 执行顺序（必须按顺序）

1. **先执行** `backend/db/00_schema_final.sql`  
   - 会创建库 `community_platform`（若不存在），删除旧表并重建所有表结构。
2. **再执行** `backend/db/01_test_data_final.sql`  
   - 插入四端角色、测试用户、社区/住房、居民绑定、报修/投诉/账单/访客/公告/活动/投票/互助/设施/停车/智能客服等测试数据。

### 3. 执行方式示例

**方式 A：Navicat / DBeaver 等图形工具**

- 打开并执行 `00_schema_final.sql`，确认无报错。
- 再打开并执行 `01_test_data_final.sql`，确认末尾提示“执行完成”。

**方式 B：MySQL 命令行**

```bash
mysql -u root -p < backend/db/00_schema_final.sql
mysql -u root -p < backend/db/01_test_data_final.sql
```

或登录后：

```sql
source C:/Users/杨/Desktop/bishe_finally/backend/db/00_schema_final.sql
source C:/Users/杨/Desktop/bishe_finally/backend/db/01_test_data_final.sql
```

### 4. 后端连接配置

- 数据库名：`community_platform`
- 当前配置见 `backend/src/main/resources/application.yml`：  
  - `url`: `jdbc:mysql://localhost:3306/community_platform?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai`  
  - `username`: `root`  
  - `password`: `123456`  

若本机 MySQL 用户名/密码不同，请修改该文件中的 `spring.datasource.username` 与 `spring.datasource.password`。

---

## 二、后端启动

```bash
cd backend
mvn spring-boot:run
```

- 默认端口：**8080**
- 启动成功后接口基地址：`http://localhost:8080`

---

## 三、前端启动

```bash
cd frontend
npm install
npm run serve
```

- 开发环境通常为：**http://localhost:8080** 或 **http://localhost:8082**（以终端输出为准）。

---

## 四、测试账号（01_test_data_final.sql 插入）

| 角色       | 姓名/账号   | 手机号       | 密码   |
|------------|-------------|--------------|--------|
| 居民       | 张三        | 13800001111  | 123456 |
| 物业管理员 | 李四        | 13800002222  | 123456 |
| 维修工     | 王五        | 13800003333  | 123456 |
| 系统管理员 | admin       | 13800000000  | 123456 |

登录时一般用 **手机号** 或 **用户名** + 密码（具体以当前前端登录页为准）。

---

## 五、常用查询示例（改动后数据库）

以下 SQL 均在执行完 `00_schema_final.sql` 和 `01_test_data_final.sql` 后，在库 `community_platform` 下执行。

### 1. 按角色查用户（姓名+手机号 身份键）

```sql
SELECT u.id, u.nick_name AS 姓名, u.phone AS 手机号, r.name AS 角色
FROM user u
JOIN user_role ur ON u.id = ur.user_id
JOIN role r ON ur.role_id = r.id
ORDER BY r.id, u.id;
```

### 2. 按报修工单号查工单及居民、住房信息

```sql
SELECT ro.order_no AS 工单号, ro.house_address AS 住房, ro.status AS 状态,
       u.nick_name AS 报修人, u.phone AS 报修人手机
FROM repair_order ro
JOIN user u ON ro.resident_id = u.id
WHERE ro.order_no = 'RO20250210001';
```

### 3. 按住房查账单与费用类型

```sql
SELECT b.bill_no AS 账单号, h.house_no AS 室号, ft.name AS 费用类型,
       b.period_start, b.period_end, b.amount, b.status
FROM bill b
JOIN house h ON b.house_id = h.id
JOIN fee_type ft ON b.fee_type_id = ft.id
ORDER BY b.id;
```

### 4. 居民房产绑定（已审核通过）

```sql
SELECT u.nick_name AS 居民, u.phone, rhb.building_no AS 栋, rhb.unit_no AS 单元, rhb.room_no AS 室, rhb.status
FROM resident_house_binding rhb
JOIN user u ON rhb.user_id = u.id
WHERE rhb.status = 'APPROVED';
```

### 5. 报修工单及维修工（已派单时）

```sql
SELECT ro.order_no, ro.status, resident.nick_name AS 居民, repairer.nick_name AS 维修工
FROM repair_order ro
JOIN user resident ON ro.resident_id = resident.id
LEFT JOIN user repairer ON ro.repairer_id = repairer.id;
```

按需把上述语句在 Navicat 或 `mysql` 客户端中执行即可验证数据与联动。

---

## 六、旧脚本说明

- **权威脚本**：仅以 `00_schema_final.sql`（表结构）与 `01_test_data_final.sql`（测试数据）为准。
- 此前各类迁移脚本、单独测试数据脚本均已由上述两文件替代；如需保留可自行挪至 `backend/db/archive/` 等目录备份。
