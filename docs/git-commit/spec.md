# Git 提交信息规范

## 🎯 目的

- **清晰表达** - 一眼看出这次提交做了什么
- **便于追溯** - 以后查找历史记录时快速定位
- **团队协作** - 如果有其他人参与，沟通成本更低

---

## 📝 基本格式

```text
<类型>: <简短描述>

[可选的详细说明]

[可选的脚注/引用]
```

### 示例

```text
feat: 添加 LED 闪烁频率控制功能

- 新增 led_set_blink_rate() 函数
- 支持 100ms-5000ms 范围设置
- 更新 main.c 演示代码

Closes #12
```

---

## 🏷️ 提交类型（Type）

### 常用类型（推荐掌握这 5 个就够用）

| 类型 | 含义 | 使用场景 | 示例 |
|------|------|---------|------|
| `feat` | 新功能 | 添加之前没有的功能 | `feat: 添加串口命令解析` |
| `fix` | 修复 Bug | 修正错误的行为 | `fix: 修复 LED 极性反转问题` |
| `refactor` | 重构 | 改代码结构但不改功能 | `refactor: 提取 GPIO 初始化函数` |
| `docs` | 文档 | 只修改文档 | `docs: 更新 README 安装说明` |
| `chore` | 杂项 | 配置、工具等不改动代码 | `chore: 添加.gitignore 文件` |

### 进阶类型（需要时使用）

| 类型 | 含义 | 示例 |
|------|------|------|
| `perf` | 性能优化 | `perf: 优化 UART 接收缓冲区大小` |
| `style` | 代码格式 | `style: 格式化 main.c 缩进` |
| `test` | 测试相关 | `test: 添加 LED 控制单元测试` |

---

## 📋 嵌入式开发常用场景

### 1. CubeMX 同步

```bash
# 首次同步
feat: 从 CubeMX 导入初始工程

# 常规同步
sync: 同步 CubeMX 配置 (启用 SPI2)

# 大量修改
sync: CubeMX 代码同步 - 更新 USART 和定时器配置
```

### 2. 硬件驱动开发

```bash
# 添加新驱动
feat: 添加 OLED 显示屏驱动 (SSD1306)

# 修改现有驱动
fix: 修复 I2C 读写时序问题

# 调试相关
feat: 添加调试用 LED 闪烁模式
```

### 3. 配置文件修改

```bash
# PlatformIO 配置
chore: 添加 release 编译环境

# VSCode 配置
chore: 添加代码片段模板

# 工具配置
chore: 更新 sync.bat 脚本
```

### 4. 文档更新

```bash
# README
docs: 更新硬件连接说明

# 使用指南
docs: 添加 DAP-Link 调试指南

# 注释
docs: 为 main.c 添加详细函数注释
```

---

## 💡 实用技巧

### 场景 1：小修改（一句话搞定）

```bash
# ✅ 推荐
fix: 修正 LED 引脚定义错误
docs: 更新波特率说明
chore: 删除调试代码

# ❌ 避免
修改了 LED
更新一下
小修小补
```

### 场景 2：中等修改（标题 + 要点列表）

```bash
# ✅ 推荐格式
feat: 添加多 LED 支持

- 新增 led_init_all() 批量初始化
- 支持最多 8 个 LED 控制
- 更新 LED_PIN 宏定义

# ❌ 避免
添加了 LED 功能
改了很多地方
LED 相关修改
```

### 场景 3：大修改（分多次提交）

```bash
# 假设你要重构整个 HAL 层

# 第 1 次提交
refactor: 分离 GPIO 初始化代码到独立模块

# 第 2 次提交
refactor: 提取 UART 通用处理函数

# 第 3 次提交
refactor: 统一错误处理机制

# 而不是：一次性提交 "重构代码"
```

### 场景 4：CubeMX 同步后的提交

