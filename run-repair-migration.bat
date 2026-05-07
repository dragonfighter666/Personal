@echo off
chcp 65001 >nul
echo 正在执行 repair_order 表结构更新...
mysql -u root -p123456 community_platform < db\repair_order_migration.sql 2>nul
if %errorlevel% neq 0 (
  echo 若密码不是 123456，请手动执行：
  echo   mysql -u root -p community_platform ^< db\repair_order_migration.sql
  echo 若某列已存在会报错，可忽略。
) else (
  echo 更新完成。
)
pause
