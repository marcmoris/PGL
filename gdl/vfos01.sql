/*
;/T/ Vue sur CPFOU_STAT 
;
;/P/ Programmeur..: Thomas BRENNEUR (créé à partir de VCLS01)
;
;    Date création: 7 Juin 1993
;
;    Description..: Cette vue logique sert à l'écran de consultation
;                   de achats toutes compagnie.
;
;                   Le but de cette vue logique est de sommariser les
;                   montants sans tenir compte du numéro de compagnie.
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
*/
Create View vfos01 
      ( fouciecle,
        foucle,
        fosann,
        v_foscumach01,
        v_foscumach02,
        v_foscumach03,
        v_foscumach04,
        v_foscumach05,
        v_foscumach06,
        v_foscumach07,
        v_foscumach08,
        v_foscumach09,
        v_foscumach10,
        v_foscumach11,
        v_foscumach12,
        v_foscumach13,
        v_foscumesc01,
        v_foscumesc02,
        v_foscumesc03,
        v_foscumesc04,
        v_foscumesc05,
        v_foscumesc06,
        v_foscumesc07,
        v_foscumesc08,
        v_foscumesc09,
        v_foscumesc10,
        v_foscumesc11,
        v_foscumesc12,
        v_foscumesc13,
        v_fosnbrjrspam01,
        v_fosnbrjrspam02,
        v_fosnbrjrspam03,
        v_fosnbrjrspam04,
        v_fosnbrjrspam05,
        v_fosnbrjrspam06,
        v_fosnbrjrspam07,
        v_fosnbrjrspam08,
        v_fosnbrjrspam09,
        v_fosnbrjrspam10,
        v_fosnbrjrspam11,
        v_fosnbrjrspam12,
        v_fosnbrjrspam13,
        v_fosnbrpam01,
        v_fosnbrpam02,
        v_fosnbrpam03,
        v_fosnbrpam04,
        v_fosnbrpam05,
        v_fosnbrpam06,
        v_fosnbrpam07,
        v_fosnbrpam08,
        v_fosnbrpam09,
        v_fosnbrpam10,
        v_fosnbrpam11,
        v_fosnbrpam12,
        v_fosnbrpam13 )
As
 Select fos.fouciecle,
        fos.foucle,
        fos.fosann,
        prosig_nvln( ( Select Sum( fos2.foscumach01 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach02 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach03 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach04 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach05 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach06 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach07 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach08 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach09 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach10 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach11 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach12 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumach13 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc01 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc02 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc03 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc04 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc05 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc06 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc07 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc08 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc09 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc10 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc11 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc12 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.foscumesc13 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam01 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam02 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam03 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam04 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam05 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam06 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam07 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam08 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam09 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam10 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam11 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam12 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrjrspam13 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam01 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam02 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam03 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam04 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam05 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam06 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam07 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam08 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam09 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam10 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam11 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam12 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) ),
        prosig_nvln( ( Select Sum( fos2.fosnbrpam13 ) From cpfou_stat fos2
                                Where fos2.fouciecle = fos.fouciecle
                                  And fos2.foucle    = fos.foucle
                                  And fos2.fosann    = fos.fosann ) )
   From cpfou_stat fos
  Group By fos.fouciecle,
           fos.foucle,
           fos.fosann;

