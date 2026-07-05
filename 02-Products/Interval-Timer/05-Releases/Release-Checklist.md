# 发布检查清单 - Interval Timer

## 📋 发布前检查（每次发布前必须检查）

### 1. 代码准备
- [ ] 所有功能开发完成
- [ ] 代码已合并到 `main` 分支
- [ ] 单元测试通过（覆盖率 > 80%）
- [ ] 集成测试通过
- [ ] 代码审查完成（如果是团队开发）
- [ ] 版本号已更新（`CFBundleShortVersionString`）
- [ ] 构建号已更新（`CFBundleVersion`）

### 2. 测试验证
- [ ] 系统测试通过（参考 `04-Testing/Test-Report-Template.md`）
- [ ] 无 P0、P1 级别 Bug
- [ ] 在真实设备上测试通过（至少 1 台）
- [ ] 测试了所有预设训练方案
- [ ] 测试了声音和震动提醒
- [ ] 测试了训练记录保存和显示

### 3. App 配置
- [ ] Bundle Identifier 正确（如 `com.yourcompany.intervaltimer`）
- [ ] 签名证书有效（Development + Distribution）
- [ ] 描述文件有效（Development + Distribution）
- [ ] App Icon 已添加（所有尺寸）
- [ ] Launch Screen 已配置
- [ ] 权限描述已添加（如果需要）
  - [ ] 通知权限（如果需要推送）
  - [ ] 其他权限（根据实际使用情况）

### 4. App Store 材料
- [ ] 应用名称
- [ ] 副标题（可选）
- [ ] 描述（≥ 100 字符）
- [ ] 关键词（≤ 100 字符）
- [ ] 支持 URL
- [ ] 隐私政策 URL
- [ ] 截图（iPhone 6.5"、5.5"）
- [ ] 应用预览视频（可选）
- [ ] 分类和主要类别
- [ ] 年龄分级
- [ ] 价格（免费/付费）

### 5. 法律合规
- [ ] 隐私政策已准备
- [ ] 用户协议已准备（如果需要）
- [ ] 使用了第三方库（已添加版权声明）
- [ ] 符合 App Store 审核指南

---

## 🚀 发布流程

### 阶段 1：Beta 测试（TestFlight）

#### 步骤
1. **归档构建**
   ```bash
   # 在 Xcode 中
   Product → Archive → Distribute App → Ad Hoc → 导出 IPA
   ```

2. **上传到 TestFlight**
   ```bash
   # 使用 Fastlane
   fastlane beta
   
   # 或手动上传
   Xcode → Window → Organizer → Distribute App → TestFlight
   ```

3. **添加测试人员**
   - 登录 [App Store Connect](https://appstoreconnect.apple.com)
   - 进入 TestFlight 标签
   - 添加内部测试人员（App 管理员）
   - 添加外部测试人员（需要邮箱邀请）

4. **收集反馈**
   - 检查崩溃报告（Xcode → Organizer → Crashes）
   - 收集测试人员反馈
   - 修复 Bug

#### 检查点
- [ ] Beta 版本已上传
- [ ] 内部测试人员已测试
- [ ] 外部测试人员已测试（如果需要）
- [ ] 无严重 Bug

---

### 阶段 2：App Store 发布

#### 步骤
1. **准备元数据**
   - 登录 [App Store Connect](https://appstoreconnect.apple.com)
   - 创建应用（如果首次发布）
   - 填写所有必填项

2. **上传构建版本**
   ```bash
   # 使用 Fastlane
   fastlane release
   
   # 或手动上传
   Xcode → Archive → Distribute App → App Store Connect
   ```

3. **提交审核**
   - 在 App Store Connect 中点击"提交审核"
   - 回答审核问题（加密、广告标识符等）
   - 等待审核（通常 24-48 小时）

4. **审核通过后**
   - 选择"手动发布"或"自动发布"
   - 如果手动发布，在"准备发布"状态时点击"发布到 App Store"

#### 检查点
- [ ] 构建版本已上传
- [ ] 元数据已填写完整
- [ ] 截图已上传
- [ ] 已提交审核
- [ ] 审核通过
- [ ] 应用已发布

---

## 📝 版本管理

### 版本号规则
- **版本号**（CFBundleShortVersionString）：`1.0.0`
  - 主版本号.次版本号.修订号
  - 重大更新：增加主版本号（1.0.0 → 2.0.0）
  - 新功能：增加次版本号（1.0.0 → 1.1.0）
  - Bug 修复：增加修订号（1.0.0 → 1.0.1）

- **构建号**（CFBundleVersion）：`1`
  - 每次构建增加 1
  - 可以使用日期格式（如 `20260705`）

### Git 标签
```bash
# 发布前打标签
git tag -a v1.0.0 -m "Version 1.0.0: MVP 版本"
git push origin v1.0.0
```

---

## 🐛 发布后监控

### 监控指标
- [ ] 下载量（App Store Connect → 分析）
- [ ] 崩溃率（Xcode → Organizer → Crashes）
- [ ] 用户反馈（App Store 评论）
- [ ] 性能指标（启动时间、响应速度）

### 问题处理
- **崩溃**：尽快修复并发布更新
- **负面反馈**：回复评论，改进产品
- **审核被拒**：根据拒绝理由修改，重新提交

---

## 📚 参考文档

- **GitHub Actions 配置**：`.github/workflows/ci-cd.yml`
- **Fastlane 配置**：`fastlane/Fastfile`
- **测试报告**：`04-Testing/Test-Report-Template.md`
- **App Store 审核指南**：https://developer.apple.com/app-store/review/guidelines/

---

## ⚠️ 常见问题

### 1. 证书过期
**症状**：构建失败，提示证书无效  
**解决**：重新生成证书和描述文件，更新 GitHub Secrets

### 2. 审核被拒
**常见原因**：
- 崩溃（提供崩溃日志）
- 功能不完整（所有宣称的功能必须可用）
- 隐私政策缺失
- 元数据不准确

**解决**：根据拒绝理由修改，回复苹果审核团队

### 3. TestFlight 构建过期
**症状**：TestFlight 提示"构建版本不可用"  
**原因**：TestFlight 构建 90 天后过期  
**解决**：重新上传构建版本

---

**文档版本**：V1.0  
**创建日期**：2026-07-05  
**创建人**：发布工程师（AI）  
**最后更新**：2026-07-05
