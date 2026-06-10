#!/bin/bash

# ===========================================
# Flutter APK 发布脚本
# 自动构建并发布到 GitHub Release
# ===========================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ===========================================
# 版本号验证
# ===========================================
validate_version() {
    local version=$1
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "版本号格式错误: $version"
        print_info "正确格式: x.y.z (例如: 1.0.0)"
        exit 1
    fi
}

# ===========================================
# 本地构建 APK
# ===========================================
build_apk_locally() {
    print_info "本地构建 APK..."
    
    # 清理旧构建
    flutter clean
    
    # 获取依赖
    flutter pub get
    
    # 构建 Release APK
    print_info "构建 Release APK..."
    flutter build apk --release
    
    # 检查构建结果
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        local size=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
        print_success "APK 构建成功！大小: $size"
        return 0
    else
        print_error "APK 构建失败"
        return 1
    fi
}

# ===========================================
# 创建 GitHub Release
# ===========================================
create_github_release() {
    local version=$1
    local release_notes=$2
    
    print_info "创建 GitHub Release: v$version"
    
    # 创建 Release 并上传 APK
    gh release create "v$version" \
        --title "v$version" \
        --notes "$release_notes" \
        --draft=false \
        --prerelease=false \
        build/app/outputs/flutter-apk/app-release.apk#app-release.apk
    
    print_success "Release v$version 创建成功"
}

# ===========================================
# 生成 Release Notes
# ===========================================
generate_release_notes() {
    local version=$1
    
    cat << EOF
## 🚀 农业地块与农作物管理 App v$version

### 📱 Android APK
- \`app-release.apk\` - Release 版本（推荐安装）

### 🔧 安装说明
1. 下载 \`app-release.apk\`
2. 在 Android 设备上允许安装未知来源应用
3. 点击 APK 文件安装

### ✨ 功能特性
- 🗺️ 地图圈地与面积计算
- 🌱 作物档案管理
- 🌤️ 气象农事提醒
- 📸 AI 长势识别
- 📊 经营总览与任务

### 🔗 相关链接
- [源代码](https://github.com/${{ github.repository }})
- [问题反馈](https://github.com/${{ github.repository }}/issues)

---
*构建时间: $(date '+%Y-%m-%d %H:%M:%S')*
EOF
}

# ===========================================
# 主流程
# ===========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Flutter APK 发布脚本"
    echo "=========================================="
    echo ""
    
    # 解析参数
    local version=""
    local skip_build=false
    local draft=false
    local notes=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --version|-v)
                version="$2"
                shift 2
                ;;
            --skip-build)
                skip_build=true
                shift
                ;;
            --draft)
                draft=true
                shift
                ;;
            --notes|-n)
                notes="$2"
                shift 2
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
    
    # 检查版本号
    if [ -z "$version" ]; then
        print_error "请指定版本号"
        show_help
        exit 1
    fi
    
    # 验证版本号格式
    validate_version "$version"
    
    # 检查 GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) 未安装"
        exit 1
    fi
    
    # 检查是否已存在该版本的 Release
    if gh release view "v$version" &> /dev/null; then
        print_error "Release v$version 已存在"
        exit 1
    fi
    
    # 本地构建（可选）
    if [ "$skip_build" = false ]; then
        if ! build_apk_locally; then
            print_error "本地构建失败"
            exit 1
        fi
    fi
    
    # 检查 APK 文件
    if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        print_error "找不到 APK 文件，请先构建"
        print_info "运行: flutter build apk --release"
        exit 1
    fi
    
    # 生成 Release Notes
    if [ -z "$notes" ]; then
        notes=$(generate_release_notes "$version")
    fi
    
    # 创建 Release
    create_github_release "$version" "$notes"
    
    # 推送 tag
    git tag -a "v$version" -m "Release v$version"
    git push origin "v$version"
    
    echo ""
    echo "=========================================="
    echo "  ✅ 发布完成！"
    echo "=========================================="
    echo ""
    print_info "Release 地址: $(gh release view v$version --json url -q .url)"
    print_info "APK 下载: $(gh release view v$version --json assets -q '.assets[0].url')"
    echo ""
}

# ===========================================
# 显示帮助
# ===========================================
show_help() {
    echo "用法: $0 --version <版本号> [选项]"
    echo ""
    echo "选项:"
    echo "  --version, -v VER    版本号 (必须, 格式: x.y.z)"
    echo "  --skip-build         跳过本地构建"
    echo "  --draft              创建草稿 Release"
    echo "  --notes, -n NOTES    自定义 Release Notes"
    echo "  --help, -h           显示帮助"
    echo ""
    echo "示例:"
    echo "  $0 -v 1.0.0                    # 构建并发布 v1.0.0"
    echo "  $0 -v 1.0.0 --skip-build       # 跳过构建，直接发布"
    echo "  $0 -v 1.0.0 --draft            # 创建草稿 Release"
    echo "  $0 -v 1.0.0 -n '自定义说明'     # 使用自定义说明"
}

# 运行
main "$@"
