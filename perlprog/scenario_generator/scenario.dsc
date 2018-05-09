# Fichier de description d'un scenario

ScenarioName:

StartTime:
StopTime:

AreaNorth:
AreaSouth:
AreaWest:
AreaEst:

OwnPlateformLattitude:
OwnPlateformLongitude:
OwnPlateformAltitude:

HostNumber:24
LinkL11Number:2
LinkL16Number:1

#LinkL11X
LinkID:
LinkType:
FirstTN:
LastTN:
OwnPlatformLinkTN:
DLRPLattitude:
DLRPLongitude:
<Event>
Initialize
Start
Stop
ResetTacticalData
ResetInit
ResetInit&TacticalData

#LinkL16X
LinkID:
LinkType:
FirstTN:
LastTN:
OwnPlatformLinkTN:
<Event>
Initialize
Start
Stop
ResetTacticalData
ResetInit
ResetInit&TacticalData

#RessourceL11X
Ressourcetype:
RessourceHostName:
RemoteObjectNumber:
<Event>
Open
Close

#L11RemoteObjectX
RemoteObjectType:M1

#L16RemoteObjectX
StartTime:
StopTime:
RemoteObjectType:
RemoteObjectNumber:
UnitaireTrackFileName:
STN:
LinkTN:
Lattitude:
Longitude:
TQ:
<Event>
Emergency
ForceTell
Drop

#SystemObjectX
StartTime:
StopTime:
SystemObjectType:
systemObjectNumber:
UnitaireTrackFileName:
SystemTN:
Lattitude:
Longitude:
TQ:
<Event>
Emergency
ForceTell
Drop


#HostX
StartTime:
StopTime:
HostName:
Host_ID:
FirstRemoteObjectSysTN:
FirstSystemObjectSysTN:
SystemObjectNumber:
InputFileName:
ControlledLinkNumber:
ControlledLinkIDX:
<Event>
Connect
Disconnect
Registrate

