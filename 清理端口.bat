@echo off
chcp 65001 >nul
echo 正在清理端口 8080、8082、8083 ...
for %%p in (8080 8082 8083) do (
  for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p" ^| findstr "LISTENING"') do (
    if not "%%a"=="0" taskkill /PID %%a /F >nul 2>&1
  )
)
echo 清理完成。
pause
