# Fichier de description d'un scenario

ScenarioName:GLOBAL

Date:

Comment:

StartTime:12/00/00.000
StopTime:13/00/00.000

# Filtrage TX/RX square  N54°/E20°/N36°/W9°
# ASSET_FILTER 1 W9°/N54° E7°/N54° E7°/N47° W9°/N47°
# ASSET_FILTER 2 E7°/N54° E20°/N54° E20°/N47° E7°/N47°
# ASSET_FILTER 3 W9°/N47° E7°/N47° E7°/N36° W9°/N36°
# ASSET_FILTER 4 E7°/N47° E20°/N47° E20°/N36° E7°/N36°

OwnPlateformLattitude:N/045/00/00.000
OwnPlateformLongitude:W/003/00/00.000
OwnPlateformAltitude:0

HostNumber:3

#Host_1
StartTime:00/00/20.000
StopTime:02/00/00.000
HostName:L16NCM
Host_ID:1001
FirstRemoteObjectSysTN:o0
FirstSystemObjectSysTN:o0
SystemObjectNumber:0
ControlledLink:LinkL16_1
<Bibliotheque_file>
ConnexionFileName:L16NCM_CONNECT.xhd
FilterFileName:L16NCM_FILTER.xhd
ControlLinkFileName:LinkL16_1_Control.xhd
ControlRessourceFileName1:RessourceL16_1_ControlFile.xhd
ControlRessourceFileName2:RessourceL16_2_ControlFile.xhd
ControlRessourceFileName3:RessourceL16_3_ControlFile.xhd
ControlRessourceFileName4:RessourceL16_4_ControlFile.xhd
<Scenario_file>
InputFileName:L16NCM_GLOBAL.xhd
<Event>
00/00/20.000:connect
00/00/21.000:registrate
00/00/25.000:open:RessourceL16_1
00/00/26.000:initialize:RessourceL16_1
00/00/30.000:open:RessourceL16_2
00/00/31.000:initialize:RessourceL16_2
00/00/35.000:open:RessourceL16_3
00/00/36.000:initialize:RessourceL16_3
00/00/45.000:open:RessourceL16_4
00/00/46.000:initialize:RessourceL16_4

#Host_2
StartTime:00/00/20.000
StopTime:00/59/59.999
HostName:C2_1
Host_ID:1002
FirstRemoteObjectSysTN:99
FirstSystemObjectSysTN:200
SystemObjectNumber:100
ControlledLinkNumber:0
<file>
ConnexionFileName:C2_1_CONNECT.xhd
ControlLinkFileName:LinkL11_1_Control.xhd
LocalObjetcFileName:C2_1_GLOBAL.xhd
<Event>
00/00/10.000:connect
00/00/12.000:registrate
00/00/22.000:initialize:Link11_1
00/00/23.000:open:RessourceL11_1
00/00/24.000:activate:Link11_1
00/00/25.000:initialize:RessourceL11_1
00/00/26.000:start_transmit:RessourceL11_1
00/00/27.000:send_list_PU:RessourceL11_1

#LinkL11_1
LinkID:2
LinkType:L11
FirstTN:o2000
LastTN:o2777
OwnPlatformLinkTN:o0050
DLRPLattitude:N/45/00/00.000
DLRPLongitude:W/007/00/00.000
Own UnitLatitude:N/45/00/00.000
OwnUnitLongitude:W/007/00/00.000
RessourceNumber:1
<Ressource>
RessourceL11_1
<event>
Initialize
Start
Stop
ResetTacticalData
ResetInit
ResetInit&TacticalData

#LinkL16_1
Link_ID:1
LinkType:L16
ManagingHostName:L16NCM
FirstTN:o01000
LastTN:o01777
OwnPlatformLinkTN:o0007
RessourceNumber:4
<file>

<Event>
00/00/22.000:initiate
00/00/40.000:start
00/00/41.000:activate

#RessourceL16_1
Ressourcetype:MIDS
RessourceHostName:verdi
ManagingHostName:L16NCM
RemoteObjectNumber:100
<file>
InputFileName:RessourceL16_1_GLOBAL.ji
<Event>


#L16RemoteObject_01
StartTime:00/02/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:o00017
FirtLinkTN:512
Lattitude:N/045/01/00.000
Longitude:W/001/01/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_01.ji

#L16RemoteObject_02
StartTime:00/03/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:612
Lattitude:N/045/01/00.000
Longitude:W/001/02/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_02.ji

#L16RemoteObject_03
StartTime:00/04/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:712
Lattitude:N/045/01/00.000
Longitude:W/001/03/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_03.ji

#L16RemoteObject_04
StartTime:00/05/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:812
Lattitude:N/045/01/00.000
Longitude:W/001/01/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_04.ji

#L16RemoteObject_05
StartTime:00/06/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:912
Lattitude:N/045/01/00.000
Longitude:W/001/05/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_05.ji

#L16RemoteObject_06
StartTime:00/07/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:1012
Lattitude:N/045/01/00.000
Longitude:W/001/06/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_06.ji

#L16RemoteObject_07
StartTime:00/08/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:1112
Lattitude:N/045/01/00.000
Longitude:W/001/07/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_07.ji

#L16RemoteObject_08
StartTime:00/09/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:1212
Lattitude:N/045/01/00.000
Longitude:W/001/01/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_08.ji

#L16RemoteObject_09
StartTime:00/10/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:1312
Lattitude:N/045/01/00.000
Longitude:W/001/09/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_09.ji

#L16RemoteObject_10
StartTime:00/11/00.000
StopTime:00/23/00.000
RemoteObjectType:AirTrackGroup
RemoteObjectNumber:100
STN:17
FirtLinkTN:1412
Lattitude:N/045/01/00.000
Longitude:W/001/10/00.000
TQ:12
DeltaLat:
DeltaLong:
DeltaTime:0.01
UnitaireTrackFileName:AirTrack.ji
RemoteObjectFileName:L16RemoteObject_10.ji

#RessourceL16_2
Ressourcetype:MIDS
RessourceHostName:verdi
ManagingHostName:L16NCM
RemoteObjectNumber:100
ControlFileName:RessourceL16_2_Control.xhd
<Event>


#RessourceL16_3
Ressourcetype:MIDS
RessourceHostName:verdi
ManagingHostName:L16NCM
RemoteObjectNumber:100
ControlFileName:RessourceL16_3_Control.xhd
<Event>


#RessourceL16_4
Ressourcetype:MIDS
RessourceHostName:verdi
ManagingHostName:L16NCM
RemoteObjectNumber:100
ControlFileName:RessourceL16_4_Control.xhd
<Event>




#Host3
StartTime:01/00/00.000
StopTime:01/59/59.999
HostName:C2_2
Host_ID:1002
FirstRemoteObjectSysTN:
FirstSystemObjectSysTN:
FirstSystemObjectLinkTN:
SystemObjectNumber:
InputFileName:
ControlledLinkNumber:
ControlledLinkIDX:
<Event>
Connect
Disconnect
Registrate




LinkL11Number:1
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

#LinkL16_1
StartTime:
StopTime:
LinkID:
LinkType:
FirstTN:
LastTN:
OwnPlatformLinkTN:
RemoteObjectNumber:


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

