
unit Unit1neu;

interface

uses
  System.SysUtils, System.Classes, JS, Web, WEBLib.Graphics, WEBLib.Controls,
  WEBLib.Forms, WEBLib.Dialogs, Vcl.Controls, WEBLib.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.StdCtrls, WEBLib.StdCtrls, WEBLib.JSON, Types,
  Vcl.Grids, WEBLib.Grids;

type
  TTeam = record
    Name: string;
    Points, GoalsFor, GoalsAgainst, Played: Integer;
  end;

type
  TForm1 = class(TWebForm)
    // Neue ScrollBox-Struktur
    ScrollBox_Startseite: TWebScrollBox;
    ScrollBox_Hauptanwend: TWebScrollBox;
    
    // Bestehende Panels werden zu Children der ScrollBoxen
    pnlStartseite: TWebPanel;
    plnHauptanwend: TWebPanel;
    
    // Alle anderen Komponenten bleiben gleich
    WebImageControl1: TWebImageControl;
    WebButton1: TWebButton;
    WebButton2: TWebButton;
    WebLabel1: TWebLabel;
    WebLabel2: TWebLabel;
    WebPanel1: TWebPanel;
    WebButton3: TWebButton;
    edtTeamName: TWebEdit;
    cmbTeam1: TWebComboBox;
    cmbTeam2: TWebComboBox;
    gridTable: TWebStringGrid;
    edtGoals1: TWebEdit;
    edtGoals2: TWebEdit;
    btnAddTeam: TWebButton;
    btnAddResult: TWebButton;
    WebLabel3: TWebLabel;
    WebLabel4: TWebLabel;
    laden: TWebButton;
    speichern: TWebButton;
    gridResults: TWebStringGrid;
    
    procedure WebFormCreate(Sender: TObject);
    procedure WebButton1Click(Sender: TObject);
    procedure WebButton2Click(Sender: TObject);
    procedure WebButton3Click(Sender: TObject);
    procedure WebButton4Click(Sender: TObject);
    procedure btnAddTeamClick(Sender: TObject);
    procedure btnAddResultClick(Sender: TObject);
    procedure ladenClick(Sender: TObject);
    procedure speichernClick(Sender: TObject);
    procedure WebFormResize(Sender: TObject);
  private
    { Private-Deklarationen }
    FTeams: array[0..5] of TTeam;
    FTeamCount: Integer;
    procedure InitStartseite;
    procedure InitHauptanwend;
    procedure SetBoxShadow;
    procedure InitializeTable;
    procedure InitializeResultsGrid;
    procedure UpdateTeamList;
    procedure UpdateTable;
    procedure InitScrollBoxes;  // Neue Procedure
    procedure AddMatchResult(const HomeTeam, AwayTeam: string; HomeGoals, AwayGoals: Integer);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// Neue Procedure für ScrollBox-Initialisierung
procedure TForm1.InitScrollBoxes;
begin
  // ScrollBox für Startseite
  ScrollBox_Startseite.Align := alClient;
  ScrollBox_Startseite.Visible := True;
  //ScrollBox_Startseite.HorzScrollBar.Visible := True;
 // ScrollBox_Startseite.VertScrollBar.Visible := False;
  ScrollBox_Startseite.ElementHandle.style.setProperty('overflow-x', 'auto');
  ScrollBox_Startseite.ElementHandle.style.setProperty('overflow-y', 'hidden');
  
  // ScrollBox für Hauptanwendung
  ScrollBox_Hauptanwend.Align := alClient;
  ScrollBox_Hauptanwend.Visible := False;
  //ScrollBox_Hauptanwend.HorzScrollBar.Visible := True;
  //ScrollBox_Hauptanwend.VertScrollBar.Visible := False;
  ScrollBox_Hauptanwend.ElementHandle.style.setProperty('overflow-x', 'auto');
  ScrollBox_Hauptanwend.ElementHandle.style.setProperty('overflow-y', 'hidden');
  
  // Panel Startseite: Feste Größe, nicht alClient
  pnlStartseite.Parent := ScrollBox_Startseite;
  pnlStartseite.Align := alNone;
  pnlStartseite.Width := 458;  // Ihre gewünschte Breite
  pnlStartseite.Height := 610; // Ihre gewünschte Höhe
  pnlStartseite.Left := 0;
  pnlStartseite.Top := 0;
  
  // Panel Hauptanwendung: Feste Größe, nicht alClient
  plnHauptanwend.Parent := ScrollBox_Hauptanwend;
  plnHauptanwend.Align := alNone;
  plnHauptanwend.Width := 800;  // Breite für Ihre Tabelle
  plnHauptanwend.Height := 600; // Höhe für Ihre Tabelle
  plnHauptanwend.Left := 0;
  plnHauptanwend.Top := 0;
