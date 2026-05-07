@echo off

cd /d "%~dp0backend"
start "Backend" cmd /k mvn spring-boot:run

cd /d "%~dp0frontend"
start "Frontend" cmd /k npm run serve

cd /d "%~dp0frontend-visitor"
start "Frontend-Visitor" cmd /k npm run serve

timeout /t 25

start chrome.exe "http://localhost:8082/login"
start chrome.exe "http://localhost:8082/login"
start chrome.exe "http://localhost:8082/login"
start chrome.exe "http://localhost:8082/login"
start chrome.exe "http://localhost:8082/login"
start chrome.exe "http://localhost:8082/visitor-portal"

pause
