Set Term !! ;
Create Trigger tslcsto For cpsel_cap
Before Insert
Position 0 As
/*
;----------------------------------------------------------------------------
;/T/ M.a.j. du flag de sélection
;
;/P/ Programmeur..: Alain Côté
;    Date Création: 3 juin 1992
;
;    Description..: Mise à jour du flag de sélection dans la table
;                   CPCAP_CEDULE pour éviter de sélectionner deux fois
;                   la même ligne de cédule.
;
;/M/ François Déry, 4 juin 1999
;       Conversion en ISQL.
;
; Traitement lors de l'ajout d'un enregistrement. On met le flag à Oui(1) dans
; la cédule.
;
*/
Begin
  Update cpcap_cedule Set cpcflgsel = "1"
                    Where fouciecle = New.fouciecle
                      And foucle    = New.foucle
                      And capcle    = New.capcle
                      And cpcclelig = New.cpcclelig;
End !!
Set Term ; !!
