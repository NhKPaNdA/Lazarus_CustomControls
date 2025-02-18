{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit CustomControls_Addon_Multilog;

{$warn 5023 off : no warning about unused units}
interface

uses
  uCustomControlsMultiLog, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('uCustomControlsMultiLog', @uCustomControlsMultiLog.Register);
end;

initialization
  RegisterPackage('CustomControls_Addon_Multilog', @Register);
end.
