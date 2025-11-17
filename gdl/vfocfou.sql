/*
;/T/ Vue sur CPFOU_CIE et CPFOURNISSEUR
;
;/P/ Programmeur..: Alain Côté / Adapté pour les C.P. par Thomas BRENNEUR
;
;    Date création: 2 juin 1993
;
;    Description..: Regroupement du fournisseur et de ses informations
;                   spécifiques à chaque compagnie pour ne pas définir
;                   deux relations dans tous les écrans qui désirent des
;                   renseignement sur un fournisseur.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vfoc_fou 
As
 Select FOU.FOUCIECLE,
        FOU.FOUCLE,
        FOU.FOUTYP,
        FOU.FOULNG,
        FOU.FOUCAT,
        FOU.FOUCIEINT,
        FOU.FOUNOM,
        FOU.FOUNOMABR,
        FOU.DEVCLE,
        FOU.FOUDATOUV,
        FOU.FOUDATFER,
        FOU.FOUSTU,
        FOU.FOURTU,
        FOU.FOUREFTYP,
        FOU.FOUUSRCRE,
        FOU.FOUDATCRE,
        FOU.FOUHRECRE,
        FOU.FOUUSRMOD,
        FOU.FOUDATMOD,
        FOU.FOUHREMOD,
        FOC.FOCCIECLE,
        FOC.FOCSLDACJ,
        FOC.FOCADRPAM,
        FOC.FOCADRACH,
        FOC.FOCADRRET,
        FOC.FOCCPTCAP,
        FOC.LBQCPTENC,
        FOC.FOCCPTESC,
        FOC.FOCENRTPS,
        FOC.FOCENRTVQ,
        FOC.FOCTAXTYPTPS,
        FOC.FOCTAXCODTPS,
        FOC.FOCTAXTYPTVQ,
        FOC.FOCTAXCODTVQ,
        FOC.FOCTERNET,
        FOC.FOCTERESC1,
        FOC.FOCTERESC2,
        FOC.CMDTRP,
        FOC.CMDFAB,
        FOC.FOCTERESCACH,
        FOC.FOCUSISEC
   From cpfou_cie     foc,
        cpfournisseur fou
  Where foc.fouciecle = fou.fouciecle
    And foc.foucle    = fou.foucle;

