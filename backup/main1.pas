unit main1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, JvCreateProcess, windows, lazUTF8, SynEdit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    JvCreateProcess1: TJvCreateProcess;
    Memo1: TMemo;
    Panel1: TPanel;
    SynEdit1: TSynEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure JvCreateProcess1Read(Sender: TObject; const S: string;
      const StartsOnNewLine: Boolean);
    procedure JvCreateProcess1Terminate(Sender: TObject; ExitCode: DWORD);
    //procedure JvCreateProcess1Terminate(Sender: TObject; ExitCode: DWORD);
  private
    procedure ChangeLastLine(const S: string);
    function FormatForDisplay(const S: string): string;
    //procedure JvCreateProcess1Read(Sender: TObject; const S: string;const StartsOnNewLine: Boolean);



  public
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
  self.JvCreateProcess1.WriteLn(ansistring('makeCore.bat'));
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
  self.InitCommand('INIT');
  self.SynEdit1.Lines.LoadFromFile(getCurrentDir()+'/ino/default.ino');
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  self.JvCreateProcess1.WriteLn(ansistring('exit'));
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

