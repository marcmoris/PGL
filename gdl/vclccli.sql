/*
;/T/ Vue sur CRCLI_CIE et CRCLIENT
;
;/P/ Programmeur..: Alain Côté
;
;    Date création: 2 juin 1993
;
;    Description..: Le but de cette vue logique est de nous fournir les informa-
;                   tions sur le client provenant de la relation client et
;                   de celle par compagnie. Sert lors de la saisie des tran-
;                   sactions, évite d'ouvrir deux relations.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
;
;/M/ Programmeur..: Martin Bruyère
;    Date modif...: 6 juin 1996
;    Description..: Ajout du champ CLC.CLCNUMIRS pour le module de production
;
;
*/
Create View vclc_cli 
As
 Select clc.cliciecle,
        clc.clicle,
        clc.ciecle,
        clc.clcadrfac,
        clc.clcadretacpt,
        clc.clccptcar,
        clc.lbqcptenc,
        clc.clctaxtyptps,
        clc.clctaxcodtps,
        clc.clctaxtyptvp,
        clc.clctaxcodtvp,
        clc.clcternet,
        clc.clcteresc1,
        clc.clcteresc2,
        clc.clcterfrs,
        clc.clcsldacj,
        clc.clcexptps,
        clc.clcexptvp,
        clc.clclimcrt,
        clc.clcnumirs,
        cli.clicat,
        cli.clistu,
        cli.clityp,
        cli.clireftyp,
        cli.clinom,
        cli.clinomabr,
        cli.devcle,
        cli.clilng,
        cli.clietacpt,
        cli.clicieint
   From crcli_cie clc,
        crclient  cli
  Where clc.cliciecle = cli.cliciecle 
    And clc.clicle    = cli.clicle;
