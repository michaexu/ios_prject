# 设计交付规范（Design Handoff）- Interval Timer

## 📋 交付清单

### 已完成文档
- ✅ **Design-System.md** - 设计系统规范
- ✅ **Information-Architecture.md** - 信息架构
- ✅ **Wireframes.md** - 页面线框图

### 待交付资源
- ⏳ **UI Mockups** - 高保真设计稿（需要 Figma 或图片）
- ⏳ **Icon Set** - 图标资源（SVG / PDF）
- ⏳ **Sound Files** - 提示音文件

---

## 🎨 设计决策记录

### 1. 为什么选择深色主题？
- **场景适配**：健身房环境通常光线较暗，深色更舒适
- **科技感**：深色 + 霓虹色更能体现科技感
- **省电**：OLED 屏幕深色更省电

### 2. 为什么使用圆形进度条？
- **直观**：圆形更符合"时间循环"的概念
- **美观**：与科技感设计语言一致
- **实用**：在倒计时大字体周围展示进度，不占额外空间

### 3. 为什么底部标签栏用图标 + 文字？
- **降低认知负担**：新手用户也能快速理解
- **iOS 规范**：符合 iOS 设计规范

---

## 📐 开发注意事项

### 1. 进度环实现
**推荐方案**：
- 使用 `SwiftUI` 的 `Circle()` + `trim()` 实现
- 或使用 `CAShapeLayer` + `UIBezierPath`（UIKit）

**关键代码逻辑**：
```swift
// 计算进度
let progress = CGFloat(currentTime) / CGFloat(totalTime)

// 绘制进度环
Circle()
    .trim(from: 0, to: progress)
    .stroke(
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.green]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        style: StrokeStyle(lineWidth: 8, lineCap: .round)
    )
    .rotationEffect(.degrees(-90))
```

### 2. 倒计时精度
**要求**：误差 < 0.1秒

**推荐方案**：
- 使用 `DispatchSourceTimer`（更精确）代替 `Timer`
- 或记录开始时间，每次计算 `Date().timeIntervalSince(now)`

**避免方案**：
- ❌ 不要使用 `Timer.scheduledTimer`（精度不够）

### 3. 声音和震动
**声音实现**：
```swift
import AVFoundation

let systemSoundID: SystemSoundID = 1005  // 系统提示音
AudioServicesPlaySystemSound(systemSoundID)
```

**震动实现**：
```swift
import CoreHaptics

let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)
```

### 4. 屏幕常亮
```swift
// 训练开始时
UIApplication.shared.isIdleTimerDisabled = true

// 训练结束或退出时
UIApplication.shared.isIdleTimerDisabled = false
```

---

## 📦 资源清单

### 图标（需要设计）
| 图标名称 | 用途 | 尺寸 | 格式 |
|---------|------|------|------|
| `icon-home` | 首页标签 | 24pt | SVG |
| `icon-timer` | 计时器标签 | 24pt | SVG |
| `icon-programs` | 方案标签 | 24pt | SVG |
| `icon-stats` | 统计标签 | 24pt | SVG |
| `icon-settings` | 设置标签 | 24pt | SVG |
| `icon-play` | 开始按钮 | 32pt | SVG |
| `icon-pause` | 暂停按钮 | 32pt | SVG |
| `icon-stop` | 停止按钮 | 24pt | SVG |
| `icon-add` | 新建按钮 | 24pt | SVG |
| `icon-edit` | 编辑按钮 | 24pt | SVG |
| `icon-delete` | 删除按钮 | 24pt | SVG |

### 提示音（需要录制或购买）
| 音效名称 | 用途 | 时长 | 格式 |
|---------|------|------|------|
| `beep-short` | 训练开始/结束 | 0.5s | WAV |
| `beep-long` | 全部完成 | 1.5s | WAV |
| `voice-start` | "开始训练"语音 | 1s | WAV |
| `voice-rest` | "休息结束"语音 | 1s | WAV |

**备选方案**：使用系统声音
- `AudioServicesPlaySystemSound(1005)` - 提示音
- `AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)` - 震动

---

## ✅ 设计评审检查表

### 视觉设计
- [ ] 配色符合科技感定位
- [ ] 字体层级清晰
- [ ] 间距统一（8pt grid）
- [ ] 圆角、阴影一致

### 用户体验
- [ ] 操作流程顺畅（≤ 3 步完成训练）
- [ ] 按钮大小适合点击（≥ 44pt）
- [ ] 文字对比度足够（WCAG AA）
- [ ] 加载状态有反馈

### 技术可行性
- [ ] 进度环可实现
- [ ] 倒计时精度可保证
- [ ] 声音/震动可调用系统 API
- [ ] 适配所有 iPhone 尺寸

---

## 🚀 下一步：开发阶段

### 开发任务分解
1. **搭建项目结构**（Xcode 项目、SwiftUI）
2. **实现设计系统**（Color、Font、Component 扩展）
3. **开发首页**（HomeView）
4. **开发计时器页**（TimerView）- 核心功能
5. **开发方案页**（ProgramsView）
6. **开发统计页**（StatsView）
7. **开发设置页**（SettingsView）
8. **实现数据持久化**（CoreData / UserDefaults）
9. **测试**（单元测试 + UI 测试）
10. **打包发布**（App Store）

### 预计时间
- **设计转代码**：2 天
- **核心功能**：3 天
- **辅助功能**：2 天
- **测试 + 修复**：2 天
- **总计**：约 9 个工作日

---

## 📝 备注

- 本设计文档为 V1.0，后续根据开发反馈和用户反馈迭代
- 如有疑问，联系 UI 设计师（AI）
- 设计稿最终解释权归产品团队所有

---

**文档版本**：V1.0  
**创建日期**：2026-07-05  
**创建人**：UI 设计师（AI）  
**交接对象**：iOS 开发工程师（AI）  
**交接日期**：2026-07-05
