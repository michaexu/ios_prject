# iOS 产品开发工作流程

## 流程概览

```
产品想法 → PRD → 设计稿 → 代码 → 测试 → 发布
   ↓        ↓       ↓      ↓      ↓      ↓
  你     产品经理  设计师  开发   测试   运维
```

## 详细步骤

### 1️⃣ 产品想法（你）
- 输入：简单的产品描述
- 输出：产品想法文档（`02-Products/[产品名]/00-Idea.md`）

### 2️⃣ PRD 生成（虚拟产品经理）
- 输入：产品想法
- 活动：提问澄清 → 生成 PRD、用户故事、路线图
- 输出：
  - `01-PRD/PRD.md`
  - `01-PRD/User-Stories.md`
  - `01-PRD/Roadmap.md`

### 3️⃣ UI 设计（虚拟设计师）
- 输入：PRD
- 活动：信息架构 → 线框图 → 视觉设计
- 输出：
  - `02-Design/Wireframes/`（线框图）
  - `02-Design/UI-Mockups/`（设计稿）
  - `03-Shared-Resources/Design-System/`（设计系统）

### 4️⃣ 开发（虚拟开发工程师）
- 输入：PRD + 设计稿
- 活动：架构设计 → 代码实现 → 单元测试
- 输出：
  - `03-Code/` Xcode 项目
  - GitHub 仓库
  - 单元测试

### 5️⃣ 测试（虚拟测试工程师）
- 输入：PRD + 代码
- 活动：测试用例设计 → 执行测试 → Bug 报告
- 输出：
  - `04-Testing/Test-Cases.md`
  - `04-Testing/Test-Report.md`
  - GitHub Issues（Bug）

### 6️⃣ 发布（虚拟运维工程师）
- 输入：测试通过的代码
- 活动：配置 CI/CD → 准备上架材料 → 提交审核
- 输出：
  - `05-Releases/` 发布记录
  - App Store 上架

## 如何启动虚拟员工

每个虚拟员工对应一个 **WorkBuddy Expert**（专家），你可以：

1. **方式 1**：在 WorkBuddy 中创建对应的 Expert，配置 system prompt 为 `ROLE.md` 内容
2. **方式 2**：每次需要某个角色时，告诉我"启动产品经理"，我会加载对应的 ROLE.md 并执行任务
3. **方式 3**：使用自动化脚本，按顺序调用不同角色的 API

## 当前产品：运动间歇性训练时间工具

- **产品名**：Interval Timer（暂定）
- **目标**：开发一个简单易用的间歇性训练计时器 App
- **下一步**：启动产品经理，生成 PRD
