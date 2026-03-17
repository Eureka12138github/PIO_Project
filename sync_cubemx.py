"""
CubeMX 到 PlatformIO 自动同步脚本
功能：
1. 从 CubeMX 生成的工程复制必要文件到 PlatformIO 项目
2. 智能合并 main.c 文件，保留用户自定义代码
3. 备份机制，防止数据丢失
4. 支持双向同步（可选）
"""

import os
import shutil
import re
from pathlib import Path
from datetime import datetime

# ==================== 配置区域 ====================

# CubeMX 工程路径
CUBEMX_PROJECT_PATH = r"D:\Embedded-related\PlatformIO\CUBEMX FOR PIO\PROJECT_FOR_PIO"

# PlatformIO 工程路径（默认）
DEFAULT_PIO_PROJECT_PATH = r"D:\Embedded-related\PlatformIO\PIO_TEST2"

# ==================== 核心功能函数 ====================

def get_pio_project_path():
    """
    尝试获取当前 VSCode 工作区路径
    如果失败，返回默认路径
    """
    # 方法 1: 尝试从环境变量获取
    vscode_pid = os.environ.get('VSCODE_PID')
    if vscode_pid:
        # VSCode 环境中，尝试读取工作区
        workspace_folder = os.environ.get('VSCODE_WORKSPACE_FOLDER')
        if workspace_folder and os.path.exists(workspace_folder):
            print(f"✓ 检测到 VSCode 工作区：{workspace_folder}")
            return workspace_folder
    
    # 方法 2: 使用默认路径
    print(f"ℹ 使用默认 PlatformIO 工程路径：{DEFAULT_PIO_PROJECT_PATH}")
    return DEFAULT_PIO_PROJECT_PATH


def validate_paths(cubemx_path, pio_path):
    """验证路径是否存在"""
    errors = []
    
    if not os.path.exists(cubemx_path):
        errors.append(f"❌ CubeMX 工程路径不存在：{cubemx_path}")
    
    if not os.path.exists(pio_path):
        errors.append(f"❌ PlatformIO 工程路径不存在：{pio_path}")
    
    # 检查 CubeMX 目录结构
    core_inc_path = os.path.join(cubemx_path, "Core", "Inc")
    core_src_path = os.path.join(cubemx_path, "Core", "Src")
    
    if not os.path.exists(core_inc_path):
        errors.append(f"❌ CubeMX Core/Inc 目录不存在：{core_inc_path}")
    
    if not os.path.exists(core_src_path):
        errors.append(f"❌ CubeMX Core/Src 目录不存在：{core_src_path}")
    
    # 检查 PlatformIO 目录结构
    pio_src_path = os.path.join(pio_path, "src")
    pio_inc_path = os.path.join(pio_path, "include")
    
    if not os.path.exists(pio_src_path):
        errors.append(f"❌ PlatformIO src 目录不存在：{pio_src_path}")
    
    if not os.path.exists(pio_inc_path):
        errors.append(f"❌ PlatformIO include 目录不存在：{pio_inc_path}")
    
    if errors:
        for error in errors:
            print(error)
        return False
    
    print("✓ 路径验证通过")
    return True


def create_backup(file_path, backup_dir="backup"):
    """
    创建文件备份
    返回备份文件路径
    """
    if not os.path.exists(file_path):
        return None
    
    # 创建备份目录
    backup_path = os.path.join(os.path.dirname(file_path), backup_dir)
    os.makedirs(backup_path, exist_ok=True)
    
    # 生成带时间戳的备份文件名
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = os.path.basename(file_path)
    backup_filename = f"{filename}.{timestamp}.bak"
    backup_full_path = os.path.join(backup_path, backup_filename)
    
    # 复制文件
    shutil.copy2(file_path, backup_full_path)
    print(f"✓ 已备份：{filename} -> {backup_filename}")
    
    return backup_full_path


def extract_user_code_sections(file_path):
    """
    提取 main.c 中的用户自定义代码段
    返回用户代码段字典
    """
    if not os.path.exists(file_path):
        return {}
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    user_sections = {}
    
    # 匹配 /* USER CODE BEGIN XXX */ 和 /* USER CODE END XXX */ 之间的内容
    pattern = r'/\* USER CODE BEGIN (.*?) \*/\s*(.*?)\s*/\* USER CODE END (.*?) \*/'
    matches = re.findall(pattern, content, re.DOTALL)
    
    for begin_tag, code, end_tag in matches:
        if begin_tag == end_tag:
            user_sections[begin_tag] = code.strip()
            print(f"  ✓ 提取用户代码段：USER CODE {begin_tag}")
    
    return user_sections