```bash
# 如果只同步了少量文件
sync: 更新 stm32f1xx_hal_conf.h 配置

# 如果同步了大量文件
sync: CubeMX 同步 - 更新 5 个源文件

# 如果做了额外修改
sync: CubeMX 同步并修复编译警告
```

---

## 🚀 快速上手模板

### PowerShell 快捷命令（推荐）

在你的 `$PROFILE` 中添加：

```powershell
# Git 提交别名
function gitc { 
    param(
        [string]$type = "feat",
        [string]$message = ""
    )
    if ($message) {
        git commit -m "$($type): $($message)"
    } else {
        git commit  # 打开编辑器手动输入
    }
}

# 使用示例
gitc -type fix -message "修复 LED 闪烁异常"
```

### 常用组合速查

```bash
# 日常开发
git add .
git commit -m "feat: 添加 XXX 功能"
git push

# 修复 Bug
git add .
git commit -m "fix: 修复 XXX 问题"

# 文档更新
git add docs/
git commit -m "docs: 更新 XXX 说明"

# 配置修改
git add platformio.ini
git commit -m "chore: 更新编译配置"
```

---

## ⚠️ 常见错误

### ❌ 太模糊

```bash
# 不好
update
修改了一些代码
继续开发

# 好
feat: 添加 PWM 输出功能
fix: 修正串口乱码问题
```

### ❌ 太长或太短

```bash
# 太短（信息不足）
fix: 修改 bug

# 太长（超过 72 字符）
feat: 这是一个非常非常长的提交信息描述了所有修改细节包括为什么要这样改以及改了什么地方还有未来计划

# 刚好
feat: 添加 PWM 占空比动态调整功能

- 新增 pwm_set_duty() 函数
- 支持 0-100% 范围设置
```

### ❌ 类型误用

```bash
# 这是文档修改，不是功能
❌ feat: 更新 README 安装说明
✅ docs: 更新 README 安装说明

# 这是重构，不是新功能
❌ feat: 把 main.c 的代码拆分成多个函数
✅ refactor: 提取外设初始化函数
```

---

## 📊 实际案例参考

### 项目早期

```bash
feat: 创建 STM32F103C8 基础工程
feat: 实现 LED 闪烁功能
feat: 配置串口通信 (115200bps)
docs: 完善 README.md 使用说明
```

### 开发中期

```bash
fix: 修复串口打印乱码 (波特率不匹配)
feat: 添加命令行解析功能
refactor: 重构 LED 控制接口
perf: 优化延时函数精度
docs: 添加故障排除指南
```

### 稳定期

```bash
fix: 边界条件检查 (#23)
docs: 更新 API 文档
chore: 清理调试代码
test: 添加基础功能测试
```

---

## 🎨 个性化建议

### 如果你想要更简单

只用这 3 个类型就够了：

```bash
add: 添加任何东西
fix: 修复任何东西
chg: 修改任何东西
```

### 如果你想要更详细

可以添加前缀：

```bash
feat(hal): HAL 库相关新功能
fix(uart): 串口相关问题修复
docs(readme): README 文档更新
```

---

## 🔧 工具辅助

### 自动化工具（可选）

如果想强制执行规范，可以安装：

```bash
# commitlint (需要 Node.js)
npm install -g @commitlint/cli @commitlint/config-conventional

# 配置后会自动检查提交信息格式
```

### VSCode 插件

- **GitLens** - 增强 Git 历史查看
- **Git Graph** - 可视化提交历史
- **Commit Message Editor** - 图形化编辑提交信息

---

## 💯 最佳实践总结

1. **及时提交** - 完成一个小功能就提交，不要攒一堆
2. **一次一事** - 每次提交只做一件事
3. **说人话** - 用清晰的中文描述做了什么
4. **分类准确** - 选对类型（feat/fix/docs/chore）
5. **适度详细** - 重要修改加要点列表

---

**版本：** v1.0  
**创建日期：** 2026-03-17  
**适用范围：** STM32 嵌入式项目开发
