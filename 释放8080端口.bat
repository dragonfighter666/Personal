@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title 释放 8080 端口
echo 正在查找占用 8080 端口的进程...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
  echo 发现进程 PID: %%a，正在结束...
  taskkill /F /PID %%a 2>nul
  if !errorlevel! equ 0 (echo 已结束 PID %%a) else (echo 结束失败，请右键“以管理员身份运行”本脚本)
)
echo.
echo 完成。可重新启动后端。
pause
