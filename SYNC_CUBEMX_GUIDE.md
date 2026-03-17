# CubeMX 与 PlatformIO 集成自动化同步指南

## 📋 目录

- [概述](#概述)
- [文件说明](#文件说明)
- [快速开始](#快速开始)
- [使用方式](#使用方式)
- [main.c 合并策略](#main.c 合并策略)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)

---

## 概述

本工具集提供自动化脚本，用于从 STM32CubeMX 生成的工程中提取必要文件并同步到 PlatformIO 项目中，同时保留用户自定义代码。

### 核心功能

✅ **自动文件复制** - 从 CubeMX Core/Inc 和 Core/Src 复制必要文件  
✅ **智能代码合并** - 保留 main.c 中的用户自定义代码  
✅ **安全备份机制** - 自动备份被覆盖的文件  
✅ **双向同步支持** - 可选择将修改同步回 CubeMX  
✅ **备份管理** - 自动清理 7 天前的旧备份  

---

## 文件说明

### 脚本文件

```
PIO_TEST2/
├── sync_cubemx.py          # Python 版本脚本（跨平台）
├── sync_cubemx.ps1         # PowerShell 版本脚本（Windows 推荐）
├── sync.bat                # Windows 快速启动批处理
└── SYNC_CUBEMX_GUIDE.md    # 本文档
```

### 同步的文件

#### 头文件（Core/Inc → include/）
- `stm32f1xx_hal_conf.h` - HAL 库配置文件
- `stm32f1xx_it.h` - 中断处理头文件
- `main.h` - 主程序头文件

#### 源文件（Core/Src → src/）
- `stm32f1xx_hal_msp.c` - HAL MSP 初始化
- `stm32f1xx_it.c` - 中断服务程序
- `system_stm32f1xx.c` - 系统时钟配置
- `main.c` - **智能合并，不直接覆盖**

---

## 快速开始

### 方式 1：双击批处理文件（最简单）

```bash
# 在 PIO_TEST2 目录下双击
sync.bat
```

### 方式 2：PowerShell 直接运行

```powershell
# 在 PIO_TEST2 目录下执行
.\sync_cubemx.ps1
```

### 方式 3：Python 运行

```bash
# 在 PIO_TEST2 目录下执行
python sync_cubemx.py
```

### 方式 4：命令行参数（高级）

```powershell
# 使用默认参数快速同步
.\sync_cubemx.ps1

# 强制覆盖模式
.\sync_cubemx.ps1 -Force

# 仅备份不复制
.\sync_cubemx.ps1 -BackupOnly

# 同步回 CubeMX
.\sync_cubemx.ps1 -SyncBack

# 清理旧备份
.\sync_cubemx.ps1 -CleanBackup

# 自定义路径
.\sync_cubemx.ps1 -CubeMXPath "D:\Path\To\CubeMX" -PIOPath "D:\Path\To\PIO"
```

---

## 使用方式

### 首次同步

1. **运行脚本**
   ```bash
   .\sync.bat
   ```

2. **选择"标准模式"**（选项 1）
   - 自动复制必要文件
   - 智能合并 main.c
   - 创建备份

3. **验证编译**
   ```bash
   pio run
   ```

### 后续更新

每次在 CubeMX 中修改配置后：

1. **在 CubeMX 中重新生成代码**
2. **运行同步脚本**
   ```bash
   .\sync.bat
   ```
3. **选择"标准模式"**
4. **编译验证**
   ```bash
   pio run
   ```

---

## main.c 合并策略

### 问题分析

CubeMX 生成的 `main.c` 包含以下结构：

```c
/* USER CODE BEGIN Header */
// 许可证信息
/* USER CODE END Header */

/* Includes */
#include "main.h"

/* USER CODE BEGIN Includes */
// 用户包含
/* USER CODE END Includes */

/* Private variables */
/* USER CODE BEGIN PV */
// 用户变量
/* USER CODE END PV */

/* Private function prototypes */
/* USER CODE BEGIN PFP */
// 用户函数声明
/* USER CODE END PFP */

/* Private user code */
/* USER CODE BEGIN 0 */
// 用户函数实现
/* USER CODE END 0 */

int main(void) {
    /* USER CODE BEGIN 1 */
    // 用户代码
    /* USER CODE END 1 */
    
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    
    /* USER CODE BEGIN 2 */
    // 用户初始化
    /* USER CODE END 2 */
    
    while (1) {
        /* USER CODE BEGIN WHILE */
        // 用户主循环
        /* USER CODE END WHILE */
        
        /* USER CODE BEGIN 3 */
        // 用户代码
        /* USER CODE END 3 */
    }
}
```

### 合并算法

**脚本的合并策略：**

1. **提取** PlatformIO 中所有 `/* USER CODE BEGIN XXX */` 和 `/* USER CODE END XXX */` 之间的内容
2. **读取** CubeMX 生成的最新 main.c
3. **替换** CubeMX 文件中的用户代码段为提取的内容
4. **写入** 合并后的文件到 PlatformIO

**保留的内容：**
- ✅ 所有 `USER CODE BEGIN/END` 块中的代码
- ✅ 你的业务逻辑
- ✅ 自定义函数和变量

**更新的内容：**
- ✅ CubeMX 生成的初始化代码
- ✅ 外设配置
- ✅ 系统时钟配置
- ✅ 中断处理框架

### 示例

假设你在 PlatformIO 的 main.c 中添加了：

```c
/* USER CODE BEGIN 0 */
#include <stdio.h>

void LED_Blink(void) {
    HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
}
/* USER CODE END 0 */

/* USER CODE BEGIN WHILE */
LED_Blink();
HAL_Delay(100);
/* USER CODE END WHILE */
```

同步后，这些代码会**自动保留**在新的框架中：

```c
/* USER CODE BEGIN 0 */
#include <stdio.h>

void LED_Blink(void) {
    HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);
}
/* USER CODE END 0 */

int main(void) {
    // ... CubeMX 生成的最新初始化代码 ...
    
    while (1) {
        /* USER CODE BEGIN WHILE */
        LED_Blink();
        HAL_Delay(100);
        /* USER CODE END WHILE */
    }
}
```

---

## 最佳实践

### 🌟 推荐方案：**初始导入 + 手动维护**

**流程：**

1. **首次使用 CubeMX 配置外设**
   ```bash
   # 运行同步脚本
   .\sync.bat
   # 选择选项 1：标准模式
   ```

2. **后续在 PlatformIO 中手动添加业务逻辑**
   - 在 `USER CODE BEGIN/END` 块内编写代码
   - 不要修改 CubeMX 生成的初始化函数

3. **如需修改外设配置**
   - 在 CubeMX 中修改并重新生成
   - 运行同步脚本（会自动合并）
   - 检查编译结果

**优点：**
- ✅ 简单可靠，不易出错
- ✅ 代码版本可控
- ✅ 避免频繁同步导致的冲突
- ✅ 保持 PlatformIO 项目独立性

**缺点：**
- ⚠️ 需要手动添加业务逻辑到正确位置

### 方案对比

#### 方案 A：初始一次性导入后不再自动覆盖（推荐）

| 优点 | 缺点 |
|------|------|
| 代码稳定，不易丢失 | 需要手动维护 main.c |
| 版本控制清晰 | 外设变更需要手动合并 |
| 适合成熟项目 | |

**适用场景：**
- 项目已稳定，外设配置不常变更
- 有完善的代码管理规范
- 团队成员熟悉 PlatformIO 结构

#### 方案 B：每次同步前回滚到 CubeMX（不推荐）

| 优点 | 缺点 |
|------|------|
| 理论上保持 CubeMX 最新 | 操作复杂，易出错 |
| 自动化程度高 | 可能丢失 PIO 特定优化 |
| | 双向同步风险高 |

**风险：**
- ❌ 可能引入代码冲突
- ❌ 备份管理复杂
- ❌ 调试困难

#### 方案 C：仅同步特定文件（折中方案）

**推荐做法：**

```bash
# 仅复制硬件抽象层文件
.\sync_cubemx.ps1

# 手动检查 main.c 变更
# 选择性应用变更
```

**适用场景：**
- 外设配置频繁变更
- 需要保持与 CubeMX 同步
- 有充足的测试时间

### 📊 决策矩阵

```
项目阶段          推荐方案
─────────────────────────────
原型开发    →    方案 C（频繁同步）
功能开发    →    方案 A（稳定优先）
维护阶段    →    方案 A（最小变更）
紧急修复    →    手动修改（绕过同步）
```

---

## 其他文件处理

### stm32f1xx_hal_msp.c

**策略：直接覆盖**

这个文件通常不需要用户修改，CubeMX 会自动生成正确的 MSP 初始化代码。

**例外情况：**
- 如果你添加了自定义的 MSP 回调
- 修改了引脚复用配置

**建议：**
- 在 `USER CODE BEGIN/END` 块中添加自定义代码
- 或使用 `__weak` 函数覆盖默认实现

### stm32f1xx_it.c（中断文件）

**策略：直接覆盖 + 备份**

中断服务程序通常由 CubeMX 管理，但你可能添加了中断处理逻辑。

**建议：**
- 在 `USER CODE BEGIN/END` 块中添加中断处理代码
- 或使用独立的中断处理函数文件

### system_stm32f1xx.c

**策略：直接覆盖**

系统时钟配置完全由 CubeMX 管理，不建议手动修改。

**如需自定义时钟：**
- 在 CubeMX 中配置
- 或在 main.c 中调用自定义时钟函数

---

## 常见问题

### Q1: 同步后编译失败

**可能原因：**
- 缺少某些外设驱动文件
- 头文件路径不正确

**解决方案：**
```bash
# 检查 platformio.ini 配置
# 确保包含路径正确

build_flags = 
    -Iinclude
    -DUSE_HAL_DRIVER
    -DSTM32F103xB
```

### Q2: main.c 中的代码丢失

**原因：**
- 代码未放在 `USER CODE BEGIN/END` 块内

**解决方案：**
1. 从备份恢复
   ```bash
   # 备份文件在 src/backup/ 目录
   ```
2. 确保所有自定义代码都在 `USER CODE` 块内

### Q3: 如何合并多个外设配置

**场景：**
- 在 CubeMX 中配置了 UART
- 又配置了 SPI
- 需要合并两次配置

**解决方案：**
```bash
# 方式 1：在 CubeMX 中同时配置所有外设，一次性生成
# 方式 2：分次同步，手动合并 main.c
```

**推荐：**
- 在 CubeMX 中完成所有外设配置后再生成

### Q4: 如何回滚到之前的版本

**使用备份：**
```bash
# 备份文件位置
src/backup/main.c.YYYYMMDD_HHMMSS.bak

# 恢复备份
Copy-Item src\backup\main.c.*.bak src\main.c -Force
```

### Q5: 是否需要同步 Drivers 目录

**不需要！**

PlatformIO 自动管理 HAL 库，Drivers 目录的内容已经包含在 `platformio` 包中。

---

## 高级配置

### 自定义同步路径

编辑 `sync_cubemx.ps1`：

```powershell
param(
    [string]$CubeMXPath = "你的 CubeMX 路径",
    [string]$PIOPath = "你的 PlatformIO 路径"
)
```

### 修改备份保留时间

```powershell
$BackupRetentionDays = 30  # 保留 30 天
```

### 添加自定义文件同步

在 `Copy-FilesSafely` 函数中添加：

```powershell
# 添加自定义文件
$customFiles = @(
    'my_driver.c',
    'my_config.h'
)
```

---

## 自动化集成

### 与 Git 集成

```bash
# .gitignore 中添加
src/backup/
include/backup/
```

### CI/CD 集成

```yaml
# .github/workflows/build.yml
- name: Sync CubeMX
  run: ./sync_cubemx.ps1 -Force

- name: Build
  run: pio run
```

### 与 VSCode 任务集成

```json
// .vscode/tasks.json
{
    "label": "Sync CubeMX",
    "type": "shell",
    "command": ".\\sync_cubemx.ps1",
    "problemMatcher": []
}
```

---

## 技术支持

### 脚本问题

检查以下位置：
1. PowerShell 执行策略
   ```powershell
   Get-ExecutionPolicy
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. Python 版本（如果使用 Python 脚本）
   ```bash
   python --version  # 需要 Python 3.6+
   ```

### 代码合并问题

1. 检查备份文件
2. 手动比较差异
3. 使用 Git 进行版本控制

---

## 更新日志

### v1.0.0 (2026-03-17)
- ✅ 初始版本发布
- ✅ 支持基本的文件同步
- ✅ main.c 智能合并
- ✅ 自动备份机制
- ✅ 双向同步支持

---

## 许可证

本脚本遵循 MIT 许可证，可自由修改和分发。

---

## 贡献

欢迎提交问题和改进建议！

**最佳实践总结：**
1. ✅ 始终在 `USER CODE` 块内编写代码
2. ✅ 定期备份重要文件
3. ✅ 使用版本控制（Git）
4. ✅ 首次同步后尽量保持 main.c 稳定
5. ✅ 外设配置变更时再同步
