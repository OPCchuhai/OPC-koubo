# 用 AI 做数字人口播

这是一套免费说明，交给 Claude、ChatGPT 这类 AI，让它用 Renoise 做出「同一个人出镜说话」的短视频。橙哥出海（OPCchuhai）开源，许可是 MIT，不收费。

English: a free MIT skill from OPCchuhai. Your AI makes talking-head videos through Renoise.

技能正文在 [`skills/digital-human-koubo/SKILL.md`](skills/digital-human-koubo/SKILL.md)。把这个文件夹交给 AI 就行，不用自己改代码。

## 你需要准备什么

- 一个能对话的 AI：Claude、ChatGPT、WorkBuddy、豆包、千问、OpenClaw、Hermes，或其它能连上外部工具的产品
- 一个 Renoise 账号
- 一张你本人的照片，或你已经得到授权、可以用来做数字人的照片

## 最快开始

还没有 Renoise 账号，或还没登录？先打开这条注册链接：

https://www.renoise.ai/?utm_campaign=affiliate_program&utm_medium=affiliate&utm_source=rewardful&via=quantbang

然后把下面整段复制，贴进你正在用的 AI：

```text
请安装并使用橙哥出海（OPCchuhai）开源的「数字人口播」：
仓库 https://github.com/OPCchuhai/OPC-koubo
先阅读并遵守 skills/digital-human-koubo/SKILL.md。

请先看我正在用哪个 AI。如果还不能调用 Renoise 的 get_account，就按技能里「按产品连接 Renoise MCP」里对应的那一段，带我装好并登录。
地址只用这一条，不要改：
https://renoise.tv/api/public/mcp

如果我还没登录、或需要注册，只发这一条注册链接：
https://www.renoise.ai/?utm_campaign=affiliate_program&utm_medium=affiliate&utm_source=rewardful&via=quantbang

连上之后，告诉我是哪个账号、还剩多少积分，再问我想做：产品广告、照着喜欢的视频复刻，还是从 Renoise 模板开始。我要做数字人口播的话，接着走技能里的口播流程。

persona.json 只是占位。用我自己的照片，在我的 Renoise 账号里重建形象，不要写入别人的素材编号。花积分前先报价，等我同意再生成。成片要标明是 AI 数字人。
```

## 怎么连上 Renoise

打开 [`skills/digital-human-koubo/SKILL.md`](skills/digital-human-koubo/SKILL.md)，找到「按产品连接 Renoise MCP」，用和你的产品同名的那一段。地址只有这一条，不要改成别的：

https://renoise.tv/api/public/mcp

最常见的两种，可以直接做：

**Claude。** 打开下面这个链接。页面会自动填好名称和地址，点添加。在网页里加好之后，Claude 电脑版也能用。

https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=Renoise&connectorUrl=https%3A%2F%2Frenoise.tv%2Fapi%2Fpublic%2Fmcp

**ChatGPT。** 打开 https://chatgpt.com/plugins ，添加一个名为 Renoise 的自定义服务器，地址填 `https://renoise.tv/api/public/mcp`，登录方式选 OAuth。如果看不到添加入口，先到 Settings → Apps → Advanced settings，打开 Developer mode。

WorkBuddy、豆包、千问、OpenClaw、Hermes，以及 Cursor 这类其它产品，都用技能文件里对应的那一段，按它写的去点、去复制。浏览器会打开 Renoise 的页面，你在那里登录并允许访问。不用准备 API key。

## 连上之后做什么

1. 形象文件现在是空的占位。先用你自己的照片，在你的 Renoise 账号里做好数字人。
2. 生成之前，AI 会先告诉你大概要花多少积分。你同意了再开始。
3. 成片标明「内容由 AI 数字人演绎」。

## 致谢

做法灵感来自 Berryxia / andyhuo520 的开源项目 [digital-human-koubo](https://github.com/andyhuo520/digital-human-koubo)（MIT）。

这个仓库是橙哥出海自己重写的，不是把上游文件原样拷过来。这里没有别人的照片，也没有别人的素材编号。请用你自己的照片。

## 许可

[MIT License](LICENSE)。Copyright (c) 2026 OPCchuhai（橙哥出海）。
