@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===========================================
:: Flutter APK 发布脚本 (Windows)
:: ===========================================

echo.
echo ==========================================
echo   Flutter APK 发布脚本
echo ==========================================
echo.

:: 解析参数
set "VERSION="
set "SKIP_BUILD="
set "NOTES="

:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="--version" (
    set "VERSION=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-v" (
    set "VERSION=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--skip-build" (
    set "SKIP_BUILD=true"
    shift
    goto :parse_args
)
if /i "%~1"=="--notes" (
    set "NOTES=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-n" (
    set "NOTES=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="-h" goto :show_help
echo [ERROR] 未知参数: %~1
goto :show_help

:main
:: 检查版本号
if not defined VERSION (
    echo [ERROR] 请指定版本号
    goto :show_help
)

:: 验证版本号格式
echo %VERSION% | findstr /r "^[0-9]*\.[0-9]*\.[0-9]*$" >nul
if %errorlevel% neq 0 (
    echo [ERROR] 版本号格式错误: %VERSION%
    echo [INFO] 正确格式: x.y.z (例如: 1.0.0)
    pause
    exit /b 1
)

:: 检查 GitHub CLI
where gh >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] GitHub CLI (gh) 未安装
    pause
    exit /b 1
)

:: 检查是否已存在该版本的 Release
gh release view "v%VERSION%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [ERROR] Release v%VERSION% 已存在
    pause
    exit /b 1
)

:: 本地构建（可选）
if not "%SKIP_BUILD%"=="true" (
    echo [INFO] 本地构建 APK...
    
    :: 清理旧构建
    flutter clean
    
    :: 获取依赖
    flutter pub get
    
    :: 构建 Release APK
    echo [INFO] 构建 Release APK...
    flutter build apk --release
    
    if %errorlevel% neq 0 (
        echo [ERROR] APK 构建失败
        pause
        exit /b 1
    )
    
    echo [SUCCESS] APK 构建成功
)

:: 检查 APK 文件
if not exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo [ERROR] 找不到 APK 文件，请先构建
    echo [INFO] 运行: flutter build apk --release
    pause
    exit /b 1
)

:: 创建 Release
echo [INFO] 创建 GitHub Release: v%VERSION%

if defined NOTES (
    gh release create "v%VERSION%" ^
        --title "v%VERSION%" ^
        --notes "%NOTES%" ^
        build\app\outputs\flutter-apk\app-release.apk#app-release.apk
) else (
    gh release create "v%VERSION%" ^
        --title "v%VERSION%" ^
        --notes "## 🚀 农业地块与农作物管理 App v%VERSION%"\n\n"### 📱 Android APK"\n"- app-release.apk - Release 版本（推荐）"\n\n"### 🔧 安装说明"\n"1. 下载 app-release.apk"\n"2. 允许安装未知来源应用"\n"3. 点击安装" ^
        build\app\outputs\flutter-apk\app-release.apk#app-release.apk
)

if %errorlevel% neq 0 (
    echo [ERROR] Release 创建失败
    pause
    exit /b 1
)

:: 推送 tag
git tag -a "v%VERSION%" -m "Release v%VERSION%"
git push origin "v%VERSION%"

echo.
echo ==========================================
echo   ✅ 发布完成！
echo ==========================================
echo.
echo [INFO] 查看 Release: gh release view v%VERSION%
echo.

pause
exit /b 0

:: ===========================================
:: 显示帮助
:: ===========================================
:show_help
echo 用法: %~nx0 --version ^<版本号^> [选项]
echo.
echo 选项:
echo   --version, -v VER    版本号 (必须, 格式: x.y.z)
echo   --skip-build         跳过本地构建
echo   --notes, -n NOTES    自定义 Release Notes
echo   --help, -h           显示帮助
echo.
echo 示例:
echo   %~nx0 -v 1.0.0                    # 构建并发布 v1.0.0
echo   %~nx0 -v 1.0.0 --skip-build       # 跳过构建，直接发布
echo   %~nx0 -v 1.0.0 -n "自定义说明"     # 使用自定义说明
echo.
pause
exit /b 0
