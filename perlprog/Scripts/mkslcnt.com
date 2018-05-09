!--------------------------------------------------------------------------
! @(#)mkslcnt.com	2.1 97/09/03 Thomson-CSF TTM / ATGL
!--------------------------------------------------------------------------
!	FICHIER DCL VMS
!	Compilation de la commande SLCNT permettant d'obtenir des statistiques
!	diverses sur le source de differents modules de langages differents.
!--------------------------------------------------------------------------
$ define LIBDIR 'f$environ("default")' ! directory containing the .exe and .cld
$ on warning then continue
$ if P1.eqs."VMS"
$ then
$   delete slcnt.obj;*
$   mms/description=makefile.mms/macro=("PURE_VMS=0")
$   rename slcnt.exe LIBDIR:slcnt.exe
$   set command LIBDIR:slcnt.cld
$   delete/symbol/global slcnt
$ else
$   delete slcnt.obj;*
$   mms/description=makefile.mms/macro=("VMS_AS_UNIX=0")
$   rename slcnt.exe LIBDIR:slcnt.exe
$   slcnt=="$LIBDIR:slcnt.exe"
$ endif
