;/T/ Détail de la commande
;
;/P/ Programmeur..: Nancy Marceau
;    Date Création: 11 mars 1994
;
;    Description..: Cet écran permet de faire la gestion du détail de la
;                   commande.  C'est dans cet écran qu'on commande des
;                   produits.  Les montants engagés et les quantités des
;                   produits sont mis à jour.
;
;/M/ Modification.: Pierre Routhier
;                   02 Mai 1997
;
;                   Si notion de projet (HLDNTNPRO OF MCHOLDING) = Oui et
;                   que le compte (CPTCLE) inscrit est un compte de nature
;                   revenu (NACCLE = 4) ou dépense (NACCLE = 5) de la table
;                   mcnature_ctb :
;                      - On demande les projets et ce, de façon obligatoire.
;
;                   Si notion de projet (HLDNTNPRO OF MCHOLDING) = Non ou
;                   que le compte (CPTCLE) inscrit est un compte de bilan
;                   (actif, passif ou capital - NACCLE = 1 ou 2 ou 3) de la
;                   table mcnature_ctb:
;                      - On ne les demande pas du tout.
;-------------------------------------------------------------------------------
;/M/ Pascal Tremblay, 98-01-29
;
;    Ajustement pour le changement de siècle
;
;/V/ Écran vérifier pour le passage à l'an 2000
;
;-------------------------------------------------------------------------------
;/M/ Programmeur.......: Sylvie Chouinard
;    Debut modification: 25 mai 1998
;    Fin   modification: 25 mai 1998
;    Etat..............: Termine
;    Description.......: Changer le OR pour un AND dans la condition de
;                        reinitialisation du projet/sous-projet de la
;                        procdure process cptcle.
;                        (SOS 159)
;
;
;/M/ Programmeur.......: Patrick Langlois
;    Date modification.: 09 Juin 1999
;    Description.......: Migration Achat/Réception/Inventaire de l'environnement (BOC)
;
;/M/ Programmeur.......: Francois Richard
;    Date modification : 19 juillet 1999
;    Description.......: Aid\351 la saisie de prdcle
;
;/M/ Programmeur.......: Patrick Langlois
;    Date modification : 28 juillet 1999
;    Description.......: Mettre l'écran en 132 colonnes pour permettre de saisir 2 occurences.
;-------------------------------------------------------------------------------

SCREEN ar007a ACTIONBAR &
             MODE LABEL "" AT 2,132 &      
             FROM 1,1 TO 23,132 &
             NOACTION FIELDMARK RETAIN STARTUP &
             HELP POPUP FROM 4,9 TO 20,72 &
             RECEIVING T_CIECLEMNU, &
                       T_CIENOM,    &
                       T_CMDSTUOLD, &
                       T_PECCLEMNU, &
                       ARCOMMANDE , &
                       ARCMD_HISTO, &
                       T_CDECLEFND, &
                       T_CDECLE

TEMPORARY D_PECCLE_ARCOMMANDE CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

TEMPORARY D_CPTPECDEBI_VCPT CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

TEMPORARY D_CPTPECDEBA_VCPT CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

TEMPORARY D_CCUPECDEBI_MC CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

TEMPORARY D_CCUPECDEBA_MCCHARTE CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

TEMPORARY T_PECCLE_ARCOMMANDE CHARACTER SIZE 5 ; Temporaire servant pour le changement de siècle

USE ustrasse NOLIST     ; Pour les sous-écrans

USE ussectmp NOLIST     ; Variable pour la sécurité
    "AR007A"            ; Nom de l'écran

USE ar007a.hlp NOLIST  ; Use servant à la documentation de l'écran

USE usactecr NOLIST     ; Actionbar standard dans les écrans pleine page et sous-écrans
@IF FRANCAIS
ACTIONMENU LABEL "Sous-écrans"
  MENUITEM LABEL "Note descriptive                " ACTION DESIGNER D001
@ELSE
ACTIONMENU LABEL "Subscreen"
  MENUITEM LABEL "%%%%-maximum 32 caractères------" ACTION DESIGNER D001
@ENDIF


;-------------------------------------------------------------------------------
TEMPORARY T_CIECLEMNU CHARACTER SIZE 4  ; Numéro de la compagnie
TEMPORARY T_CIENOM    CHARACTER SIZE 40 ; Nom de la compagnie
TEMPORARY T_PECCLEMNU CHARACTER SIZE 4  ; Période du menu
TEMPORARY T_CMDSTUOLD CHARACTER SIZE 1  ; Ancien statut de la commande
TEMPORARY T_CDECLEFND CHARACTER SIZE 1  ; Ligne de détail (recherche par catalogue)
TEMPORARY T_CDECLE    INTEGER   SIZE 4  ; Ligne de détail (recherche par catalogue)
;-------------------------------------------------------------------------------
;
DEFINE DZ_CIECLE CHARACTER SIZE 4  = T_CIECLEMNU
DEFINE DZ_CIENOM CHARACTER SIZE 40 = CENTER( T_CIENOM )

;
; Commande
;
FILE ARCOMMANDE        MASTER  NOITEM
;
; Historique
;
FILE ARCMD_HISTO       MASTER  NOITEM

FILE ARCMD_DETAIL      PRIMARY NOITEM OCCURS 2

  ITEM PECCLE OF ARCMD_DETAIL INITIAL PECCLE OF ARCOMMANDE
  ITEM CIECLE OF ARCMD_DETAIL INITIAL CIECLE OF ARCOMMANDE
  ITEM CMDCLE OF ARCMD_DETAIL INITIAL CMDCLE OF ARCOMMANDE
  ITEM CMDAJT OF ARCMD_DETAIL INITIAL CMDAJT OF ARCOMMANDE
  ITEM CDESTU OF ARCMD_DETAIL INITIAL " "  ; La ligne est saisie

;
; Historique d'engagement
;
FILE MCHIS_ECR_ENG     DESIGNER
FILE MCHIS_PROJET_ENG  DESIGNER
;
; Fichier d'historique des transactions
;
FILE ARPRD_HISTO       DESIGNER

;------------------------------------------------------------------------------
;
; Pour valider que la réquisition existe s'il y en a une.
;
FILE ARREQUISITION      REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CIECLE, &
               REQCLE  &
         USING CIECLE OF ARCMD_DETAIL, &
               REQCLE OF ARCMD_DETAIL

TEMPORARY T_REQCLEFND CHARACTER SIZE 9 ; Appel de la réquisition

;
; Catalogue du fournisseur pour obtenir le dernier coûtant du produit
;
FILE ARPRD_FOU     REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CIECLE,    &
               PRDCLE,    &
               FOUCIECLE, &
               FOUCLE     &
         USING CIECLE    OF ARCOMMANDE, &
               PRDCLE    OF ARCMD_DETAIL, &
               FOUCIECLE OF ARCOMMANDE, &
               FOUCLE    OF ARCOMMANDE



;
; Fichier permet de valider la possibilité d'annuler une ligne de commande
; s'il ne reste pas de réceptions non journalisées.
;
FILE ARRECEPTION       DESIGNER OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CIECLE, &
               CMDCLE  &
         USING CIECLE OF ARCOMMANDE, &
               CMDCLE OF ARCOMMANDE

;-------------------------------------------------------------------------------
;
; Validation du projet et affichage de sa description.
;
FILE GPPROJETS          REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA CIECLE, &
             PRJCLE  &
         USING CIECLE OF ARCOMMANDE, &
               PRJCLE OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
;
; Validation de l'activité et affichage de sa description.
;
FILE GPPRO_ACTIVITE        REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS VIA CIECLE, &
             PRJCLE, &
             PRACLE  &
         USING CIECLE OF ARCOMMANDE, &
               PRJCLE OF ARCMD_DETAIL, &
               PRACLE OF ARCMD_DETAIL


;------------------------------------------------------------------------------
;
; Codes bilingues du mode de transport.
;
DEFINE    D_CDETRP CHARACTER SIZE 16 = "CMDTRP"
TEMPORARY T_CDETRP CHARACTER SIZE 4

FILE VCBI_DSC          REFERENCE ALIAS A_CBI_CDETRP OCCURS WITH ARCMD_DETAIL
  ACCESS  VIA XELNOM, &
              CBICLE  &
          USING D_CDETRP, &
                CDETRP OF ARCMD_DETAIL

;------------------------------------------------------------------------------
;
; Codes bilingues du code de terme de commerce
;
DEFINE    D_CDEFAB CHARACTER SIZE 16 = "CMDFAB"
TEMPORARY T_CDEFAB CHARACTER SIZE 4

FILE VCBI_DSC          REFERENCE ALIAS A_CBI_CDEFAB OCCURS WITH ARCMD_DETAIL
  ACCESS  VIA XELNOM, &
              CBICLE  &
          USING D_CDEFAB, &
                CDEFAB OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
;
; Validation de la charte de compte.
;
FILE MCCHARTE_UNA      REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS  VIA   CPTCLE, &
                CIECLE, &
                UNACLE &
          USING CPTCLE OF ARCMD_DETAIL, &
                CIECLE OF ARCMD_DETAIL, &
                UNACLE OF ARCMD_DETAIL


;-------------------------------------------------------------------------------
; Validation du code de taxe fédéral.
;
FILE MCTAXE            REFERENCE &
                      ALIAS A_TAX_TPS OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   TAXCLETYP, &
               TAXCLECOD &
         USING CDETAXTYPTPS OF ARCMD_DETAIL, &
               CDETAXCODTPS OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
; Validation du code de taxe provincial.
;
FILE MCTAXE            REFERENCE &
                      ALIAS A_TAX_TVP OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   TAXCLETYP, &
               TAXCLECOD &
         USING CDETAXTYPTVQ OF ARCMD_DETAIL, &
               CDETAXCODTVQ OF ARCMD_DETAIL



;-------------------------------------------------------------------------------
; Codes bilingues du statut de la ligne de commande
;
DEFINE    D_CDESTU CHARACTER SIZE 16 = "CDESTU"
TEMPORARY T_CDESTU CHARACTER SIZE 4

FILE VCBI_DSC          REFERENCE ALIAS A_CBI_CDESTU OCCURS WITH ARCMD_DETAIL
  ACCESS  VIA XELNOM, &
              CBICLE  &
          USING D_CDESTU, &
                CDESTU OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
; Pour valider le compte et afficher la description lors de la
; saisie.
;

FILE VCPT_DSC            REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CPTCLE    &
         USING CPTCLE OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
; Pour valider l'unité administrative et afficher la description lors de la
; saisie.
;

FILE MCUNITE_ADM       REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CIECLE, &
               UNACLE  &
         USING CIECLE OF ARCMD_DETAIL, &
               UNACLE OF ARCMD_DETAIL



;-------------------------------------------------------------------------------
; Fichier permettant de prendre par défaut le terme d'escompte sur achat
; du fournisseur.
;
FILE VFOC_FOU          REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS VIA   FOUCIECLE, &
               FOUCLE,    &
               FOCCIECLE  &
         USING FOUCIECLE OF ARCOMMANDE,&
               FOUCLE    OF ARCOMMANDE, &
               CIECLE    OF ARCOMMANDE


;-------------------------------------------------------------------------------
;
; Pour l'unité administrative d'inter.
;
FILE MCCOMPAGNIE       REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS VIA   CIECLE &
         USING FOUCIEINT OF VFOC_FOU

;-------------------------------------------------------------------------------
FILE VPRE_PRD          REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS VIA   CIECLE, &
               PRDCLE, &
               ENTCLE  &
         USING CIECLE OF ARCOMMANDE, &
               PRDCLE OF ARCMD_DETAIL, &
               ENTCLE OF ARCOMMANDE

;-------------------------------------------------------------------------------
; Fichier du terme d'escompte d'achat du fournisseur.
;
FILE VTER_DSC          REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA    TERCLE  &
         USING  CDETERESCACH OF ARCMD_DETAIL


