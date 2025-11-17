/*
;/T/ Vue sur CRCLIENT, MCCOMPAGNIE
;
;/P/ Programmeur......: Nancy Marceau
;    Date de création.: 24 mars 1994
;    Description......: Vue permettant de retrouver le solde du 
;                       client ainsi que son solde en tant que
;                       fournisseur. Cette vue permet donc de simplifier
;                       l'écran des soldes par compagnie.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vcli_sld 
      ( cliciecle,
        clicle, 
        foucle,
        ciecle,
        v_clcsldacj,
        v_focsldacj )
As
 Select CLI.CLICIECLE,
        CLI.CLICLE, 
        CLI.FOUCLE,
        CIE.CIECLE,
        prosig_nvln( ( Select Sum( clc.clcsldacj ) From crcli_cie clc
                                     Where cli.cliciecle = clc.cliciecle 
                                       And cli.clicle    = clc.clicle
                                       And cie.ciecle    = clc.ciecle ) ),
        prosig_nvln( ( Select Sum( foc.focsldacj ) From cpfou_cie foc
                                     Where cli.cliciecle = foc.fouciecle 
                                       And cli.foucle    = foc.foucle 
                                       And cie.ciecle    = foc.focciecle ) )
   From crclient cli,
        mccompagnie cie;
                             
