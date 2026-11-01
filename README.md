# 数字人口播（OPC-koubo）

橙哥出海（OPCchuhai）开源的 Agent Skill：把数字人口播 / digital human koubo（真人出镜感的 talking-head 视频）交给 Claude、Cursor 等智能体，经 Renoise 官方 MCP 生成。

English: a free, MIT-licensed Agent Skill for digital-human talking-head video. OPCchuhai does not sell the skill.

## 项目定位

- 这是一份 **Agent Skill**，入口在 [`skills/digital-human-koubo/SKILL.md`](skills/digital-human-koubo/SKILL.md)，用来做数字人口播。
- 由 **橙哥出海（OPCchuhai）** 开源。技能本身免费，不单独售卖、不设付费墙。

## 致谢

流程和「用 Agent Skill 包一层数字人口播」的做法，灵感来自 Berryxia / andyhuo520 的开源项目 [digital-human-koubo](https://github.com/andyhuo520/digital-human-koubo)（MIT）。

本仓库是橙哥出海（OPCchuhai）自己重写、按 fork 方式重新包装的技能骨架，**不是**上游仓库的逐字节复制。这里没有上游的二进制、人物照片、包装素材或 Renoise material ID。请用你自己的照片重建形象。

## 注册链接

还没有 Renoise 账号、或尚未登录 Renoise、智能体发现还没连上而需要你先注册时，使用这一条注册链接：

https://www.renoise.ai/?utm_campaign=affiliate_program&utm_medium=affiliate&utm_source=rewardful&via=quantbang

已有账号、只是要把工具接上时，用下一节的官方 MCP 地址，不要把 MCP 地址改成别的域名，也不要用别的地址代替这条注册链接。

## 一键丢给 AI

复制下面整段，贴进 Claude、Cursor 或其他智能体：

```text
请安装并使用橙哥出海（OPCchuhai）开源的「数字人口播」Agent Skill：
仓库 https://github.com/OPCchuhai/OPC-koubo
先阅读并遵守 skills/digital-human-koubo/SKILL.md，再帮我做数字人口播。

连接 Renoise 官方 MCP，地址不要改：
https://renoise.ai/api/public/mcp

如果我还没注册、或 Renoise 没连上、需要我去注册：只发这一条注册链接（给尚未登录 Renoise 的用户）：
https://www.renoise.ai/?utm_campaign=affiliate_program&utm_medium=affiliate&utm_source=rewardful&via=quantbang

persona.json 只是占位。用我自己的照片在我的 Renoise 账号里重建形象；不要写入任何上游或其他账号的 material ID。花积分前先报价，等我同意再生成。
```

## 怎么用

1. 克隆本仓库，或把 `skills/digital-human-koubo/` 交给智能体当技能目录。
2. 让智能体阅读并遵守 [`skills/digital-human-koubo/SKILL.md`](skills/digital-human-koubo/SKILL.md)。
3. 连接 Renoise **官方** MCP，地址保持为：

   https://renoise.ai/api/public/mcp

   Cursor 等支持远程 MCP 的客户端可以这样写：

   ```json
   {
     "mcpServers": {
       "renoise": {
         "url": "https://renoise.ai/api/public/mcp"
       }
     }
   }
   ```

4. 还没有账号、或尚未登录时，打开上一节的注册链接完成注册，再回到客户端登录授权。
5. 用你自己的照片把 `persona.json` 从占位改成可用形象，然后再出片。

模型、分辨率、积分和接口以 **当前 Renoise 文档** 加上本技能为准。本仓库提供的是技能骨架和流程大纲，不附带可直接开拍的人物素材。

## 形象占位 persona.json

[`skills/digital-human-koubo/persona.json`](skills/digital-human-koubo/persona.json) **只是占位**。姓名、外观、声音、提示词和 `reference_material` 都是 `TODO`，`photos` 为空，里面没有任何 Renoise material ID。

你需要：

1. 准备一张你有权使用的照片（本人或已获授权的肖像）。
2. 在自己的 Renoise 账号里按现行文档重建数字人。
3. 把**你的账号**返回的引用写回 `persona.json`。

不要填上游项目或别人账号里的素材编号。那些编号不能在你的账号上使用，本仓库也不会附带上游的人物照片。

## 许可

[MIT License](LICENSE)。Copyright (c) 2026 OPCchuhai（橙哥出海）。
