program nonoproj;

{%ToDo 'nonoproj.todo'}

uses
  QForms,
  nongram in 'nongram.pas' {mainform};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.
