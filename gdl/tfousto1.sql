set term !! ;
create trigger TFOUSTO1 for CPFOURNISSEUR
after insert 
position 1 as
/*
;----------------------------------------------------------------------------
;/T/ Programme permettant de gérer les enregistrements MCREF_SOLDE 
;    lors de l'enregistrement d'un fournisseur et lui fournissant un numéro 
;    de client.
;
;/P/ Programmeur..: Francois Goulet 
;    Date Création: Le 16 mars 1995 
;
;    Description..: Quand on inscrit un numéro de client au fournisseur, on 
;                   met à jour la table MCREF_SOLDE, on inscrit le numéro de 
;                   fournisseur dans la table et laisse le solde à zéro, car 
;                   le fournisseur n'a pas encore de solde.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL
;-------------------------------------------------------------------------------
*/

begin
  if ( new.clicle <> "" )
  then begin
    /* ajouter dans le record du client, le numéro du fournisseur et le solde 
       à zéro, vue que le fournisseur est nouveau il n'a pas de solde. */  
    Update MCREF_SOLDE Set FOUCLE    = NEW.FOUCLE,
                           FOCSLDACJ = 0
                     Where CLICLE = NEW.CLICLE;
  end 
end !!
set term ; !!
