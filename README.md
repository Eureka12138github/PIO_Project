# STM32F103C8 PlatformIO 开发指南

## 📋 项目概述

本项目使用 **PlatformIO** 开发 **STM32F103C8**（蓝 pill）开发板，采用 **HAL 库**进行开发。

## 🛠️ 开发环境配置

### 硬件要求

- STM32F103C8 开发板（Blue Pill）
- DAP-Link 下载器 或 USB 转 TTL 模块
- LED 灯（PC13 引脚已内置）

### 软件要求

- PlatformIO IDE（VSCode 插件）
- STM32CubeMX（可选，用于图形化配置）

## 📁 项目结构

```text
PIO_HAL_PROJECT_TEMPLATE/
├── src/                          # 源代码目录
│   ├── main.c                    # 主程序（HAL 库初始化 + 用户代码）
│   ├── stm32f1xx_hal_msp.c       # HAL 库 MSP 初始化文件
│   ├── stm32f1xx_it.c            # 中断服务函数
│   └── system_stm32f1xx.c        # 系统时钟配置文件
├── include/                      # 公共头文件目录
│   ├── main.h                    # 主头文件（引脚定义 + 函数声明）
│   ├── stm32f1xx_hal_conf.h      # HAL 库配置文件
│   └── stm32f1xx_it.h            # 中断头文件
├── lib/                          # 第三方库目录
├── .vscode/                      # VSCode 配置
├── .lingma/                      # AI 助手配置（内部使用，勿修改）
├── docs/                         # 项目文档目录
│   ├── README.md                 # 文档总索引
│   ├── CUBEMX_GUIDE.md           # CubeMX 同步指南
│   ├── DAPLINK_GUIDE.md          # DAP-Link 使用指南
│   ├── QUICK_REFERENCE.md        # 快速参考手册
│   ├── TROUBLESHOOTING.md        # 故障排除指南
│   └── git-commit/               # Git 提交规范目录
│       ├── spec.md               # Git 提交详细规范
│       ├── guide.md              # Git 提交使用指南
│       └── quick-reference.md    # Git 提交速查卡
├── platformio.ini                # PlatformIO 配置文件
├── sync_cubemx_simple.ps1        # CubeMX 代码同步脚本
└── sync.bat                      # 同步脚本批处理包装
```

## ⚙️ 环境说明

### 可用编译环境

#### 1. HAL 库调试版本（默认）

```ini
[env:genericSTM32F103C8]
```

- 使用 STM32 HAL 库
- 优化级别：O0（无优化）
- 包含完整调试信息
- 适合开发和调试阶段

#### 2. HAL 库发布版本

```ini
[env:genericSTM32F103C8_release]
```

- 使用 STM32 HAL 库
- 优化级别：O3（最大优化）
- 移除调试代码
- 适合产品发布

## 🚀 快速开始

### 1. 编译项目

**调试版本：**

```bash
pio run
```

**发布版本：**

```bash
pio run -e genericSTM32F103C8_release
```

### 2. 烧录程序

**使用 DAP-Link：**

```bash
pio run --target upload
```

**使用串口下载：**

```bash
pio run --target upload
; 需要在 platformio.ini 中修改 upload_protocol = serial
```

### 3. 打开串口监视器

```bash
pio device monitor
```

**指定波特率：**

```bash
pio device monitor -b 115200
```

### 4. 清理项目

```bash
pio run --target clean
```

### 5. 查看设备列表

```bash
pio device list
```

## 💻 命令行快速参考

### 基本命令

```bash
# 编译项目（默认 debug 环境）
pio run

# 编译指定环境
pio run -e genericSTM32F103C8_release

# 烧录程序
pio run --target upload

# 打开串口监视器
pio device monitor -b 115200

# 清理构建
pio run --target clean
```

### 快捷别名配置（推荐）

在 PowerShell 中运行以下命令可设置快捷别名，大幅提升开发效率：

```powershell
# 查看配置文件路径
$PROFILE

# 用记事本打开
notepad $PROFILE
```

在打开的文件中添加：

```powershell
# 设置 UTF-8 编码（解决中文显示）
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# PlatformIO 快捷命令
function piob { pio run -e genericSTM32F103C8 }
function piou { pio run -e genericSTM32F103C8 --target upload }
function piobu { 
    Write-Host "=== 开始编译 ===" -ForegroundColor Cyan
    pio run -e genericSTM32F103C8
    if ($LASTEXITCODE -eq 0) {
        Write-Host "=== 开始烧录 ===" -ForegroundColor Green
        pio run -e genericSTM32F103C8 --target upload
    }
}
function piom { pio device monitor -b 115200 }
function pioc { pio run --target clean }
```

保存后重新加载：`. $PROFILE`

**使用效果：**

