unit Unit1;

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
    pnlStartseite: TWebPanel;
    plnHauptanwend: TWebPanel;
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
    ScrollBox_Startseite: TWebScrollBox;
    ScrollBox_Hauptanwend: TWebScrollBox;
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
    procedure  InitializeTable;
    procedure InitializeResultsGrid;
    procedure UpdateTeamList;
    procedure UpdateTable;
    procedure SetScrollForSmallScreens;
    procedure InitScrollBoxes;
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
  //ScrollBox_Startseite.VertScrollBar.Visible := False;
  ScrollBox_Startseite.ElementHandle.style.setProperty('overflow-x', 'auto');
  ScrollBox_Startseite.ElementHandle.style.setProperty('overflow-y', 'hidden');

  // ScrollBox für Hauptanwendung
  ScrollBox_Hauptanwend.Align := alClient;
  ScrollBox_Hauptanwend.Visible := False;
 // ScrollBox_Hauptanwend.HorzScrollBar.Visible := True;
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

procedure TForm1.WebButton1Click(Sender: TObject);
begin
 // zur Anwendung
 pnlStartseite.Visible := False;
 plnHauptanwend.Visible := True;
// plnHauptanwend.Color := clNone;
 InitHauptanwend;
// plnHauptanwend.ElementHandle.style.setProperty('max-width', '408px');
 SetBoxShadow;
end;



procedure TForm1.SetBoxShadow;
 var
   styleElement: TJSHTMLElement;
   cssText: string;
begin
 //console.log('in Funktion setShadow');
 {

 console.log('ElementTag ist: ' + Self.ElementHandle.tagName);
 Self.ElementHandle.style.setProperty('background-color', '#ffffff');
 Self.ElementHandle.style.setProperty('box-shadow', '0 20px 40px rgba(0,0,0,0.7)');

    shadowValue := Self.ElementHandle.style.getPropertyValue('box-shadow') ;
    console.log('gesetzter Wert: ' + shadowValue);
    }
  styleElement := TJSHTMLElement(document.createElement('style'));
  cssText := 'body { box-shadow: 0 20px 33px rgba(0, 0, 0, 0.8) !important; }';
  styleElement.innerHTML := cssText;
  document.head.appendChild(styleElement);

end;

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

procedure TForm1.WebButton2Click(Sender: TObject);
begin
  // zurueck zur Startseite
 pnlStartseite.Visible := True;
 plnHauptanwend.Visible := False;
 InitStartseite;
 pnlStartseite.Color := clGreen;
 pnlStartseite.ElementHandle.style.setProperty('max-width', '458px');
 //pnlStartseite.ElementHandle.style.setProperty('max-width', '418px');
  pnlStartseite.ElementHandle.style.setProperty('max-hight', '610px');
end;

procedure TForm1.WebButton3Click(Sender: TObject);
begin
  // hier soll Gruppe B
end;

procedure TForm1.WebButton4Click(Sender: TObject);
begin
   // TesButton
end;

procedure TForm1.WebFormCreate(Sender: TObject);
begin
 // erzeugen
 //InitStartseite;
// InitHauptanwend;
 FTeamCount := 0;
 InitializeTable;
 InitializeResultsGrid;
 SetScrollForSmallScreens;

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

 pnlStartseite.Visible := True;
 plnHauptanwend.Visible := False;
 //pnlStartseite.Color := clNone;
 plnHauptanwend.Color := clNone;
 //pnlStartseite.BevelOuter := bvNone;
  pnlStartseite.ElementHandle.style.setProperty('max-width', '458px');
 pnlStartseite.Align := alClient;
 plnHauptanwend.Align := alClient;

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

// Setze Formular-Eigenschaften
//Self.Width := 430;
//Self.Height := 500;
//Self.Color := RGB(255,255,255);

end;

procedure TForm1.WebFormResize(Sender: TObject);
var
  scaleFactor: Double;
begin
  // Skalieren
  console.log('in Funktion: WebFormResize');
  SetScrollForSmallScreens ;
  if window.innerWidth <768  then
  begin
    scaleFactor := window.innerWidth / 768;
    //plnHauptanwend.ElementHandle.style.setProperty('transform', 'scale(' + FloatToStr(scaleFactor) +')');
    //plnHauptanwend.ElementHandle.style.setProperty('transform-origin', ' 0 0');
    // plnHauptanwend.ElementHandle.style.setProperty('width', FloatToStr(100 / scaleFactor) + '%');
    // plnHauptanwend.ElementHandle.style.setProperty('height', FloatToStr(100 / scaleFactor) + '%');

  end;

end;

procedure TForm1.InitStartseite;
begin
 //ShowMessage('in proce Start');
  // Init Start
 //pnlStartseite.Color := clSilver;

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

procedure TForm1.ladenClick(Sender: TObject);
  var
  StoredData: string;
  TeamData: TJSONArray;
  TeamObj: TJSONObject;
  i: Integer;
