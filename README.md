# Mac Window Tidy

按应用 bundle ID 与窗口标题精确匹配的 macOS 窗口关闭脚本。默认仅预览，显式 --apply 才点击匹配窗口的关闭按钮。遇到已修改文档或 sheet 跳过。

## 使用

macOS，Swift / Xcode Command Line Tools，并为实际执行终端授予辅助功能权限。

```sh
swift close_selected_windows.swift targets.example.json
swift close_selected_windows.swift targets.example.json --apply
```

将自己的匹配规则保存为 config.json（已忽略）。示例为虚构应用 ID，不会匹配正常应用。输出 JSON 到标准输出；没有固定文件输出。脚本不会替用户处理保存/丢弃弹窗。辅助功能字段是否可靠取决于应用实现，先在无重要内容的窗口验证。

0.1.0 预发布；只做编译检查，未针对任意第三方应用保证行为。
