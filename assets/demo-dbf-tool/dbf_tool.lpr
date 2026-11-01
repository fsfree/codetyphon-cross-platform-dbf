program dbf_tool;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, mainform;

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;          // 高 DPI 适配（跨平台，尤其国产 OS）
  Application.Initialize;
  {$IFDEF LINUX}
  Screen.SystemFont.Size := 12;        // Linux 下默认字体偏小，全局放大
  {$ENDIF}
  Application.Title := 'DBF数据处理工具';
  Application.CreateForm(TMainForm, frmMain);
  Application.Run;
end.