;-------------------------------------------------------------------------------
;
; Fichier pour ajuster le prix unitaire lorsqu'il provient de l'entrepôt et
; que la devise est différente du holding.
;
FILE MCDEVISE          REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS VIA    DEVCLE &
         USING  DEVCLE OF VFOC_FOU


  ITEM DEVTAU       OF ARCMD_DETAIL INITIAL DEVTAU OF MCDEVISE

;-------------------------------------------------------------------------------
; Paramètres pour la compagnie consolidé(holding)
;
FILE MCHOLDING         REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA CIENMC USING "1"

;-------------------------------------------------------------------------------
; Fichier afin de valider que la période d'achat n'est pas fermée lors de
; l'annulation d'une ligne de commande.
;
FILE MCPERIODE_CIE     DESIGNER OPEN READ SHARE
  ACCESS VIA   CIECLE, &
               PECCLE  &
         USING CIECLE OF ARCOMMANDE, &
               PECCLE OF ARCOMMANDE



FILE MCREF_ADRESSE     REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS  VIA   REFCIECLE, &
                REFCLETYP, &
                REFCLENUM, &
                RADCLE &
          USING FOUCIECLE OF ARCOMMANDE, &
                REFCLETYP OF ARCOMMANDE, &
                FOUCLE    OF ARCOMMANDE, &
                RADCLE    OF ARCOMMANDE

;-------------------------------------------------------------------------------
;
; Destruction des notes descriptives.
;
FILE ARCDE_NOTE        DELETE  &
                      NOITEMS OCCURS WITH ARCMD_DETAIL
  ACCESS VIA    CIECLE   , &
                CMDCLE   , &
                CMDAJT   , &
                CDECLE     &
         USING  CIECLE    OF ARCOMMANDE, &
                CMDCLE    OF ARCOMMANDE, &
                CMDAJT    OF ARCOMMANDE, &
                CDECLE    OF ARCMD_DETAIL

FILE MCCOMPTE            REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   CPTCLE &
         USING CPTCLE OF ARCMD_DETAIL

FILE MCNATURE_CTB        REFERENCE OCCURS WITH ARCMD_DETAIL
  ACCESS VIA   NACCLE &
         USING NACCLE OF MCCOMPTE

;-------------------------------------------------------------------------------
;
; Valide l'immobilisation et affiche la description.
;
TEMPORARY T_IMMCLE CHARACTER SIZE 12 ; Popup sur les immobilisations.

FILE IMIMMOBILISATION REFERENCE OCCURS WITH ARCMD_DETAIL

  ACCESS  VIA   CIECLE, &
                IMMCLE &
          USING CIECLE OF ARCMD_DETAIL , &
                IMMCLE OF ARCMD_DETAIL

  SELECT IF IMMSTU OF IMIMMOBILISATION = "A"



;-------------------------------------------------------------------------------
TEMPORARY T_ANNEE     CHARACTER SIZE 2
TEMPORARY T_NUMSEQ    INTEGER UNSIGNED SIZE 4
TEMPORARY T_HENCLE    INTEGER UNSIGNED SIZE 4
TEMPORARY T_CPTLIG    INTEGER UNSIGNED SIZE 2
TEMPORARY T_MNTANN    ZONED SIZE 12

TEMPORARY T_ENTCLE    CHARACTER SIZE 4  ; Entrepôt pour écran dépisteur.
TEMPORARY T_PRDCLE    CHARACTER SIZE 12 ; Produit pour écran dépisteur.

TEMPORARY T_REQCLE    CHARACTER SIZE 9 ; Popup ligne réquisition.

TEMPORARY T_TAXCLETYP CHARACTER SIZE 1 ; Popup sur les codes de taxes
TEMPORARY T_TAXCLECOD CHARACTER SIZE 2 ; Popup sur les codes de taxes
TEMPORARY T_TAXMODPAT CHARACTER SIZE 5 ; Popup sur les codes de taxes

TEMPORARY T_TERCLE    CHARACTER SIZE  4 ; Popup sur terme d'escompte.
TEMPORARY T_TERCAT    CHARACTER SIZE  4 ; Popup sur terme d'escompte.

TEMPORARY T_CPTCLE    CHARACTER SIZE 6 ; Popup sur les comptes.
TEMPORARY T_PECCLE    CHARACTER SIZE 4 ; Popup sur les comptes.
TEMPORARY T_CPTTYPPAT CHARACTER SIZE 1 ; Popup sur les comptes.
TEMPORARY T_CPTCATPAT CHARACTER SIZE 8 ; Popup sur les comptes.

TEMPORARY T_UNACLE    CHARACTER SIZE 8 ; Popup sur unités administratives.

TEMPORARY T_PRJCLE    CHARACTER SIZE 8 ; Popup sur les projets.
TEMPORARY T_PRJSTUPAT CHARACTER SIZE 8 ; Popup sur les projets.

TEMPORARY T_PRACLE    CHARACTER SIZE 3 ; Popup sur les activités.
TEMPORARY T_PRASTUPAT CHARACTER SIZE 5 ; Popup sur les activités.

TEMPORARY T_CDEPRIUNI CHARACTER SIZE 14 ; Popup sur dernier coûtant
TEMPORARY T_CDEQTEREJ INTEGER   SIZE 4  ; Quantités négatives lorsque ligne "X"

TEMPORARY T_PECCLEDES CHARACTER SIZE 4
                                        ; Période de désengagement
TEMPORARY T_FOUCIECLE CHARACTER SIZE 4  ; Compagnie pour la réception.
TEMPORARY T_RECCLEFND CHARACTER SIZE 12 ; Commande pour la réception.
TEMPORARY T_REQCLENUMFND INTEGER SIGNED SIZE 4

;
; Pour le calcul des taxes.
;

TEMPORARY T_FLGMOD       CHARACTER SIZE 1 ; Flag pour déceler s'il y eu modif.
TEMPORARY T_TAXMODTPSOLD CHARACTER SIZE 1 ; Pour diminuer le bon cumul de taxe.
TEMPORARY T_TAXMODTVQOLD CHARACTER SIZE 1 ; Pour diminuer le bon cumul de taxe.
TEMPORARY T_CDESTUOLD    CHARACTER SIZE 1 ; Pour conserver ancien statut
TEMPORARY T_FLAG_ALT     CHARACTER SIZE 1 ; Flag pour un record en modification
TEMPORARY T_FLAG_ENT     CHARACTER SIZE 1 ; Flag pour un record en entrée

;
; Temporaires nécessaires au calcul des taxes
;
USE ustaxtmp NOLIST

USE usvarprd NOLIST ; Variables servant à la saisie de prdcle

DEFINE D_PRDQTETOT    FLOAT   SIZE 8 = &  ; Pour valider que la quantité
                                          ; commandée dépasse pas qté maximum
  PREQTECOM OF VPRE_PRD + &
  PREQTEPHY OF VPRE_PRD + &
  CDEQTECOM OF ARCMD_DETAIL

;-------------------------------------------------------------------------------
;
USE usdrw132 NOLIST     ; Draw pour les écrans
USE ustitstd132 NOLIST     ; En-tête pour les écrans
USE ushilite NOLIST     ; Hilite pour tous les écrans

DRAW THIN 5,1 TO 5,132
DRAW THIN 14,1 TO 14,132

SKIP

TITLE &
@IF FRANCAIS
      " Détail de commande " &
@ELSE
      " %%%Détail de commande  " &
@ENDIF
      CENTERED AT ,1

USE ustitoff NOLIST           ; Pour placer le TITLE OFF

;-------------------------------------------------------------------------------

SKIP

ALIGN (,3,19)(,41,50)(,,57)

FIELD CMDCLE OF ARCOMMANDE &
        FIXED

FIELD FOUCLE OF ARCOMMANDE &
        FIXED &
        LABEL "Fourn..:"

FIELD RADNOM OF MCREF_ADRESSE  &
        FIXED SIZE 40
                   
SKIP 1       

ALIGN (2,3,19)(,,33)(,72,85)
              
CLUSTER OCCURS WITH ARCMD_DETAIL                     

FIELD PRDCLE OF ARCMD_DETAIL   &
        REQUIRED NOCHANGE      &
        HIDDEN ID 1            &
        LOOKUP ON VPRE_PRD &
          MESSAGE 1373 ; Ce produit n'existe pas pour l'entrepôt de la commande.

FIELD CDEDSCPRD OF ARCMD_DETAIL &
        REQUIRED IF PRDTYP OF VPRE_PRD = "D" & ; Description est saisie si le
        SIZE 38                                ; produit est de type divers.

FIELD CDEREFFOU OF ARCMD_DETAIL &
        LABEL "Référence..:"


ALIGN (2,3,19)(,41,50)(,,52)
FIELD CDECLE OF ARCMD_DETAIL   &
        HIDDEN ID 5            &
        REQUIRED NOCHANGE      &
        LOOKUP NOTON ARCMD_DETAIL       &
          VIA   CIECLE,                 &
                CMDCLE,                 &
                CDECLE                  &
          USING CIECLE OF ARCOMMANDE,    &
                CMDCLE OF ARCOMMANDE,    &
                CDECLE OF ARCMD_DETAIL   &
          MESSAGE 1372           ; Cet item de la commande existe déjà.

FIELD CDESTU OF ARCMD_DETAIL &    
        LABEL "Statut.:"     &
        NOENTRY  &
        LOOKUP ON A_CBI_CDESTU &
          MESSAGE 1359 ; Ce statut de commande est invalide.

FIELD CBIDSC OF A_CBI_CDESTU &
        SIZE 19              &
        DISPLAY


ALIGN (2,3,19)(,41,50)(,,55)(,72,85)(,,98)


FIELD CDEDATLIVPRE OF ARCMD_DETAIL  FORMAT YYYYMMDD &
        HIDDEN ID 15

FIELD CDETRP OF ARCMD_DETAIL   &
        LABEL "Transp.:"       &
        LOOKUP ON A_CBI_CDETRP &
          MESSAGE 1364 ; Ce mode de transport n'existe pas.

FIELD CBIDSC OF A_CBI_CDETRP   &
        SIZE 16                &
        DISPLAY

FIELD IMMCLE       OF ARCMD_DETAIL &
        LABEL "Équipement.:"       &
        LOOKUP ON IMIMMOBILISATION &
        MESSAGE 491 ; Cette immobilisation n'existe pas ou est inactive.

FIELD IMMDSC OF IMIMMOBILISATION DISPLAY SIZE 33


ALIGN (2,3,19)(,,24)(,41,50)(,72,85)(,,95)

FIELD CDEFAB OF ARCMD_DETAIL   &
        HIDDEN ID 25           &
        LOOKUP ON A_CBI_CDEFAB &
          MESSAGE 1365 ; Ce code de terme de commerce n'existe pas.

FIELD CBIDSC OF A_CBI_CDEFAB   &
        DISPLAY                &
        SIZE 16                
        
FIELD CDELIE OF ARCMD_DETAIL   &
        LABEL "Endroit:"

FIELD REQCLE OF ARCMD_DETAIL   &
        NOENTRY                &   ; Champs Display mais avec un popup détaillé
        LABEL "Réquisition:"                                
                                
FIELD REQDSC OF ARREQUISITION  &
        DISPLAY SIZE 36


ALIGN (2,3,19)(,,26)(,41,50)(,,59)(,72,85)(,,94)(,107,116)(,,120)
FIELD CPTCLE OF ARCMD_DETAIL     &
        HIDDEN ID 40             &
        REQUIRED                 &
        LOOKUP ON VCPT_DSC       &
          MESSAGE 1313 ; Ce compte n'existe pas.

FIELD CPTDSCABR OF VCPT_DSC      &
        DISPLAY                  &
        SIZE 14

