@echo off
chcp 65001 >nul

REM K6 Load Test Script (Windows)
REM Start Docker containers first: docker compose up -d

REM Get script directory and project root
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%~dp0.."

REM Change to project root
cd /d "%PROJECT_ROOT%"

echo ===== K6 Load Test Start =====
echo Test Config: VU=2, Duration=1min, RPS=10
echo Script Dir: %SCRIPT_DIR%
echo Project Root: %PROJECT_ROOT%
echo Current Dir: %CD%
echo.

REM Check Docker containers
echo 1. Docker Container Status...
docker compose ps
echo.

REM Create results directory
if not exist "%SCRIPT_DIR%results" mkdir "%SCRIPT_DIR%results"

REM Generate timestamp
for /f "tokens=1-3 delims=/- " %%a in ('date /t') do set "datestr=%%c%%a%%b"
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set "timestr=%%a%%b"
set "timestr=%timestr: =0%"
set "TIMESTAMP=%datestr%_%timestr%"

echo 2. Download Tests...
echo    2-1. Download via nginx1 proxy
k6 run --out json="%SCRIPT_DIR%results\download_nginx1_%TIMESTAMP%.json" "%SCRIPT_DIR%download-nginx1.js"

echo    2-2. Download direct nginx2
k6 run --out json="%SCRIPT_DIR%results\download_nginx2_%TIMESTAMP%.json" "%SCRIPT_DIR%download-nginx2.js"

echo.
echo 3. Upload Tests...
echo    3-1. Upload via nginx1 proxy
k6 run --out json="%SCRIPT_DIR%results\upload_nginx1_%TIMESTAMP%.json" "%SCRIPT_DIR%upload-nginx1.js"

echo    3-2. Upload direct nginx2
k6 run --out json="%SCRIPT_DIR%results\upload_nginx2_%TIMESTAMP%.json" "%SCRIPT_DIR%upload-nginx2.js"

echo.
echo ===== K6 Load Test Complete =====
echo Results saved to: %SCRIPT_DIR%results\
echo Timestamp: %TIMESTAMP%

echo.
echo ===== Test Summary =====
echo Check JSON files for detailed results

pause