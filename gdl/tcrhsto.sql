set term !! ;
create trigger TCRHSTO for CRCAR_HISTO
before insert
position 0 as
/*
;/T/ Ajout dans la table CRCAR_HISTO
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
Declare Variable t_foucle    char(6);

begin
/*
    ; Mise à jour du solde du client par compagnie pour les encaissements et
    ; les mauvaises créances. Les factures, les crédits, les notes de crédit 
    ; et les ajustements mettent à jour le solde du client par la relation 
    ; CRCPT_A_REC.
*/
  if (    NEW.CRHTYPECR = "EN"
       or NEW.CRHTYPECR = "MC" )
  then begin
    Select REFCIECLE, REFCLENUM
      From CRCPT_A_REC
     Where CIECLE = NEW.CIECLE
       And CARCLE = NEW.CARCLE
      Into :t_refciecle, :t_refclenum;

    Update CRCLI_CIE Set CLCSLDACJ = CLCSLDACJ - NEW.CRHMNTCAR
                Where CLICIECLE = :t_refciecle
                  And CLICLE    = :t_refclenum
                  And CIECLE    = NEW.CIECLE;

/*
    ; Permet de retrouver le numéro du compte fournisseur du client.
*/
    Select FOUCLE
      From CRCLIENT
     Where CLICIECLE = :t_refciecle
       And CLICLE    = :t_refclenum
      Into :t_foucle;

    Insert into MCREF_SOLDE 
                   ( REFCIECLE, CIECLE, FOUCLE, CLICLE, CLCSLDACJ, FOCSLDACJ )
            Select :t_refciecle,
                   NEW.CIECLE,   
                   :t_foucle,
                   :t_refclenum,
                   0,
                   0
              From MCHOLDING
             Where CIENMC = "1"
               And Not Exists ( Select REFCIECLE From MCREF_SOLDE
                                      Where REFCIECLE = :t_refciecle
                                        And CLICLE    = :t_refclenum
                                        And CIECLE    = NEW.CIECLE 
                                        And FOUCLE    = :t_foucle );

/*
    ; Après création de l'enregistrement, mise à jour du solde
*/
    Update MCREF_SOLDE Set CLCSLDACJ = CLCSLDACJ - NEW.CRHMNTCAR
                Where REFCIECLE = :t_refciecle
                  And CLICLE    = :t_refclenum
                  And CIECLE    = NEW.CIECLE
                  And FOUCLE    = :t_foucle;

  end
end !!
set term ; !!