FIELD UNACLE OF ARCMD_DETAIL     &  
        LABEL "Unité..:"         &
        REQUIRED                 &
        LOOKUP ON MCUNITE_ADM    &
          MESSAGE 1314 ; Cette unité administrative n'existe pas dans la charte.

FIELD UNANOMABR OF MCUNITE_ADM   &
        DISPLAY                  &
        SIZE 12

FIELD PRJCLE OF ARCMD_DETAIL     &
        LABEL "Projet.....:"

FIELD PRJDSC1 OF GPPROJETS       &
        DISPLAY                  &
        SIZE 12

FIELD PRACLE OF ARCMD_DETAIL     &
        LABEL "Sous-pr:"

FIELD PRADSC1 OF GPPRO_ACTIVITE  &
        DISPLAY &
        SIZE 11


ALIGN (2,3,19)(,41,50)(,72,85)

FIELD CDEQTECOM  OF ARCMD_DETAIL &
        HIDDEN ID 50             &
        PICTURE "^^^^^.^^^ "     &
        REQUIRED

FIELD CDEQTEREC OF ARCMD_DETAIL  &
        PICTURE  "^^^^^.^^^ "    &
        NOENTRY                  &
        LABEL "Qté rec:"

FIELD CDEPRIUNI OF ARCMD_DETAIL  &
        LABEL "Prix unit..:"



ALIGN (2,3,19)(,,22)(,41,50)(,72,85)(,,90)(,107,116)

FIELD CDETAXCODTPS OF ARCMD_DETAIL &
        HIDDEN ID 60

FIELD TAXDSCFRA OF A_TAX_TPS     &
        DISPLAY                  &
        SIZE 18

FIELD CDEMNTTPS OF ARCMD_DETAIL  &
        DISPLAY &
        LABEL "Mnt TPS:"
        
FIELD CDETERESCACH OF ARCMD_DETAIL &   
        LABEL "Terme esc..:"

FIELD TERDSCABR OF VTER_DSC      &
        DISPLAY                  &
        SIZE 16

FIELD CDEMNTESC OF ARCMD_DETAIL  &
        DISPLAY                  &
        LABEL "Mnt esc:"

    
        
ALIGN (2,3,19)(,,22)(,41,50)(,72,85)(,107,116)
        

FIELD CDETAXCODTVQ OF ARCMD_DETAIL &
        HIDDEN ID 65

FIELD TAXDSCFRA OF A_TAX_TVP     &
        DISPLAY                  &
        SIZE 18

FIELD CDEMNTTVQ OF ARCMD_DETAIL  &
        DISPLAY                  &
        LABEL "Mnt TVQ:"

FIELD CDEMNTTOT OF ARCMD_DETAIL  &
        DISPLAY                  &
        LABEL "Mnt brut...:"

FIELD CDEMNTNET OF ARCMD_DETAIL  &
        DISPLAY                  &
        LABEL "Mnt net:"        
        
SKIP 1 

CLUSTER

;-------------------------------------------------------------------------------
;
; Valide la sécurité d'accès de l'écran.
;
;
PROCEDURE INITIALIZE
BEGIN
  USE ussececr NOLIST
END

;-------------------------------------------------------------------------------
;
; Calcul du CTI = remboursement de TPS.
;
PROCEDURE INTERNAL CALCUL_CTI
BEGIN
  ;
  ; Il faut diminuer le cumulatif de taxe de la facture.
  ;
  LET CMDMNTCTI OF ARCOMMANDE = CMDMNTCTI OF ARCOMMANDE - &
                                   CDEMNTCTI OF ARCMD_DETAIL
  ;
  LET CDEMNTCTI OF ARCMD_DETAIL = 0

  ;
  ; Calcul du remboursement fédéral.
  ;
  LET CDEMNTCTI OF ARCMD_DETAIL = &
                ROUND( CDEMNTTPS OF ARCMD_DETAIL * TAXPCTCTI OF A_TAX_TPS )
  ;
  ; Il faut augmenter le cumulatif de taxe de la facture.
  ;
  LET CMDMNTCTI OF ARCOMMANDE = CMDMNTCTI OF ARCOMMANDE + &
                                   CDEMNTCTI OF ARCMD_DETAIL
END

;-------------------------------------------------------------------------------
;
; Calcul du RTI = remboursement de TVQ.
;
PROCEDURE INTERNAL CALCUL_RTI
BEGIN
  ;
  ; Il faut diminuer le cumulatif de taxe de la facture.
  ;
  LET CMDMNTRTI OF ARCOMMANDE = CMDMNTRTI OF ARCOMMANDE - &
                                   CDEMNTRTI OF ARCMD_DETAIL
  ;
  LET CDEMNTRTI OF ARCMD_DETAIL = 0

  ;
  ; Calcul du remboursement fédéral.
  ;
  LET CDEMNTRTI OF ARCMD_DETAIL = &
                ROUND( CDEMNTTVQ OF ARCMD_DETAIL * TAXPCTCTI OF A_TAX_TVP )
  ;
  ; Il faut augmenter le cumulatif de taxe de la facture.
  ;
  LET CMDMNTRTI OF ARCOMMANDE = CMDMNTRTI OF ARCOMMANDE + &
                                   CDEMNTRTI OF ARCMD_DETAIL
END



;-------------------------------------------------------------------------------
; Calcul des taxes (provinciale et fédérale)
;
PROCEDURE INTERNAL CALCUL_TAXES
BEGIN
  ;
  ; Enlève les anciennes valeurs des totaux
  ;
  LET CMDMNTTPS OF ARCOMMANDE = CMDMNTTPS OF ARCOMMANDE - &
                                   CDEMNTTPS OF ARCMD_DETAIL

  LET CMDMNTTVQ OF ARCOMMANDE = CMDMNTTVQ OF ARCOMMANDE - &
                                   CDEMNTTVQ OF ARCMD_DETAIL
  ;
  LET CDEMNTTPS OF ARCMD_DETAIL = 0
  LET CDEMNTTVQ OF ARCMD_DETAIL = 0
  ;
  ; On prend le montant brut de la ligne de commande pour le calcul des taxes.
  ;
  LET TZ_MNTTXB = CDEMNTTOT OF ARCMD_DETAIL
  ;
  ; Use standard pour le calcul des taxes
  ;
  USE ustaxcal NOLIST

  LET CDEMNTTPS OF ARCMD_DETAIL = TZ_MNTTPS
  LET CDEMNTTVQ OF ARCMD_DETAIL = TZ_MNTTVP

  LET CMDMNTTPS OF ARCOMMANDE = CMDMNTTPS OF ARCOMMANDE + &
                                CDEMNTTPS OF ARCMD_DETAIL

  LET CMDMNTTVQ OF ARCOMMANDE = CMDMNTTVQ OF ARCOMMANDE + &
                                CDEMNTTVQ OF ARCMD_DETAIL

  ;
  ; Si le mode de taxation est "EN SUS", il faut mettre à jour le cumulatif brut
  ; de la commande.
  ;
  IF TAXMOD OF A_TAX_TPS = "S"
  THEN BEGIN
    LET CMDMNTTOT OF ARCOMMANDE   = CMDMNTTOT OF ARCOMMANDE   + &
                                      CDEMNTTPS    OF ARCMD_DETAIL

    LET CDEMNTTOT OF ARCMD_DETAIL = CDEMNTTOT OF ARCMD_DETAIL  + &
                                      CDEMNTTPS    OF ARCMD_DETAIL

  END


  IF TAXMOD OF A_TAX_TVP = "S"
  THEN BEGIN
     LET CMDMNTTOT OF ARCOMMANDE   = CMDMNTTOT OF ARCOMMANDE   + &
                                       CDEMNTTVQ    OF ARCMD_DETAIL

     LET CDEMNTTOT OF ARCMD_DETAIL = CDEMNTTOT OF ARCMD_DETAIL + &
                                       CDEMNTTVQ    OF ARCMD_DETAIL

  END

  ;
  ; Calcul des montants de taxe remboursables (CTI & RTI)
  ;
  DO INTERNAL CALCUL_CTI
  DO INTERNAL CALCUL_RTI

  LET CDEMNTNET    OF ARCMD_DETAIL =  CDEMNTTOT OF ARCMD_DETAIL - &
                                      CDEMNTTPS OF ARCMD_DETAIL - &
                                      CDEMNTTVQ OF ARCMD_DETAIL

  LET CMDMNTNET    OF ARCOMMANDE   =  CMDMNTTOT OF ARCOMMANDE   - &
                                      CMDMNTTPS OF ARCOMMANDE   - &
                                      CMDMNTTVQ OF ARCOMMANDE

  DISPLAY CDEMNTESC OF ARCMD_DETAIL
  DISPLAY CDEMNTTOT OF ARCMD_DETAIL
  DISPLAY CDEMNTNET OF ARCMD_DETAIL
END


;-------------------------------------------------------------------------------
; Calcul de l'escompte si le terme du fournisseur est spécifié.
;
PROCEDURE INTERNAL CALCUL_ESCOMPTE
BEGIN
  LET CMDMNTESC OF ARCOMMANDE = CMDMNTESC OF ARCOMMANDE - &
                                CDEMNTESC OF ARCMD_DETAIL

  LET CDEMNTESC OF ARCMD_DETAIL = 0


  ; On calcule le montant d'escompte en utilisant le pourcentage d'escompte
  ; du terme.

  IF CDETERESCACH OF ARCMD_DETAIL <> ""
  THEN BEGIN
    LET CDEMNTESC OF ARCMD_DETAIL = ROUND ( CDEMNTNET OF ARCMD_DETAIL * &
                                            TERPCT    OF VTER_DSC )

    LET CMDMNTESC OF ARCOMMANDE  = CMDMNTESC OF ARCOMMANDE + &
                                   CDEMNTESC OF ARCMD_DETAIL

    LET CMDMNTTOT OF ARCOMMANDE = CMDMNTTOT OF ARCOMMANDE - &
                                  CDEMNTESC OF ARCMD_DETAIL

    LET CDEMNTTOT OF ARCMD_DETAIL = CDEMNTTOT OF ARCMD_DETAIL - &
                                    CDEMNTESC OF ARCMD_DETAIL


    IF TAXMOD OF A_TAX_TPS = "S"
    THEN LET CDEMNTTOT OF ARCMD_DETAIL = CDEMNTTOT OF ARCMD_DETAIL - &
                                         CDEMNTTPS OF ARCMD_DETAIL

    IF TAXMOD OF A_TAX_TVP = "S"
    THEN LET CDEMNTTOT OF ARCMD_DETAIL = CDEMNTTOT OF ARCMD_DETAIL - &
                                         CDEMNTTVQ OF ARCMD_DETAIL

    ; On recalcule les taxes pour tenir compte de l'escompte.
    ;
    IF 0 <> CDEMNTESC OF ARCMD_DETAIL
    THEN BEGIN
      IF TAXMOD OF A_TAX_TPS = "S"
      THEN LET CMDMNTTOT OF ARCOMMANDE = CMDMNTTOT OF ARCOMMANDE - &
                                           CDEMNTTPS OF ARCMD_DETAIL

      IF TAXMOD OF A_TAX_TVP = "S"
      THEN LET CMDMNTTOT OF ARCOMMANDE = CMDMNTTOT OF ARCOMMANDE - &
                                           CDEMNTTVQ OF ARCMD_DETAIL

      DO INTERNAL CALCUL_TAXES
    END
  END
END



