#!/bin/bash

# ===========================================
# Flutter 项目推送到 GitHub 脚本
# 使用 GitHub CLI (gh) 操作
# ===========================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ===========================================
# 检查前置条件
# ===========================================
check_prerequisites() {
    print_info "检查前置条件..."
    
    # 检查 git
    if ! command -v git &> /dev/null; then
        print_error "git 未安装，请先安装 git"
        exit 1
    fi
    
    # 检查 GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) 未安装"
        print_info "安装方法："
        print_info "  Windows: winget install GitHub.cli"
        print_info "  macOS: brew install gh"
        print_info "  Linux: sudo apt install gh"
        exit 1
    fi
    
    # 检查 GitHub CLI 登录状态
    if ! gh auth status &> /dev/null; then
        print_warning "GitHub CLI 未登录，正在尝试登录..."
        gh auth login
    fi
    
    # 检查 Flutter
    if ! command -v flutter &> /dev/null; then
        print_warning "Flutter 未安装，跳过本地构建检查"
    fi
    
    print_success "前置条件检查完成"
}

# ===========================================
# 初始化 Git 仓库
# ===========================================
init_git_repo() {
    print_info "初始化 Git 仓库..."
    
    if [ ! -d ".git" ]; then
        git init
        print_success "Git 仓库初始化完成"
    else
        print_info "Git 仓库已存在"
    fi
    
    # 创建 .gitignore（如果不存在）
    if [ ! -f ".gitignore" ]; then
        create_gitignore
    fi
}

# ===========================================
# 创建 .gitignore
# ===========================================
create_gitignore() {
    print_info "创建 .gitignore..."
    
    cat > .gitignore << 'EOF'
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
build/
.pub-cache/
.pub/
**/doc/api/

# IDE
.idea/
.vscode/
*.iml
*.ipr
*.iws

# Android
android/.gradle
android/captures/
android/gradlew
android/gradlew.bat
android/local.properties
android/**/GeneratedPluginRegistrant.java
android/key.properties
*.jks
*.keystore

# iOS
ios/**/*.mode1v3
ios/**/*.mode2v3
ios/**/*.moved-aside
ios/**/*.pbxuser
ios/**/*.perspectivev3
**/ios/**/*.pyc
**/ios/Pods/
**/ios/.symlinks/
**/ios/Flutter/Flutter.framework
**/ios/Flutter/Flutter.podspec
**/ios/Flutter/Generated.xcconfig
**/ios/Flutter/app.flx
**/ios/Flutter/app.zip
**/ios/Flutter/flutter_assets/
**/ios/Flutter/flutter_export_environment.sh
**/ios/ServiceDefinitions.json

# macOS
**/macos/Flutter/GeneratedPluginRegistrant.swift
**/macos/Flutter/ephemeral/
**/xcuserdata/

# Web
**/web/favicon.png
**/web/icons/Icon-192.png
**/web/icons/Icon-512.png
**/web/icons/Icon-maskable-192.png
**/web/icons/Icon-maskable-512.png
**/web/manifest.json

# Linux
**/linux/flutter/ephemeral/
**/linux/flutter/generated_plugins.cmake

# Windows
**/windows/flutter/ephemeral/
**/windows/flutter/generated_plugins.cmake

# Debug
*.log
debug.log

# OS
.DS_Store
Thumbs.db
*.swp
*.tmp

# Secrets
.env
.env.local
.env.production
secrets/
EOF
    
    print_success ".gitignore 创建完成"
}

# ===========================================
# 创建远程仓库
# ===========================================
create_remote_repo() {
    local repo_name=$1
    local description=${2:-"农业地块与农作物管理 App"}
    local private=${3:-false}
    
    print_info "创建远程仓库: $repo_name"
    
    # 检查仓库是否已存在
    if gh repo view "$repo_name" &> /dev/null; then
        print_warning "仓库 $repo_name 已存在"
        return 0
    fi
    
    # 创建仓库
    if [ "$private" = true ]; then
        gh repo create "$repo_name" --private --description "$description" --source=. --remote=origin
    else
        gh repo create "$repo_name" --public --description "$description" --source=. --remote=origin
    fi
    
    print_success "远程仓库创建成功: $repo_name"
}

# ===========================================
# 提交代码
# ===========================================
commit_code() {
    local message=${1:-"feat: initial commit"}
    
    print_info "提交代码..."
    
    # 添加所有文件
    git add .
    
    # 检查是否有变更
    if git diff --cached --quiet; then
        print_warning "没有代码变更"
        return 0
    fi
    
    # 提交
    git commit -m "$message"
    
    print_success "代码提交完成"
}

# ===========================================
# 推送代码
# ===========================================
push_code() {
    local branch=${1:-main}
    
    print_info "推送到远程仓库..."
    
    # 推送
    git push -u origin "$branch"
    
    print_success "代码推送成功"
}

# ===========================================
# 创建 Release 并触发构建
# ===========================================
create_release() {
    local version=$1
    local message=${2:-"Release v$version"}
    
    print_info "创建 Release: v$version"
    
    # 创建 tag
    git tag -a "v$version" -m "$message"
    git push origin "v$version"
    
    print_success "Release v$version 创建成功"
    print_info "GitHub Actions 将自动构建 APK..."
    print_info "查看构建状态: gh run list"
}

# ===========================================
# 主流程
# ===========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Flutter 项目 GitHub 推送脚本"
    echo "=========================================="
    echo ""
    
    # 解析参数
    local repo_name=""
    local version=""
    local private=false
    local skip_build=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --repo|-r)
                repo_name="$2"
                shift 2
                ;;
            --version|-v)
                version="$2"
                shift 2
                ;;
            --private|-p)
                private=true
                shift
                ;;
            --skip-build)
                skip_build=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查前置条件
    check_prerequisites
    
    # 初始化 Git
    init_git_repo
    
    # 如果指定了仓库名，创建远程仓库
    if [ -n "$repo_name" ]; then
        create_remote_repo "$repo_name" "农业地块与农作物管理 App" "$private"
    fi
    
    # 提交代码
    commit_code "feat: 完成农业管理系统前后端对接"
    
    # 推送代码
    push_code
    
    # 如果指定了版本号，创建 Release
    if [ -n "$version" ]; then
        create_release "$version"
    fi
    
    echo ""
    echo "=========================================="
    echo "  ✅ 操作完成！"
    echo "=========================================="
    echo ""
    print_info "后续操作："
    print_info "  1. 查看仓库: gh browse"
    print_info "  2. 查看构建: gh run list"
    print_info "  3. 创建 Release: ./scripts/release.sh 1.0.0"
    echo ""
}

# ===========================================
# 显示帮助
# ===========================================
show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --repo, -r NAME      创建/指定远程仓库名"
    echo "  --version, -v VER    创建 Release 版本"
    echo "  --private, -p        创建私有仓库"
    echo "  --skip-build         跳过本地构建"
    echo "  --help, -h           显示帮助"
    echo ""
    echo "示例:"
    echo "  $0                                    # 推送到已有仓库"
    echo "  $0 --repo nongzuowu-app               # 创建新仓库并推送"
    echo "  $0 --repo nongzuowu-app -v 1.0.0      # 创建仓库并发布"
    echo "  $0 -v 1.0.0                           # 推送并发布 v1.0.0"
}

# 运行主流程
main "$@"
