# CodeTyphon + Lazarus 跨平台 DBF 工具 — 技术参考

本文件是 skill 的核心知识资产，记录经实测验证的环境勘察结论、TDbf 组件正确 API 用法，以及编译踩坑清单。用于在搭建/排障跨平台 DBF 工具开发环境时快速定位问题。

---

## 一、环境勘察关键结论（实测于 CT 9.00 + Lazarus/FPC 3.2.2）

| 事实 | 说明 |
|---|---|
| CodeTyphon 安装包默认不含交叉工具链 | 体积原因，需 `CrossBuild` 菜单按需下载 |
| 交叉工具链获取路径 | IDE 菜单 `CrossBuild → Download Cross Toolchains` / `Download Libraries` / `FreePascal 32/64bits` |
| CT 默认清单无龙芯 MIPS64/LoongArch64 | 只有 aarch64/arm/i386/x86_64 等常规架构 |
| LoongArch64 已获 FPC 上游支持 | 龙芯团队已合入主分支（compiler + rtl），交叉编译器 `ppcrossloongarch64` |
| 交叉编译器命名规则 | aarch64→`ppcrossa64`，loongarch64→`ppcrossloongarch64`，x86_64→`ppcrossx64`，mips64el→`ppcrossmips64` |

## 二、关键目录结构

```
CodeTyphon  C:\codetyphon
├── binCenter\    已就绪的交叉目标（aarch64-linux-gtk2 等）
├── binBase\      FPC 基础目标（x86_64-win64 等）
├── binLibraries\ 目标平台系统库（$(TargetCPU)-$(TargetOS)）
└── ScriptsWin\   交叉编译构建脚本

Lazarus  D:\lazarus
├── lcl\units\$(CPU)-$(OS)\           LCL 基础单元（interfacebase、forms、controls…）
├── lcl\units\$(CPU)-$(OS)\win32\     widgetset 单元（interfaces、win32int…）
├── components\tdbf\dbflaz.lpk        TDbf 组件包
├── components\lazutils\lib\...       LazUTF8 等工具单元
└── fpc\3.2.2\units\$(CPU)-$(OS)\fcl-db\   TDbf 底层实现单元（dbf、dbf_fields…）
```

## 三、TDbf 组件正确 API 用法（以 fpc 源码为准，勿照抄网络文章）

真实源码位置：`D:\lazarus\fpc\3.2.2\source\packages\fcl-db\src\dbase\`

### 3.1 单元名（下划线敏感）

| 文章写法 | 正确单元名 |
|---|---|
| `Dbf` | `dbf`（大小写不敏感，等价） |
| `DbfFields` | `dbf_fields`（**下划线必须保留**） |
| `Dbf_Common` | `dbf_common` |

### 3.2 动态建表

```pascal
uses ..., dbf, dbf_fields, dbf_common;

var MyDbf: TDbf;
MyDbf := TDbf.Create(nil);
try
  MyDbf.FilePath   := ExtractFilePath(Application.ExeName) + 'Data';
  MyDbf.TableName  := 'supplier.dbf';
  MyDbf.TableLevel := 25;              // FoxPro 级别（文章 A 写 7 是笔误）
  MyDbf.FieldDefs.Clear;
  MyDbf.FieldDefs.Add('SupplierID', ftAutoInc, 0,   True);   // 签名：Add(Name, DataType, Size, Required)
  MyDbf.FieldDefs.Add('Name',       ftString,  100, False);
  // 或返回对象赋值：with MyDbf.FieldDefs.AddFieldDef do ...
  MyDbf.IndexDefs.Clear;
  with MyDbf.IndexDefs.Add do        // Add 是无参函数，返回 TDbfIndexDef（非三参数！）
  begin
    IndexFile := 'IdxName';          // 索引文件名
    SortField := 'Name';             // 被索引字段
    Options   := [ixUnique];         // TIndexOptions 类型
  end;
  MyDbf.CreateTable;
finally
  MyDbf.Free;
end;
```

### 3.3 批量导入提速

```pascal
Dbf1.DisableControls;      // 断开界面联动，避免逐条重绘
Dbf1.BatchMode := True;    // 批量提交模式
Dbf1.Exclusive := True;    // 独占模式
try
  // 循环 Append + Post
finally
  Dbf1.Exclusive := False;
  Dbf1.BatchMode := False;
  Dbf1.EnableControls;
end;
```

### 3.4 主从汇总（DBF 无 JOIN）

外层遍历主表 + 内层 Filter 过滤从表累加（见示例工程 mainform.pas 思路）。

---

## 四、编译踩坑清单（实测 7 坑，均已解决）

| # | 现象 | 根因 | 解法 |
|---|---|---|---|
| 1 | `Can't find unit Interfaces` | lazbuild 未自动附加 LCL 路径（配置目录缺 packagefiles.xml） | 工程 .lpi 的 OtherUnitFiles 显式加 LCL 单元目录 |
| 2 | `Can't find unit LazUTF8` | lazutils 包路径未加 | 加 `components\lazutils\lib\$(CPU)-$(OS)` |
| 3 | `Can't find unit InterfaceBase` | 缺 LCL 基础单元目录（interfacebase 在 `lcl\units\...\` 根，非 win32 子目录） | 加 `lcl\units\$(CPU)-$(OS)` |
| 4 | `Can't find unit DbfFields` | ① fcl-db 路径未加；② 单元名写错（下划线敏感） | 加 fcl-db 路径；uses 用 `dbf_fields` |
| 5 | `Duplicate identifier "mainform"` | 单元名与全局变量重名 | 全局变量改名（如 frmMain） |
| 6 | `Wrong number of parameters for Add` | 文章 A 的 `IndexDefs.Add(name,field,opts)` 是简化写法 | 用 `with IndexDefs.Add do ...` 属性赋值 |
| 7 | `Can't open resource file *.res` | .lpr 的 `{$R *.res}` 引用不存在的主资源文件 | 最小验证工程移除 `{$R *.res}` |

## 五、龙芯编译要点

| 配置 | MIPS64（3A4000 老架构） | LoongArch64（3A5000/6000） |
|---|---|---|
| 目标 CPU | mips64el | loongarch64 |
| 附加参数 | `-CpMIPS64R2` | — |
| 优化 | **关闭 `-O-`**（龙芯开优化反而慢） | 同上，实测反直觉 |
| 链接 | 静态 `-X9` | 静态 |
| IDE | **装不了，必须 x86 交叉编译** | 同上 |

LoongArch64 构建两法：
1. **fpcupdeluxe** 图形化：Cross 标签页选 loongarch64-linux 一键安装；
2. **源码手工**：下载 FPC 源码 → 龙芯社区引导编译器 `ppcloongarch64` → 改 `compiler/loongarch64/agcpugas.pas` 的 `'lp64d'`→`'lp64'` → 编译生成 `ppcrossloongarch64`。

构建后需注册到 `fpcdefines.xml`（对应目标的 RealCompiler 指向交叉编译器路径），否则 IDE 提示 `does not support target loongarch64-linux`。

## 六、跨平台代码书写规范

- 路径分隔符用 `PathDelim` / `IncludeTrailingPathDelimiter()`，不写死 `\` 或 `/`
- 外部命令用跨平台 `TProcess`，不直接调 `dir`/`ls`
- Linux 保存文件后显式 `Chmod`（权限问题）
- Linux 界面字体偏小：`Screen.SystemFont.Size := 12`
- 高 DPI：工程 .lpr 加 `Application.Scaled := True`
- DBF 字段名不能以数字开头、对特殊字符敏感 → Excel 表头必须清洗