end;

// ==============================================
procedure TForm1.WebButton1Click(Sender: TObject);
begin
  // zur Anwendung - jetzt mit ScrollBoxen
  ScrollBox_Startseite.Visible := False;
  ScrollBox_Hauptanwend.Visible := True;
  
  InitHauptanwend;
  SetBoxShadow;
end;

// ===============================================
procedure TForm1.WebButton2Click(Sender: TObject);
begin
  // zurueck zur Startseite - jetzt mit ScrollBoxen
  ScrollBox_Hauptanwend.Visible := False;
  ScrollBox_Startseite.Visible := True;
  
  InitStartseite;
  pnlStartseite.Color := clGreen;
end;

// ==============================
procedure TForm1.SetBoxShadow;
var
  styleElement: TJSHTMLElement;
  cssText: string;
begin
  styleElement := TJSHTMLElement(document.createElement('style'));
  cssText := 'body { box-shadow: 0 20px 33px rgba(0, 0, 0, 0.8) !important; }';
  styleElement.innerHTML := cssText;
  document.head.appendChild(styleElement);
end;

// =============================================
procedure TForm1.speichernClick(Sender: TObject);
var
  TeamData: TJSONArray;
  TeamObj: TJSONObject;
  i: Integer;
begin
  // Inhalt abspeichern
  TeamData := TJSONArray.Create;
  try
    // Alle Teams in JSON-Array konvertieren
    for i := 0 to FTeamCount - 1 do
    begin
      TeamObj := TJSONObject.Create;
      TeamObj.AddPair('name', FTeams[i].Name);
      TeamObj.AddPair('points', TJSONNumber.Create(FTeams[i].Points));
      TeamObj.AddPair('goalsFor', TJSONNumber.Create(FTeams[i].GoalsFor));
      TeamObj.AddPair('goalsAgainst', TJSONNumber.Create(FTeams[i].GoalsAgainst));
      TeamObj.AddPair('played', TJSONNumber.Create(FTeams[i].Played));
      TeamData.Add(TeamObj);
    end;

    // In localStorage speichern
    window.localStorage.setItem('tournamentData', TeamData.ToString);
    ShowMessage('Turnierdaten wurden gespeichert');
  finally
    TeamData.Free;
  end;
end;

// ================================================
procedure TForm1.WebButton3Click(Sender: TObject);
begin
  // hier soll Gruppe B
end;

// ================================================
procedure TForm1.WebButton4Click(Sender: TObject);
begin
  // TesTButton
end;

// ============================================
procedure TForm1.WebFormCreate(Sender: TObject);
begin
  // Zuerst ScrollBoxen initialisieren
  InitScrollBoxes;
  
  // Dann restliche Initialisierung
  FTeamCount := 0;
  InitializeTable;
  InitializeResultsGrid;

  // Initialisiere Eingabefelder
  edtTeamName.Text := 'Mannschaften';
  edtGoals1.Text := '1';
  edtGoals2.Text := '2';
  edtGoals1.ElementHandle.style.setProperty('text-align', 'center');
  edtGoals2.ElementHandle.style.setProperty('text-align', 'center');

  // Formatiere ComboBoxen
  cmbTeam1.Font.Size := 15;
  cmbTeam2.Font.Size := 15;
  cmbTeam1.Height := 38;
  cmbTeam2.Height := 38;
  cmbTeam1.ElementHandle.style.setProperty('padding', '4px');
  cmbTeam2.ElementHandle.style.setProperty('padding', '4px');

  // Formular-Styling (bleibt gleich)
  Self.ElementHandle.style.setProperty('position', 'absolute');
  Self.ElementHandle.style.setProperty('left', '50%');
  Self.ElementHandle.style.setProperty('top', '50%');
  Self.ElementHandle.style.setProperty('transform', 'translate(-50%, -50%)');
  Self.ElementHandle.style.setProperty('min-width', '460px');
  Self.ElementHandle.style.setProperty('max-width', '510px');
  Self.ElementHandle.style.setProperty('min-height', '540px');
  Self.ElementHandle.style.setProperty('max-height', '590px');
  Self.ElementHandle.style.setProperty('border', '3px solid #333333');
  Self.ElementHandle.style.setProperty('border-radius', '12px');