begin
  // Laden
  StoredData := window.localStorage.getItem('tournamentData');
  if StoredData = '' then
  begin
    ShowMessage('Keine gespeicherten Daten gefunden');
    Exit;
  end;

  try
    // JSON parsen
    TeamData := TJSONObject.ParseJSONValue(StoredData) as TJSONArray;
    if not Assigned(TeamData) then Exit;

    try
      // Bestehende Daten löschen
      FTeamCount := 0;

      // Daten aus JSON laden
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

      // UI aktualisieren
      UpdateTeamList;
      UpdateTable;

      // Eingabefelder aktivieren wenn Teams vorhanden
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

procedure TForm1.btnAddResultClick(Sender: TObject);
 var
  idx1, idx2, g1, g2: Integer;
begin
  // Prüfe Teamauswahl
  if (cmbTeam1.ItemIndex < 0) or (cmbTeam2.ItemIndex < 0) then
  begin
   //asm alert('Bitte beide Teams auswählen'); end;
    Exit;
  end;

  if cmbTeam1.ItemIndex = cmbTeam2.ItemIndex then
  begin
   // asm alert('Bitte zwei verschiedene Teams auswählen'); end;
    Exit;
  end;

  // Prüfe Toreingabe
  if not TryStrToInt(edtGoals1.Text, g1) or not TryStrToInt(edtGoals2.Text, g2) then
  begin
   // asm alert('Bitte gültige Zahlen für Tore eingeben'); end;
    Exit;
  end;

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

 procedure TForm1.AddMatchResult(const HomeTeam, AwayTeam: string; HomeGoals, AwayGoals: Integer);
var
  RowIndex: Integer;
begin
  // Neue Zeile hinzufügen
  RowIndex := gridResults.RowCount;
  gridResults.RowCount := RowIndex + 1;

  // Ergebnis eintragen
  gridResults.Cells[0, RowIndex] := '  ' + HomeTeam;  // Einrückung durch Leerzeichen
  gridResults.Cells[1, RowIndex] := Format('  %d:%d  ', [HomeGoals, AwayGoals]);  // Leerzeichen
  gridResults.Cells[2, RowIndex] := '  ' + AwayTeam;  // Einrückung durch Leerzeichen
end;


procedure TForm1.btnAddTeamClick(Sender: TObject);
var
  i: Integer;
begin
  // Teams dazu
 if (FTeamCount >= 6) then
  begin
   // asm alert('Maximale Anzahl von Teams (6) erreicht'); end;
    Exit;
  end;

  if Trim(edtTeamName.Text) = '' then
  begin
   // asm alert('Bitte Teamnamen eingeben'); end;
    Exit;
  end;

  // Prüfe ob Team bereits existiert
  for i := 0 to FTeamCount - 1 do
    if CompareText(FTeams[i].Name, edtTeamName.Text) = 0 then
    begin
     // asm alert('Team existiert bereits'); end;
      Exit;
    end;

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
    //btnAddResult.Enabled := True;
  end;
end;
 // ===================================
procedure TForm1.UpdateTeamList;
var
  i: Integer;
begin
  // Aktualisiere Teamauswahl
  cmbTeam1.Items.Clear;
  cmbTeam2.Items.Clear;
  for i := 0 to FTeamCount - 1 do
  begin
    cmbTeam1.Items.Add(FTeams[i].Name);
    cmbTeam2.Items.Add(FTeams[i].Name);
  end;
end;
 // =====================================
procedure TForm1.InitHauptanwend ;
begin
  //ShowMessage('in proce Anwendung');
  //plnHauptanwend.Color := clBlue;
  // Init Anwendung
  Self.ElementHandle.style.setProperty('position', 'absolute');
Self.ElementHandle.style.setProperty('left', '50%');
Self.ElementHandle.style.setProperty('top', '50%');
Self.ElementHandle.style.setProperty('transform', 'translate(-50%, -50%)');
//Self.ElementHandle.style.setProperty('min-width', '460px');
//Self.ElementHandle.style.setProperty('max-width', '510px');

Self.ElementHandle.style.setProperty('min-width', '408px');
Self.ElementHandle.style.setProperty('max-width', '418px');

Self.ElementHandle.style.setProperty('min-height', '540px');
Self.ElementHandle.style.setProperty('max-height', '590px');

 Self.ElementHandle.style.setProperty('border', '3px solid #333333');
Self.ElementHandle.style.setProperty('border-radius', '12px');

end;


