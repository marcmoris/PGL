/* Solde des factures et note de crédit.

  ;/T/ Vue sur FACPT_A_REC 
  ;
  ;/P/ Programmeur..: Marie-Josée Hamel
  ;    Date création: 96.02.12
  ;    Description..: Cette vue donne le solde du compte à recvoir.
  ;
  ;                   Seuls les documents suivant peuvent être référés;
  ;                      - Les factures FA,
  ;                      - Les crédits  CR,
  ;                      - Les note de crédits NC,
  ;
  ;                   Sert dans l'écran des factures pour avoir le détail
  ;                   des montants qui affectent une facture.
  ;
  ;/M/ François Déry, 7 juin 1999
  ;     Conversion en ISQL.
*/
Create View vfar_sld 
      ( ciecle,
        farcle,
        fartypecr,
        refciecle,
        refclenum,
        fardat,
        fardatjou,
        farmnt,
        farmntrec,
        v_farmntajt,
        v_farmntcrt )
As
 Select far.ciecle,
        far.farcle,
        far.fartypecr,
        far.refciecle,
        far.refclenum,
        far.fardat,
        far.fardatjou,
        far.farmnt,
        far.farmntrec,
/*
  Ajustement de la facture.
*/
        prosig_nvln( ( Select Sum( far2.farmnt ) From facpt_a_rec far2
                                Where far2.ciecle    = far.ciecle
                                  And far2.farcleref = far.farcle
                                  And far2.fartypecr = "AJ" ) ),
/*
  Note de crédit, incluant ajustement sur note de crédit.
*/
        prosig_nvln( ( Select Sum( far2.farmnt ) From facpt_a_rec far2
                                Where far2.ciecle    = far.ciecle
                                  And far2.farcleref = far.farcle
                                  And far2.fartypecr = "NC" ) )
   From facpt_a_rec far
  Where far.fartypecr != "AJ";