end;

// ================================================
procedure TForm1.WebFormResize(Sender: TObject);
begin
  // WebFormResize vereinfacht - ScrollBox übernimmt das Scrolling
  console.log('in Funktion: WebFormResize');
  
  // Für sehr kleine Bildschirme können Sie optional das Formular anpassen
  if window.innerWidth < 480 then
  begin
    Self.ElementHandle.style.setProperty('min-width', '320px');
    Self.ElementHandle.style.setProperty('max-width', '100%');
  end
  else
  begin
    Self.ElementHandle.style.setProperty('min-width', '460px');
    Self.ElementHandle.style.setProperty('max-width', '510px');
  end;
end;

// ==================================================================
procedure TForm1.InitStartseite;
begin
  // Formular-Styling für Startseite
  Self.ElementHandle.style.setProperty('position', 'absolute');
  Self.ElementHandle.style.setProperty('left', '50%');
  Self.ElementHandle.style.setProperty('top', '50%');
  Self.ElementHandle.style.setProperty('transform', 'translate(-50%, -60%)');
  Self.ElementHandle.style.setProperty('min-width', '460px');
  Self.ElementHandle.style.setProperty('max-width', '510px');
  Self.ElementHandle.style.setProperty('min-height', '540px');
  Self.ElementHandle.style.setProperty('max-height', '590px');
  Self.ElementHandle.style.setProperty('border', '1px solid #ffffff');
  Self.ElementHandle.style.setProperty('border-radius', '4px');
end;

// ==========================================
procedure TForm1.ladenClick(Sender: TObject);
var
  StoredData: string;
  TeamData: TJSONArray;
  TeamObj: TJSONObject;
  i: Integer;
begin
  // Laden (bleibt unverändert)
  StoredData := window.localStorage.getItem('tournamentData');
  if StoredData = '' then
  begin
    ShowMessage('Keine gespeicherten Daten gefunden');
    Exit;
  end;

  try
    TeamData := TJSONObject.ParseJSONValue(StoredData) as TJSONArray;
    if not Assigned(TeamData) then Exit;

    try
      FTeamCount := 0;
      for i := 0 to TeamData.Count - 1 do
      begin
        TeamObj := TeamData.Items[i] as TJSONObject;
        FTeams[i].Name := TeamObj.GetValue('name').Value;
        FTeams[i].Points := (TeamObj.GetValue('points') as TJSONNumber).AsInt;
        FTeams[i].GoalsFor := (TeamObj.GetValue('goalsFor') as TJSONNumber).AsInt;
        FTeams[i].GoalsAgainst := (TeamObj.GetValue('goalsAgainst') as TJSONNumber).AsInt;
        FTeams[i].Played := (TeamObj.GetValue('played') as TJSONNumber).AsInt;
        Inc(FTeamCount);
      end;

      UpdateTeamList;
      UpdateTable;

      if FTeamCount >= 2 then
      begin
        cmbTeam1.Enabled := True;
        cmbTeam2.Enabled := True;
        edtGoals1.Enabled := True;
        edtGoals2.Enabled := True;
        btnAddResult.Enabled := True;
      end;

      ShowMessage('Turnierdaten wurden geladen');
    finally
      TeamData.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Fehler beim Laden der Daten: ' + E.Message);
  end;
end;

