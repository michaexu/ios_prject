# 设计系统（Design System）
## ReceiptKeeper - AI 收据管家

**版本：** V1.0  
**日期：** 2026-07-05  
**作者：** UI 设计师（虚拟员工）

---

## 一、设计理念

### 核心原则
1. **清晰优先**：收据信息一目了然
2. **专业简洁**：适合商务场景
3. **高效操作**：3 步完成核心任务

### 设计风格
- **风格**：专业简洁（Professional & Clean）
- **参考**：Notion、Linear、Apple 原生 App
- **配色**：浅色主题（收据照片在深色下不好看）
- **字体**：系统字体（SF Pro / Roboto）

---

## 二、色彩系统

### 2.1 主色（Primary）
| 颜色 | 用途 | Hex | SwiftUI |
|------|------|-----|---------|
| **品牌蓝** | 主按钮、链接、强调 | `#2563EB` | `Color.blue` |
| **品牌蓝（深色）** | 按钮按下状态 | `#1D4ED8` | `Color.blue.opacity(0.8)` |

### 2.2 辅助色（Secondary）
| 颜色 | 用途 | Hex |
|------|------|-----|
| **成功绿** | 成功提示、已识别 | `#10B981` |
| **警告橙** | 警告提示、待处理 | `#F59E0B` |
| **错误红** | 错误提示、删除 | `#EF4444` |

### 2.3 中性色（Neutral）
| 颜色 | 用途 | Hex |
|------|------|-----|
| **背景白** | 主背景 | `#FFFFFF` |
| **背景灰** | 卡片背景 | `#F9FAFB` |
| **边框灰** | 分割线、边框 | `#E5E7EB` |
| **文本主** | 主要文字 | `#111827` |
| **文本次** | 次要文字 | `#6B7280` |
| **文本禁用** | 禁用状态 | `#D1D5DB` |

### 2.4 分类色（Category Colors）
| 分类 | 颜色 | 图标 |
|------|------|------|
| 🍽️ 餐饮 | `#EF4444` | `fork.knife` |
| ✈️ 交通 | `#3B82F6` | `car.fill` |
| 🏨 住宿 | `#8B5CF6` | `bed.double.fill` |
| 💼 办公 | `#F59E0B` | `briefcase.fill` |
| 📦 其他 | `#6B7280` | `square.grid.2x2.fill` |

---

## 三、字体系统

### 3.1 字体族
- **英文**：SF Pro（iOS 系统字体）
- **中文**：PingFang SC（iOS 系统字体）

### 3.2 字体大小
| 用途 | 大小 | 粗细 | SwiftUI |
|------|------|------|---------|
| **大标题** | 34pt | Bold | `.largeTitle` |
| **标题 1** | 28pt | Bold | `.title` |
| **标题 2** | 22pt | Semibold | `.title2` |
| **标题 3** | 20pt | Semibold | `.title3` |
| **正文** | 17pt | Regular | `.body` |
| **副文本** | 15pt | Regular | `.callout` |
| **说明** | 13pt | Regular | `.caption` |
| **小字** | 12pt | Regular | `.caption2` |

---

## 四、布局系统

### 4.1 间距（Spacing）
| 名称 | 值 | SwiftUI |
|------|-----|---------|
| **XS** | 4pt | `4` |
| **S** | 8pt | `8` |
| **M** | 16pt | `16` |
| **L** | 24pt | `24` |
| **XL** | 32pt | `32` |
| **XXL** | 48pt | `48` |

### 4.2 圆角（Corner Radius）
| 元素 | 圆角 | SwiftUI |
|------|------|---------|
| **小卡片** | 8pt | `8` |
| **卡片** | 12pt | `12` |
| **大卡片** | 16pt | `16` |
| **按钮** | 8pt | `8` |
| **输入框** | 8pt | `8` |

### 4.3 阴影（Shadow）
```swift
// 卡片阴影
.shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

// 悬浮按钮阴影
.shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
```

---

## 五、组件库

### 5.1 按钮（Buttons）

#### 主按钮（Primary Button）
```swift
Button("Save") {
    // action
}
.buttonStyle(.borderedProminent)
.tint(Color.blue)
```

**规范：**
- 背景：品牌蓝 `#2563EB`
- 文字：白色，17pt，Semibold
- 高度：50pt
- 圆角：8pt
- 内边距：水平 24pt，垂直 12pt

#### 次按钮（Secondary Button）
```swift
Button("Cancel") {
    // action
}
.buttonStyle(.bordered)
```

**规范：**
- 边框：品牌蓝 `#2563EB`，1pt
- 文字：品牌蓝，17pt，Semibold
- 高度：50pt
- 圆角：8pt

#### 文本按钮（Text Button）
```swift
Button("Forgot password?") {
    // action
}
.foregroundColor(.blue)
```

---

### 5.2 输入框（Text Fields）

