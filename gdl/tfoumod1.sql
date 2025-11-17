Set Term !! ;
Create Trigger tfoumod1 For cpfournisseur
After Update
Position 1 As
/*
;----------------------------------------------------------------------------
;/T/ Programme permettant de gérer les enregistrements MCREF_SOLDE 
;    lors de la modification d'un fournisseur et lui fournissant un nouveau 
;    numéro de client.
;
;/P/ Programmeur..: Francois Goulet 
;    Date Création: Le 16 mars 1995 
;
;    Description..: Lors de la phase de modification, il y a deux alternatives
;                   possibles. 
;
;                   1- lorsque le numéro de client est vide et il en ajoute un.
;
;                   2- lorsque le numéro de client est déjà inscrit et il le 
;                      change pour un nouveau.
;
;/M/ François Déry, 4 juin 1999
;       Conversion en ISQL
;-------------------------------------------------------------------------------
*/
Declare Variable t_ciecle Char(4);

Begin
  /* Si l'on change l'ancien client et que celui-ci n'était pas vide,
     on extrait le client du record */
  If (     Old.clicle != New.clicle 
       And Old.clicle != " "
     )
  Then Begin
    Insert Into mcref_solde
                    ( refciecle, ciecle, foucle, clicle,
                      focsldacj, clcsldacj )
               Select refciecle, ciecle, " ", clicle,
                      0, clcsldacj
                 From mcref_solde xxx
                Where refciecle = Old.fouciecle
                  And clicle    = Old.clicle
                  And foucle    = Old.foucle;
    Update mcref_solde Set clicle = " ",
                           clcsldacj = 0
                     Where refciecle = Old.fouciecle
                       And clicle    = " "
                       And foucle    = Old.foucle;
  End
  /* Si l'on modife le client ou on ajoute un nouveau. */
  If ( Old.clicle != New.clicle And New.clicle != "" )
  Then Begin
    For Select ciecle
          From mcref_solde 
         Where refciecle = Old.fouciecle
           And foucle    = Old.foucle
          Into :t_ciecle
    Do
      Begin
        /* Si le fournisseur existe dans une cie et pas le client  
           on crée le met quand même le client dans le record avec son 
           solde à zéro */
        /* Si le client exist on incorpore le client et son solde dans 
           le record du fournisseur */ 
        Update mcref_solde Set clicle    = New.clicle,
                               clcsldacj = ( Select Sum( clcsldacj )
                                               From mcref_solde 
                                              Where refciecle = Old.fouciecle
                                                And ciecle    = :t_ciecle
                                                And clicle    = New.clicle )
                         Where refciecle = Old.fouciecle
                           And foucle    = Old.foucle
                           And ciecle    = :t_ciecle;
        /* Attention au null */
        Update mcref_solde Set clcsldacj = 0
                         Where refciecle = Old.fouciecle
                           And foucle    = Old.foucle
                           And ciecle    = :t_ciecle
                           And clicle    = New.clicle 
                           And clcsldacj Is Null;
        /* Destruction du record client car il est maintenant importé dans le 
           record fournisseur. Si il reste des records de clients, c'est que le 
           client existe dans une cie que le fournisseur n'est pas. */
        Delete from mcref_solde 
              Where refciecle = Old.fouciecle
                And clicle    = New.clicle
                And foucle    = " "
                And ciecle    = :t_ciecle;
      End 
    /* Si le client spécifié existe dans une cie, que le fournisseur 
       lui n'est pas, on doit tout simplement transférer le fournisseur 
       dans le client */
    Update mcref_solde Set foucle = Old.foucle,
                           focsldacj = 0
                     Where refciecle = Old.fouciecle
                       And clicle    = New.clicle
                       And foucle    = " ";
  End  /* end if du client */ 
End !! /* end du post modify */ 
Set Term ; !!