// =====================================================
procedure TForm1.btnAddResultClick(Sender: TObject);
var
  idx1, idx2, g1, g2: Integer;
begin
  // Prüfe Teamauswahl
  if (cmbTeam1.ItemIndex < 0) or (cmbTeam2.ItemIndex < 0) then
    Exit;

  if cmbTeam1.ItemIndex = cmbTeam2.ItemIndex then
    Exit;

  // Prüfe Toreingabe
  if not TryStrToInt(edtGoals1.Text, g1) or not TryStrToInt(edtGoals2.Text, g2) then
    Exit;

  idx1 := cmbTeam1.ItemIndex;
  idx2 := cmbTeam2.ItemIndex;

  // Tore eintragen
  Inc(FTeams[idx1].GoalsFor, g1);
  Inc(FTeams[idx1].GoalsAgainst, g2);
  Inc(FTeams[idx2].GoalsFor, g2);
  Inc(FTeams[idx2].GoalsAgainst, g1);

  // Punkte vergeben
  if g1 > g2 then
    Inc(FTeams[idx1].Points, 3)
  else if g1 < g2 then
    Inc(FTeams[idx2].Points, 3)
  else
  begin
    Inc(FTeams[idx1].Points);
    Inc(FTeams[idx2].Points);
  end;

  // Spiele zählen
  Inc(FTeams[idx1].Played);
  Inc(FTeams[idx2].Played);

  // Ergebnis zur Liste hinzufügen
  AddMatchResult(cmbTeam1.Text, cmbTeam2.Text, g1, g2);

  // UI zurücksetzen
  cmbTeam1.ItemIndex := -1;
  cmbTeam2.ItemIndex := -1;
  edtGoals1.Text := '0';
  edtGoals2.Text := '0';

  UpdateTable;
end;

// ================================================================
procedure TForm1.AddMatchResult(const HomeTeam, AwayTeam: string; HomeGoals, AwayGoals: Integer);
var
  RowIndex: Integer;
begin
  RowIndex := gridResults.RowCount;
  gridResults.RowCount := RowIndex + 1;
  gridResults.Cells[0, RowIndex] := '  ' + HomeTeam;
  gridResults.Cells[1, RowIndex] := Format('  %d:%d  ', [HomeGoals, AwayGoals]);
  gridResults.Cells[2, RowIndex] := '  ' + AwayTeam;
end;

// ==============================================
procedure TForm1.btnAddTeamClick(Sender: TObject);
var
  i: Integer;
begin
  if (FTeamCount >= 6) then
    Exit;

  if Trim(edtTeamName.Text) = '' then
    Exit;

  // Prüfe ob Team bereits existiert
  for i := 0 to FTeamCount - 1 do
    if CompareText(FTeams[i].Name, edtTeamName.Text) = 0 then
      Exit;

  // Füge neues Team hinzu
  FTeams[FTeamCount].Name := edtTeamName.Text;
  FTeams[FTeamCount].Points := 0;
  FTeams[FTeamCount].GoalsFor := 0;
  FTeams[FTeamCount].GoalsAgainst := 0;
  FTeams[FTeamCount].Played := 0;
  Inc(FTeamCount);

  // Aktualisiere UI
  edtTeamName.Text := '';
  UpdateTeamList;
  UpdateTable;

  // Aktiviere Ergebniseingabe wenn mind. 2 Teams vorhanden
  if FTeamCount >= 2 then
  begin
    cmbTeam1.Enabled := True;
    cmbTeam2.Enabled := True;
    edtGoals1.Enabled := True;
    edtGoals2.Enabled := True;
  end;
end;

// ===================================
procedure TForm1.UpdateTeamList;
var
  i: Integer;
begin
  cmbTeam1.Items.Clear;
  cmbTeam2.Items.Clear;
  for i := 0 to FTeamCount - 1 do
  begin
    cmbTeam1.Items.Add(FTeams[i].Name);
    cmbTeam2.Items.Add(FTeams[i].Name);
  end;
end;

