# 节气茶饮 iOS

原生 SwiftUI iPhone App，数据保存在应用包内，不需要网络即可浏览、搜索和查看 60 条茶饮资料。

## 打开与运行

1. 在 macOS 上安装 Xcode 16 或更新版本，并打开 `SeasonalTea.xcodeproj`。
2. 选择 `SeasonalTea` scheme 和 iPhone 12 模拟器。
3. 点击 Run。若要安装到真机，在 Xcode 的 Signing & Capabilities 中选择自己的 Apple Developer Team。

也可以在 macOS 终端构建：

```sh
xcodebuild -project SeasonalTea.xcodeproj \
  -scheme SeasonalTea \
  -destination 'platform=iOS Simulator,name=iPhone 12' \
  build
```

推送到 GitHub 的 `main` 分支后，Actions 会在 macOS runner 上编译并启动 iPhone 模拟器中的 App。每次运行会保存一张模拟器截图，可在该次 Actions 运行的 Artifacts 中下载。此流程验证编译和启动，不替代对各页面交互的完整 UI 测试。

Deployment Target 是 iOS 17.0，目标设备仅为 iPhone。Swift 语言模式设为 5.0。App 不请求相机、位置或健康数据权限，也没有服务器依赖。

## 工程内容

- `SeasonalTea/Models`：茶饮、原料、分类和节气模型。
- `SeasonalTea/Services`：节气计算、推荐和搜索索引。
- `SeasonalTea/Repositories`：应用启动时一次性读取并缓存本地数据。
- `SeasonalTea/Views`：今日推荐、茶库、分类列表和详情页。
- `SeasonalTea/Resources/tea_data.json`：源数据的 60 条记录，保留原字段，并补充多分类、类型和详情页使用的原料列表。

搜索索引在茶库创建时生成，输入后延迟约 180 ms 再筛选。列表使用 `LazyVStack` / `LazyVGrid`。详情页来源通过系统 `Link` 打开，分享使用 `ShareLink`。导航使用原生 `NavigationStack`，系统返回手势保持可用。

## 节气算法与推荐规则

`SolarTermService` 根据太阳视黄经每 15 度的交点计算二十四节气时刻，并以 `Asia/Shanghai` 时区确定日期。公式采用低精度太阳位置模型，适合用于节气 UI 日期；不是天文历书级的观测数据。

`RecommendationService` 只从标记为 `seasonRecommendable` 的单品饮品中选择。现有 30 条复方食养资料不进入普通节气推荐池。推荐理由只描述季节和饮用场景，并附带原数据中的证据范围。

## 验证状态

本地 Windows 环境没有 Xcode、iOS SDK 或 iPhone Simulator，无法在本机编译或启动。GitHub Actions 会提供 macOS 上的实际构建和模拟器启动结果；若 iPhone 12 模拟器不可用，工作流会选用 runner 上可用的 iPhone 模拟器。
