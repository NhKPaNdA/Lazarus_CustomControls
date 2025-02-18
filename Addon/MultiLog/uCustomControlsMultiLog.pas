unit uCustomControlsMultiLog;

{$mode ObjFPC}{$H+}

interface

uses
  uCustomControls, Classes, Forms, Messages, Graphics, ComCtrls, Controls,
  LCLIntf, LCLType, LogTreeView;

type 

  { TCustomHintToolTip }

  TCustomHintToolTip = class(TCustomHintWindow)
  public
    procedure Paint; override;
  end;

  { TCustomLogTreeView }

  TCustomLogTreeView = class(TLogTreeView)
  private
    FLastHintNode: TTreeNode;
    FTooltipBackgroundColor: TColor;
    FTooltipBorderColor: TColor;
    FTooltipTextColor: TColor;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;  
  public
    constructor Create(AOwner: TComponent); override;
    property TooltipBackgroundColor: TColor read FTooltipBackgroundColor write FTooltipBackgroundColor default clWindow;
    property TooltipBorderColor: TColor read FTooltipBorderColor write FTooltipBorderColor default clWindowText;
    property TooltipTextColor: TColor read FTooltipTextColor write FTooltipTextColor default clWindowText;
  end;

  { Register }

  procedure Register;

implementation

  { TCustomHintToolTip }

  procedure TCustomHintToolTip.Paint;
  var
    R: TRect;
    ABackgroundColor, ABorderColor, ATextColor: TColor;
  begin
    R := ClientRect;

    // Set custom colors according to TCustomLogTreeView
    if HintControl is TCustomLogTreeView then
    begin
      with TCustomLogTreeView(HintControl) do
      begin
        ABackgroundColor := TooltipBackgroundColor;
        ABorderColor := TooltipBorderColor;
        ATextColor := TooltipTextColor;
      end;
    end
    else
    begin
        ABackgroundColor := BackgroundColor;
        ABorderColor := BorderColor;
        ATextColor := TextColor;
    end;

    Canvas.Brush.Color := ABackgroundColor;
    Canvas.Pen.Color := ABorderColor;
    Canvas.Font.Color := ATextColor;

    Canvas.FillRect(R);
    Canvas.Rectangle(R);
    Canvas.Font.Style := [];
    InflateRect(R, -4, -4);
    DrawText(Canvas.Handle, PChar(Caption), -1, R, DT_WORDBREAK or DT_LEFT);
  end;

  { TCustomLogTreeView }

  procedure TCustomLogTreeView.CMHintShow(var Message: TMessage);
  var
    HintInfo: PHintInfo;
    Node: TTreeNode;
    NodeRect: TRect;
  begin
    HintInfo := PHintInfo(Message.LParam);
    Node := GetNodeAt(HintInfo^.CursorPos.X, HintInfo^.CursorPos.Y);
    if Assigned(Node) then
    begin
      NodeRect := Node.DisplayRect(True);

      if Node <> FLastHintNode then
      begin
        FLastHintNode := Node; // Track the new node
        HintInfo^.HintStr := Node.Text;
        HintInfo^.HintControl := Self; // Tell hint window it's for a tooltip
        HintInfo^.HintPos := ClientToScreen(TPoint.Create(NodeRect.Left, NodeRect.Top));
        HintInfo^.ReshowTimeout := 0;
        HintInfo^.HideTimeout := 30000;
        Message.Result := 0;
      end;
    end;

    inherited;
  end;

  procedure TCustomLogTreeView.CMMouseLeave(var Message: TMessage);
  begin
    inherited;
    FLastHintNode := nil;
    Application.CancelHint; // Hide hint immediately
  end;

  procedure TCustomLogTreeView.MouseMove(Shift: TShiftState; X, Y: Integer);
  var
    Node: TTreeNode;
  begin
    inherited MouseMove(Shift, X, Y);
    Node := GetNodeAt(X, Y);

    // Force hint update ONLY if the node has changed
    if Node <> FLastHintNode then
    begin
      Application.CancelHint; // Cancel previous hint
      Application.ActivateHint(ClientToScreen(TPoint.Create(X, Y))); // Trigger new hint check
    end;
  end; 

  constructor TCustomLogTreeView.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    FTooltipBackgroundColor := clWindow;
    FTooltipBorderColor := clWindowText;
    FTooltipTextColor := clWindowText;
  end;

  { Register }

  procedure Register;
  begin
    RegisterComponents('Custom', [TCustomHintToolTip, TCustomLogTreeView]);
  end;
end.
