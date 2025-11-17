/* VREFFOU Pour permettre la recherche sur le numéro de fournisseur 
  ;/T/
  ;
  ;/P/ Programmeur..: Patrick Langlois
  ;    Date création: 26 Juillet 1999
  ;    Description..: Pour permettre la recherche sur n'importe quel champ dans écran ar016
  ;
*/
Create View vreffou
As
 Select T1.CIECLE,
        T1.CMDCLE,
        T1.CMDAJT,
        T1.CDECLE,
        T1.PRDCLE,
        T1.CDEREFFOU,
        T1.CDEDSCPRD,
        T1.CDEQTECOM,
        T1.CDEPRIUNI,
        T2.FOUCLE,
        T2.CMDDAT
   From ARCMD_DETAIL T1,
        ARCOMMANDE   T2
  Where T1.CIECLE = T2.CIECLE AND
        T1.CMDCLE = T2.CMDCLE AND
        T1.CMDAJT = T2.CMDAJT AND
        T1.PRDTYP = "D" ;
