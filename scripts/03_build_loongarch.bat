@echo off
rem ============================================================================
rem  03_build_loongarch.bat  龙芯 LoongArch64 交叉编译器构建指引
rem  ---------------------------------------------------------------------------
rem  背景：CodeTyphon 9.00 安装包未内置 LoongArch64 工具链；但 FPC 上游社区
rem        已正式合并 LoongArch64 支持（龙芯团队 13 个 commit、2 万余行代码）。
rem        因此需单独构建 ppcrossloongarch64 交叉编译器。
rem  本脚本：给出构建步骤指引 + 产物校验（不自动下载源码，需人工执行构建）。
rem ============================================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

echo.
echo  ============================================================
echo   龙芯 LoongArch64 交叉编译器构建指引
echo  ============================================================
echo.

echo  [背景]
echo   - LoongArch64 已获 FPC 上游主分支原生支持（compiler + rtl 两部分）。
echo   - 交叉编译器命名：ppcrossloongarch64.exe（Windows 宿主）。
echo   - 适用于龙芯 3A5000 / 3A6000（新架构）。
echo.

echo  ----------------------------------------------------------------------------
echo  方法一（推荐）：fpcupdeluxe 图形化工具
echo  ----------------------------------------------------------------------------
echo   1. 下载 fpcupdeluxe（支持指定 FPC/Lazarus 版本与交叉目标）；
echo   2. 在 Cross 标签页选择 loongarch64-linux，点击安装；
echo   3. 完成后在 fpc\bin\ 下生成 ppcrossloongarch64.exe。
echo.

echo  ----------------------------------------------------------------------------
echo  方法二（进阶）：源码手工构建
echo  ----------------------------------------------------------------------------
echo   1. 下载 FPC 源码：https://gitlab.com/freepascal.org/fpc/source
echo   2. 获取 loongarch64 引导编译器 ppcloongarch64（龙芯社区提供）；
echo   3. 修改 compiler/loongarch64/agcpugas.pas 中 'lp64d' 改为 'lp64'；
echo   4. 编译生成 ppcrossloongarch64；
echo   5. 将产物放入 FPC bin 目录并注册到 Lazarus 的 fpcdefines.xml。
echo   （详见配套文档 docs/配置指南.md 的"龙芯 LoongArch64"章节）
echo.

echo  ----------------------------------------------------------------------------
echo  构建产物校验（脚本自动执行）
echo  ----------------------------------------------------------------------------
set "FPC_BIN=%LAZ_DIR%\fpc\3.2.2\bin\x86_64-win64"
set "LAZ_DIR=D:\lazarus"
echo  在以下位置查找交叉编译器：
echo   - %LAZ_DIR%\fpc\3.2.2\bin\x86_64-win64\
echo   - C:\codetyphon\binCenter\（若已下载）
echo.
echo  [检查 ppcrossloongarch64]
where /r "%LAZ_DIR%\fpc" ppcrossloongarch64.exe 2>nul
if %errorlevel%==0 (
    echo      [OK] 已找到 ppcrossloongarch64.exe
) else (
    echo      [--] 尚未生成，请按上方方法一/方法二完成构建。
)

echo.
echo  [检查 ppcrossa64]（ARM64 参考，验证交叉编译器机制是否可用）
where /r "%LAZ_DIR%\fpc" ppcrossa64.exe 2>nul
if %errorlevel%==0 (
    echo      [OK] 已找到 ppcrossa64.exe
) else (
    echo      [--] 尚未生成 aarch64 交叉编译器，请先运行 01_build_targets.bat
)

echo.
echo  ============================================================
echo  提示：LoongArch64 构建完成后，用 02_switch_target.bat loongarch 验证编译。
echo  ============================================================
echo.
pause
endlocal
