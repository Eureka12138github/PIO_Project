# Git 提交规范使用指南 🚀

## 📦 你获得了什么？

通过这套系统，你将拥有：

1. **详细规范文档** - `.lingma/git-commit-spec.md`
2. **快速参考卡片** - `.lingma/git-commit-quick-reference.md`
3. **VSCode 代码片段** - `.vscode/git-commit.code-snippets`

---

## 🎯 三种使用方式（从简到繁）

### 方式 1：最简单 - 速查卡照着写

**适用场景：** 懒得看太多，只想快速提交

**操作：**

1. 打开 `.lingma/git-commit-quick-reference.md`
2. 找到对应场景的示例
3. 复制粘贴修改

**示例：**

```bash
git commit -m "feat: 添加串口命令解析"
```

---

### 方式 2：推荐 - VSCode 代码片段

**适用场景：** 想要结构化模板，提高效率

**操作步骤：**

#### 步骤 1：在 Git 输入框中输入前缀

在 VSCode 源代码管理器中，点击输入框，输入：

```text
gitsimple
```

按 `Tab` 键，自动展开为：

```text
feat: |简短描述
```

继续输入即可。

#### 步骤 2：使用完整模板

如果需要详细说明，输入：

```text
gitfeat
```

按 `Tab` 键，自动展开为：

```text
feat: 功能描述

- 具体改动 1
- 具体改动 2

```

然后填空即可！

#### 所有可用片段

| 前缀 | 用途 | 展开效果 |
|------|------|---------|
| `gitsimple` | 简单提交 | `feat: 描述` |
| `gitfeat` | 新功能 | 带要点列表的完整模板 |
| `gitfix` | Bug 修复 | 包含原因和解决方案 |
| `gitdocs` | 文档更新 | 文档专用模板 |
| `gitrefactor` | 重构 | 重构专用模板 |
| `gitchore` | 杂项 | 配置/工具变更 |
| `gitsync` | CubeMX 同步 | 同步专用模板 |

---

### 方式 3：完整规范 - 遇到复杂情况时

**适用场景：** 大型重构、重要功能发布

**操作：**

1. 打开 `.lingma/git-commit-spec.md`
2. 查看“实际案例参考”章节
3. 按照最佳实践编写

---

## 💡 实战演示

### 场景 1：添加了 LED 控制功能

```bash
# 方式 1：简单版
git commit -m "feat: 添加 LED 控制功能"

# 方式 2：使用代码片段（推荐）
# 输入 gitfeat → Tab → 填空
git commit -m "feat: 添加 LED 控制功能

- 新增 led_init() 初始化函数
- 支持开关和闪烁模式
- 更新 main.c 演示代码"
```

### 场景 2：修复了串口乱码

```bash
# 方式 1：简单版
git commit -m "fix: 修复串口打印乱码"

# 方式 2：使用代码片段
# 输入 gitfix → Tab → 填空
git commit -m "fix: 修复串口打印乱码

- 原因：波特率配置错误 (9600 vs 115200)
- 解决：修正 USART 分频系数"
```

### 场景 3：CubeMX 同步

```bash
# 方式 1：简单版
git commit -m "sync: CubeMX 代码同步"

# 方式 2：使用专用模板
# 输入 gitsync → Tab → 填空
git commit -m "sync: CubeMX 代码同步

- 更新：启用 SPI2 外设
- 影响：新增 spi.h 和 spi.c"
```

### 场景 4：更新了 README

```bash
# 方式 1：简单版
git commit -m "docs: 更新 README 硬件连接说明"

# 方式 2：使用代码片段
# 输入 gitdocs → Tab → 填空
git commit -m "docs: 更新 README 硬件连接说明

- 补充 DAP-Link 引脚定义
- 添加串口接线图"
```

---

## 🎨 PowerShell 增强（可选）

如果你想更进一步，可以在 `$PROFILE` 中添加：

