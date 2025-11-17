/*
;/T/ Vue sur CRCPT_A_REC et CRCLIENT
;
;/P/ Programmeur..: Nancy Marceau
;
;    Date création: 5 avril 1994
;
;    Description..: Le but de cette vue logique est de nous fournir les informa-
;                   tions sur le client provenant de la relation client et
;                   de celle des pièces à recevoir. Sert lors de l'impression
;                   des comptes à recevoir en souffrance pour avoir le choix
;                   un, plusieurs ou tous pour le code de représentant.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vcar_cli 
As 
 Select CAR.CIECLE,
        CAR.CARCLE,
        CAR.REFCIECLE,
        CAR.REFCLETYP,
        CAR.REFCLENUM,
        CAR.RADCLE,
        CAR.CARTYPECR,
        CAR.CARDATJOU,
        CAR.PECCLE,
        CAR.CARCPTCAR,
        CAR.CARDAT, 
        CLI.CLICIECLE,
        CLI.CLICLE,
        CLI.CLICAT,
        CLC.CLCREP,
        CLI.CLINOM
   From crcpt_a_rec car,
        crclient    cli,
        crcli_cie   clc
  Where car.refciecle  = cli.cliciecle 
    And car.refclenum  = cli.clicle
    And car.refciecle  = clc.cliciecle
    And car.refclenum  = clc.clicle
    And car.ciecle     = clc.ciecle
    And car.cardatjou != "17-NOV-1858"
    And car.cartypecr in ("FA","CR","NA" );