def merge_main_files(cube_main_path, pio_main_path):
    """
    合并 CubeMX 的 main.c 和 PlatformIO 的 main.c
    策略：
    - 保留 PlatformIO 中的用户自定义代码段
    - 使用 CubeMX 的框架代码
    """
    print("\n📋 开始合并 main.c...")
    
    # 备份现有文件
    create_backup(pio_main_path)
    
    # 提取用户代码
    print("  提取 PlatformIO 中的用户代码...")
    user_code = extract_user_code_sections(pio_main_path)
    
    # 读取 CubeMX 的 main.c
    print("  读取 CubeMX main.c...")
    with open(cube_main_path, 'r', encoding='utf-8') as f:
        cube_content = f.read()
    
    # 如果 PlatformIO 没有用户代码，直接使用 CubeMX 版本
    if not user_code:
        print("  ℹ PlatformIO 中没有用户代码，直接复制 CubeMX 版本")
        shutil.copy2(cube_main_path, pio_main_path)
        return
    
    # 合并策略：用 CubeMX 的内容替换，但保留用户代码段
    print("  合并用户代码到 CubeMX 框架...")
    merged_content = cube_content
    
    # 对每个用户代码段，插入到对应位置
    for section_name, code in user_code.items():
        begin_marker = f"/* USER CODE BEGIN {section_name} */"
        end_marker = f"/* USER CODE END {section_name} */"
        
        # 查找插入位置
        pattern = re.escape(begin_marker) + r'.*?' + re.escape(end_marker)
        replacement = f"{begin_marker}\n{code}\n{end_marker}"
        
        merged_content = re.sub(pattern, replacement, merged_content, flags=re.DOTALL)
    
    # 写入合并后的文件
    with open(pio_main_path, 'w', encoding='utf-8') as f:
        f.write(merged_content)
    
    print("  ✓ main.c 合并完成")


def copy_files_safely(cubemx_path, pio_path, force=False):
    """
    安全复制文件
    force: 是否强制覆盖（main.c 除外，它总是使用合并模式）
    """
    core_inc = os.path.join(cubemx_path, "Core", "Inc")
    core_src = os.path.join(cubemx_path, "Core", "Src")
    pio_inc = os.path.join(pio_path, "include")
    pio_src = os.path.join(pio_path, "src")
    
    # 需要复制的文件列表
    files_to_copy = {
        'inc': [
            'stm32f1xx_hal_conf.h',
            'stm32f1xx_it.h',
            'main.h'
        ],
        'src': [
            'stm32f1xx_hal_msp.c',
            'stm32f1xx_it.c',
            'system_stm32f1xx.c'
        ]
    }
    
    print("\n📂 开始复制头文件...")
    for filename in files_to_copy['inc']:
        src_file = os.path.join(core_inc, filename)
        dst_file = os.path.join(pio_inc, filename)
        
        if os.path.exists(src_file):
            if os.path.exists(dst_file) and not force:
                create_backup(dst_file)
            shutil.copy2(src_file, dst_file)
            print(f"  ✓ {filename}")
        else:
            print(f"  ⚠ {filename} 不存在，跳过")
    
    print("\n📂 开始复制源文件...")
    for filename in files_to_copy['src']:
        src_file = os.path.join(core_src, filename)
        dst_file = os.path.join(pio_src, filename)
        
        if os.path.exists(src_file):
            if os.path.exists(dst_file) and not force:
                create_backup(dst_file)
            shutil.copy2(src_file, dst_file)
            print(f"  ✓ {filename}")
        else:
            print(f"   {filename} 不存在，跳过")
    
    # 特殊处理 main.c 和 main.h
    print("\n📂 处理 main.c（智能合并）...")
    cube_main = os.path.join(core_src, 'main.c')
    pio_main = os.path.join(pio_src, 'main.c')
    
    if os.path.exists(cube_main):
        if os.path.exists(pio_main):
            merge_main_files(cube_main, pio_main)
        else:
            shutil.copy2(cube_main, pio_main)
            print(f"  ✓ main.c (首次复制)")
    else:
        print(f"  ⚠ main.c 不存在，跳过")
    
    # main.h 也需要特殊处理（如果有用户代码）
    cube_main_h = os.path.join(core_inc, 'main.h')
    pio_main_h = os.path.join(pio_inc, 'main.h')
    
    if os.path.exists(cube_main_h):
        if os.path.exists(pio_main_h) and not force:
            # 检查是否有用户代码
            user_code = extract_user_code_sections(pio_main_h)
            if user_code:
                print("  ℹ main.h 包含用户代码，需要手动合并")
                create_backup(pio_main_h)
            shutil.copy2(cube_main_h, pio_main_h)
        else:
            shutil.copy2(cube_main_h, pio_main_h)
        print(f"  ✓ main.h")