| 命令 | 功能 | 说明 |
| ---- | ---- | ---- |
| `piobu` | 编译 + 烧录 | **最常用**，一键完成 |
| `piob` | 仅编译 | 快速检查代码 |
| `piou` | 仅烧录 | 重新烧录 |
| `piom` | 串口监视 | 查看输出 |
| `pioc` | 清理 | 解决问题时使用 |

---

## 💡 示例代码说明

### 主要功能

- LED 闪烁（PC13 引脚）
- 串口打印输出（USART1, PA9/PA10）
- 系统时钟配置为 72MHz

### 硬件连接

#### 串口通信

- TX: PA9 → USB 转 TTL RX
- RX: PA10 → USB 转 TTL TX
- GND: 共地
- 波特率：115200

#### LED

- PC13: 板载 LED（低电平点亮）

### 关键函数

```c
// GPIO 操作
HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);    // 点亮 LED
HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);  // 熄灭 LED
HAL_GPIO_TogglePin(GPIOC, GPIO_PIN_13);                  // 翻转 LED

// 延时
HAL_Delay(1000);  // 延时 1000ms

// 串口发送
HAL_UART_Transmit(&huart1, (uint8_t*)"Hello", 5, 0xFFFF);
printf("格式化输出：%d\r\n", value);
```

## 🔧 常见问题

### Q1: 无法烧录程序？

**A:** 检查以下几点：

1. DAP-Link 连接是否正确（SWDIO→PA13, SWCLK→PA14, GND, 3.3V）
2. BOOT0 跳线帽位置（运行模式：BOOT0=0）
3. 尝试按住复位键上电，然后运行烧录命令
4. 确保 DAP-Link 固件已正确安装

### Q2: 串口无输出？

**A:** 检查：

1. 波特率是否匹配（115200）
2. TX/RX 是否接反
3. 是否需要按复位键

### Q3: 如何切换到其他开发板？

**A:** 修改 `platformio.ini` 中的 `board` 参数：

```ini
board = bluepill_f103c8  ; 或使用其他板型
```

### Q4: 如何使用串口下载而不是 ST-Link？

**A:** 在 `platformio.ini` 中修改上传协议：

```ini
[env:genericSTM32F103C8]
upload_protocol = serial
upload_port = COM3  ; 替换为你的串口号
```

### Q5: 如何添加新的外设？

**A:** 两种方法：

1. 手动编写初始化代码（参考 main.c）
2. 使用 STM32CubeMX 生成代码后复制过来

## 📚 HAL 库常用 API

### GPIO 操作

```c
HAL_GPIO_Init(GPIOx, &GPIO_InitStruct);
HAL_GPIO_WritePin(GPIOx, GPIO_Pin_x, PinState);
HAL_GPIO_ReadPin(GPIOx, GPIO_Pin_x);
HAL_GPIO_TogglePin(GPIOx, GPIO_Pin_x);
```

### 中断处理

```c
HAL_GPIO_EXTI_IRQHandler(GPIO_Pin);
HAL_GPIO_EXTI_Callback(GPIO_Pin);
```

### 定时器/PWM

```c
HAL_TIM_Base_Init(&htim);
HAL_TIM_PWM_Start(&htim, TIM_CHANNEL_x);
```

### ADC

```c
HAL_ADC_Init(&hadc);
HAL_ADC_Start(&hadc);
HAL_ADC_GetValue(&hadc);
```

## 🎯 进阶配置

### 自定义编译选项

在 `platformio.ini` 中添加：

```ini
build_flags = 
    -D MY_DEFINE=1
    -DCUSTOM_FLAG
```

### 添加外部库

```bash
pio lib install "Library Name"
```

或在 `platformio.ini` 中声明：

```ini
lib_deps = Library1@^1.2.3
```

## 📖 参考资料

- [PlatformIO 官方文档](https://docs.platformio.org/)
- [STM32 HAL 库用户手册](https://www.st.com/resource/en/user_manual/um1718-description-of-stm32cube-hal-drivers-stmicroelectronics.pdf)
- [STM32F103x8/B 数据手册](https://www.st.com/resource/en/datasheet/stm32f103c8.pdf)
- [ARM Cortex-M3 权威指南](https://www.arm.com/resources/ebook/arm-cortex-m3-and-cortex-m4-book)

## ⚠️ 注意事项

1. **HAL 库 vs 标准库**
   - HAL 库是 ST 官方推荐的方式，可移植性更好
   - 标准库已停止更新，但仍有大量遗留项目使用

2. **下载方式选择**
   - DAP-Link：稳定可靠，支持调试（推荐）
   - 串口下载：成本低，但稳定性较差

3. **功耗考虑**
   - 调试版本代码体积大，功耗高
   - 发布版本经过优化，适合量产

## 🤝 贡献与反馈

如有问题或建议，欢迎提出！

---

**最后更新**: 2026-03-17  
**作者**: PlatformIO User
