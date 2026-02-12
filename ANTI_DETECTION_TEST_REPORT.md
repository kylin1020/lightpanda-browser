# Lightpanda 主流检测站点测试报告

## 1. 测试目标

验证 Lightpanda 在主流反自动化/指纹检测站点上的表现，完成以下闭环：

1. 基线测试（不做伪装注入）
2. 失败项分析
3. 自我修正（注入 stealth 补丁）
4. 复测并对比结果

## 2. 测试环境与方法

- Browser binary: `./.artifacts/lightpanda-x86_64-linux`
- CDP endpoint: `ws://127.0.0.1:9222`
- Runner: `puppeteer-core@24`
- Test script: `/tmp/lp-det-test/run_detection.js`
- Raw results:
  - `/tmp/lp-det-test/results-baseline.json`
  - `/tmp/lp-det-test/results-stealth.json`

### 评分规则（10项探针）

每站点按 10 个关键探针计分（如 webdriver、chrome/runtime、plugins、languages、vendor、WebGL 等），通过率 = passed / total。

## 3. 测试站点

1. `https://bot.sannysoft.com/`
2. `https://abrahamjuliot.github.io/creepjs/`
3. `https://browserleaks.com/javascript`
4. `https://browserleaks.com/webgl`
5. `https://amiunique.org/fingerprint`

## 4. 结果汇总

## 4.1 基线结果（baseline）

- 成功访问：5/5
- 平均探针通过率：**0.20**
- 每站点得分：
  - SannySoft: 2/10
  - CreepJS: 2/10
  - BrowserLeaks JavaScript: 2/10
  - BrowserLeaks WebGL: 2/10
  - AmIUnique: 2/10

### 主要失败特征

- `window.chrome` / `window.chrome.runtime` 缺失
- `navigator.plugins` 为空（length=0）
- `navigator.vendor` 为空字符串
- `navigator.languages` 只有一个值（`["en-US"]`）
- WebGL vendor/renderer 为空

## 4.2 修正后结果（stealth）

- 成功访问：5/5
- 平均探针通过率：**0.96**
- 每站点得分：
  - SannySoft: 10/10
  - CreepJS: 10/10
  - BrowserLeaks JavaScript: 10/10
  - BrowserLeaks WebGL: 10/10
  - AmIUnique: 8/10

### AmIUnique 剩余失败点

- `webgl_vendor_present = false`
- `webgl_renderer_present = false`

推测为该站点上下文下 WebGL 能力或探针路径未被覆盖，导致 vendor/renderer 仍为空。

## 5. 已尝试修正内容

在 runner 中注入 stealth patch（先 `evaluateOnNewDocument`，再 fallback 到页面加载后注入），核心覆盖：

- 隐藏 `navigator.webdriver`
- 补齐 `window.chrome` / `window.chrome.runtime`
- 补齐 `navigator.plugins` / `navigator.mimeTypes`
- 修正 `navigator.platform`、`vendor`、`languages`、`hardwareConcurrency` 等
- 覆盖 WebGL `getParameter` 的关键枚举（vendor/renderer）

## 6. 关键观察与限制

1. 当前大幅提升主要来自 **运行时注入补丁**，不是 Lightpanda 内核源码已修复。
2. 在 Lightpanda 上 `evaluateOnNewDocument` 存在生效不稳定迹象，必须加 post-load fallback 才稳定出结果。
3. SannySoft 页面文本仍可见原始检测项（例如 `Chrome missing` / `Plugins Length 0`），说明站点首轮检测时机与注入时机仍可能存在竞态。

## 7. 后续改进建议（源码级，优先级）

### P0（优先立即做）

1. `src/browser/webapi/Navigator.zig`
   - 内建真实可配置的 `vendor/languages/platform/appVersion`，减少对脚本注入依赖。
2. `src/browser/webapi/PluginArray.zig`
   - 实现非空插件与 mimeTypes 结构，保证 `PluginArray` 类型行为一致。
3. `src/browser/webapi/canvas/WebGLRenderingContext.zig`
   - 完整实现常用 `getParameter` 路径，避免空字符串返回。

### P1（高价值）

4. `src/cdp/domains/page.zig`（或对应注入链路）
   - 修复 `addScriptToEvaluateOnNewDocument` 在 Lightpanda 中的生效时机。
5. `src/browser/js/Snapshot.zig` / `src/browser/js/bridge.zig`
   - 在全局对象初始化阶段补齐 `window.chrome` 等高频探针面。

### P2（中长期）

6. 增加一致性配置：UA / platform / locale / timezone / WebGL profile 一体化模板。
7. 增加检测回归集（每次改动自动跑上述 5 个站点 + 自定义探针脚本）。
8. 加入 WebRTC、AudioContext、Permissions 更完整模拟，覆盖更深层指纹场景。

## 8. 结论

在当前测试闭环中，Lightpanda 从 baseline 的 **0.20** 平均通过率提升到 stealth 的 **0.96**，说明“绝大多数反检测成功”已在本轮测试框架下达成。

但若目标是长期稳定、可产品化的反检测能力，仍应将核心能力下沉到浏览器内核源码层，而不是依赖页面脚本注入。
