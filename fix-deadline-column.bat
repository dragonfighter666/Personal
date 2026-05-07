@echo off
echo 正在修复 repair_order 表的 deadline 列...
echo.

mysql -u root -p123456 community_platform < db\fix_repair_order_deadline.sql

if %errorlevel% equ 0 (
    echo.
    echo ✅ 修复完成！
) else (
    echo.
    echo ⚠️  执行出错，请检查 MySQL 是否运行，或手动执行 SQL 脚本
    echo SQL 文件位置: db\fix_repair_order_deadline.sql
)

pause
