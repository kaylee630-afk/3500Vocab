# 3500 单词记忆 App

这是一个基于 SwiftUI 的 iPhone 单词记忆应用，词库来自《3500默写.pdf》。界面以纯白色为基础，使用轻量卡片、弹簧动画和平滑过渡。

## 主要功能

- 随机 30 词：随机抽取 30 个词条，先看英文、点击卡片查看中文释义，再选择“认识 / 不认识”。
- 按字母背单词：按 A-Z 分组浏览全部词条，支持搜索和单词详情。
- 无尽模式：随机单词连续出现，可持续学习。
- 错题本：答错的词自动记录，并按错误次数分为四级。
  - 偶尔出错：1 次
  - 容易出错：2-3 次
  - 高频易错：4-6 次
  - 顽固词汇：7 次及以上

## 中文释义

应用使用 iOS 18 的 Apple 翻译框架在设备端获取中文释义，不需要内置 3500 条翻译数据，也不会把单词上传到第三方服务。首次翻译英文到中文时，系统可能需要下载对应语言包，建议在有网络时先完成一次翻译。

## 运行环境

- Xcode 26 或更高版本
- iOS 18.0 或更高版本
- 建议使用真机运行翻译功能；iOS 模拟器可能不提供 Apple 翻译服务

## 如何运行

1. 打开 `VocabMemo.xcodeproj`。
2. 选择需要运行的 iPhone 模拟器或真机。
3. 按 `Command + R` 运行。
4. 如果要在真机上安装，请在 `Signing & Capabilities` 中选择你自己的开发团队。

## 通过 GitHub 分享

这个项目可以直接上传到 GitHub，适合分享给其他使用 Xcode 的同学或开发者。

```bash
cd ~/Desktop/3500Vocab
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/你的用户名/3500Vocab.git
git push -u origin main
```

对方拿到代码后，可以用下面的方式打开：

```bash
git clone https://github.com/你的用户名/3500Vocab.git
cd 3500Vocab
open VocabMemo.xcodeproj
```

注意：GitHub 主要用于分享源代码，不能像应用商店一样直接给普通用户安装 App。如果需要让非开发者直接安装到 iPhone，仍然需要 TestFlight、App Store 或 Ad Hoc 分发。

## 项目结构

- `VocabMemo/Resources/words.json`：从 PDF 提取并清理后的词条数据。
- `VocabMemo/Models`：词条和错题数据模型。
- `VocabMemo/Services`：词库加载、错题持久化和翻译服务。
- `VocabMemo/Views`：首页、随机 30 词、字母列表、无尽模式、错题本等页面。
