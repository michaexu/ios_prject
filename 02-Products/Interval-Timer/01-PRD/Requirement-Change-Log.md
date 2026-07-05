# 需求修改记录

> 记录 Interval Timer 项目需求变更历史，包括新增、修改、删除功能的需求追踪。

---

## 变更记录

### [REQ-001] 方案明细查看
- **日期**：2026-07-05
- **类型**：新增功能
- **提出人**：马欣妍
- **优先级**：P1
- **状态**：已完成

#### 需求描述

在训练方案列表中，每个方案目前只显示名称、训练/休息时间和轮数的简要信息，用户无法查看方案的完整明细。需要在方案行上增加一个信息按钮（i 图标），点击后弹出该方案的详细参数。

#### 验收标准

1. 预设方案和自定义方案均显示信息按钮
2. 点击信息按钮弹出明细视图，包含：
   - 方案名称
   - 训练时间（格式化为分:秒）
   - 休息时间（格式化为分:秒）
   - 循环次数
   - 总时长（自动计算）
   - 总训练时间（work × rounds）
   - 总休息时间（rest × (rounds - 1)）
   - 方案类型（预设 / 自定义）
   - 创建时间（自定义方案显示）
3. 明细视图不干扰现有的"开始训练"和"编辑"操作

#### 影响范围

- `Views/ProgramsView.swift` — `ProgramRow` 增加 info 按钮，新增 `ProgramDetailView`
- `Views/HomeView.swift` — `ProgramCard` 暂不修改（卡片式布局空间有限，后续按需扩展）

#### 完成说明

- 已在 `03-Code/IntervalTimer/Views/ProgramsView.swift` 中完成方案详情入口与明细视图
- 详情页参数与汇总时长已统一为 `MM:SS` 格式

---

### [REQ-002] 全球多语言版本支持
- **日期**：2026-07-05
- **类型**：修改功能
- **提出人**：马欣妍
- **优先级**：P1
- **状态**：已完成

#### 需求描述

Interval Timer 将面向全球 App 市场发布，需要将应用改为多语言版本，默认语言为英文，并覆盖主流市场常用语言。多语言不仅包括界面文案，还应确保预设训练方案名称、提醒音名称、统计信息、设置项和发布所需的语言声明保持一致。

#### 验收标准

1. 默认显示英文文案
2. 支持以下语言：
   - English (`en`)
   - 简体中文 (`zh-Hans`)
   - 繁體中文 (`zh-Hant`)
   - 日本語 (`ja`)
   - 한국어 (`ko`)
   - Français (`fr`)
   - Deutsch (`de`)
   - Español (`es`)
   - Português (Brasil) (`pt-BR`)
   - Italiano (`it`)
   - Русский (`ru`)
   - العربية (`ar`)
3. 首页、计时器、方案、统计、设置、隐私政策等核心页面全部完成本地化
4. 预设训练方案名称按当前语言展示，自定义方案名称保持用户输入
5. 提醒音配置使用稳定 ID 存储，兼容旧版本中文音效名称
6. 工程声明支持上述语言，满足 App Store 发布所需的本地化识别

#### 影响范围

- `03-Code/IntervalTimer/Utilities/AppLocalization.swift` — 新增应用级本地化读取与格式化能力
- `03-Code/IntervalTimer/Resources/AppLocalizations.json` — 新增 12 种语言文案资源
- `03-Code/IntervalTimer/Models/Program.swift` — 预设方案稳定命名与多语言显示
- `03-Code/IntervalTimer/Models/AppSettings.swift`、`ViewModels/AppSettingsStore.swift`、`ViewModels/TimerManager.swift` — 提醒音稳定 ID 与旧值兼容
- `03-Code/IntervalTimer/Views/*.swift` — 核心界面统一切换为本地化文案
- `03-Code/IntervalTimer.xcodeproj/project.pbxproj`、`03-Code/IntervalTimer/*.lproj/InfoPlist.strings` — 补充语言声明与最小本地化发布资源

#### 完成说明

- 已完成英文默认语言和 11 种附加主流语言支持
- 已完成预设方案名称、提醒音名称、周维度统计标签的多语言展示
- 已完成旧版中文提醒音持久化值到稳定 ID 的兼容迁移
- 已补充工程语言区域声明与 `InfoPlist.strings` 本地化文件，用于发布识别

---

<!-- 后续需求变更按以下模板追加 -->

<!--

### [REQ-XXX] 需求标题
- **日期**：YYYY-MM-DD
- **类型**：新增功能 / 修改功能 / 删除功能 / Bug 修复
- **提出人**：
- **优先级**：P0 / P1 / P2 / P3
- **状态**：待评审 / 开发中 / 已完成 / 已关闭

#### 需求描述


#### 验收标准


#### 影响范围


-->