// =====================================
procedure TForm1.InitHauptanwend;
begin
  // Formular-Styling für Hauptanwendung
  Self.ElementHandle.style.setProperty('position', 'absolute');
  Self.ElementHandle.style.setProperty('left', '50%');
  Self.ElementHandle.style.setProperty('top', '50%');
  Self.ElementHandle.style.setProperty('transform', 'translate(-50%, -50%)');
  Self.ElementHandle.style.setProperty('min-width', '408px');
  Self.ElementHandle.style.setProperty('max-width', '418px');
  Self.ElementHandle.style.setProperty('min-height', '540px');
  Self.ElementHandle.style.setProperty('max-height', '590px');
  Self.ElementHandle.style.setProperty('border', '3px solid #333333');
  Self.ElementHandle.style.setProperty('border-radius', '12px');
end;

// ====================================
procedure TForm1.InitializeResultsGrid;
begin
  gridResults.ColWidths[0] := 112;
  gridResults.ColWidths[1] := 29;
  gridResults.ColWidths[2] := 113;
end;

// ===============================
procedure TForm1.InitializeTable;
begin
  gridTable.ColCount := 6;
  gridTable.DefaultColWidth := 60;
  gridTable.DefaultRowHeight := 30;

  // Spaltenbreiten
  gridTable.ColWidths[0] := 150;
  gridTable.ColWidths[1] := 40;
  gridTable.ColWidths[2] := 60;
  gridTable.ColWidths[3] := 40;
  gridTable.ColWidths[4] := 40;
  gridTable.ColWidths[5] := 30;

  // Überschriften
  gridTable.Cells[0, 0] := '(Vereine)';
  gridTable.Cells[1, 0] := 'Sp.';
  gridTable.Cells[2, 0] := 'Tore';
  gridTable.Cells[3, 0] := 'Dif.';
  gridTable.Cells[4, 0] := 'Pkt.';
  gridTable.Cells[5, 0] := 'Pl.';

  // Formatierung
  gridTable.Color := clWhite;
  gridTable.FixedColor := RGB(240,240,240);
  gridTable.Font.Name := 'Segoe UI';
  gridTable.Font.Size := 12;
  gridTable.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect];
  gridTable.RowHeights[0] := 25;
  gridTable.ElementHandle.style.setProperty('text-align', 'center');
end;

// ============================
procedure TForm1.UpdateTable;
var
  i: Integer;
  SortedTeams: TArray<TTeam>;
  Diff: Integer;
  procedure SortTeams;
  var
    i, j: Integer;
    temp: TTeam;
  begin
    for i := Low(SortedTeams) to High(SortedTeams) - 1 do
      for j := i + 1 to High(SortedTeams) do
        if (SortedTeams[j].Points > SortedTeams[i].Points) or
           ((SortedTeams[j].Points = SortedTeams[i].Points) and
            ((SortedTeams[j].GoalsFor - SortedTeams[j].GoalsAgainst) >
             (SortedTeams[i].GoalsFor - SortedTeams[i].GoalsAgainst))) then
        begin
          temp := SortedTeams[i];
          SortedTeams[i] := SortedTeams[j];
          SortedTeams[j] := temp;
        end;
  end;

begin
  if FTeamCount = 0 then
  begin
    gridTable.RowCount := 1;
    Exit;
  end;

  SetLength(SortedTeams, FTeamCount);
  for i := 0 to FTeamCount - 1 do
    SortedTeams[i] := FTeams[i];
  SortTeams;

  gridTable.RowCount := FTeamCount + 1;
  for i := 0 to FTeamCount - 1 do
  begin
    Diff := SortedTeams[i].GoalsFor - SortedTeams[i].GoalsAgainst;
    gridTable.Cells[0, i + 1] := SortedTeams[i].Name;
    gridTable.Cells[1, i + 1] := IntToStr(SortedTeams[i].Played);
    gridTable.Cells[2, i + 1] := Format('%d:%d', [SortedTeams[i].GoalsFor, SortedTeams[i].GoalsAgainst]);
    gridTable.Cells[3, i + 1] := IntToStr(Diff);
    gridTable.Cells[4, i + 1] := IntToStr(SortedTeams[i].Points);
    gridTable.Cells[5, i + 1] := IntToStr(i + 1);
  end;
end;

end.