;-------------------------------------------------------------------------------
;
; Calcul des montants et des taxes.
;
PROCEDURE INTERNAL CALCUL_MONTANT
BEGIN
  ;
  ; Calcul du montant brut du produit
  ;
  LET CMDMNTTOT OF ARCOMMANDE  = CMDMNTTOT OF ARCOMMANDE - &
                                 CDEMNTTOT OF ARCMD_DETAIL
  ;
  ; La division par 100000 représente les 3 chiffres après le point pour
  ; les qtes et 2 chiffres pour les décimales 3 et 4 du prix unitaire.
  ;
  LET CDEMNTTOT OF ARCMD_DETAIL = &
    ROUND ( CDEQTECOM OF ARCMD_DETAIL * &
            CDEPRIUNI OF ARCMD_DETAIL /100000 )

  LET CMDMNTTOT OF ARCOMMANDE = CMDMNTTOT OF ARCOMMANDE + &
                                CDEMNTTOT OF ARCMD_DETAIL



  ; Cette procédure calcule les montants de taxe ainsi que les montants de
  ; CTI et RTI.

  DO INTERNAL CALCUL_TAXES


  ; On calcule l'escompte.
  ;
  DO INTERNAL CALCUL_ESCOMPTE


  LET CDEMNTENG OF ARCMD_DETAIL = ROUND( (CDEMNTNET OF ARCMD_DETAIL + &
                                  CDEMNTTPS OF ARCMD_DETAIL + &
                                  CDEMNTTVQ OF ARCMD_DETAIL - &
                                  CDEMNTCTI OF ARCMD_DETAIL - &
                                  CDEMNTRTI OF ARCMD_DETAIL) * &
                                  DEVTAU OF ARCMD_DETAIL)



  ; On affiche les variables modifiées par les calculs.
  ;
  DISPLAY CDEMNTTPS OF ARCMD_DETAIL
  DISPLAY CDEMNTTVQ OF ARCMD_DETAIL
  DISPLAY CDEMNTTOT OF ARCMD_DETAIL
  DISPLAY CDEMNTESC OF ARCMD_DETAIL
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE INPUT CDECLE
BEGIN
  USE ussecent NOLIST
END

;------------------------------------------------------------------------------
; Cette procédure permet de faire un écran dépisteur pour les produits
; de l'entrepôt.
;
PROCEDURE INPUT PRDCLE
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_ENTCLE = ENTCLE OF ARCOMMANDE
    LET T_PRDCLE = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN ar103 MODE F PASSING T_CIECLEMNU, T_ENTCLE, T_PRDCLE  &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_PRDCLE)
  END
  ELSE BEGIN
    USE usinpprd NOLIST
  END
END

;-------------------------------------------------------------------------------
; Cette procédure permet de valider que le statut du produit est actif
;
PROCEDURE EDIT PRDCLE
BEGIN
  IF PRDSTU OF VPRE_PRD = "I"
  THEN ERROR 1374 ; Ce produit est inactif.
END

;-------------------------------------------------------------------------------
; Cette procédure permet d'affecter la première ligne de description du produit
; sur la ligne de commande si le type de produit n'est pas divers. Elle permet
; aussi de prendre le prix unitaire par défaut de l'entrepôt.
;
PROCEDURE PROCESS PRDCLE
BEGIN

  LET PRDTYP OF ARCMD_DETAIL = PRDTYP OF VPRE_PRD

  IF PRDTYP OF VPRE_PRD <> "D"
  THEN LET CDEDSCPRD OF ARCMD_DETAIL = PRDDSC1 OF VPRE_PRD
  ELSE LET CDEDSCPRD OF ARCMD_DETAIL = ""
  DISPLAY CDEDSCPRD

   ; On prend le dernier coûtant chez le fournisseur s'il est différent de
   ; zéro sinon on prend celui de l'entrepôt. Dans le cas, où il est à zéro
   ; il sera alors saisi plus tard. Si c'est celui de l'entrepôt, il faut
   ; réajuster selon la devise.
   ;
  IF PDFDERCOU OF ARPRD_FOU <> 0
  THEN LET CDEPRIUNI OF ARCMD_DETAIL = PDFDERCOU OF ARPRD_FOU
  ELSE BEGIN
   IF DEVCLE OF VFOC_FOU <> DEVCLE OF MCHOLDING
   THEN LET CDEPRIUNI OF ARCMD_DETAIL = ROUND(PREDERCOU OF VPRE_PRD / &
                                              DEVTAU OF MCDEVISE)
   ELSE LET CDEPRIUNI OF ARCMD_DETAIL = PREDERCOU OF VPRE_PRD
  END


  DISPLAY CDEPRIUNI

  DO INTERNAL CALCUL_MONTANT
END


;-------------------------------------------------------------------------------
; Cette procédure permet de valider la quantité commandée du produit lorsqu'une
; gestion des maximums s'applique.
;
PROCEDURE EDIT CDEQTECOM
BEGIN
  USE usvalmul NOLIST ; Pour valider la quantité s'il y a une restriction de
                      ; format.
  IF    PREFLGGESMAX OF VPRE_PRD = "1"  &
    AND D_PRDQTETOT > PREQTEMAX OF VPRE_PRD
  THEN ERROR 1375 ; La quantité commandée dépasse le maximum permis dans
                  ; l'entrepôt.
END


;-------------------------------------------------------------------------------
; Cette procédure permet de faire l'appel du calcul des montants.
;
PROCEDURE PROCESS CDEQTECOM
BEGIN
  DO INTERNAL CALCUL_MONTANT
END

;------------------------------------------------------------------------------
;
; Procédure qui appel la ou les réceptions.
;
PROCEDURE INPUT CDEQTEREC
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_RECCLEFND = CMDCLE    OF ARCOMMANDE
    LET T_FOUCIECLE = FOUCIECLE OF ARCOMMANDE
    RUN SCREEN ar009 MODE F PASSING     T_CIECLEMNU, &
                                        T_CIENOM   , &
                                        T_PECCLE   , &
                                        T_FOUCIECLE, &
                                        T_RECCLEFND
  END
  LET FIELDTEXT = ""
END
;-------------------------------------------------------------------------------
;
; Sous-écran de consultation des codes de taxe.
;
PROCEDURE INPUT CDETAXCODTPS
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_TAXCLETYP = CDETAXTYPTPS OF ARCMD_DETAIL
    LET T_TAXCLECOD = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    LET T_TAXMODPAT = "@"
    RUN SCREEN mc111 MODE F PASSING T_TAXCLETYP, &
                                    T_TAXCLECOD, &
                                    T_TAXMODPAT &
                                    WINDOW WIDTH CONSTANT WHEN CALLING

    LET FIELDTEXT = TRUNCATE(T_TAXCLECOD)
  END

  ;
  ; Par défaut on utilise le code de taxe de TPS du fournisseur.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDETAXCODTPS OF ARCMD_DETAIL = "" &
     AND FOCTAXCODTPS OF VFOC_FOU <> ""
  THEN LET FIELDTEXT = FOCTAXCODTPS OF VFOC_FOU

END

;-------------------------------------------------------------------------------
;
;
; Validation du code de taxe fédéral.
;
;
PROCEDURE EDIT CDETAXCODTPS
BEGIN
  IF 0 <> SIZE(TRUNCATE(FIELDTEXT))
  THEN BEGIN
    GET A_TAX_TPS OPTIONAL
    IF NOT ACCESSOK
    THEN ERROR 1376 ; Ce code de taxe n'existe pas.
  END
  ;
  ; Initialise le flag à Oui dans la procédure EDIT. Car si l'usager saisi
  ; une valeur la procédure EDIT est exécutée.
  ;
  LET T_FLGMOD = "1"
END

;-------------------------------------------------------------------------------
;
; Force le calcul de montant de taxe
;
PROCEDURE PROCESS CDETAXCODTPS
BEGIN
  EDIT CDETAXCODTVQ OF ARCMD_DETAIL
END

;-------------------------------------------------------------------------------
;
;
; Sous-écran de consultation des codes de taxe.
;
;
PROCEDURE INPUT CDETAXCODTVQ
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_TAXCLETYP = CDETAXTYPTVQ OF ARCMD_DETAIL
    LET T_TAXCLECOD = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    LET T_TAXMODPAT = "@"
    RUN SCREEN mc111 MODE F PASSING T_TAXCLETYP, &
                                    T_TAXCLECOD, &
                                    T_TAXMODPAT &
                                    WINDOW WIDTH CONSTANT WHEN CALLING

    LET FIELDTEXT = TRUNCATE(T_TAXCLECOD)
  END

  ;
  ; Par défaut on utilise le code de taxe de TVQ du fournisseur.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDETAXCODTVQ OF ARCMD_DETAIL = "" &
     AND FOCTAXCODTVQ OF VFOC_FOU <> ""
  THEN LET FIELDTEXT = FOCTAXCODTVQ OF VFOC_FOU

  ;
  ; Force l'éxécution de la procédure edit, car il y a une relation entre
  ; deux champs(taxe).
  ;
  IF    NOT FINDMODE  &
    AND 0 = SIZE(FIELDTEXT) &
    AND T_FLGMOD = "1"
  THEN LET FIELDTEXT = CDETAXCODTVQ OF ARCMD_DETAIL
END


;-------------------------------------------------------------------------------
;
;
; Validation du code de taxe provincial
;
;
PROCEDURE EDIT CDETAXCODTVQ
BEGIN
  IF 0 <> SIZE(TRUNCATE(FIELDTEXT))
  THEN BEGIN
    GET A_TAX_TVP OPTIONAL
    IF NOT ACCESSOK
    THEN ERROR 1376 ; Ce code de taxe n'existe pas.
  END

  IF    TAXMOD    OF A_TAX_TVP = "I" &
    AND TAXFLGNET OF A_TAX_TVP = "2" &
    AND TAXMOD    OF A_TAX_TPS = "S"
  THEN ERROR 1379 ; Codes de taxe TVQ inclus et TPS en sus sont incompatibles.
END

;-------------------------------------------------------------------------------
; Cette procédure permet de faire l'appel de la procédure de calcul des montants.
;
;
PROCEDURE PROCESS CDETAXCODTVQ
BEGIN
  DO INTERNAL CALCUL_MONTANT
END

;-------------------------------------------------------------------------------
; Consultation des termes d'escompte d'achat.
;
;
PROCEDURE INPUT CDETERESCACH
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_TERCAT = "ESC"
    LET T_TERCLE = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN cp102 MODE F PASSING T_TERCLE, T_TERCAT &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_TERCLE)
  END
  ;
  ; Par défaut on utilise le code de terme escompte d'achat du fournisseur.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDETERESCACH OF ARCMD_DETAIL = "" &
     AND FOCTERESCACH OF VFOC_FOU <> ""
  THEN LET FIELDTEXT = FOCTERESCACH OF VFOC_FOU
END

;-------------------------------------------------------------------------------
; Cette procédure permet de valider que le terme saisi est de type ESC
; (escompte)
;
PROCEDURE EDIT CDETERESCACH
BEGIN
  IF 0 <> SIZE (TRUNCATE (FIELDTEXT) )
  THEN BEGIN
    GET VTER_DSC  OPTIONAL
    IF NOT ACCESSOK
    THEN ERROR 1377 ; Ce terme d'escompte d'achat n'existe pas.

    ELSE BEGIN
      IF TERCAT OF VTER_DSC <> "ESC"
      THEN ERROR 1378 ; Ce terme n'est pas de type escompte.
    END
  END

END

;-------------------------------------------------------------------------------
; Cette procédure permet de faire l'appel de la procédure de calcul des montants.
;
;
PROCEDURE PROCESS CDETERESCACH
BEGIN
  DO INTERNAL CALCUL_MONTANT
END

;-------------------------------------------------------------------------------
;
; Appel du popup pour le code bilingue statut de la commande.
;
;
PROCEDURE INPUT CDESTU
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_CDESTU = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN mc102 MODE F PASSING D_CDESTU, T_CDESTU &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_CDESTU)
  END
END