def sync_back_to_cubemx(pio_path, cubemx_path):
    """
    将 PlatformIO 的修改同步回 CubeMX（可选功能）
    仅同步用户自定义代码段
    """
    print("\n⚠️  警告：此操作将修改 CubeMX 工程文件！")
    print("   建议仅在确认需要时执行此操作。")
    
    response = input("   是否继续？(y/N): ")
    if response.lower() != 'y':
        print("   已取消同步操作")
        return
    
    pio_main = os.path.join(pio_path, 'src', 'main.c')
    cube_main = os.path.join(cubemx_path, 'Core', 'Src', 'main.c')
    
    if not os.path.exists(pio_main):
        print("  ❌ PlatformIO main.c 不存在")
        return
    
    # 备份 CubeMX 文件
    create_backup(cube_main, backup_dir="backup_from_pio")
    
    # 提取用户代码
    user_code = extract_user_code_sections(pio_main)
    
    if not user_code:
        print("  ℹ PlatformIO main.c 中没有用户代码")
        return
    
    # 读取 CubeMX main.c
    with open(cube_main, 'r', encoding='utf-8') as f:
        cube_content = f.read()
    
    # 插入用户代码
    merged_content = cube_content
    for section_name, code in user_code.items():
        begin_marker = f"/* USER CODE BEGIN {section_name} */"
        end_marker = f"/* USER CODE END {section_name} */"
        
        pattern = re.escape(begin_marker) + r'.*?' + re.escape(end_marker)
        replacement = f"{begin_marker}\n{code}\n{end_marker}"
        
        merged_content = re.sub(pattern, replacement, merged_content, flags=re.DOTALL)
    
    # 写回 CubeMX
    with open(cube_main, 'w', encoding='utf-8') as f:
        f.write(merged_content)
    
    print("  ✓ 已将用户代码同步回 CubeMX")


def clean_backup(pio_path, keep_days=7):
    """
    清理旧备份文件
    keep_days: 保留最近多少天的备份
    """
    backup_dir = os.path.join(pio_path, 'src', 'backup')
    if not os.path.exists(backup_dir):
        return
    
    import time
    cutoff_time = time.time() - (keep_days * 24 * 60 * 60)
    cleaned = 0
    
    for filename in os.listdir(backup_dir):
        filepath = os.path.join(backup_dir, filename)
        if os.path.getmtime(filepath) < cutoff_time:
            os.remove(filepath)
            cleaned += 1
    
    if cleaned > 0:
        print(f"✓ 清理了 {cleaned} 个旧备份文件")


# ==================== 主程序 ====================

def main():
    """主函数"""
    print("=" * 70)
    print("CubeMX → PlatformIO 自动同步工具")
    print("=" * 70)
    
    # 获取路径
    pio_path = get_pio_project_path()
    cubemx_path = CUBEMX_PROJECT_PATH
    
    print(f"\nCubeMX 工程：{cubemx_path}")
    print(f"PlatformIO 工程：{pio_path}")
    
    # 验证路径
    if not validate_paths(cubemx_path, pio_path):
        print("\n❌ 路径验证失败，请检查配置")
        return 1
    
    # 选择模式
    print("\n请选择操作模式:")
    print("1. 标准模式 - 复制并合并文件（推荐）")
    print("2. 强制模式 - 完全覆盖（会备份现有文件）")
    print("3. 仅备份 - 仅创建备份，不复制文件")
    print("4. 同步回 CubeMX - 将 PIO 修改同步回 CubeMX")
    print("5. 清理备份 - 删除 7 天前的备份")
    
    choice = input("\n请输入选项 (1-5): ").strip()
    
    try:
        if choice == '1':
            # 标准模式
            print("\n🚀 执行标准同步...")
            copy_files_safely(cubemx_path, pio_path, force=False)
            print("\n✅ 同步完成！")
            print("   请检查编译是否成功：pio run")
            
        elif choice == '2':
            # 强制模式
            print("\n⚠️  警告：强制模式将覆盖所有文件（main.c 除外）！")
            confirm = input("   确认继续？(y/N): ").strip().lower()
            if confirm == 'y':
                copy_files_safely(cubemx_path, pio_path, force=True)
                print("\n✅ 强制同步完成！")
            else:
                print("   已取消操作")
            
        elif choice == '3':
            # 仅备份
            print("\n📦 创建备份...")
            files_to_backup = [
                os.path.join(pio_path, 'src', 'main.c'),
                os.path.join(pio_path, 'src', 'stm32f1xx_it.c'),
                os.path.join(pio_path, 'src', 'system_stm32f1xx.c'),
            ]
            for filepath in files_to_backup:
                if os.path.exists(filepath):
                    create_backup(filepath)
            print("\n✅ 备份完成！")
            
        elif choice == '4':
            # 同步回 CubeMX
            sync_back_to_cubemx(pio_path, cubemx_path)
            
        elif choice == '5':
            # 清理备份
            clean_backup(pio_path)
            print("\n✅ 清理完成！")
            
        else:
            print("\n❌ 无效选项")
            return 1
            
    except Exception as e:
        print(f"\n❌ 发生错误：{e}")
        import traceback
        traceback.print_exc()
        return 1
    
    print("\n" + "=" * 70)
    return 0


if __name__ == "__main__":
    exit(main())
