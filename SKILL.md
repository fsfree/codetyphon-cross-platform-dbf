---
name: codetyphon-cross-platform-dbf
description: 基于 CodeTyphon 与 Lazarus/Free Pascal 搭建跨平台 DBF 数据处理工具的开发环境。当用户需要为国产化平台（龙芯 MIPS64/LoongArch64、飞腾/鲲鹏 ARM64）、Linux 或 Windows 配置交叉编译环境，或开发/排障基于 TDbf 组件的单机数据处理工具（Excel 导入、数据审核、主从汇总）时使用。涵盖环境勘察、交叉编译目标生成、示例工程编译验证，以及 TDbf 组件正确 API 与编译踩坑的实战知识。
---

# CodeTyphon + Lazarus 跨平台 DBF 开发环境

## 概述

本技能用于在已安装 CodeTyphon / Lazarus 的机器上，搭建面向国产化平台（龙芯、飞腾/鲲鹏）、Linux 与 Windows 的跨平台编译环境，并落地一个基于 TDbf 组件的最小可编译 DBF 数据处理工具。

核心能力：**环境勘察 → 生成配置脚本 → 生成示例工程 → 编译验证 → 沉淀踩坑经验**，产出零依赖、可交叉编译的单文件可执行程序。

## 何时使用本技能

- 用户要求搭建 CodeTyphon / Lazarus 跨平台开发环境（提到"国产化""龙芯""麒麟""统信 UOS""交叉编译"等）；
- 用户需要开发或排障基于 TDbf 组件的 DBF 单机数据处理工具（Excel 导入、数据审核、主从汇总）；
- 用户遇到 Lazarus/FPC 编译报错（`Can't find unit ...`、`Duplicate identifier`、`Wrong number of parameters` 等）。

## 工作流程

按以下顺序执行，产出可直接交付的脚本、文档与示例工程。

### 步骤 0：勘察已安装环境（只读）

先确认 CodeTyphon、Lazarus、FPC 的安装路径与版本，以及 TDbf / FPSpreadsheet 组件是否就绪。关键勘察点：

- CodeTyphon 的 `binCenter\` 目录（已就绪的交叉目标）与 `binBase\` 目录；
- Lazarus 的 `fpc\3.2.2\bin\<CPU>-<OS>\fpc.exe` 编译器位置；
- `components\tdbf\dbflaz.lpk`（TDbf 组件）与 `components\fpspreadsheet`（Excel 读写）；
- 配置目录（由 `lazarus.cfg` 的 `--primary-config-path` 指定）中是否存在 `packagefiles.xml`——**缺失会导致命令行编译失败**（详见 `references/technical-reference.md` 第四节）。

可直接运行 `scripts/00_check_env.bat` 自动完成勘察（注意：脚本内 `CT_DIR`/`LAZ_DIR` 路径需按实际机器修改）。

### 步骤 1：生成配置脚本

将 `scripts/` 目录下的 4 个脚本复制到用户交付目录，并按实际安装路径调整脚本顶部的 `CT_DIR`/`LAZ_DIR` 变量：

| 脚本 | 作用 |
|---|---|
| `00_check_env.bat` | 环境自检（只读） |
| `01_build_targets.bat` | 交叉编译目标生成指引 + 产物校验 |
| `02_switch_target.bat` | 目标切换 + lazbuild 命令行编译 |
| `03_build_loongarch.bat` | 龙芯 LoongArch64 交叉编译器构建指引 |

`02_switch_target.bat` 支持目标：`win64` / `win32` / `linux64` / `linux32` / `aarch64` / `mips64` / `loongarch`。

### 步骤 2：生成示例工程

将 `assets/demo-dbf-tool/` 复制到交付目录，得到最小可编译的 DBF 工具工程。示例工程已实测编译通过，包含：

- `dbf_tool.lpr`（主程序，含高 DPI 与 Linux 字体适配）
- `mainform.pas`（TDBGrid + TDbf 动态建表、索引、批量导入演示）
- `mainform.lfm`（窗体资源）
- `dbf_tool.lpi`（**已内嵌 LCL/TDbf/fcl-db 单元路径**，即使配置目录缺 packagefiles.xml 也能命令行编译）

### 步骤 3：编译验证

用 lazbuild 验证基础编译链：

```bash
lazbuild.exe --cpu=x86_64 --os=win64 dbf_tool.lpi
```

编译通过即证明基础链路可用。交叉目标切换用 `02_switch_target.bat <目标>`。

### 步骤 4：处理国产化交叉编译（按需）

- **ARM64（飞腾/鲲鹏）**：CT 内置 `aarch64-linux` 工具链，按 `01_build_targets.bat` 下载构建即可；
- **龙芯 MIPS64（3A4000）**：CT 默认清单无此架构，需额外下载 mips64el 工具链，编译参数见 `references/technical-reference.md` 第五节；
- **龙芯 LoongArch64（3A5000/6000）**：FPC 上游已原生支持，按 `03_build_loongarch.bat` 用 fpcupdeluxe 或源码方式构建 `ppcrossloongarch64`。

## 关键注意事项

1. **TDbf API 以本机 fpc 源码为准**，勿照抄网络文章：单元名 `dbf_fields`（下划线敏感）、`IndexDefs.Add` 是无参函数返回对象（非三参数）、`TableLevel` 用 25（FoxPro）。
2. **`packagefiles.xml` 缺失是命令行编译失败的头号根因**：最彻底修复是首次正常启动一次 Lazarus IDE 让其自动生成。
3. **编译报错优先查 `references/technical-reference.md` 第四节的 7 坑清单**，逐条对照。
4. 示例工程的 `.lpi` 已内嵌完整路径，适合 CI/脚本化验证；正式开发仍建议走 IDE 正常流程。

## 资源

- `scripts/` — 4 个可直接复用的配置脚本（.bat，Windows 宿主）
- `references/technical-reference.md` — 环境勘察结论、TDbf 正确 API、7 坑清单、龙芯编译要点
- `assets/demo-dbf-tool/` — 最小可编译的 DBF 工具示例工程（已实测编译通过）
