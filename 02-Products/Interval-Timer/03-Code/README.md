# Interval Timer - iOS 应用

## 📱 项目简介

一款专为健身房训练场景设计的间歇性训练计时器，让用户能够快速设计训练方案并高效完成训练。

**核心特性**：
- ⚡ 3 秒开始训练（快速、简单）
- 📋 5 个预设训练计划（Tabata、7分钟训练等）
- 🔊 声音 + 震动提醒
- 📊 训练记录统计
- 🎨 科技感深色主题设计

---

## 📂 项目结构

```
IntervalTimer/
├── IntervalTimerApp.swift     # 主应用入口
├── Models/
│   └── Program.swift          # 数据模型（Program、TrainingRecord）
├── ViewModels/
│   └── TimerManager.swift     # 计时器逻辑
├── Views/
│   ├── HomeView.swift         # 首页
│   ├── TimerView.swift        # 计时器页（核心）
│   ├── ProgramsView.swift     # 方案页
│   ├── StatsView.swift        # 统计页
│   └── SettingsView.swift     # 设置页
└── Utilities/
    └── DesignSystem.swift     # 设计系统（颜色、字体、间距）
```

---

## 🚀 快速开始

### 1. 创建 Xcode 项目

1. 打开 Xcode
2. 选择 **Create New Project**
3. 选择 **iOS > App**
4. 填写项目信息：
   - **Product Name**: `Interval Timer`
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `SwiftData`（用于数据持久化）
5. 点击 **Next**，选择保存位置
6. 点击 **Create**

### 2. 导入代码文件

将本项目的所有 Swift 文件复制到 Xcode 项目中：

1. 在 Xcode 中，右键点击项目文件夹
2. 选择 **Add Files to "IntervalTimer"...**
3. 选择以下文件：
   - `IntervalTimerApp.swift`
   - `Models/Program.swift`
   - `ViewModels/TimerManager.swift`
   - `Views/HomeView.swift`
   - `Views/TimerView.swift`
   - `Views/ProgramsView.swift`
   - `Views/StatsView.swift`
   - `Views/SettingsView.swift`
   - `Utilities/DesignSystem.swift`
4. 确保勾选 **Copy items if needed**
5. 点击 **Add**

### 3. 配置项目

#### 3.1 支持的最低 iOS 版本
1. 在项目设置中，选择 **IntervalTimer** target
2. 在 **General** 标签页，设置 **Minimum Deployments** 为 **iOS 15.0**

#### 3.2 设备方向
1. 在 **General** 标签页，取消勾选 **iPad**
2. 在 **Deployment Info** 中，只保留 **Portrait**（竖屏）

#### 3.3 删除默认文件
1. 删除 Xcode 自动生成的 `ContentView.swift` 文件
2. 删除 `Assets.xcassets` 中的默认图片（保留 AppIcon）

### 4. 运行应用

1. 选择一个模拟器（如 iPhone 15 Pro）
2. 点击 **Run** 按钮（或按 `Cmd + R`）
3. 应用应该成功编译并启动

---

## 🎨 设计系统

### 颜色

```swift
Color.backgroundDeep   // #0A0E27 - 主背景
Color.backgroundLight  // #151B3D - 卡片背景
Color.neonBlue         // #00D9FF - 主色调
Color.neonGreen        // #00FF88 - 成功/休息状态
Color.neonPurple       // #B44AFF - 强调色
```

### 字体

```swift
Font.largeTitle  // 34pt Bold
Font.title       // 28pt Bold
Font.timer       // 72pt Bold（倒计时）
```

### 间距

```swift
Spacing.sm   // 8pt
Spacing.md   // 16pt
Spacing.lg   // 24pt
```

---

## 🔧 核心功能说明

### 1. 计时器逻辑（TimerManager）

**关键特性**：
- 使用 `Timer.scheduledTimer` 实现倒计时
- 支持训练/休息阶段自动切换
- 支持暂停/继续/停止
- 播放声音和震动提醒

**使用方法**：
```swift
let timerManager = TimerManager()
timerManager.setup(program: program)
timerManager.start()
```

### 2. 圆形进度环（TimerView）

**实现方式**：
- 使用 `Circle().trim()` 绘制进度环
- 使用 `LinearGradient` 实现渐变效果
- 使用 `rotationEffect(.degrees(-90))` 调整起始位置

### 3. 数据持久化（SwiftData）

**模型**：
- `Program` - 训练方案
- `TrainingRecord` - 训练记录

**保存训练记录**：
```swift
@Environment(\.modelContext) private var modelContext
modelContext.insert(record)
try? modelContext.save()
```

---

## 📝 待完成功能

### 高优先级
- [ ] 实现 SwiftData 数据持久化（目前只是打印）
- [ ] 添加 App Icon 和 Launch Screen
- [ ] 测试倒计时精度（确保误差 < 0.1秒）
- [ ] 实现后台计时（如果需要）

### 中优先级
- [ ] 保存自定义训练方案到 SwiftData
- [ ] 统计页面显示真实数据（从数据库读取）
- [ ] 优化 UI 动画和过渡效果
- [ ] 添加单元测试

### 低优先级
- [ ] 支持 iPad 版本
- [ ] 多语言支持（英文）
- [ ] Apple Watch 配套 App
- [ ] 社区分享功能

---

## 🐛 已知问题

1. **Timer 精度问题**：使用 `Timer.scheduledTimer` 可能有精度误差，建议使用 `DispatchSourceTimer`
2. **数据未持久化**：目前训练记录只是打印，未保存到数据库
3. **预览未完全配置**：SwiftUI Preview 可能需要额外配置才能正常显示

---

## 📚 参考资料

- **设计稿**：`02-Products/Interval-Timer/02-Design/`
- **PRD**：`02-Products/Interval-Timer/01-PRD/PRD.md`
- **用户故事**：`02-Products/Interval-Timer/01-PRD/User-Stories.md`
- **路线图**：`02-Products/Interval-Timer/01-PRD/Roadmap.md`

---

## 👥 虚拟团队

- **产品经理**：生成 PRD、用户故事、路线图
- **UI 设计师**：设计系统、线框图、视觉设计
- **iOS 开发工程师**：实现代码（当前角色）
- **测试工程师**：（待启动）编写测试用例、测试报告
- **运维工程师**：（待启动）配置 CI/CD、发布到 App Store

---

## 📄 许可证

本项目为个人学习项目，仅供学习和参考使用。

---

**创建日期**：2026-07-05  
**版本**：V1.0 (MVP)  
**开发者**：iOS 开发工程师（AI）
