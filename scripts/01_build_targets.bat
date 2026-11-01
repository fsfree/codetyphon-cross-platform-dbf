@echo off
rem ============================================================================
rem  01_build_targets.bat  交叉编译目标生成脚本（CodeTyphon 主流程）
rem  ---------------------------------------------------------------------------
rem  用途：指导/驱动 CodeTyphon 通过 CrossBuild 菜单下载并构建目标平台工具链。
rem  注意：CodeTyphon 的"下载工具链/库 + 构建 cross elements"主要依赖其 IDE 的
rem        CrossBuild 图形界面完成，本脚本负责：
rem        (1) 校验前置条件；(2) 输出每一步操作指引；(3) 构建完成后校验产物。
rem        真正的一键下载受 CodeTyphon 服务器与 GUI 限制，脚本无法完全替代。
rem  用法：双击运行，按提示操作。
rem ============================================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "CT_DIR=C:\codetyphon"
set "LAZ_DIR=D:\lazarus"

echo.
echo  ============================================================
echo   交叉编译目标生成 —— 操作指引
echo  ============================================================
echo.

rem ---------- 前置校验 -------------------------------------------------------
if not exist "%CT_DIR%\setup.bat" (
    echo  [错误] 未找到 CodeTyphon，路径 %CT_DIR%
    echo  请修改脚本顶部 CT_DIR 变量后重试。
    pause & exit /b 1
)

echo  [前置] CodeTyphon 已就绪。
echo.

echo  ----------------------------------------------------------------------------
echo  第一步：下载目标平台交叉工具链（CodeTyphon IDE 内操作）
echo  ----------------------------------------------------------------------------
echo   1. 以【管理员身份】运行 CodeTyphon Studio；
echo   2. 菜单：CrossBuild ^> Download Cross Toolchains；
echo   3. 勾选需要的目标（按你的国产化需求）：
echo        - aarch64-linux      （飞腾/鲲鹏 ARM64）
echo        - mips64el-linux     （龙芯 3A4000 老架构 MIPS64）
echo        - i386-linux         （32 位 Linux，可选）
echo        - x86_64-linux       （常规 64 位 Linux，可选）
echo   4. 点击 Download，等待下载解压完成（网络慢需耐心，勿中途关闭）。
echo.
echo  ----------------------------------------------------------------------------
echo  第二步：下载目标平台系统库（Oses Libraries）
echo  ----------------------------------------------------------------------------
echo   菜单：CrossBuild ^> Download Libraries，选择与第一步相同的目标下载。
echo   作用：提供目标平台的 C 运行库/头文件，供静态链接使用。
echo.
echo  ----------------------------------------------------------------------------
echo  第三步：构建 FPC cross elements（生成 ppcross 交叉编译器）
echo  ----------------------------------------------------------------------------
echo   菜单：CrossBuild ^> FreePascal 32bits / 64bits，选择对应目标构建。
echo   构建完成后，会在 FPC 的 bin 目录生成交叉编译器，例如：
echo        ppcrossa64.exe      （aarch64）
echo        ppcrossmips64.exe   （mips64el，若存在）
echo        ppcrossx64.exe      （x86_64）
echo.
echo  ----------------------------------------------------------------------------
echo  第四步（可选）：FixSymlinks（Linux 类目标必做，避免跨平台编译失败）
echo  ----------------------------------------------------------------------------
echo   开始菜单 ^> CodeTyphon ^> FixSymlinks，执行一次。
echo.
echo  ----------------------------------------------------------------------------
echo  构建产物校验（脚本自动执行）
echo  ----------------------------------------------------------------------------
echo  正在检查已生成的交叉编译器与库目录 ...

set "CT_BINL=%CT_DIR%\binLibraries"
echo.
echo  [库目录 binLibraries]
if exist "%CT_BINL%" (
    for /d %%d in ("%CT_BINL%\*") do echo      %%~nxd
) else (
    echo      （尚无库目录，说明第一步/第二步尚未完成）
)

echo.
echo  [binCenter 交叉目标]
if exist "%CT_DIR%\binCenter" (
    for /d %%d in ("%CT_DIR%\binCenter\*") do echo      %%~nxd
) else (
    echo      （无 binCenter）
)

echo.
echo  ============================================================
echo  提示：以上步骤完成后，请在 Lazarus IDE 中
echo        "工程选项 ^> 编译选项 ^> Config and Target" 切换目标，
echo        或使用 02_switch_target.bat 辅助设置编译目标。
echo  ============================================================
echo.
pause
endlocal