;-------------------------------------------------------------------------------
; Cette procédure permet de valider que le seul statut modifiable est " "
; (saisie) ou "S" et que la seule valeur permise en saisie est "X" (annulée)
; lorsque la commande est approuvée.
;
PROCEDURE EDIT CDESTU
BEGIN
  IF    T_CDESTUOLD = "X" &
     OR T_CDESTUOLD = "C" &
     OR CMDSTU OF ARCOMMANDE = "P" &
     OR CMDSTU OF ARCOMMANDE = "C"
  THEN ERROR 1360 ; On ne peut pas changer le statut de la commande.

  IF FIELDTEXT <> "X" AND FIELDTEXT <> " "
  THEN ERROR 1370 ; Cette valeur n'est pas permise.

END



;-------------------------------------------------------------------------------
; Procédure pour le dépisteur du numéro de compte.
;
PROCEDURE INPUT CPTCLE
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_CPTCLE    = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    LET T_PECCLE    = " "
    LET T_CPTTYPPAT = "@"
    LET T_CPTCATPAT = "@"
    RUN SCREEN mc103 MODE F PASSING T_CPTCLE   , &
                                    T_CPTTYPPAT, &
                                    T_CPTCATPAT, &
                                    T_PECCLE     &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_CPTCLE)
  END

  ;
  ; Par défaut on utilise le compte d'inventaire du produit.
  ;
  IF 0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CPTCLE    OF ARCMD_DETAIL = ""
  THEN LET FIELDTEXT = PRDCPTINV OF VPRE_PRD


END

;-------------------------------------------------------------------------------
;
;
; Validation si le compte est actif.
;
;
PROCEDURE EDIT CPTCLE
BEGIN
  ;
  ; Note: La période de fin, est la première période d'inactivité.
  ;
  ; Ajustement pour le changement de siècle
  IF CPTPECDEBA OF VCPT_DSC[1:1] < "8"
  THEN LET D_CPTPECDEBA_VCPT = "1" + CPTPECDEBA OF VCPT_DSC
  ELSE LET D_CPTPECDEBA_VCPT = "0" + CPTPECDEBA OF VCPT_DSC

  ; Ajustement pour le changement de siècle
  IF CPTPECDEBI OF VCPT_DSC[1:1] < "8"
  THEN LET D_CPTPECDEBI_VCPT = "1" + CPTPECDEBI OF VCPT_DSC
  ELSE LET D_CPTPECDEBI_VCPT = "0" + CPTPECDEBI OF VCPT_DSC

  ; Ajustement pour le changement de siècle
  IF PECCLE OF ARCOMMANDE[1:1] < "8"
  THEN LET D_PECCLE_ARCOMMANDE = "1" + PECCLE OF ARCOMMANDE
  ELSE LET D_PECCLE_ARCOMMANDE = "0" + PECCLE OF ARCOMMANDE

  IF D_PECCLE_ARCOMMANDE >= D_CPTPECDEBA_VCPT AND &
     ( &
       D_PECCLE_ARCOMMANDE < D_CPTPECDEBI_VCPT OR &
       CPTPECDEBI OF VCPT_DSC = "" &
     )
  THEN NULL
  ELSE ERROR 1380 ; Ce compte est inactif.

  IF CPTTYP OF VCPT_DSC <> "R"
  THEN ERROR 1381 ; On ne peut pas utiliser ce compte dans une commande.

  IF     DEVCLE OF VCPT_DSC <> DEVCLE OF VFOC_FOU  &
     AND DEVCLE OF VCPT_DSC <> DEVCLE OF MCHOLDING
  THEN ERROR 1382 ; On ne peut pas utiliser ce compte à cause de la devise.
END

PROCEDURE PROCESS CPTCLE
BEGIN
  IF NACCLE OF MCNATURE_CTB <> 4 AND &
     NACCLE OF MCNATURE_CTB <> 5
  THEN BEGIN
    LET PRJCLE OF ARCMD_DETAIL = ""
    LET PRACLE OF ARCMD_DETAIL = ""
    DISPLAY PRJCLE  OF ARCMD_DETAIL
    DISPLAY PRJDSC1 OF GPPROJETS
    DISPLAY PRACLE  OF ARCMD_DETAIL
    DISPLAY PRADSC1 OF GPPRO_ACTIVITE
  END
END


;-------------------------------------------------------------------------------
;
;
PROCEDURE INPUT UNACLE
BEGIN
  ;
  ; Popup sur les unités administratives.
  ;
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_CPTCLE = CPTCLE OF ARCMD_DETAIL
    LET T_PECCLE = PECCLE OF ARCOMMANDE
    LET T_UNACLE = FIELDTEXT[1:IND(FIELDTEXT,"*") - 1] + "@"
    ;
    ; Il y a trois popup possible:
    ;  1) sur les unités administrative par compagnie(MCUNITE_ADM).
    ;  2) sur les unités administrative d'une charte de compte(MCCHARTE_UNA).
    ;  3) sur les unités administrative qui ne sont pas définis dans la charte
    ;     de compte(MCUNITE_ADM, MCCHARTE_UNA).
    ;
    IF HLDCHTCPT OF MCHOLDING = "0"
    THEN RUN SCREEN mc104 MODE F PASSING T_CIECLEMNU, T_UNACLE
    ELSE BEGIN
      IF HLDCHTCPTRLT OF MCHOLDING = "I"
      THEN RUN SCREEN mc115 MODE F PASSING T_CIECLEMNU, T_CPTCLE, T_UNACLE, &
                                           T_PECCLE
      ELSE RUN SCREEN mc116 MODE F PASSING T_CIECLEMNU, T_CPTCLE, T_UNACLE, &
                                           T_PECCLE
    END
    LET FIELDTEXT = TRUNCATE(T_UNACLE)
  END
  ;
  ; Par défaut on utilise l'unité administrative du produit.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND UNACLE    OF ARCMD_DETAIL = "" &
     AND PRDUNAINV OF VPRE_PRD <> ""
  THEN LET FIELDTEXT = PRDUNAINV OF VPRE_PRD

  ;
  ; Force le lookup de l'unité pour la charte.
  ;
  IF NOT FINDMODE AND &
     0 = SIZE(FIELDTEXT) AND &
     0 <> SIZE(TRUNCATE(UNACLE OF ARCMD_DETAIL))
  THEN LET FIELDTEXT = UNACLE OF ARCMD_DETAIL
END


;-------------------------------------------------------------------------------
;
;
; Validation si l'unité administrative est active.
;
;
PROCEDURE EDIT UNACLE
BEGIN
  IF HLDCHTCPT OF MCHOLDING = "1"
  THEN BEGIN
    GET MCCHARTE_UNA OPTIONAL
    ;
    ; Si la charte est incluse, le lien est obligatoire.
    ;
    IF NOT ACCESSOK
    THEN BEGIN
      IF HLDCHTCPTRLT OF MCHOLDING = "I"
      THEN ERROR 1314 ; La combinaison compte/unité administrative n'existe pas.
    END
    ELSE BEGIN
      ;
      ; Si la charte est Exclusive et que la période fait partie de
      ; l'intervalle de périodes de la charte alors c'est une erreur.
      ;
      ; Si la charte est inclusive et que la période ne fait pas partie de
      ; l'intervalle de périodes de la charte alors c'est une erreur.
      ;
      ; Ajustement pour le changement de siècle
      IF PECCLE OF ARCOMMANDE[1:1] < "8"
      THEN LET T_PECCLE_ARCOMMANDE = "1" + PECCLE OF ARCOMMANDE
      ELSE LET T_PECCLE_ARCOMMANDE = "0" + PECCLE OF ARCOMMANDE

      ; Ajustement pour le changement de siècle
      IF CCUPECDEBA OF MCCHARTE_UNA[1:1] < "8"
      THEN LET D_CCUPECDEBA_MCCHARTE = "1" + CCUPECDEBA OF MCCHARTE_UNA
      ELSE LET D_CCUPECDEBA_MCCHARTE = "0" + CCUPECDEBA OF MCCHARTE_UNA

      ; Ajustement pour le changement de siècle
      IF CCUPECDEBI OF MCCHARTE_UNA[1:1] < "8"
      THEN LET D_CCUPECDEBI_MC = "1" + CCUPECDEBI OF MCCHARTE_UNA
      ELSE LET D_CCUPECDEBI_MC = "0" + CCUPECDEBI OF MCCHARTE_UNA

      IF ( &
           T_PECCLE_ARCOMMANDE >= D_CCUPECDEBA_MCCHARTE AND &
           ( &
             T_PECCLE_ARCOMMANDE < D_CCUPECDEBI_MC OR &
             CCUPECDEBI OF MCCHARTE_UNA = " " &
           ) &
         )
      THEN BEGIN
        IF HLDCHTCPTRLT OF MCHOLDING = "E"
        THEN ERROR 1384 ; La combinaison compte/unité administrative est inactive.
      END
      ELSE BEGIN
        IF HLDCHTCPTRLT OF MCHOLDING = "I"
        THEN ERROR 1384 ; La combinaison compte/unité administrative est inactive.
      END
    END
  END
END

;-------------------------------------------------------------------------------
;
;
; Popup sur les projets.
;
;
PROCEDURE INPUT PRJCLE
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_PRJSTUPAT = "A"
    LET T_PRJCLE    = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN gp104 MODE F PASSING T_CIECLEMNU, &
                                    T_PRJCLE   , &
                                    T_PRJSTUPAT WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_PRJCLE)
  END

  ;
  ; Pour forcer la procédure EDIT
  ;
  IF      NOT FINDMODE &
    AND 0  = SIZE (TRUNCATE(FIELDTEXT)) &
    AND "" <> TRUNCATE (PRJCLE OF ARCMD_DETAIL)
  THEN LET FIELDTEXT = PRJCLE OF ARCMD_DETAIL

  IF (HLDNTNPRO OF MCHOLDING    = "1" AND &
      NACCLE    OF MCNATURE_CTB = 4   AND &
      FIELDTEXT                 = "" ) OR &
     (HLDNTNPRO OF MCHOLDING    = "1" AND &
      NACCLE    OF MCNATURE_CTB = 5   AND &
      FIELDTEXT                 = "" )
  THEN ERROR 889

END


;-------------------------------------------------------------------------------
;
;
; Validation du projet, le projet est optionnel dans la ligne de commande.
;
;
PROCEDURE EDIT PRJCLE
BEGIN
 GET GPPROJETS  OPTIONAL
 IF NOT ACCESSOK
 THEN ERROR 1385 ; Ce projet n'existe pas.

 IF PRJSTU OF GPPROJETS <> "A"
 THEN ERROR 1386 ; Ce projet n'est pas actif.
END

PROCEDURE PROCESS PRJCLE
BEGIN
  IF 0 = SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
  THEN BEGIN
    LET PRACLE OF ARCMD_DETAIL = " "
    DISPLAY PRACLE OF ARCMD_DETAIL
  END
END
;-------------------------------------------------------------------------------
;
;
PROCEDURE INPUT PRACLE
BEGIN
  IF PRJCLE OF ARCMD_DETAIL = ""
  THEN ERROR 889
  ;
  ; Popup sur les activités.
  ;
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_PRJCLE    = PRJCLE OF ARCMD_DETAIL
    LET T_PRASTUPAT = "A"
    LET T_PRACLE    = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN gp108 MODE F PASSING T_CIECLEMNU, &
                                    T_PRJCLE   , &
                                    T_PRACLE   , &
                                    T_PRASTUPAT WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_PRACLE)
  END

  ;
  ; Force le lookup de l'activité car il est en liaison avec le projet
  ;
  IF NOT FINDMODE AND &
     0 = SIZE(FIELDTEXT) AND &
     0 <> SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
  THEN LET FIELDTEXT = PRACLE OF ARCMD_DETAIL
END


