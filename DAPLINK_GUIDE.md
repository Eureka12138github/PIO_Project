# DAP-Link 开发指南

## 📋 概述

DAP-Link（CMSIS-DAP）是 ARM 公司推出的开源调试器，相比 ST-Link 具有更好的兼容性和稳定性。

## 🔌 硬件连接

### DAP-Link 引脚定义

```text
DAP-Link        STM32F103C8
--------        -----------
3.3V    →→→→→   3.3V (可选，如果开发板有独立供电则不接)
GND     →→→→→   GND
SWDIO   →→→→→   PA13
SWCLK   →→→→→   PA14
nRST    →→→→→   NRST (可选，用于硬件复位)
```

### 接线图

```text
     DAP-Link
    ┌─────────┐
    │  3.3V   │──────→ 3.3V
    │   GND   │──────→ GND
    │  SWDIO  │──────→ PA13
    │  SWCLK  │──────→ PA14
    │   nRST  │──────→ NRST (可选)
    └─────────┘
```

### 注意事项

1. **共地**：必须连接 GND
2. **电压匹配**：确认 DAP-Link 输出电压为 3.3V
3. **线缆长度**：尽量短（<20cm），避免干扰
4. **上电顺序**：先给开发板上电，再连接 DAP-Link

## ⚙️ PlatformIO 配置

### 基本配置

在 `platformio.ini` 中设置：

```ini
[env:genericSTM32F103C8]
platform = ststm32
board = genericSTM32F103C8
framework = stm32cube
upload_protocol = cmsis-dap
debug_tool = cmsis-dap
```

### 完整配置示例

```ini
; PlatformIO Project Configuration File

[common]
defines = 
    -DSTM32F103xB
    -DUSE_HAL_DRIVER
build_flags = 
    -Wall
    -Wextra
    -fdata-sections
    -ffunction-sections
monitor_speed = 115200

[env:genericSTM32F103C8]
platform = ststm32
board = genericSTM32F103C8
framework = stm32cube
extends = common
build_type = debug
build_flags = 
    ${common.build_flags}
    -O0
    -g3
    -DDEBUG
upload_protocol = cmsis-dap
debug_tool = cmsis-dap
debug_init_break = tbreak main

[env:genericSTM32F103C8_release]
extends = env:genericSTM32F103C8
build_type = release
build_flags = 
    ${common.build_flags}
    -O3
    -DNDEBUG
```

## 🚀 快速开始

### 1. 安装驱动程序

**Windows 系统：**

- DAP-Link 通常无需额外驱动
- 设备管理器中应显示 "CMSIS-DAP" 设备
- 如果没有识别，尝试安装 mbed 驱动

**验证安装：**

```bash
pio device list
```

应该能看到 CMSIS-DAP 设备

### 2. 编译项目

```bash
# 调试版本
pio run

# 发布版本
pio run -e genericSTM32F103C8_release
```

### 3. 烧录程序

```bash
pio run --target upload
```

### 4. 调试程序

```bash
pio debug
```

### 5. 串口监视器

```bash
pio device monitor -b 115200
```

## 🔍 故障排除

### Q1: 无法识别 DAP-Link 设备

**解决方案：**

1. 检查 USB 连接
2. 在设备管理器中查看是否有未知设备
3. 重新插拔 USB
4. 更换 USB 端口
5. 安装 mbed 串口驱动

### Q2: 烧录失败 "Failed to connect to target"

**可能原因：**

1. 接线错误或接触不良
2. 目标板未供电
3. SWD 引脚被占用或配置错误
4. 芯片处于休眠模式

**解决方案：**

```bash
# 方法 1：按住复位键上电后烧录
pio run --target upload

# 方法 2：修改连接策略
# 在 platformio.ini 中添加：
upload_flags =
    -c
    "set CONNECT_UNDER_RESET 1"
```

### Q3: 烧录速度慢

**优化方法：**

```ini
upload_flags =
    -S          ; 使用更快的传输速度
```

### Q4: 调试时无法连接

**检查项：**

1. 确认 `debug_tool = cmsis-dap` 已配置
2. 检查 BOOT0 跳线（应在 0 位置）
3. 确认目标板供电正常
4. 尝试降低 SWD 频率

## 💡 高级技巧

### 1. 使用多个 DAP-Link

如果有多个调试器，可以指定序列号：

```ini
upload_flags =
    -s
    <SERIAL_NUMBER>
```

### 2. 自定义 SWD 频率

```ini
upload_flags =
    -H
    1000000     ; 1MHz
```

### 3. 批量生产烧录

```bash
# 连续烧录多个芯片
pio run --target program
```

### 4. 读取芯片信息

```bash
# 使用 OpenOCD（PlatformIO 内置）
pio run --target upload --verbose
```

## 📊 DAP-Link vs ST-Link

| 特性 | DAP-Link | ST-Link V2 |
| :--- | :------- | :--------- |
| 开源性 | ✅ 完全开源 | ❌ 专有协议 |
| 兼容性 | ✅ 支持所有 ARM Cortex-M | ⚠️ 主要支持 STM32 |
| 调试功能 | ✅ 完整支持 | ✅ 完整支持 |
| 下载速度 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 价格 | 💰 便宜 | 💰 便宜 |
| 驱动 | ✅ 免驱 | ⚠️ 需要驱动 |
| 推荐度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

## 🔧 固件更新

如果你的 DAP-Link 支持固件更新：

1. 访问：[DAP-Link GitHub](https://github.com/ARMmbed/DAPLink)
2. 下载最新固件
3. 进入 bootloader 模式（通常按住 Boot 键插入 USB）
4. 将固件文件拖入 DAP-Link 存储设备

## ⚠️ 注意事项

1. **静电防护**：操作前触摸接地金属
2. **热插拔**：尽量避免带电插拔 SWD 线
3. **电源保护**：不要将 5V 接到 3.3V 引脚
4. **信号完整性**：使用屏蔽线或双绞线

## 📚 参考资料

- [CMSIS-DAP 官方文档](https://arm-software.github.io/CMSIS_5/DAP/html/index.html)
- [DAP-Link GitHub](https://github.com/ARMmbed/DAPLink)
- [PlatformIO 调试文档](https://docs.platformio.org/en/latest/plus/debug-tools/index.html)

---

**最后更新**: 2026-03-17  
**适用型号**: 所有支持 CMSIS-DAP 的 ARM Cortex-M 开发板
