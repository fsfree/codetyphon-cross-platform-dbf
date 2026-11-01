@echo off
rem ============================================================================
rem  02_switch_target.bat  目标平台切换脚本
rem  ---------------------------------------------------------------------------
rem  用途：用 lazbuild 命令行切换目标 OS/CPU 并编译示例工程，便于脚本化验证。
rem  用法：02_switch_target.bat <目标> [工程.lpi 路径]
rem        目标可选：win64 / win32 / linux64 / linux32 / aarch64 / mips64 / loongarch
rem        缺省工程路径为 demo-dbf-tool 下的示例工程。
rem ============================================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

set "LAZ_DIR=D:\lazarus"
set "LAZBUILD=%LAZ_DIR%\lazbuild.exe"
set "SCRIPT_DIR=%~dp0"
set "DEMO_LPI=%SCRIPT_DIR%..\demo-dbf-tool\src\dbf_tool.lpi"

set "TARGET=%~1"
if "%TARGET%"=="" set "TARGET=win64"

rem ---------- 目标 → lazbuild 参数映射 ---------------------------------------
set "CPU="
set "OS="
if /i "%TARGET%"=="win64"    ( set "CPU=x86_64" & set "OS=win64" )
if /i "%TARGET%"=="win32"    ( set "CPU=i386"   & set "OS=win32" )
if /i "%TARGET%"=="linux64"  ( set "CPU=x86_64" & set "OS=linux" )
if /i "%TARGET%"=="linux32"  ( set "CPU=i386"   & set "OS=linux" )
if /i "%TARGET%"=="aarch64"  ( set "CPU=aarch64"& set "OS=linux" )
if /i "%TARGET%"=="mips64"   ( set "CPU=mips64el" & set "OS=linux" )
if /i "%TARGET%"=="loongarch" ( set "CPU=loongarch64" & set "OS=linux" )

if "%CPU%"=="" (
    echo  [错误] 未知目标 "%TARGET%"
    echo  支持目标：win64 win32 linux64 linux32 aarch64 mips64 loongarch
    exit /b 1
)

if not exist "%LAZBUILD%" (
    echo  [错误] 未找到 lazbuild.exe : %LAZBUILD%
    exit /b 1
)

echo.
echo  ============================================================
echo   切换并编译目标平台：%TARGET%  （CPU=%CPU% , OS=%OS%）
echo  ============================================================
echo.

rem ---------- 编译示例工程 ----------------------------------------------------
if exist "%DEMO_LPI%" (
    echo  [编译] 示例工程 %DEMO_LPI%
    echo  执行：lazbuild --cpu=%CPU% --os=%OS% "%DEMO_LPI%"
    echo.
    "%LAZBUILD%" --cpu=%CPU% --os=%OS% "%DEMO_LPI%"
    echo.
    echo  [结果] 退出码 %ERRORLEVEL%
    if "%ERRORLEVEL%"=="0" (
        echo  [成功] 目标 %TARGET% 编译通过。产物见 demo-dbf-tool\src\ 下对应目录。
    ) else (
        echo  [失败] 请确认该目标工具链已构建完成（先运行 01_build_targets.bat）。
    )
) else (
    echo  [提示] 未找到示例工程 %DEMO_LPI%
    echo  可传入第二个参数指定你自己的 .lpi 文件。
    if "%~2"=="" (
        echo  用法：02_switch_target.bat %TARGET% "D:\你的工程\xx.lpi"
    ) else (
        echo  [编译] 指定工程 %~2
        "%LAZBUILD%" --cpu=%CPU% --os=%OS% "%~2"
    )
)

echo.
pause
endlocal