;-------------------------------------------------------------------------------
;
;
; Validation de l'activité, l'activité est optionnelle dans la ligne de commande.
;
;
PROCEDURE EDIT PRACLE
BEGIN
  GET GPPRO_ACTIVITE  OPTIONAL
  IF NOT ACCESSOK
  THEN ERROR 1387 ; Cette activité n'existe pas.

  IF PRASTU OF GPPRO_ACTIVITE <> "A"
  THEN ERROR 1388 ; Cette activité est inactive.
END

;-------------------------------------------------------------------------------
; Pop up pour la catégorie d'équipement
;
PROCEDURE INPUT IMMCLE
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_IMMCLE = FIELDTEXT[1:IND(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN im102 MODE F &
                     PASSING T_CIECLEMNU, &
                             T_IMMCLE  WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE( T_IMMCLE )
  END

  ;
  ; Par défaut on utilise la catégorie définie dans GPPROJETS S'il n'y en a pas
  ; on force la validation.
  ;
  IF     0 = SIZE(FIELDTEXT) &
     AND 0 = SIZE(TRUNCATE(IMMCLE OF ARCMD_DETAIL))
  THEN BEGIN
     IF 0 <> SIZE(TRUNCATE(PRAIMMCLE OF GPPRO_ACTIVITE))
     THEN LET FIELDTEXT = PRAIMMCLE OF GPPRO_ACTIVITE
     ELSE LET FIELDTEXT = IMMCLE OF ARCMD_DETAIL
  END
END


PROCEDURE EDIT IMMCLE
BEGIN
   IF IMMTYP OF IMIMMOBILISATION <> "E"
   THEN ERROR 1503
END

;-------------------------------------------------------------------------------
;
;
PROCEDURE INPUT CDEPRIUNI
BEGIN
  ;
  ; Popup sur le dernier coûtant du produit.
  ;
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_PRDCLE    = PRDCLE OF ARCMD_DETAIL
    LET T_CDEPRIUNI = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN ar104 MODE F PASSING T_CIECLEMNU, T_PRDCLE, T_CDEPRIUNI &
                       WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_CDEPRIUNI)
  END

  ;
  ; Par défaut on utilise le dernier coûtant du produit de l'entrepôt.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDEPRIUNI OF ARCMD_DETAIL = 0 &
     AND PREDERCOU OF VPRE_PRD <> 0
  THEN LET FIELDTEXT = ASCII(PREDERCOU OF VPRE_PRD,11)[1:7] + "." + &
                       ASCII(PREDERCOU OF VPRE_PRD,11)[8:4]


  ;
  ; Force l'éxécution de la procédure EDIT si non présent sur le produit
  ; entrepôt car ce champ est obligatoire.
  ;
  IF NOT FINDMODE AND &
     0 = SIZE(FIELDTEXT)
  THEN LET FIELDTEXT = ASCII(CDEPRIUNI OF ARCMD_DETAIL,11)[1:7] + "." + &
                       ASCII(CDEPRIUNI OF ARCMD_DETAIL,11)[8:4]
END


;-------------------------------------------------------------------------------
; Cette procédure permet de valider que le prix unitaire est saisi dans le cas
; où le dernier coûtant n'est pas présent dans la table ARPRD_ENT.
;
PROCEDURE EDIT CDEPRIUNI
BEGIN
  IF FIELDVALUE = 0
  THEN ERROR 1383 ; Vous devez saisir le prix unitaire du produit.
END




;-------------------------------------------------------------------------------
; Cette procédure permet de faire l'appel de la procédure de calcul des taxes.
;
;
PROCEDURE PROCESS CDEPRIUNI
BEGIN
  DO INTERNAL CALCUL_MONTANT
END

;-------------------------------------------------------------------------------
;
; Appel du popup pour le code bilingue mode de transport.
;
;
PROCEDURE INPUT CDETRP
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_CDETRP = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN mc102 MODE F PASSING D_CDETRP, T_CDETRP &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_CDETRP)
  END


  ;
  ; Par défaut on utilise le code de transport du fournisseur.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDETRP    OF ARCMD_DETAIL = ""
  THEN BEGIN
     IF CMDTRP    OF VFOC_FOU <> ""
     THEN LET FIELDTEXT = CMDTRP OF VFOC_FOU
     ELSE LET FIELDTEXT = CDETRP OF ARCMD_DETAIL
  END
END


;-------------------------------------------------------------------------------
;
; Appel du popup pour le code bilingue code de terme de commerce
;
;
PROCEDURE INPUT CDEFAB
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*")
  THEN BEGIN
    LET T_CDEFAB = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    RUN SCREEN mc102 MODE F PASSING D_CDEFAB, T_CDEFAB &
                            WINDOW WIDTH CONSTANT WHEN CALLING
    LET FIELDTEXT = TRUNCATE(T_CDEFAB)
  END


  ;
  ; Par défaut on utilise le code de transport du fournisseur.
  ;
  IF     0 = SIZE( FIELDTEXT ) &
     AND NEWRECORD OF ARCMD_DETAIL &
     AND CDEFAB    OF ARCMD_DETAIL = ""
  THEN BEGIN
    IF CMDFAB    OF VFOC_FOU <> ""
    THEN LET FIELDTEXT = CMDFAB OF VFOC_FOU
    ELSE LET FIELDTEXT = CDEFAB OF ARCMD_DETAIL
  END
END

;-------------------------------------------------------------------------------
;
; Appel de l'écran dépisteur pour le numéro de réquisition.
;
;
PROCEDURE INPUT REQCLE
BEGIN
  IF 0 <> INDEX(FIELDTEXT,"*") AND &
     0 <> SIZE( TRUNCATE( REQCLE OF ARCMD_DETAIL ) )
  THEN BEGIN
    LET T_REQCLEFND = FIELDTEXT[1:INDEX(FIELDTEXT,"*") - 1] + "@"
    LET T_REQCLENUMFND = 0
    RUN SCREEN ar006 MODE F PASSING     T_CIECLEMNU, &
                                        T_CIENOM   , &
                                        T_PECCLEMNU, &
                                        T_FOUCIECLE, &
                                        T_REQCLEFND, &
                                        T_REQCLENUMFND
  END
  ;
  ; Ce Champs est non modifiable, seul l'appel de popup est permis.
  ;
  LET FIELDTEXT = REQCLE OF ARCMD_DETAIL
END

;-------------------------------------------------------------------------------
;
;
PROCEDURE POSTFIND
BEGIN
  FOR ARCMD_DETAIL
  BEGIN
    ; Il faut conserver l'ancien statut de la ligne pour permettre ou non
    ; la modification.
    ;

    LET T_CDESTUOLD = CDESTU OF ARCMD_DETAIL

    ;
    ; Il faut conserver l'ancienne valeur qui a servi à incrémenter le cumulatif
    ; des montants bruts(incluant taxe). Il faut prendre les informations du
    ; code de taxe précédemment saisi, c'est pour cette raison que le traitement
    ; est fait dans cette procédure.
    ;
    LET T_TAXMODTPSOLD = TAXMOD OF A_TAX_TPS
    LET T_TAXMODTVQOLD = TAXMOD OF A_TAX_TVP
  END
END


;-------------------------------------------------------------------------------
;
;
PROCEDURE POSTUPDATE
BEGIN
  FOR ARCMD_DETAIL
  BEGIN
    ; Il faut conserver l'ancien statut de la ligne pour permettre ou non
    ; la modification.
    ;

    LET T_CDESTUOLD = CDESTU OF ARCMD_DETAIL


    ;
    ; Il faut conserver l'ancienne valeur qui a servi à incrémenter le cumulatif
    ; des montants bruts(incluant taxe). Il faut prendre les informations du
    ; code de taxe précédemment saisi, c'est pour cette raison que le traitement
    ; est fait dans cette procédure.
    ;
    LET T_TAXMODTPSOLD = TAXMOD OF A_TAX_TPS
    LET T_TAXMODTVQOLD = TAXMOD OF A_TAX_TVP
  END
END


;-------------------------------------------------------------------------------
; Cette procédure permet de mettre à jour les engagements losrque la commande
; est approuvée.  A noter qu'un trigger met à jour les soldes annuels du grand
; livre.
;
PROCEDURE INTERNAL MAJ_ENGAGEMENTS
BEGIN

  LET T_CPTLIG = T_CPTLIG + 1

  LET HENCLE       OF MCHIS_ECR_ENG = HENCLE      OF ARCOMMANDE
  LET CPTCLE       OF MCHIS_ECR_ENG = CPTCLE      OF ARCMD_DETAIL
  LET UNACLE       OF MCHIS_ECR_ENG = UNACLE      OF ARCMD_DETAIL
  LET CIECLE       OF MCHIS_ECR_ENG = CIECLE      OF ARCMD_DETAIL
  LET PECCLE       OF MCHIS_ECR_ENG = T_PECCLEDES
  LET HEENUMDOC2   OF MCHIS_ECR_ENG = " "
  IF FOUTYP OF VFOC_FOU <> "I"
  THEN LET HEECIEINT OF MCHIS_ECR_ENG = CIECLE      OF ARCMD_DETAIL
  ELSE LET HEECIEINT OF MCHIS_ECR_ENG = FOUCIEINT   OF VFOC_FOU
  LET HEEUNAINT    OF MCHIS_ECR_ENG = CIEUNABIL OF MCCOMPAGNIE
  LET HEEFLGINT    OF MCHIS_ECR_ENG = "0"
  LET HEEMNTCRT    OF MCHIS_ECR_ENG = 0
  LET HEEMNTCRTORI OF MCHIS_ECR_ENG = 0
  LET HEEMNTDBT    OF MCHIS_ECR_ENG = 0
  LET HEEMNTDBTORI OF MCHIS_ECR_ENG = 0

  LET T_MNTANN                      =  ( CDEMNTENG OF ARCMD_DETAIL - &
                                         CDEMNTDES OF ARCMD_DETAIL  )
  IF T_MNTANN >= 0
  THEN BEGIN
    LET HEEMNTCRT    OF MCHIS_ECR_ENG = T_MNTANN
    LET HEEMNTCRTORI OF MCHIS_ECR_ENG = T_MNTANN
  END
  ELSE BEGIN
    LET HEEMNTDBT    OF MCHIS_ECR_ENG = ABSOLUTE(T_MNTANN)
    LET HEEMNTDBTORI OF MCHIS_ECR_ENG = ABSOLUTE(T_MNTANN)
  END

  PUT MCHIS_ECR_ENG RESET

  LET HENCLE       OF MCHIS_PROJET_ENG = HENCLE      OF ARCOMMANDE
  LET HPENUMLIG    OF MCHIS_PROJET_ENG = T_CPTLIG
  LET PRJCLE       OF MCHIS_PROJET_ENG = PRJCLE      OF ARCMD_DETAIL
  LET PRACLE       OF MCHIS_PROJET_ENG = PRACLE      OF ARCMD_DETAIL
  LET CPTCLE       OF MCHIS_PROJET_ENG = CPTCLE      OF ARCMD_DETAIL
  LET UNACLE       OF MCHIS_PROJET_ENG = UNACLE      OF ARCMD_DETAIL
  LET CIECLE       OF MCHIS_PROJET_ENG = CIECLE      OF ARCMD_DETAIL
  LET PECCLE       OF MCHIS_PROJET_ENG = T_PECCLEDES
  LET IMMCLE       OF MCHIS_PROJET_ENG = IMMCLE      OF ARCMD_DETAIL
  LET HPEMNTDBT    OF MCHIS_PROJET_ENG = 0
  LET HPEMNTDBTORI OF MCHIS_PROJET_ENG = 0
  LET HPEMNTCRT    OF MCHIS_PROJET_ENG = 0
  LET HPEMNTCRTORI OF MCHIS_PROJET_ENG = 0

  IF T_MNTANN >= 0
  THEN BEGIN
    LET HPEMNTCRT    OF MCHIS_PROJET_ENG = T_MNTANN
    LET HPEMNTCRTORI OF MCHIS_PROJET_ENG = T_MNTANN
  END
  ELSE BEGIN
    LET HPEMNTDBT    OF MCHIS_PROJET_ENG = ABSOLUTE(T_MNTANN)
    LET HPEMNTDBTORI OF MCHIS_PROJET_ENG = ABSOLUTE(T_MNTANN)
  END

  PUT MCHIS_PROJET_ENG RESET

