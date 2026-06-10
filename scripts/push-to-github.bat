@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ===========================================
:: Flutter 项目推送到 GitHub 脚本 (Windows)
:: ===========================================

echo.
echo ==========================================
echo   Flutter 项目 GitHub 推送脚本
echo ==========================================
echo.

:: 检查 GitHub CLI
where gh >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] GitHub CLI (gh) 未安装
    echo [INFO] 安装方法: winget install GitHub.cli
    pause
    exit /b 1
)

:: 检查 gh 登录状态
gh auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] GitHub CLI 未登录，正在尝试登录...
    gh auth login
)

:: 解析参数
set "REPO_NAME="
set "VERSION="
set "PRIVATE="

:parse_args
if "%~1"=="" goto :main
if /i "%~1"=="--repo" (
    set "REPO_NAME=%~2"
    shift
    shift
    goto :parse_args
)
if /i "%~1"=="-r" (
    set "REPO_NAME=%~2"
    shift
    shift
    goto :parse_args
)
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
if /i "%~1"=="--private" (
    set "PRIVATE=true"
    shift
    goto :parse_args
)
if /i "%~1"=="-p" (
    set "PRIVATE=true"
    shift
    goto :parse_args
)
if /i "%~1"=="--help" (
    goto :show_help
)
if /i "%~1"=="-h" (
    goto :show_help
)
echo [ERROR] 未知参数: %~1
goto :show_help

:main
:: 初始化 Git 仓库
if not exist ".git" (
    echo [INFO] 初始化 Git 仓库...
    git init
    echo [SUCCESS] Git 仓库初始化完成
)

:: 创建 .gitignore（如果不存在）
if not exist ".gitignore" (
    echo [INFO] 创建 .gitignore...
    call :create_gitignore
)

:: 创建远程仓库（如果指定了）
if defined REPO_NAME (
    echo [INFO] 创建远程仓库: %REPO_NAME%
    gh repo view %REPO_NAME% >nul 2>&1
    if %errorlevel% neq 0 (
        if "%PRIVATE%"=="true" (
            gh repo create %REPO_NAME% --private --description "农业地块与农作物管理 App" --source=. --remote=origin
        ) else (
            gh repo create %REPO_NAME% --public --description "农业地块与农作物管理 App" --source=. --remote=origin
        )
        echo [SUCCESS] 远程仓库创建成功
    ) else (
        echo [WARNING] 仓库已存在
    )
)

:: 提交代码
echo [INFO] 提交代码...
git add .
git commit -m "feat: 完成农业管理系统前后端对接"
echo [SUCCESS] 代码提交完成

:: 推送代码
echo [INFO] 推送到远程仓库...
git push -u origin main
echo [SUCCESS] 代码推送成功

:: 创建 Release（如果指定了版本号）
if defined VERSION (
    echo [INFO] 创建 Release: v%VERSION%
    git tag -a "v%VERSION%" -m "Release v%VERSION%"
    git push origin "v%VERSION%"
    echo [SUCCESS] Release v%VERSION% 创建成功
    echo [INFO] GitHub Actions 将自动构建 APK...
)

echo.
echo ==========================================
echo   ✅ 操作完成！
echo ==========================================
echo.
echo [INFO] 后续操作:
echo   1. 查看仓库: gh browse
echo   2. 查看构建: gh run list
echo   3. 发布版本: scripts\release.bat 1.0.0
echo.

pause
exit /b 0

:: ===========================================
:: 创建 .gitignore
:: ===========================================
:create_gitignore
(
echo # Flutter
echo .dart_tool/
echo .flutter-plugins
echo .flutter-plugins-dependencies
echo .packages
echo build/
echo .pub-cache/
echo .pub/
echo.
echo # IDE
echo .idea/
echo .vscode/
echo *.iml
echo.
echo # Android
echo android/.gradle
echo android/captures/
echo android/gradlew
echo android/gradlew.bat
echo android/local.properties
echo *.jks
echo *.keystore
echo.
echo # iOS
echo ios/Pods/
echo ios/.symlinks/
echo ios/Flutter/Flutter.framework
echo ios/Flutter/Generated.xcconfig
echo.
echo # Debug
echo *.log
echo debug.log
echo.
echo # OS
echo .DS_Store
echo Thumbs.db
echo.
echo # Secrets
echo .env
echo .env.local
) > .gitignore
echo [SUCCESS] .gitignore 创建完成
goto :eof

:: ===========================================
:: 显示帮助
:: ===========================================
show_help
echo 用法: %~nx0 [选项]
echo.
echo 选项:
echo   --repo, -r NAME      创建/指定远程仓库名
echo   --version, -v VER    创建 Release 版本
echo   --private, -p        创建私有仓库
echo   --help, -h           显示帮助
echo.
echo 示例:
echo   %~nx0                                    # 推送到已有仓库
echo   %~nx0 --repo nongzuowu-app               # 创建新仓库并推送
echo   %~nx0 --repo nongzuowu-app -v 1.0.0      # 创建仓库并发布
echo   %~nx0 -v 1.0.0                           # 推送并发布 v1.0.0
echo.
pause
exit /b 0