```powershell
# Git 快速提交函数
function gca {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("feat","fix","docs","refactor","chore","sync")]
        [string]$type,
        
        [Parameter(Mandatory=$true)]
        [string]$msg
    )
    git add .
    git commit -m "$($type): $($msg)"
    Write-Host "✓ 提交成功 [$($type)]" -ForegroundColor Green
}

# 使用示例
gca feat "添加串口命令解析"
gca fix "修复 LED 极性反转问题"
gca docs "更新 README 安装说明"
```

---

## ⚠️ 常见误区

### ❌ 不要这样写

```bash
git commit -m "update"
git commit -m "修改了一些代码"
git commit -m "今天修了好多 bug"
git commit -m "asdfasdf"  # 乱打一通
```

### ✅ 应该这样写

```bash
git commit -m "feat: 添加 PWM 输出功能"
git commit -m "fix: 修复定时器中断冲突"
git commit -m "docs: 更新 API 文档"
```

---

## 📊 决策流程图

```text
准备提交代码
    ↓
这次改了什么？
    │
    ├─ 新功能？ → 用 gitfeat
    │   └─ 例：feat: 添加 SPI 通信
    │
    ├─ 修 Bug？ → 用 gitfix
    │   └─ 例：fix: 修复内存泄漏
    │
    ├─ 改文档？ → 用 gitdocs
    │   └─ 例：docs: 更新使用说明
    │
    ├─ 重构代码？ → 用 gitrefactor
    │   └─ 例：refactor: 提取公共函数
    │
    ├─ 改配置？ → 用 gitchore
    │   └─ 例：chore: 更新编译选项
    │
    └─ CubeMX 同步？ → 用 gitsync
        └─ 例：sync: 更新 USART 配置
```

---

## 🎯 21 天养成习惯计划

### 第 1 周：强制使用

- 每次提交都打开速查卡
- 强迫自己不用"update"这种词
- 至少写清楚做了什么

### 第 2 周：熟练使用

- 开始使用 VSCode 代码片段
- 尝试写更详细的提交信息
- 重要的提交加上要点列表

### 第 3 周：形成习惯

- 自然而然地写出规范提交
- 开始享受清晰的 Git 历史
- 可能会忍不住教别人 😄

---

## 📈 你会得到的好处

### 短期（1-2 周）

- ✅ 不再为提交信息发愁
- ✅ 提交质量明显提升
- ✅ 同事/队友开始夸你

### 中期（1-2 月）

- ✅ Git 历史清晰易读
- ✅ 回滚/查找更方便
- ✅ 写提交信息成为习惯

### 长期（3 月+）

- ✅ 项目历史就是开发日志
- ✅ 新人能通过提交记录学习
- ✅ 团队协作更顺畅

---

## 🔗 相关资源

- **详细规范** - `.lingma/git-commit-spec.md`
- **速查卡片** - `.lingma/git-commit-quick-reference.md`
- **VSCode 片段** - `.vscode/git-commit.code-snippets`

---

## 💬 常见问题

### Q: 记不住这么多类型怎么办

**A:** 先用这 3 个就够了：

- `feat:` - 新功能
- `fix:` - 修 Bug  
- `docs:` - 改文档

### Q: 有时候改动很小，也要写很详细吗

**A:** 不用！小改动一行搞定：

```bash
git commit -m "fix: 修正 LED 引脚定义"
```

### Q: 如果一次改了很多东西呢

**A:** 最好分成多次提交。如果实在要一起提交，就列个清单：

```bash
git commit -m "feat: 添加多个新功能

- 新增 LED 控制
- 添加串口命令解析  
- 更新配置文件"
```

### Q: 写错了怎么办

**A:** 最后一次提交可以修改：

```bash
git commit --amend -m "正确的提交信息"
```

---

**开始行动吧！** 下次提交时就试试这些模板！🚀

**版本：** v1.0  
**创建日期：** 2026-03-17
