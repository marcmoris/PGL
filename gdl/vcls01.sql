/*
;/T/ Vue sur CRCLI_STAT 
;
;/P/ Programmeur..: Alain Côté
;
;    Date création: 21 mai 1993
;
;    Description..: Cette vue logique sert à l'écran de consultation
;                   de ventes toutes compagnie.
;
;                   Le but de cette vue logique est de sommariser les
;                   montants sans tenir compte du numéro de compagnie.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vcls01 
      ( cliciecle,
        clicle,
        clsann,
        v_clscumfac01,
        v_clscumfac02,
        v_clscumfac03,
        v_clscumfac04,
        v_clscumfac05,
        v_clscumfac06,
        v_clscumfac07,
        v_clscumfac08,
        v_clscumfac09,
        v_clscumfac10,
        v_clscumfac11,
        v_clscumfac12,
        v_clscumfac13,
        v_clscumesc01,
        v_clscumesc02,
        v_clscumesc03,
        v_clscumesc04,
        v_clscumesc05,
        v_clscumesc06,
        v_clscumesc07,
        v_clscumesc08,
        v_clscumesc09,
        v_clscumesc10,
        v_clscumesc11,
        v_clscumesc12,
        v_clscumesc13,
        v_clsnbrjrsdpo01,
        v_clsnbrjrsdpo02,
        v_clsnbrjrsdpo03,
        v_clsnbrjrsdpo04,
        v_clsnbrjrsdpo05,
        v_clsnbrjrsdpo06,
        v_clsnbrjrsdpo07,
        v_clsnbrjrsdpo08,
        v_clsnbrjrsdpo09,
        v_clsnbrjrsdpo10,
        v_clsnbrjrsdpo11,
        v_clsnbrjrsdpo12,
        v_clsnbrjrsdpo13,
        v_clsnbrdpo01,
        v_clsnbrdpo02,
        v_clsnbrdpo03,
        v_clsnbrdpo04,
        v_clsnbrdpo05,
        v_clsnbrdpo06,
        v_clsnbrdpo07,
        v_clsnbrdpo08,
        v_clsnbrdpo09,
        v_clsnbrdpo10,
        v_clsnbrdpo11,
        v_clsnbrdpo12,
        v_clsnbrdpo13 )
As
 Select CLS.CLICIECLE,
        CLS.CLICLE,
        CLS.CLSANN,
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC01 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC02 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC03 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC04 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC05 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC06 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC07 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC08 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC09 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC10 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC11 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC12 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMFAC13 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC01 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC02 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC03 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC04 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC05 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC06 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC07 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC08 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC09 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC10 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC11 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC12 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSCUMESC13 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO01 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO02 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO03 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO04 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO05 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO06 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO07 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO08 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO09 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO10 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO11 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO12 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRJRSDPO13 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO01 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO02 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO03 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO04 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO05 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO06 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO07 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO08 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO09 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO10 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO11 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO12 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) ),
        prosig_nvln( ( Select Sum( CLS2.CLSNBRDPO13 ) From crcli_stat cls2
                                        Where cls2.cliciecle = cls.cliciecle
                                          And cls2.clicle    = cls.clicle
                                          And cls2.clsann    = cls.clsann ) )
   From crcli_stat cls
  Group By CLS.CLICIECLE,
           CLS.CLICLE   ,
           CLS.CLSANN;

