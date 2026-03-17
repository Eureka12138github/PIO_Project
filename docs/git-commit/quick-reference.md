# Git 提交信息速查卡 📝

## 🎯 5 个核心类型（记住这些就够用了）

| 命令 | 含义 | 何时使用 |
|------|------|---------|
| `feat: 描述` | 新功能 | 添加了之前没有的功能 |
| `fix: 描述` | 修复 Bug | 修正了错误的行为 |
| `docs: 描述` | 文档 | 只修改了文档/注释 |
| `refactor: 描述` | 重构 | 改代码结构但不改功能 |
| `chore: 描述` | 杂项 | 配置、工具等不改动代码 |

---

## ⚡ 快速模板（复制粘贴即可）

### 小修改（一行搞定）

```bash
git commit -m "feat: 添加 XXX 功能"
git commit -m "fix: 修复 XXX 问题"
git commit -m "docs: 更新 XXX 说明"
git commit -m "chore: 更新 XXX 配置"
```

### 中等修改（带要点列表）

```bash
git commit -m "feat: 添加多 LED 支持

- 新增 led_init_all() 批量初始化
- 支持最多 8 个 LED 控制
- 更新 LED_PIN 宏定义"
```

---

## 🔥 嵌入式开发高频场景

### CubeMX 同步

```bash
# 首次导入
git commit -m "feat: 从 CubeMX 导入初始工程"

# 常规同步
git commit -m "sync: 同步 CubeMX 配置 (启用 SPI2)"

# 大量修改
git commit -m "sync: CubeMX 代码同步 - 更新 USART 和定时器配置"
```

### 硬件驱动

```bash
# 新驱动
git commit -m "feat: 添加 OLED 显示屏驱动 (SSD1306)"

# 修复问题
git commit -m "fix: 修复 I2C 读写时序问题"

# 调试相关
git commit -m "feat: 添加调试用 LED 闪烁模式"
```

### 配置文件

```bash
# PlatformIO
git commit -m "chore: 添加 release 编译环境"

# VSCode
git commit -m "chore: 添加代码片段模板"

# 脚本
git commit -m "chore: 更新 sync.bat 脚本"
```

### 文档更新

```bash
git commit -m "docs: 更新 README 硬件连接说明"
git commit -m "docs: 添加 DAP-Link 调试指南"
git commit -m "docs: 为 main.c 添加函数注释"
```

---

## ✅ vs ❌ 对比

```bash
# ❌ 太模糊
git commit -m "update"
git commit -m "修改了一些代码"

# ✅ 清晰具体
git commit -m "feat: 添加 PWM 输出功能"
git commit -m "fix: 修正串口打印乱码"
```

```bash
# ❌ 类型错误
git commit -m "feat: 更新 README 说明"

# ✅ 类型正确
git commit -m "docs: 更新 README 说明"
```

```bash
# ❌ 太长
git commit -m "今天花了一下午终于把这个该死的 bug 修好了主要是定时器中断的问题还有 GPIO 初始化顺序也不对"

# ✅ 简洁明了
git commit -m "fix: 修复定时器和 GPIO 初始化顺序问题"
```

---

## 🎨 PowerShell 快捷命令（强烈推荐）

在你的 `$PROFILE` 中添加这个函数：

```powershell
# Git 快速提交
function gitcommit {
    param(
        [Parameter(Mandatory=$true)]
        [string]$msg
    )
    git add .
    git commit -m $msg
    Write-Host "✓ 提交成功：$msg" -ForegroundColor Green
}

# 使用示例
gitcommit "feat: 添加串口命令解析"
```

---

## 📊 实际项目案例

### 项目启动阶段

```bash
git commit -m "feat: 创建 STM32F103C8 基础工程"
git commit -m "feat: 实现 LED 闪烁功能"
git commit -m "feat: 配置串口通信 (115200bps)"
git commit -m "docs: 完善 README.md 使用说明"
```

### 开发阶段

```bash
git commit -m "fix: 修复串口打印乱码 (波特率不匹配)"
git commit -m "feat: 添加命令行解析功能"
git commit -m "refactor: 重构 LED 控制接口"
git commit -m "perf: 优化延时函数精度"
```

### 稳定维护阶段

```bash
git commit -m "fix: 边界条件检查 (#23)"
git commit -m "docs: 更新 API 文档"
git commit -m "chore: 清理调试代码"
```

---

## 💡 决策树（不知道用什么类型时看这里）

```text
这次提交做了什么？
│
├─ 加了新功能？ → feat
│   └─ 例：feat: 添加 SPI 通信功能
│
├─ 修了 Bug？ → fix  
│   └─ 例：fix: 修复内存泄漏问题
│
├─ 只改了文档/注释？ → docs
│   └─ 例：docs: 更新函数参数说明
│
├─ 改了代码结构但功能不变？ → refactor
│   └─ 例：refactor: 提取公共函数到 utils.c
│
└─ 其他（配置、工具等）？ → chore
    └─ 例：chore: 更新.gitignore
```

---

## 🎯 黄金法则

1. **一次提交只做一件事** - 不要混在一起
2. **用中文写清楚做了什么** - 别用"update"这种废话
3. **重要的修改加说明列表** - 超过 3 处改动就加上
4. **及时提交别攒着** - 完成一个小功能就提交

---

**打印建议：** 将此卡片打印出来贴在显示器旁边，提交时随时参考！

**版本：** v1.0  
**创建日期：** 2026-03-17
