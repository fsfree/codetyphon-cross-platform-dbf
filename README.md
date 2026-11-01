# codetyphon-cross-platform-dbf

基于 **CodeTyphon 与 Lazarus / Free Pascal** 搭建跨平台 DBF 数据处理工具开发环境的 Skill。

面向国产化平台（龙芯 MIPS64 / LoongArch64、飞腾 / 鲲鹏 ARM64）、Linux 与 Windows，提供交叉编译环境配置、TDbf 组件正确用法，以及经实测验证的编译踩坑经验。

## 目录结构

```
.
├── SKILL.md                         # Skill 核心工作流
├── scripts/                         # 4 个可复用的配置脚本（.bat）
│   ├── 00_check_env.bat             # 环境自检
│   ├── 01_build_targets.bat         # 交叉目标生成
│   ├── 02_switch_target.bat         # 目标切换 + 编译
│   └── 03_build_loongarch.bat       # 龙芯 LoongArch 构建指引
├── references/
│   └── technical-reference.md       # TDbf API + 7 坑清单 + 龙芯要点
└── assets/
    └── demo-dbf-tool/               # 最小可编译的 DBF 示例工程
```

## 快速开始

1. 运行 `scripts/00_check_env.bat` 勘察本机环境；
2. 将 `assets/demo-dbf-tool/` 复制到工作目录，用 lazbuild 编译验证：
   ```bash
   lazbuild.exe --cpu=x86_64 --os=win64 dbf_tool.lpi
   ```
3. 按 `scripts/01_build_targets.bat` 下载并构建交叉编译目标；
4. 国产化架构（龙芯/飞腾）按 `references/technical-reference.md` 第五节处理。

## 环境要求

- CodeTyphon（建议 GENERATION 9+）
- Lazarus + Free Pascal（FPC 3.2.2，含 TDbf / FPSpreadsheet 组件）

## 许可证

本 Skill 用于学习与工程实践，示例代码基于 LGPL（LCL 例外）许可的 Lazarus/FPC 组件。
