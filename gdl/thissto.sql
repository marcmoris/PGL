set term !! ;
create trigger THISSTO for MCHISTO
after insert
position 0 as
/* 
 ;/T/ Ajout dans MCHISTO.
 ;
 ;/P/ Programmeur..: Alain Côté
 ;    Date Création: 16 août 1992
 ;
 ;    Description..: Met à jour l'année de la dernière période journalisée 
 ;                   dans la table MCANNEE_REF.
 ; 
  Mise à jour de l'année financière dans la table MCANNEE_REF pour le programme
  qui recalcul les soldes d'ouverture.
 ;
 ;/M/ François Déry, 3 juin 1999
 ;      Conversion en ISQL
 ;
 ;/M/ Stéphane JackSon 1998-09-16
 ;    Ajustement pour le changement de siècle
 ;    
 ;
*/
begin
/*
  S'il n'y a aucun record, il faut l'ajouter. Ceci indique qu'il s'agit
  de la première journalisation dans le système.
*/
  Insert Into MCANNEE_REF
              ( ANRANN )
         Select NEW.SANANN
           From MCHOLDING
          Where CIENMC = "1"
            And 0 = ( Select count(*) From MCANNEE_REF );
/*
  Si l'année de la transaction est inférieure à l'année du dernier calcul
  des soldes d'ouverture, cela signifi que l'usager fait une écriture
  dans l'année précédante.
*/
  Update MCANNEE_REF Set ANRANN = NEW.SANANN
                Where prosig_annper( ANRANN ) > prosig_annper( NEW.SANANN );
end !!
set term ; !!
