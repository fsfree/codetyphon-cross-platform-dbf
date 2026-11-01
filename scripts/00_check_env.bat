@echo off
rem ============================================================================
rem  00_check_env.bat  跨平台开发环境自检脚本
rem  ---------------------------------------------------------------------------
rem  用途：探测本机 CodeTyphon / Lazarus / FPC 安装情况、版本与已就绪的
rem        交叉编译目标，为后续脚本和文档提供事实依据。
rem  说明：本脚本只读、不改动任何文件。
rem  用法：双击运行，或在命令行执行 00_check_env.bat
rem ============================================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
echo.
echo  ============================================================
echo   跨平台开发环境自检
echo  ============================================================
echo.

rem ---------- 1. 默认安装路径（可按实际修改） -------------------------------
set "CT_DIR=C:\codetyphon"
set "LAZ_DIR=D:\lazarus"

echo  [1] 探测 CodeTyphon
if exist "%CT_DIR%\setup.bat" (
    echo      [OK] 找到 CodeTyphon : %CT_DIR%
    for /f "delims=" %%v in ('findstr /i "GENERATION" "%CT_DIR%\changeslog.txt" 2^>nul ^| findstr /i "GENERATION"') do echo      %%~v
) else (
    echo      [!!] 未找到 CodeTyphon，请确认路径 %CT_DIR%
)

echo.
echo  [2] 探测 Lazarus
if exist "%LAZ_DIR%\lazarus.exe" (
    echo      [OK] 找到 Lazarus  : %LAZ_DIR%
) else (
    echo      [!!] 未找到 Lazarus，请确认路径 %LAZ_DIR%
)

echo.
echo  [3] 探测 FPC 编译器
set "FPC_EXE=%LAZ_DIR%\fpc\3.2.2\bin\x86_64-win64\fpc.exe"
if exist "%FPC_EXE%" (
    echo      [OK] 找到 FPC      : %FPC_EXE%
    "%FPC_EXE%" -iV 2>nul
    echo      --------------------
    echo      版本信息:
    "%FPC_EXE%" -iV 2>nul
) else (
    echo      [!!] 未找到 fpc.exe，请确认 FPC 版本目录
)

echo.
echo  [4] 探测 Lazarus 关键组件（TDbf / FPSpreadsheet）
if exist "%LAZ_DIR%\components\tdbf\dbflaz.lpk" (
    echo      [OK] TDbf 组件存在（DBF 数据库核心）
) else (
    echo      [!!] 缺少 TDbf 组件
)
if exist "%LAZ_DIR%\components\fpspreadsheet" (
    echo      [OK] FPSpreadsheet 组件存在（Excel 读写）
) else (
    echo      [--] 未找到 fpspreadsheet 目录（请确认已安装该包）
)

echo.
echo  [5] CodeTyphon 已就绪的交叉编译目标（binCenter 目录）
if exist "%CT_DIR%\binCenter" (
    echo      以下是已解包、可直接使用的目标：
    for /d %%d in ("%CT_DIR%\binCenter\*") do echo         %%~nxd
) else (
    echo      [!!] 未找到 binCenter 目录
)

echo.
echo  [6] CodeTyphon FPC 基础目标（binBase 目录）
if exist "%CT_DIR%\binBase" (
    for /d %%d in ("%CT_DIR%\binBase\*") do echo         %%~nxd
) else (
    echo      [!!] 未找到 binBase 目录
)

echo.
echo  [7] 关键结论提示
echo      - ARM64（飞腾/鲲鹏）    : 依赖 binCenter 中 aarch64-linux-* 是否已下载
echo      - 龙芯 MIPS64（3A4000） : 需通过 CrossBuild 下载 mips64el 工具链
echo      - 龙芯 LoongArch64      : FPC 主分支已原生支持，需单独构建 ppcrossloongarch64
echo.
echo  [8] 组件包注册表检查（影响命令行编译）
set "PKG_XML=%APPDATA%\lazarus\packagefiles.xml"
if exist "D:\laz_conf\packagefiles.xml" (
    echo      [OK] D:\laz_conf\packagefiles.xml 存在，组件包已注册
) else (
    echo      [!!] 缺少 D:\laz_conf\packagefiles.xml
    echo           这是 Lazarus 首次启动时才生成的关键文件；
    echo           缺失会导致 lazbuild 无法自动附加 LCL/TDbf 等组件包路径。
    echo           解决：首次正常启动一次 Lazarus IDE 即可自动生成。
)
echo.
echo  ============================================================
echo   自检完成。请将上方输出回传，以便进一步配置。
echo  ============================================================
echo.
pause
endlocal