END


;-------------------------------------------------------------------------------
; Cette procédure permet de mettre à jour l'historique losrque la commande
; est approuvée.  A noter, qu'un trigger met à jour l'information des quantités
; dans le catalogue fournisseur ainsi que dans le produit entrepôt.
;
PROCEDURE INTERNAL MAJ_HISTORIQUE
BEGIN
  LET T_CDEQTEREJ = CDEQTEREJ OF ARCMD_DETAIL * -1

  LET CIECLE    OF ARPRD_HISTO = CIECLE OF ARCMD_DETAIL
  LET PRDCLE    OF ARPRD_HISTO = PRDCLE OF ARCMD_DETAIL
  LET PRDTYP    OF ARPRD_HISTO = PRDTYP OF VPRE_PRD
  LET PRHTIMSTP OF ARPRD_HISTO = SYSDATE * 1000000 + ROUND(SYSTIME / 100)
  LET ENTCLE    OF ARPRD_HISTO = ENTCLE OF ARCOMMANDE
  LET PECCLE    OF ARPRD_HISTO = PECCLE OF ARCOMMANDE
  LET PRHNUMREF OF ARPRD_HISTO = CMDCLE OF ARCMD_DETAIL + CMDAJT OF ARCMD_DETAIL
  LET PRHDATREF OF ARPRD_HISTO = CMDDAT OF ARCOMMANDE
  LET PRHTYP    OF ARPRD_HISTO = "01"   ; Commande.

  LET PRHQTETRS OF ARPRD_HISTO = T_CDEQTEREJ
  LET PRHUSRCRE OF ARPRD_HISTO = TZ_LOGONID
  LET PRHDATCRE OF ARPRD_HISTO = SYSDATE
  LET PRHHRECRE OF ARPRD_HISTO = SYSTIME / 10000

  LET PRHITM    OF ARPRD_HISTO = CDECLE    OF ARCMD_DETAIL
  LET PRHDERCOU OF ARPRD_HISTO = CDEPRIUNI OF ARCMD_DETAIL
  LET FOUCIECLE OF ARPRD_HISTO = FOUCIECLE OF ARCOMMANDE
  LET FOUCLE    OF ARPRD_HISTO = FOUCLE    OF ARCOMMANDE
  LET PRHDSC    OF ARPRD_HISTO = RADNOM    OF MCREF_ADRESSE

  PUT ARPRD_HISTO RESET

END

;-------------------------------------------------------------------------------
; Cette procédure permet de mettre à jour les quantités rejetées lorsque le statut de la
; la ligne de commande est annulée et que la commande est déjà approuvée. Les
; montants à désengager sont également mis à jour.
;
PROCEDURE INTERNAL DESENGAGER_MONTANTS
BEGIN

  LET T_CPTLIG = 50
  ;
  ; Valider que s'il y a des réceptions, elles soient journalisées.
  ; S'il n'y a pas de réceptions, on peut annuler la ligne sans problème.
  ;

  WHILE RETRIEVING ARRECEPTION
  BEGIN
    IF RECDATJOU OF ARRECEPTION = 0
    THEN ERROR 1470 ; Impossible d'annuler la ligne, il reste des réceptions
                    ; non journalisées.
  END

    ;
    ; Valider si la période de la commande d'achat est fermée. Si oui,
    ; il faut désengager dans la période courante.
    ;

  GET MCPERIODE_CIE OPTIONAL
  IF ACCESSOK
  THEN BEGIN
    IF PCCSTUAR OF MCPERIODE_CIE = "F"
    THEN BEGIN
      WARNING 1407    ; La période de la commande est fermée, désengagement
                      ; dans la période courante.
      GET MCPERIODE_CIE &
        VIA   CIECLE,  &
              PCCSTUAR &
        USING CIECLE OF ARCOMMANDE, &
              "C" OPTIONAL
      IF ACCESSOK
      THEN LET T_PECCLEDES = PECCLE OF MCPERIODE_CIE
      ELSE ERROR 1308 ; Il n'y a pas de période courante définie
    END
    ELSE LET T_PECCLEDES = PECCLE OF ARCOMMANDE
  END


  DO INTERNAL MAJ_ENGAGEMENTS


  LET CDEMNTDES OF ARCMD_DETAIL = CDEMNTDES OF ARCMD_DETAIL + &
                                  ( CDEMNTENG OF ARCMD_DETAIL - &
                                    CDEMNTDES OF ARCMD_DETAIL )

  LET CDEQTEREJ OF ARCMD_DETAIL = CDEQTECOM OF ARCMD_DETAIL - &
                                  CDEQTEREC OF ARCMD_DETAIL


  ; On met à jour l'historique seulement si c'est pas un produit divers
  ; ou un produit de frais.
  ;
  IF    PRDTYP OF VPRE_PRD <> "D" &
    AND PRDTYP OF VPRE_PRD <> "F"
  THEN DO INTERNAL MAJ_HISTORIQUE
END


;----------------------------------------------------------------
;
;
;
PROCEDURE ENTRY
BEGIN
  FOR ARCMD_DETAIL
  BEGIN
    PERFORM APPEND
  END
END


PROCEDURE APPEND
BEGIN
  ACCEPT PRDCLE OF ARCMD_DETAIL
  IF PRDTYP OF VPRE_PRD = "D"
  THEN ACCEPT CDEDSCPRD OF ARCMD_DETAIL
  ELSE DISPLAY CDEDSCPRD OF ARCMD_DETAIL
  ACCEPT  CDEREFFOU    OF ARCMD_DETAIL
  ACCEPT  CDECLE       OF ARCMD_DETAIL
  DISPLAY CBIDSC       OF A_CBI_CDESTU
  ACCEPT  CDEDATLIVPRE OF ARCMD_DETAIL
  ACCEPT  CDETRP       OF ARCMD_DETAIL
  DISPLAY CBIDSC       OF A_CBI_CDETRP
  ACCEPT  IMMCLE       OF ARCMD_DETAIL
  DISPLAY IMMDSC       OF IMIMMOBILISATION
  ACCEPT  CDEFAB       OF ARCMD_DETAIL
  DISPLAY CBIDSC       OF A_CBI_CDEFAB
  ACCEPT  CDELIE       OF ARCMD_DETAIL
  DISPLAY REQDSC       OF ARREQUISITION
  ACCEPT  CPTCLE       OF ARCMD_DETAIL
  DISPLAY CPTDSCABR    OF VCPT_DSC
  ACCEPT  UNACLE       OF ARCMD_DETAIL
  DISPLAY UNANOMABR    OF MCUNITE_ADM
  INFORMATION = UNANOM OF MCUNITE_ADM
  ;
  ; Si notion de projet.
  ;
  IF (HLDNTNPRO OF MCHOLDING = "1" AND NACCLE OF MCNATURE_CTB = 4) OR &
     (HLDNTNPRO OF MCHOLDING = "1" AND NACCLE OF MCNATURE_CTB = 5)
  THEN BEGIN
    WHILE 0 = SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
    BEGIN
      ACCEPT  PRJCLE OF ARCMD_DETAIL
      DISPLAY PRJDSC1 OF GPPROJETS
      IF 0 <> SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
      THEN BEGIN
        INFORMATION = PRJDSC1 OF GPPROJETS
        ACCEPT  PRACLE OF ARCMD_DETAIL
        DISPLAY PRADSC1 OF GPPRO_ACTIVITE
        INFORMATION = PRADSC1 OF GPPRO_ACTIVITE
        LET T_FLAG_ENT = "1"
      END
    END
  END
  ELSE BEGIN
    LET PRJCLE OF ARCMD_DETAIL = " "
    LET PRACLE OF ARCMD_DETAIL = " "
  END
  ACCEPT  CDEQTECOM    OF ARCMD_DETAIL
  ACCEPT  CDEPRIUNI    OF ARCMD_DETAIL
  ACCEPT  CDETAXCODTPS OF ARCMD_DETAIL
  DISPLAY TAXDSCFRA    OF A_TAX_TPS
  DISPLAY CDEMNTTPS    OF ARCMD_DETAIL
  ACCEPT  CDETERESCACH OF ARCMD_DETAIL
  INFORMATION = TERDSC OF VTER_DSC
  DISPLAY TERDSCABR    OF VTER_DSC
  DISPLAY CDEMNTESC    OF ARCMD_DETAIL
  ACCEPT  CDETAXCODTVQ OF ARCMD_DETAIL
  DISPLAY TAXDSCFRA    OF A_TAX_TVP
  DISPLAY CDEMNTTVQ    OF ARCMD_DETAIL
  DISPLAY CDEMNTTOT    OF ARCMD_DETAIL
  DISPLAY CDEMNTNET    OF ARCMD_DETAIL

  IF PRDTYP OF VPRE_PRD <> "D"
  THEN BEGIN
    RUN SCREEN ar007g MODE F PASSING  T_CIECLEMNU  , &
                                      T_CIENOM     , &
                                      ARCOMMANDE   , &
                                      ARCMD_DETAIL
  END
END


;--------------------------------------------------------------------------------
;
; Note descriptive sous-écran
;
PROCEDURE DESIGNER D001
BEGIN
  IF PRDTYP OF VPRE_PRD <> "D"
  THEN BEGIN
    RUN SCREEN ar007g MODE F PASSING  T_CIECLEMNU  , &
                                      T_CIENOM     , &
                                      ARCOMMANDE   , &
                                      ARCMD_DETAIL
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 01
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDEREFFOU OF ARCMD_DETAIL 
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 15
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDEDATLIVPRE OF ARCMD_DETAIL
    ACCEPT  CDETRP       OF ARCMD_DETAIL
    DISPLAY CBIDSC       OF A_CBI_CDETRP 
    ACCEPT  IMMCLE       OF ARCMD_DETAIL 
    DISPLAY IMMDSC       OF IMIMMOBILISATION 
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 25
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDEFAB OF ARCMD_DETAIL
    DISPLAY CBIDSC OF A_CBI_CDEFAB
    ACCEPT  CDELIE OF ARCMD_DETAIL
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 40
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CPTCLE OF ARCMD_DETAIL
    DISPLAY CPTDSCABR OF VCPT_DSC
    INFORMATION = CPTDSC OF VCPT_DSC
    ACCEPT  UNACLE OF ARCMD_DETAIL
    DISPLAY UNANOMABR OF MCUNITE_ADM
    INFORMATION = UNANOM OF MCUNITE_ADM     
    ;
    ; Si notion de projet.
    ;
    IF (HLDNTNPRO OF MCHOLDING = "1" AND NACCLE OF MCNATURE_CTB = 4) OR &
       (HLDNTNPRO OF MCHOLDING = "1" AND NACCLE OF MCNATURE_CTB = 5)
    THEN BEGIN
      WHILE 0 = SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
      BEGIN
        ACCEPT  PRJCLE OF ARCMD_DETAIL
        DISPLAY PRJDSC1 OF GPPROJETS
        IF 0 <> SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
        THEN BEGIN
          INFORMATION = PRJDSC1 OF GPPROJETS
          ACCEPT  PRACLE OF ARCMD_DETAIL
          DISPLAY PRADSC1 OF GPPRO_ACTIVITE
          INFORMATION = PRADSC1 OF GPPRO_ACTIVITE
          LET T_FLAG_ALT = "1"
        END
      END
      IF T_FLAG_ALT <> "1"
      THEN BEGIN
        ACCEPT  PRJCLE OF ARCMD_DETAIL
        DISPLAY PRJDSC1 OF GPPROJETS
        IF 0 <> SIZE(TRUNCATE(PRJCLE OF ARCMD_DETAIL))
        THEN BEGIN
          INFORMATION = PRJDSC1 OF GPPROJETS
          ACCEPT  PRACLE OF ARCMD_DETAIL
          DISPLAY PRADSC1 OF GPPRO_ACTIVITE
          INFORMATION = PRADSC1 OF GPPRO_ACTIVITE
        END
      END
    END
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 50
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDEQTECOM OF ARCMD_DETAIL
  END

  ACCEPT CDEQTEREC OF ARCMD_DETAIL

  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDEPRIUNI OF ARCMD_DETAIL
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 60
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDETAXCODTPS OF ARCMD_DETAIL
    DISPLAY TAXDSCFRA OF A_TAX_TPS
    DISPLAY CDEMNTTPS OF ARCMD_DETAIL
    ACCEPT  CDETERESCACH OF ARCMD_DETAIL
    INFORMATION = TERDSC OF VTER_DSC
    DISPLAY TERDSCABR OF VTER_DSC
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE DESIGNER 65
BEGIN
  IF CMDSTU OF ARCOMMANDE = "P"
  THEN BEGIN
    ACCEPT  CDETAXCODTVQ OF ARCMD_DETAIL
    DISPLAY TAXDSCFRA OF A_TAX_TVP
    DISPLAY CDEMNTTVQ OF ARCMD_DETAIL
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE PATH
BEGIN
  IF T_CDECLEFND = "1"
  THEN BEGIN
    LET PATH = 99
  END
  ELSE BEGIN
    REQUEST CDECLE OF ARCMD_DETAIL
    IF PROMPTOK
    THEN LET PATH = 1
    IF PATH = 0
    THEN BEGIN
      LET PATH = 2
    END
  END
