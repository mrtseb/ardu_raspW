unit main1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, JvCreateProcess, windows, lazUTF8, SynEdit;

type

  { TForm1 }

  TForm1 = class(TForm)
    JvCreateProcess1: TJvCreateProcess;
    JvCreateProcess2: TJvCreateProcess;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    Memo2: TMemo;
    mnuPortSelect: TMenuItem;
    mnuUploadHEX: TMenuItem;
    mnuCompile: TMenuItem;
    mnuCompileCore: TMenuItem;
    mnuExit: TMenuItem;
    mnuArduinotools: TMenuItem;
    mnuFichier: TMenuItem;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure JvCreateProcess1Read(Sender: TObject; const S: string;
      const StartsOnNewLine: Boolean);
    procedure JvCreateProcess1Terminate(Sender: TObject; ExitCode: DWORD);
    procedure JvCreateProcess2ErrorRawRead(Sender: TObject; const S: string);
    procedure JvCreateProcess2Read(Sender: TObject; const S: string;
      const StartsOnNewLine: Boolean);
    procedure Memo1Change(Sender: TObject);
    procedure mnuCompileClick(Sender: TObject);
    procedure mnuCompileCoreClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuPortSelectClick(Sender: TObject);
    procedure mnuUploadHEXClick(Sender: TObject);
    //procedure JvCreateProcess1Terminate(Sender: TObject; ExitCode: DWORD);
  private
    FPort:string;
    FListOfStrings:TstringList;
    procedure Split(Delimiter: Char; Str: string) ;
    procedure ChangeLastLine(const S: string);
    function FormatForDisplay(const S: string): string;
    //procedure JvCreateProcess1Read(Sender: TObject; const S: string;const StartsOnNewLine: Boolean);



  public
    constructor create(sender:Tobject) ;
    procedure AddNewLine(const S: string);
    procedure ClearScreen;
    procedure InitCommand(cmd:string);


  end;
const
  PREFIX='D:\lazarus3\stuff\Arduino\';
  AVR_CPP=PREFIX+'hardware\tools\avr\bin\avr-c++.exe';
  AVR_GCC=PREFIX+'hardware\tools\avr\bin\avr-gcc.exe';
var
  Form1: TForm1;

implementation
uses
  JclSysInfo, JclStrings, JvDSADialogs;

{$R *.lfm}

resourcestring
  sProcessTerminated = 'Process "%s" terminated, ExitCode: %.8x';
  sScript = '%s %s';

constructor TForm1.create(sender:Tobject) ;
  begin
   FListOfStrings:=Tstringlist.create;
end;
procedure TForm1.Split(Delimiter: Char; Str: string) ;
  begin
   FListOfStrings.Clear;
   FListOfStrings.Delimiter       := Delimiter;
   FListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   FListOfStrings.DelimitedText   := Str;
end;
procedure Tform1.InitCommand(cmd:string);
var CommandLine:string;
begin
  { Retrieve the command processor name }
  if not JclSysInfo.GetEnvironmentVar('COMSPEC', CommandLine) or (Length(CommandLine) = 0) then
    { Paranoid }
    CommandLine := 'COMMAND.EXE';
    //CommandLine:=cmd;

  JvCreateProcess1.CommandLine := CommandLine;
  { Redirect console output, we'll receive the output via the OnRead event }
  JvCreateProcess1.ConsoleOptions := JvCreateProcess1.ConsoleOptions + [coRedirect];
  { Hide the console window }
  JvCreateProcess1.StartupInfo.ShowWindow := swHide;
  JvCreateProcess1.StartupInfo.DefaultWindowState := False;
  { And start the console }
  JvCreateProcess1.Run;
  JvCreateProcess2.CommandLine := CommandLine;
  { Redirect console output, we'll receive the output via the OnRead event }
  JvCreateProcess2.ConsoleOptions := JvCreateProcess2.ConsoleOptions + [coRedirect];
  { Hide the console window }
  JvCreateProcess2.StartupInfo.ShowWindow := swHide;
  JvCreateProcess2.StartupInfo.DefaultWindowState := False;
  { And start the console }
  JvCreateProcess2.Run;
end;

function Tform1.FormatForDisplay(const S: string): string;
  begin
    Result := StrReplaceChar(S, #255, ' ');
  end;
procedure Tform1.ClearScreen;
begin
  memo1.Clear;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  form1.caption:= GetCurrentDir()+'\bat\makeCore.bat';

end;

procedure TForm1.Button2Click(Sender: TObject);
begin

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
     end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  memo2.clear;
  self.InitCommand('INIT');
  self.SynEdit1.Lines.LoadFromFile(getCurrentDir()+'/ino/default.ino');
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.JvCreateProcess1.WriteLn(ansistring('exit'));
   self.JvCreateProcess2.WriteLn(ansistring('exit'));
end;

procedure TForm1.JvCreateProcess1Read(Sender: TObject; const S: string;
  const StartsOnNewLine: Boolean);
begin
  // $0C is the Form Feed char.
  if S = #$C then
    ClearScreen
  else
  if StartsOnNewLine then
    AddNewLine(S)
  else
    ChangeLastLine(S);
end;

procedure TForm1.JvCreateProcess1Terminate(Sender: TObject; ExitCode: DWORD);
begin
  AddNewLine(Format(sProcessTerminated, [JvCreateProcess1.CommandLine, ExitCode]));
end;

procedure TForm1.JvCreateProcess2ErrorRawRead(Sender: TObject; const S: string);
begin

end;

procedure TForm1.JvCreateProcess2Read(Sender: TObject; const S: string;
  const StartsOnNewLine: Boolean);
var t:string;
begin

 if (pos('COM',s)>0) and (pos('Arduino',s)>0) then
   begin
     t:=trim(s);
     t:=copy(t,1,5);
     FPort:=(trim(t));
     memo2.lines.add(Fport);
   end;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.mnuCompileClick(Sender: TObject);
begin
 self.SynEdit1.Lines.SaveToFile('ino/default.ino');
 self.JvCreateProcess1.WriteLn(ansistring(GetCurrentDir()+'/bat/compilHEX.bat'));
end;

procedure TForm1.mnuCompileCoreClick(Sender: TObject);
begin
  self.JvCreateProcess1.WriteLn(ansistring(GetCurrentDir()+'/bat/makeCore.bat'));
end;

procedure TForm1.mnuExitClick(Sender: TObject);
begin
  self.close;
end;

procedure TForm1.mnuPortSelectClick(Sender: TObject);
begin
 memo2.clear;
 self.JvCreateProcess2.WriteLn(ansistring(GetCurrentDir()+'/tools/listComPorts.exe'));
end;

procedure TForm1.mnuUploadHEXClick(Sender: TObject);
begin
 if FPort<> '' then self.JvCreateProcess1.WriteLn(ansistring(Format(sScript, [GetCurrentDir()+'/bat/uploadHEX.bat', FPort])));

end;


procedure Tform1.ChangeLastLine(const S: string);
begin
  with memo1 do
  begin
    if lines.Count > 0 then
      Lines[lines.Count - 1] := FormatForDisplay(S)
    else
      AddNewLine(S);
    //ItemIndex := Count - 1;
  end;
end;

procedure Tform1.AddNewLine(const S: string);
begin
  with memo1 as Tmemo do
  begin
    Lines.Add(FormatForDisplay(S));
    //ItemIndex := Count - 1;
  end;
end;



end.