#### 标准输入框
```swift
TextField("Merchant name", text: $merchant)
    .textFieldStyle(.roundedBorder)
    .padding(.horizontal, 16)
```

**规范：**
- 高度：44pt
- 边框：灰色 `#E5E7EB`，1pt
- 圆角：8pt
- 内边距：12pt
- 字体：17pt

#### 带图标的输入框
```swift
HStack {
    Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
    TextField("Search receipts", text: $searchText)
}
.padding(12)
.background(Color(.systemGray6))
.cornerRadius(8)
```

---

### 5.3 卡片（Cards）

#### 收据卡片
```swift
VStack(alignment: .leading, spacing: 8) {
    HStack {
        Image(systemName: category.icon)
            .foregroundColor(category.color)
        Text(merchant)
            .font(.headline)
        Spacer()
        Text(amount)
            .font(.headline)
    }
    Text(date)
        .font(.caption)
        .foregroundColor(.secondary)
}
.padding(16)
.background(Color.white)
.cornerRadius(12)
.shadow(color: Color.black.opacity(0.05), radius: 4, y: 2)
```

**规范：**
- 背景：白色
- 圆角：12pt
- 阴影：轻微阴影
- 内边距：16pt

---

### 5.4 标签（Tags）

#### 分类标签
```swift
Text(category.name)
    .font(.caption)
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(category.color.opacity(0.1))
    .foregroundColor(category.color)
    .cornerRadius(4)
```

---

### 5.5 图标（Icons）

**规范：**
- 使用 **SF Symbols**（iOS 系统图标）
- 大小：
  - 小图标：16pt
  - 中图标：24pt
  - 大图标：32pt
- 颜色：
  - 主图标：品牌蓝
  - 次图标：灰色 `#6B7280`
  - 分类图标：分类颜色

**常用图标清单：**
| 功能 | 图标名称 |
|------|---------|
| 拍照 | `camera.fill` |
| 相册 | `photo.on.rectangle` |
| 搜索 | `magnifyingglass` |
| 筛选 | `line.3.horizontal.decrease.circle` |
| 导出 | `square.and.arrow.up` |
| 删除 | `trash` |
| 编辑 | `pencil` |
| 设置 | `gearshape` |
| 统计 | `chart.pie` |
| 分类 | `tag.fill` |

---

## 六、SwiftUI 实现

### 6.1 设计系统扩展
```swift
// Colors.swift
extension Color {
    static let appPrimary = Color.blue
    static let appBackground = Color(.systemBackground)
    static let appCardBackground = Color(.secondarySystemBackground)
    static let appTextPrimary = Color(.label)
    static let appTextSecondary = Color(.secondaryLabel)
    static let appBorder = Color(.separator)
}

// CategoryColors.swift
extension Category {
    var color: Color {
        switch self {
        case .meals: return Color.red
        case .travel: return Color.blue
        case .accommodation: return Color.purple
        case .office: return Color.orange
        case .other: return Color.gray
        }
    }
}
```

---

## 七、响应式设计

### 7.1 适配不同设备
- **iPhone SE**：最小宽度 375pt，字体适当缩小
- **iPhone 15 Pro**：标准宽度 393pt
- **iPhone 15 Pro Max**：最大宽度 430pt
- **iPad**：V1.1 支持，使用 Split View

### 7.2 安全区域
```swift
// 适配刘海屏
.edgesIgnoringSafeArea(.bottom)
```

---

## 八、动效设计

### 8.1 过渡动画
```swift
// 页面过渡
.transition(.asymmetric(
    insertion: .move(edge: .trailing).combined(with: .opacity),
    removal: .move(edge: .leading).combined(with: .opacity)
))

// 列表动画
.withAnimation {
    receipts.remove(at: index)
}
```

### 8.2 加载动画
```swift
// 识别中加载动画
ProgressView()
.progressViewStyle(CircularProgressViewStyle())
.scaleEffect(1.5)
```

---

## 九、无障碍设计

### 9.1 支持 VoiceOver
```swift
Text(amount)
    .accessibilityLabel("Amount: \(amount)")
    .accessibilityHint("Double tap to edit")
```

### 9.2 动态字体
```swift
// 支持用户调整字体大小
.font(.body)
.dynamicTypeSize(.medium ... .accessibility5)
```

---

## 十、设计检查清单

### 10.1 UI 一致性检查
- [ ] 所有按钮样式统一
- [ ] 所有输入框样式统一
- [ ] 所有卡片样式统一
- [ ] 配色符合设计系统
- [ ] 字体符合设计系统

### 10.2 用户体验检查
- [ ] 核心任务 ≤ 3 步
- [ ] 所有按钮可点击区域 ≥ 44pt
- [ ] 支持 VoiceOver
- [ ] 支持动态字体
- [ ] 加载状态有明确反馈

---

## 十一、更新日志

| 版本 | 日期 | 修改内容 |
|------|------|---------|
| V1.0 | 2026-07-05 | 初始版本 |

---

**文档结束**
