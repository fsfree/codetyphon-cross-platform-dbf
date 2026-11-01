# DBF 数据处理工具 — 最小示例工程

用于验证 CodeTyphon / Lazarus 跨平台编译链的最小可编译工程。

## 功能演示

| 按钮 | 功能 | 对应技术要点 |
|---|---|---|
| 创建表 | 动态创建 `supplier.dbf`（TableLevel=25 FoxPro） | TDbf 动态建表 + 索引 |
| 打开表 | 打开表并绑定 TDBGrid | TDBGrid → TDataSource → TDbf |
| 追加5条记录 | 批量插入（DisableControls 提速） | 批量导入提速关键 |
| 关闭表 | 关闭数据集 | — |

## 编译方式

**方式一：命令行（推荐，脚本已封装）**

```bat
cd scripts
02_switch_target.bat win64       # Windows 64 位
02_switch_target.bat aarch64     # 飞腾/鲲鹏 ARM64
02_switch_target.bat linux64     # x86_64 Linux（统信/麒麟）
02_switch_target.bat loongarch   # 龙芯 LoongArch64
```

**方式二：Lazarus IDE 手动**

1. 用 `D:\lazarus\lazarus.exe` 打开 `src\dbf_tool.lpi`；
2. 「工程选项 → 编译选项 → Config and Target」切换目标 OS/CPU；
3. 点「运行」编译。

## 目录约定

- 数据文件输出到程序同级的 `Data\` 目录（跨平台路径，用 `ExtractFilePath` + `DirectoryExists`）；
- 单元编译输出到 `lib/$(TargetCPU)-$(TargetOS)`，切换目标无需改路径。

## 依赖组件

- `TDbf`（`D:\lazarus\components\tdbf\dbflaz.lpk`，已存在）
- 标准 LCL / DB 控件

> 本工程为最小验证用。正式工具需按 `docs/配置指南.md` 第六节要点扩展：
> Excel 导入（FPSpreadsheet）、数据审核（Filter 表达式）、主从汇总、报表导出等。