END

;-------------------------------------------------------------------------------
;
;
;
PROCEDURE FIND
BEGIN
  FOR MISSING ARCMD_DETAIL
  BEGIN
    IF PATH = 1
    THEN GET ARCMD_DETAIL VIA CIECLE , CMDCLE , CMDAJT , CDECLE &
             ORDERBY CIECLE , CMDCLE , CMDAJT , CDECLE USING CIECLE OF &
             ARCOMMANDE , CMDCLE OF ARCOMMANDE , CMDAJT OF ARCOMMANDE , &
             CDECLE OF ARCMD_DETAIL
 
    IF PATH = 2
    THEN GET ARCMD_DETAIL VIA CIECLE , CMDCLE , CMDAJT ORDERBY &
             CIECLE , CMDCLE , CMDAJT , CDECLE USING CIECLE OF &
             ARCOMMANDE , CMDCLE OF ARCOMMANDE , CMDAJT OF ARCOMMANDE
   
    IF PATH = 99
    THEN GET ARCMD_DETAIL VIA CIECLE , CMDCLE , CMDAJT , CDECLE &
             ORDERBY CIECLE , CMDCLE , CMDAJT , CDECLE USING CIECLE OF &
             ARCOMMANDE , CMDCLE OF ARCOMMANDE , CMDAJT OF ARCOMMANDE , &
             T_CDECLE
  END
END


;-------------------------------------------------------------------------------
;
;
; Valide les traitements permis par écran et par usager.
;
;
PROCEDURE PREUPDATE
BEGIN
  FOR ARCMD_DETAIL
  BEGIN
    ;
    ; Validation de la destruction
    ;
    IF     DELETEDRECORD OF ARCMD_DETAIL &
       AND TZ_SECDEL = "0"
    THEN ERROR 1
    ;
    ; Validation de la modification.
    ;
    IF     ALTEREDRECORD     OF ARCMD_DETAIL &
       AND NOT NEWRECORD     OF ARCMD_DETAIL &
       AND NOT DELETEDRECORD OF ARCMD_DETAIL &
       AND TZ_SECMOD = "0"
    THEN ERROR 2

  IF (HLDNTNPRO OF MCHOLDING = "1" AND (NACCLE OF MCNATURE_CTB = 4  OR &
                                        NACCLE OF MCNATURE_CTB = 5) AND &
      PRJCLE OF ARCMD_DETAIL = "")
  THEN ERROR 889
    ; Enlever le droit de modification et de destruction si la commande n'est
    ; plus préliminaire.
    ; Cependant, on peut annuler une ligne de commande à l'aide du statut "X".
    ;
    IF     ALTEREDRECORD     OF ARCMD_DETAIL &
       AND NOT NEWRECORD     OF ARCMD_DETAIL &
       AND T_CDESTUOLD <> " "                &
       AND T_CDESTUOLD <> "S"
      THEN ERROR 1371 ; Seule la modification d'une commande préliminaire est
                      ; permise.
    ;
    ; Enlever le droit de modification si la commande n'est plus préliminaire.
    ; Cependant, on permet la mise à jour si le statut vient juste d'être changer
    ; pour "A".
    ;
    IF  (   DELETEDRECORD OF ARCMD_DETAIL  &
         OR NEWRECORD     OF ARCMD_DETAIL ) &
      AND T_CMDSTUOLD <> "P"
    THEN  ERROR 1371  ; Seule la modification d'une commande préliminaire est
                      ; permise.

    ;
    ; Mise à jour du timbre de modification si l'usager change la commande.
    ;
    IF    NOT NEWRECORD OF ARCOMMANDE &
      AND ALTEREDRECORD OF ARCMD_DETAIL
    THEN BEGIN
      LET CMDDATMOD OF ARCOMMANDE  = SYSDATE
      LET CMDHREMOD OF ARCOMMANDE  = SYSTIME / 10000
      LET CMDUSRMOD OF ARCOMMANDE  = TZ_LOGONID
    END


    ; Mise à jour du nombre d'items de la commande.
    ;
    ;
    IF         NEWRECORD     OF ARCMD_DETAIL &
       AND NOT DELETEDRECORD OF ARCMD_DETAIL
    THEN LET CMDNBRITE OF ARCOMMANDE = CMDNBRITE OF ARCOMMANDE + 1
    ELSE BEGIN
      IF        DELETEDRECORD OF ARCMD_DETAIL &
        AND NOT NEWRECORD     OF ARCMD_DETAIL
      THEN LET CMDNBRITE OF ARCOMMANDE = CMDNBRITE OF ARCOMMANDE - 1
    END

    ;
    ; Désengagements des montants
    ;
    IF    ALTEREDRECORD OF ARCMD_DETAIL &
      AND CDESTU        OF ARCMD_DETAIL = "X"
    THEN DO INTERNAL DESENGAGER_MONTANTS

  END
END


PROCEDURE UPDATE
BEGIN
  FOR ARCMD_DETAIL
  BEGIN
    PUT ARCDE_NOTE
    PUT ARCMD_DETAIL
  END
  PUT ARCOMMANDE
  PUT ARCMD_HISTO
END

;-------------------------------------------------------------------------------
;
; Cette procédure permet de mettre à jour les totaux.
;
;
PROCEDURE DELETE
BEGIN
  IF NOT DELETEDRECORD OF ARCMD_DETAIL
  THEN BEGIN
    ;
    ; Enlève les anciennes valeurs.
    ;
    LET CMDMNTTPS OF ARCOMMANDE = CMDMNTTPS OF ARCOMMANDE - &
                                  CDEMNTTPS OF ARCMD_DETAIL

    LET CMDMNTTVQ OF ARCOMMANDE = CMDMNTTVQ OF ARCOMMANDE - &
                                  CDEMNTTVQ OF ARCMD_DETAIL

    LET CMDMNTCTI OF ARCOMMANDE = CMDMNTCTI OF ARCOMMANDE - &
                                  CDEMNTCTI OF ARCMD_DETAIL

    LET CMDMNTRTI OF ARCOMMANDE = CMDMNTRTI OF ARCOMMANDE - &
                                  CDEMNTRTI OF ARCMD_DETAIL

    LET CMDMNTESC OF ARCOMMANDE = CMDMNTESC OF ARCOMMANDE - &
                                  CDEMNTESC OF ARCMD_DETAIL

    LET CMDMNTTOT OF ARCOMMANDE = CMDMNTTOT OF ARCOMMANDE - &
                                  CDEMNTTOT OF ARCMD_DETAIL

    LET CMDMNTNET OF ARCOMMANDE = CMDMNTNET OF ARCOMMANDE - &
                                  CDEMNTNET OF ARCMD_DETAIL
  END
  DELETE ARCMD_DETAIL
  DELETE ARCDE_NOTE
END

BUILD LIST DETAIL
                                                                                                                                   
                                                                                                                                   
@IF FORMAT    
         1         2         3         4         5         6         7         8         9       100       110       120
123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012

* Commande......: xxxxxxxxx             Fourn..: xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx                                                     
************************************************************************************************************************************                      
* Code produit..: xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Référence..: xxxxxxxxxxxxxxx                                *
* Item..........: xxxxxxx               Statut.: x xxxxxxxxxxxxxxx                                                                 *
* Livraison prev: xxxxxxxxxx            Transp.: xxxx xxxxxxxxxxxxxxxx Equipement.: xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx * 
* Terme de comm.: xxxx xxxxxxxxxxxxxxxx Endroit: xxxxxxxxxxxxxxxxxxxxx Réquisition: xxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx *    
* Compte........: xxxxxx xxxxxxxxxxxxx  Unité..: xxxxxxxx xxxxxxxxxxxx Projet.....: xxxxxxxx xxxxxxxxxxxx Sous-pr: xxx xxxxxxxxxxx *   
* Qté commandé..: xxxxxxxxxx            Qté rec: xxxxxxxxxx            Prix unit..: xxxxxxxxxxxxxxx                                *
* Code taxe féd.: xx xxxxxxxxxxxxxxxxxx Mnt TPS: xxxxxxxxxxxxxxx       Terme esc..: xxxx xxxxxxxxxxxxxxxx Mnt esc: xxxxxxxxxxxxxxx *       
* Code taxe prov: xx xxxxxxxxxxxxxxxxxx Mnt TVQ: xxxxxxxxxxxxxxx       Mnt brut...: xxxxxxxxxxxxxxx       Mnt net: xxxxxxxxxxxxxxx *       
************************************************************************************************************************************
* Code produit..: xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Référence..: xxxxxxxxxxxxxxx                                *
* Item..........: xxxxxxx               Statut.: x xxxxxxxxxxxxxxx                                                                 *
* Livraison prev: xxxxxxxxxx            Transp.: xxxx xxxxxxxxxxxxxxxx Equipement.: xxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx * 
* Terme de comm.: xxxx xxxxxxxxxxxxxxxx Endroit: xxxxxxxxxxxxxxxxxxxxx Réquisition: xxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx *    
* Compte........: xxxxxx xxxxxxxxxxxxx  Unité..: xxxxxxxx xxxxxxxxxxxx Projet.....: xxxxxxxx xxxxxxxxxxxx Sous-pr: xxx xxxxxxxxxxx *  
* Qté commandé..: xxxxxxxxxx            Qté rec: xxxxxxxxxx            Prix unit..: xxxxxxxxxxxxxxx                                *
* Code taxe féd.: xx xxxxxxxxxxxxxxxxxx Mnt TPS: xxxxxxxxxxxxxxx       Terme esc..: xxxx xxxxxxxxxxxxxxxx Mnt esc: xxxxxxxxxxxxxxx *       
* Code taxe prov: xx xxxxxxxxxxxxxxxxxx Mnt TVQ: xxxxxxxxxxxxxxx       Mnt brut...: xxxxxxxxxxxxxxx       Mnt net: xxxxxxxxxxxxxxx *       
************************************************************************************************************************************
@ENDIF


