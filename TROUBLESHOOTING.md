# 常见问题与解决方案

## ✅ 已解决的问题

### 1. HAL 库头文件找不到错误

**错误信息：**

```text
fatal error: stm32f1xx_hal.h: No such file or directory
```

**原因：**

- `genericSTM32F103C8_stdlib` 环境使用的是 CMSIS 框架，不包含 HAL 库
- 但代码中包含了 `stm32f1xx_hal.h`

**解决方案：**

已删除 `genericSTM32F103C8_stdlib` 环境，因为：

- STM32 标准库已停止更新
- 你主要使用 HAL 库开发
- 避免混淆和编译错误

**现在可用的环境：**

- ✅ `genericSTM32F103C8` - HAL 库调试版本
- ✅ `genericSTM32F103C8_release` - HAL 库发布版本

---

### 2. 编译警告（可忽略）

**警告信息：**

```text
warning: unused parameter 'PLL_InputFrequency' [-Wunused-parameter]
warning: unused parameter 'UTILS_PLLInitStruct' [-Wunused-parameter]
warning: unused parameter 'UTILS_ClkInitStruct' [-Wunused-parameter]
```

**说明：**

- 这些是 ST 官方 HAL 库文件的警告
- 来自 `stm32f1xx_ll_utils.c` 文件
- **不影响程序运行**，可以安全忽略
- 这是 ST 官方库的实现问题，不是你的代码问题

**如果想消除警告：**

在 `platformio.ini` 中添加编译选项：

```ini
build_flags = 
    -Wno-unused-parameter
```

---

## 📋 当前配置总结

### platformio.ini 配置

```ini
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
upload_protocol = stlink

[env:genericSTM32F103C8_release]
extends = env:genericSTM32F103C8
build_type = release
```

### 可用命令

#### 编译调试版本

```bash
pio run
```

#### 编译发布版本

```bash
pio run -e genericSTM32F103C8_release
```

#### 烧录程序（DAP-Link）

```bash
pio run --target upload
```

#### 串口监视器

```bash
pio device monitor -b 115200
```

---

## 🔧 下载方式切换

### 使用 DAP-Link（默认，推荐）

```ini
upload_protocol = cmsis-dap
```

### 使用 ST-Link

```ini
upload_protocol = stlink
```

### 使用串口下载

```ini
upload_protocol = serial
upload_port = COM3  ; 改为你的串口号
```

**注意：** 串口下载需要将 BOOT0 跳线帽接到 3.3V，下载完成后接回 GND。

---

## 💡 开发建议

### 1. 调试阶段

- 使用 `genericSTM32F103C8` 环境
- 包含完整调试信息
- 可以进行单步调试

### 2. 发布阶段

- 使用 `genericSTM32F103C8_release` 环境
- 代码优化，体积更小
- 执行效率更高

### 3. 硬件连接检查

- SWDIO → PA13
- SWCLK → PA14
- GND → GND
- 3.3V → 3.3V（如果需要供电）

---

## ⚠️ 注意事项

1. **不要添加标准库环境**

   - 除非你真的需要同时维护两个版本的代码
   - HAL 库是官方推荐，功能更强大

2. **关于编译警告**

   - HAL 库自身的警告可以忽略
   - 自己代码的警告应该重视

### 3. DAP-Link 下载失败处理

- 检查 DAP-Link 连接（SWDIO→PA13, SWCLK→PA14, GND, 3.3V）
- 检查 BOOT0 跳线位置（运行模式：BOOT0=0）
- 尝试按住复位键上电后下载
- 确保 DAP-Link 驱动程序已安装
- 在设备管理器中确认能看到 CMSIS-DAP 设备

---

**最后更新**: 2026-03-17
