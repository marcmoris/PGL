/*
;/T/ Vue sur CPCPT_A_PAYER , VCPC_SLD et MCREFERENCE
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date création: 21 Juin 1993
;    Description..: Vue permettant de retrouver toutes les cédules qui ne sont
;                   pas encore payées. Elle permet de simplifier l'écran
;                   de sélection des paiements à effectuer.
;                   
;                   La sélection doit tenir compte des critères suivant:
;                     - le compte à payer doit être journalisé
;                     - le compte à payer ne doit pas être en retenu
;                     - le solde de la cédule doit être impayé
;                     - le fournisseur ou l'employé doit être actif
;                     - le fournisseur ne doit pas être en retenu
;
;/M/ François Déry, 7 juin 1999
;       Conversion en ISQL.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;    Description..: Ajout du concept du paiement non-appliqué.
;
;
*/
Create View vcap_sel 
As 
 Select cap.fouciecle,
        cap.foucle,
        cap.capcle,
        vcpc.cpcclelig,
        cap.refciecle,
        cap.refcletyp,
        cap.refclenum,
        cap.captypecr,
        cap.capciecle,
        ref.devcle,
        ref.refcat,
        cap.capflgced,
        vcpc.cpcdatdue,
        cap.capdatesc1,
        cap.capdatesc2,
        cap.capteresc1,
        cap.capteresc2,
        cap.capmntnet,
        vcap.v_capmntpye,
        vcpc.v_cpcsld
   From cpcpt_a_payer cap,
        vcpc_sld      vcpc,
        vcap_sld      vcap,
        mcreference   ref
  Where not     (    cap.capdatjou = "17-NOV-1858" 
                  Or cap.capdatjou Is Null )
            And cap.captypecr In ( "FA","CR","NA","PA","RD" )
            And cap.caprtu      = "0"
            And vcpc.fouciecle  = cap.fouciecle
            And vcpc.foucle     = cap.foucle
            And vcpc.capcle     = cap.capcle
            And vcpc.v_cpcsld  != 0 
            And vcpc.cpcflgsel  = "0"
            And vcap.fouciecle  = cap.fouciecle
            And vcap.foucle     = cap.foucle
            And vcap.capcle     = cap.capcle
            And ref.refciecle   = cap.refciecle
            And ref.refcletyp   = cap.refcletyp
            And ref.refclenum   = cap.refclenum
            And ref.reffourtu   = "0"
            And ref.refstu      = "A";
