unit mainform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, DB,
  StdCtrls, dbf;

type

  { TMainForm }

  TMainForm = class(TForm)
    Dbf1: TDbf;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    btnCreate: TButton;
    btnAdd: TButton;
    btnOpen: TButton;
    btnClose: TButton;
    procedure btnCreateClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    procedure EnsureDataDir;
  public
  end;

var
  frmMain: TMainForm;

implementation

{$R *.lfm}

{ 确保数据目录存在，使用跨平台路径分隔符 }
procedure TMainForm.EnsureDataDir;
var
  Dir: string;
begin
  Dir := ExtractFilePath(Application.ExeName) + 'Data';
  if not DirectoryExists(Dir) then
    CreateDir(Dir);
  Dbf1.FilePath := Dir;
end;

{ 动态创建 DBF 表（FoxPro 级别，TableLevel=25） }
procedure TMainForm.btnCreateClick(Sender: TObject);
var
  MyDbf: TDbf;
begin
  EnsureDataDir;
  MyDbf := TDbf.Create(nil);
  try
    MyDbf.FilePath   := ExtractFilePath(Application.ExeName) + 'Data';
    MyDbf.TableName  := 'supplier.dbf';
    MyDbf.TableLevel := 25;              // FoxPro 级别，ftAutoInc 等支持最好
    MyDbf.FieldDefs.Clear;
    with MyDbf.FieldDefs do
    begin
      Add('SupplierID', ftAutoInc, 0,   True);   // 自增编号，主键
      Add('Name',       ftString,  100, False);  // 供应商名称
      Add('Contact',    ftString,  50,  False);  // 联系人
      Add('Credit',     ftFloat,   0,   False);  // 信用额度
    end;
    MyDbf.IndexDefs.Clear;
    with MyDbf.IndexDefs.Add do
    begin
      IndexFile := 'IdxName';           // 索引文件名
      SortField := 'Name';              // 被索引字段
      Options   := [ixUnique];          // 唯一索引
    end;
    MyDbf.CreateTable;
    ShowMessage('供应商表 supplier.dbf 创建成功！');
  finally
    MyDbf.Free;
  end;
end;

{ 打开表并绑定到网格 }
procedure TMainForm.btnOpenClick(Sender: TObject);
begin
  EnsureDataDir;
  Dbf1.TableName  := 'supplier.dbf';
  Dbf1.TableLevel := 25;
  Dbf1.Active     := True;
  DataSource1.DataSet := Dbf1;
  DBGrid1.DataSource  := DataSource1;
  ShowMessage('表已打开，共 ' + IntToStr(Dbf1.RecordCount) + ' 条记录。');
end;

{ 关闭表 }
procedure TMainForm.btnCloseClick(Sender: TObject);
begin
  Dbf1.Active := False;
  ShowMessage('表已关闭。');
end;

{ 追加一条示例记录（演示批量提速的 DisableControls 用法） }
procedure TMainForm.btnAddClick(Sender: TObject);
var
  i: Integer;
begin
  if not Dbf1.Active then
    btnOpenClick(nil);

  Dbf1.DisableControls;                  // 断开界面联动，批量提速关键
  try
    for i := 1 to 5 do
    begin
      Dbf1.Append;
      Dbf1.FieldByName('Name').AsString    := Format('供应商%02d', [i]);
      Dbf1.FieldByName('Contact').AsString := Format('联系人%02d', [i]);
      Dbf1.FieldByName('Credit').AsFloat   := 10000 + i * 100;
      Dbf1.Post;
    end;
  finally
    Dbf1.EnableControls;
  end;
  ShowMessage('已追加 5 条示例记录。');
end;

end.
