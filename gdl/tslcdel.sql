Set Term !! ;
Create Trigger tslcdel For cpsel_cap
Before Delete
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
;       Conversion en ISQL. Enlever le condition sur le programme de MAJ.
;
; Destruction d'un enregistrement. Il faut remettre le flag à non, pour indi-
; quer que la ligne de cédule n'est plus sélectionnée.
;
*/
Begin
  Update cpcap_cedule Set cpcflgsel = "0"
                    Where fouciecle = Old.fouciecle
                      And foucle    = Old.foucle
                      And capcle    = Old.capcle
                      And cpcclelig = Old.cpcclelig;
End !!
Set Term ; !!
