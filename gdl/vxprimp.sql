/*
  Sert pour l'impression interactive des factures car il y avait trop de 
  fichier.

/M/ François Déry, 8 juin 1999
        Conversion en ISQL
*/
Create View vxprimp
As 
 Select xpr.xprnom,
        usr.usrcle,
        frm.xfrphynam,
        xlo.xilquenam,
        xlo.xilgrpimp
   From gsprogramme xpr,
        gsusager    usr,
        gsforme     frm,
        gsxim_local xlo
  Where frm.xfrcle = xpr.xfrcle
    And xlo.xlocle = usr.xlocle
    And xlo.ximcod = xpr.ximcod;
