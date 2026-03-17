# PIO_TEST2 文档索引

**项目：** STM32F103C8 PlatformIO 开发模板  
**版本：** v1.1.0  
**最后更新：** 2026-03-17

---

## 📚 文档导航

### 🎯 核心文档

#### 1. [README.md](../README.md) - 项目概述 ⭐⭐⭐⭐⭐

**位置：** 项目根目录  
**用途：** 快速了解项目结构和使用方法  
**推荐：** 必读

#### 2. [docs/CUBEMX_GUIDE.md](CUBEMX_GUIDE.md) - CubeMX 集成完整指南 ⭐⭐⭐⭐⭐

**位置：** docs/ 目录  
**用途：** CubeMX 与 PlatformIO 集成的完整教程  
**包含：**

- 快速开始（30 秒上手）
- CubeMX 配置指南
- 自动化同步脚本使用
- 文件复制规范
- main.c 合并策略
- 最佳实践
- 常见问题解答

**推荐：** CubeMX 用户必读

---

### 🛠️ 工具文档

#### 3. [CHANGELOG.md](../CHANGELOG.md) - 更新日志 ⭐⭐⭐

**位置：** 项目根目录  
**用途：** 查看版本更新记录  
**包含：**

- v1.1.0 路径自动检测功能
- v1.0.0 初始版本
- 未来计划

---

### 🔧 参考文档

#### 4. [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - 故障排除 ⭐⭐⭐⭐

**位置：** 项目根目录  
**用途：** 解决常见问题  
**包含：**

- 编译错误
- 烧录问题
- 串口通信问题
- 调试技巧

---

### 📖 其他文档

#### 5. [DAPLINK_GUIDE.md](../DAPLINK_GUIDE.md) - DAP-Link 使用指南 ⭐⭐⭐

**位置：** 项目根目录  
**用途：** DAP-Link 下载器使用说明

#### 6. [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - 快速参考卡 ⭐⭐⭐⭐

**位置：** 项目根目录  
**用途：** 快速查询常用命令和操作  
**特点：** 简洁明了，一目了然

---

### 📝 Git 提交规范文档

#### 7. [git-commit/](git-commit/) - Git 提交规范完整指南 ⭐⭐⭐⭐⭐

**位置：** docs/git-commit/  
**用途：** Git 提交信息规范化指导  
**包含：**

- [spec.md](git-commit/spec.md) - 详细规范（系统学习）
- [guide.md](git-commit/guide.md) - 使用指南（实战演示）
- [quick-reference.md](git-commit/quick-reference.md) - 速查卡（快速参考）

**推荐：** 团队协作必读

---

### 💻 显示设备驱动文档

#### 8. [OLED_DISPLAY_GUIDE.md](OLED_DISPLAY_GUIDE.md) - OLED 显示屏完整指南 ⭐⭐⭐⭐⭐

**位置：** docs/OLED_DISPLAY_GUIDE.md  
**用途：** SSD1306/SH1106 OLED 驱动开发完整教程  
**包含：**

- 快速开始（3 步上手）
- 硬件连接图（I2C/SPI）
- anurag3301/STM32-SSD1306 库使用
- 完整代码示例（基础 + 高级）
- API 速查表
- 故障排除指南
- 自行开发驱动框架

**推荐：** OLED 用户必读

#### 9. [QUICK_REFERENCE_OLED.md](QUICK_REFERENCE_OLED.md) - OLED 驱动速查卡 ⭐⭐⭐⭐

**位置：** docs/QUICK_REFERENCE_OLED.md  
**用途：** OLED 驱动快速参考  
**特点：** 简洁明了，一目了然

---

### 📂 历史文档（已合并）

以下文档已合并到 `docs/CUBEMX_GUIDE.md`，**不再推荐使用**：

- ❌ `AUTO_DETECT_README.md` - 已合并
- ❌ `AUTO_DETECT_TEST.md` - 已合并
- ❌ `AUTO_DETECT_FIX.md` - 已合并
- ❌ `SYNC_CUBEMX_GUIDE.md` - 已合并
- ❌ `CUBEMX_INTEGRATION_GUIDE.md` - 已合并

---

## 🎯 使用建议

### 新手入门

```text
1. 阅读 README.md → 了解项目
2. 阅读 docs/CUBEMX_GUIDE.md → 学习集成
3. 参考 QUICK_REFERENCE.md → 快速查询
4. 遇到问题查看 TROUBLESHOOTING.md → 解决问题
```

### 日常开发

```text
1. 使用 sync.bat 同步 → 参考 CUBEMX_GUIDE.md
2. 编写提交信息 → 参考 git-commit/guide.md
3. 编译验证 → 参考 README.md
4. 遇到问题 → 查看 TROUBLESHOOTING.md
```

### 版本升级

```text
1. 查看 CHANGELOG.md → 了解变更
2. 按照说明升级 → 更新文件
3. 测试验证 → 确保正常
```

---

## 📊 文档结构

```text
PIO_TEST2/
├── README.md                    # 主入口，项目概述
├── docs/                        # 文档目录
│   ├── CUBEMX_GUIDE.md         # CubeMX 集成完整指南
│   └── git-commit/             # Git 提交规范目录
│       ├── spec.md             # 详细规范
│       ├── guide.md            # 使用指南
│       └── quick-reference.md  # 速查卡
├── CHANGELOG.md                 # 更新日志
├── TROUBLESHOOTING.md           # 故障排除
├── DAPLINK_GUIDE.md             # DAP-Link 指南
├── QUICK_REFERENCE.md           # 快速参考
└── (历史文档已合并，不推荐使用)
```

---

## 🚀 快速查找

### 我想…

- **了解项目** → [README.md](../README.md)
- **学习 CubeMX 集成** → [docs/CUBEMX_GUIDE.md](CUBEMX_GUIDE.md)
- **学习 Git 提交规范** → [docs/git-commit/guide.md](git-commit/guide.md)
- **快速查询命令** → [QUICK_REFERENCE.md](../QUICK_REFERENCE.md)
- **解决编译问题** → [TROUBLESHOOTING.md](../TROUBLESHOOTING.md)
- **使用 DAP-Link** → [DAPLINK_GUIDE.md](../DAPLINK_GUIDE.md)
- **查看更新记录** → [CHANGELOG.md](../CHANGELOG.md)
- **了解版本变化** → [CHANGELOG.md](../CHANGELOG.md)

---

## 📞 技术支持

### 遇到问题？

1. **查看文档索引** - 本文档
2. **阅读故障排除** - TROUBLESHOOTING.md
3. **查看更新日志** - CHANGELOG.md
4. **检查代码仓库** - Git 历史

---

## 🎉 总结

### 必读文档（按优先级）

1. ⭐⭐⭐⭐⭐ [README.md](../README.md) - 项目概述
2. ⭐⭐⭐⭐⭐ [docs/CUBEMX_GUIDE.md](CUBEMX_GUIDE.md) - CubeMX 集成
3. ⭐⭐⭐⭐ [QUICK_REFERENCE.md](../QUICK_REFERENCE.md) - 快速参考
4. ⭐⭐⭐⭐ [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) - 故障排除
5. ⭐⭐⭐ [CHANGELOG.md](../CHANGELOG.md) - 更新日志

### 推荐学习路径

```text
README.md
    ↓
docs/CUBEMX_GUIDE.md
    ↓
docs/git-commit/guide.md
    ↓
QUICK_REFERENCE.md
    ↓
TROUBLESHOOTING.md
```

---

**祝开发顺利！** 🚀

---

**最后更新：** 2026-03-17  
**文档版本：** v1.0  
**维护状态：** ✅ 活跃
