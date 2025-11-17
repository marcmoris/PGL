/*
;/T/ Vue sur CPFOU_CIE, CPFOURNISSEUR, MCREF_ADRESSE
;
;/P/ Programmeur..: Francois Déry
;
;    Date création: 2 juin 1993
;
;    Description..: Fait parce que trop de fichier utiliser dans la 
;                   journalisation des facture de CAP.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vfoc_fouref 
As
 Select fou.fouciecle,
        fou.foucle,
        fou.foutyp,
        fou.foulng,
        fou.foucat,
        fou.foucieint,
        fou.founom,
        fou.founomabr,
        fou.devcle,
        fou.foudatouv,
        fou.foudatfer,
        fou.foustu,
        fou.fourtu,
        fou.foureftyp,
        fou.fouusrcre,
        fou.foudatcre,
        fou.fouhrecre,
        fou.fouusrmod,
        fou.foudatmod,
        fou.fouhremod,
        foc.focciecle,
        foc.focsldacj,
        foc.focadrpam,
        foc.focadrach,
        foc.focadrret,
        foc.foccptcap,
        foc.lbqcptenc,
        foc.foccptesc,
        foc.focenrtps,
        foc.focenrtvq,
        foc.foctaxtyptps,
        foc.foctaxcodtps,
        foc.foctaxtyptvq,
        foc.foctaxcodtvq,
        foc.focternet,
        foc.focteresc1,
        foc.focteresc2,
        foc.cmdtrp,
        foc.cmdfab,
        foc.focterescach,
        foc.focusisec,
        ref.radcle,
        ref.radnom
   From cpfou_cie     foc,
        cpfournisseur fou,
        mcref_adresse ref
  Where foc.fouciecle = fou.fouciecle 
    And foc.foucle    = fou.foucle 
    And foc.fouciecle = ref.refciecle 
    And "F"           = ref.refcletyp 
    And foc.foucle    = ref.refclenum;
