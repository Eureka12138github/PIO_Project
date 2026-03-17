# CubeMX 集成 - 快速参考卡

## 🎯 一句话答案

**CubeMX 选择 `Makefile` 工具链，只复制 `Core/Inc` 和 `Core/Src` 到 PIO 的 `include/` 和 `src/`，使用 `sync.bat` 自动同步。**

---

## ⚡ 30 秒快速开始

```bash
# 1. CubeMX 配置外设 → 选择 Makefile → 生成代码
# 2. 双击运行
sync.bat
# 3. 选择 1 (标准模式)
# 4. 验证编译
pio run
```

---

## 📋 文件复制清单

### ✅ 需要复制（脚本自动完成）

| 源目录 | 目标目录 | 文件 |
| ------ | -------- | ---- |
| `Core/Inc/` | `include/` | `stm32f1xx_hal_conf.h`, `stm32f1xx_it.h`, `main.h` |
| `Core/Src/` | `src/` | `stm32f1xx_hal_msp.c`, `stm32f1xx_it.c`, `system_stm32f1xx.c`, `main.c` |

### ❌ 不要复制

- `Drivers/` - PIO 自动管理
- `Makefile`, `.mxproject` - 不需要
- `startup_*.s`, `*.ld` - PIO 自动处理
- `syscalls.c`, `sysmem.c` - PIO 已提供

---

## 🔧 脚本命令速查

| 命令 | 功能 | 说明 |
| ---- | ---- | ---- |
| `sync.bat` | 快速同步 | 双击运行 |
| `.\sync_cubemx_simple.ps1` | PowerShell 版 | 命令行运行 |
| `pio run` | 编译验证 | 必须执行 |

---

## ⚠️ 关键注意事项

### main.c 处理

**脚本会：**

- ✅ 自动备份现有文件
- ⚠️ 复制新版本（**需要手动合并业务逻辑**）

**你应该：**

1. 检查 `src/backup/main.c.*.bak`
2. 复制你的业务逻辑到新生成的文件
3. 在 `USER CODE BEGIN/END` 块内编写代码

### 其他文件

- `stm32f1xx_hal_msp.c` - 直接覆盖
- `stm32f1xx_it.c` - 直接覆盖
- `system_stm32f1xx.c` - 直接覆盖

---

## 🎓 最佳实践

### 推荐流程 ⭐⭐⭐⭐⭐

```text
CubeMX 配置 → 生成代码 → sync.bat → pio run → 开发业务逻辑
```

**优点：**

- 简单可靠
- 代码稳定
- 易于维护

### 开发模式

**首次配置：**

```bash
CubeMX → sync.bat → pio run ✓
```

**后续开发：**

```text
在 PIO 中编写业务逻辑 → 测试 → Git 提交
```

**配置变更：**

```text
CubeMX 修改 → 生成 → sync.bat → 手动合并 main.c → pio run ✓
```

---

## 🚨 紧急恢复

### 代码丢失

```bash
# 从备份恢复
Copy-Item src\backup\main.c.*.bak src\main.c -Force

# 或使用 Git
git checkout HEAD -- src/main.c
```

### 编译失败

```ini
; 检查 platformio.ini
build_flags = 
    -Iinclude
    -DUSE_HAL_DRIVER
    -DSTM32F103xB
```

---

## 📚 完整文档

- `CUBEMX_INTEGRATION_GUIDE.md` - 完整实践指南
- `SYNC_CUBEMX_GUIDE.md` - 脚本使用说明
- `README.md` - 项目概述

---

## 💡 快速决策

| 场景 | 推荐操作 |
| ---- | -------- |
| 首次使用 | 运行 `sync.bat` |
| 修改外设 | CubeMX → sync.bat → 手动合并 |
| 日常开发 | 在 PIO 中直接开发 |
| 代码丢失 | 从备份恢复 |
| 编译失败 | 检查 `platformio.ini` |

---

**开发顺利！** 🚀
