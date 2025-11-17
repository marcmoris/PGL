/*
;/T/ Vue sur CPFOURNISSEUR, MCCOMPAGNIE
;
;/P/ Programmeur......: Nancy Marceau
;    Date de création.: 24 mars 1994
;    Description......: Vue permettant de retrouver le solde du 
;                       fournisseur ainsi que son solde en tant que
;                       client.  Cette vue permet donc de simplifier
;                       l'écran des soldes par compagnie.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vfou_sld 
      ( fouciecle,
        foucle, 
        clicle,
        ciecle,
        V_FOCSLDACJ,
        V_CLCSLDACJ )
As
 Select fou.fouciecle,
        fou.foucle, 
        fou.clicle,
        cie.ciecle,
        prosig_nvln( ( Select Sum( foc.focsldacj ) From cpfou_cie foc
                                Where fou.fouciecle = foc.fouciecle
                                  And fou.foucle    = foc.foucle
                                  And cie.ciecle    = foc.focciecle ) ),
        prosig_nvln( ( Select Sum( clc.clcsldacj ) From crcli_cie clc
                                Where fou.fouciecle = clc.cliciecle
                                  And fou.clicle    = clc.clicle
                                  And cie.ciecle    = clc.ciecle ) )
   From cpfournisseur fou,
        mccompagnie   cie;
