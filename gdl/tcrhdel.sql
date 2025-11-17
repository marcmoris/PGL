set term !! ;
create trigger TCRHDEL for CRCAR_HISTO
before delete
position 0 as
/*
;/T/ Destruction dans la table CRCAR_HISTO
;
;/P/ Programmeur..: Alain Côté
;    Date création: 28 juin 1993
;
;    Description..: Le but est de maintenir le solde dans le client.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL.
*/

Declare Variable t_refciecle char(4);
Declare Variable t_refclenum char(6);

begin
/*
  ; Mise à jour du solde du client par compagnie pour les encaissements et
  ; les mauvaises créances. Les factures, les crédits, les notes de crédit 
  ; et les ajustements mettent à jour le solde du client par la relation 
  ; CRCPT_A_REC.
*/
  if (    OLD.CRHTYPECR = "EN"
       or OLD.CRHTYPECR = "MC" )
  then begin
    Select REFCIECLE, REFCLENUM
      From CRCPT_A_REC
     Where CIECLE = OLD.CIECLE
       And CARCLE = OLD.CARCLE
      Into :t_refciecle, :t_refclenum;


    Update CRCLI_CIE Set CLCSLDACJ = CLCSLDACJ + OLD.CRHMNTCAR
                Where CLICIECLE = :t_refciecle
                  And CLICLE    = :t_refclenum
                  And CIECLE    = OLD.CIECLE;

    Update MCREF_SOLDE Set CLCSLDACJ = CLCSLDACJ + OLD.CRHMNTCAR
                Where REFCIECLE = :t_refciecle
                  And CLICLE    = :t_refclenum
                  And CIECLE    = OLD.CIECLE;
  end
end !!
set term ; !!