procedure TForm1.InitializeResultsGrid;
begin
  // Grundeinstellungen
  //gridResults.RowCount := 0;  // Keine Zeilen am Anfang
  //gridResults.ColCount := 3;  // Heim, Ergebnis, Gast
  //gridResults.DefaultRowHeight := 30;
  //gridResults.ScrollBars := ssVertical;
  //gridResults.FixedRows := 0;  // Kein Header

  // Spaltenbreiten
  gridResults.ColWidths[0] := 112;  // Heimmannschaft
  gridResults.ColWidths[1] := 29;   // Ergebnis (z.B. "2:1")
  gridResults.ColWidths[2] := 113;  // Gastmannschaft

  // Styling
  //gridResults.Color := clWhite;
  //gridResults.Font.Name := 'Segoe UI';
 // gridResults.Font.Size := 12;
 // gridResults.Options := [goVertLine, goHorzLine];  // Minimale Linien

  // Maximale Höhe (3 Zeilen)
  //gridResults.Height := (30 * 3) + 2;  // 3 Zeilen plus Border

  // Position unterhalb der Tabelle
  //gridResults.Top := gridTable.Top + gridTable.Height + 20;  // 20 Pixel Abstand
  //gridResults.Left := gridTable.Left;
  //gridResults.Width := gridTable.Width
end;


procedure TForm1.InitializeTable;
begin
 // Tabelle initialisieren
  gridTable.ColCount := 6;
  gridTable.DefaultColWidth := 60;
  gridTable.DefaultRowHeight := 30;    // Höhere Zeilen für bessere Lesbarkeit

  // Spaltenbreiten
  gridTable.ColWidths[0] := 150;      // Mannschaft
  gridTable.ColWidths[1] := 40;       // Spiele
  gridTable.ColWidths[2] := 60;       // Tore
  gridTable.ColWidths[3] := 40;       // Differenz
  gridTable.ColWidths[4] := 40;       // Punkte
  gridTable.ColWidths[5] := 30;       // Platz

  // Überschriften
  gridTable.Cells[0, 0] := '(Vereine)';
  gridTable.Cells[1, 0] := 'Sp.';
  gridTable.Cells[2, 0] := 'Tore';
  gridTable.Cells[3, 0] := 'Dif.';
  gridTable.Cells[4, 0] := 'Pkt.';
  gridTable.Cells[5, 0] := 'Pl.';

  // Formatierung
  gridTable.Color := clWhite;
  gridTable.FixedColor := RGB(240,240,240);  // Hellgrauer Header
  gridTable.Font.Name := 'Segoe UI';
  gridTable.Font.Size := 12;
  gridTable.Options := [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect];
  gridTable.RowHeights[0] := 25;  // Header etwas höher

  // Spalten zentrieren (außer Mannschaftsnamen) über CSS
  gridTable.ElementHandle.style.setProperty('text-align', 'center');
  // Erste Spalte (Mannschaftsnamen) linksbündig
  //for var row := 0 to gridTable.RowCount-1 do
  //begin
    //gridTable.ElementHandle.children[row].children[0].style.setProperty('text-align', 'left');
 // end;
 // SetBoxShadow;

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

  // Teams sortieren
  SetLength(SortedTeams, FTeamCount);
  for i := 0 to FTeamCount - 1 do
    SortedTeams[i] := FTeams[i];
  SortTeams;

  // Tabelle aktualisieren
  gridTable.RowCount := FTeamCount + 1;
  for i := 0 to FTeamCount - 1 do
  begin
     Diff := SortedTeams[i].GoalsFor - SortedTeams[i].GoalsAgainst;

    gridTable.Cells[0, i + 1] := SortedTeams[i].Name;
    gridTable.Cells[1, i + 1] := IntToStr(SortedTeams[i].Played);
    gridTable.Cells[2, i + 1] := Format('%d:%d', [SortedTeams[i].GoalsFor, SortedTeams[i].GoalsAgainst]);
    gridTable.Cells[3, i + 1] := IntToStr(Diff);  // Einfache Zahl ohne Vorzeichen
    gridTable.Cells[4, i + 1] := IntToStr(SortedTeams[i].Points);
    gridTable.Cells[5, i + 1] := IntToStr(i + 1);
  end;
end;

  // =============================================
procedure TForm1.SetScrollForSmallScreens;
begin
   // console.log('in Funktion: Scroll');
  // srollen der Breite wenn Bildschirm zu klein
  if window.innerWidth <= 768 then
  begin
    //plnHauptanwend.Align := alNone;
    //plnHauptanwend.Width := 800;
   // plnHauptanwend.Height := Self.Height;
     // console.log('in Funktion: Scroll und kleiner Screen');
    plnHauptanwend.ElementHandle.style.setProperty('overflow-x', 'auto');
    plnHauptanwend.ElementHandle.style.setProperty('overflow-y', 'hidden');
    //plnHauptanwend.ElementHandle.style.setProperty('min-width', '800px');
    end
    else
    begin
    //plnHauptanwend.ElementHandle.style.setProperty('overflow', 'visible');
    //plnHauptanwend.ElementHandle.style.setProperty('min-width', 'auto');
  end;
end;


end.