set term !! ;
create trigger TCARSTO for CRCPT_A_REC
before insert
position 0 as
/*
;/T/ Ajout dans la table CRCPT_A_REC
;
;/P/ Programmeur..: Alain Côté
;    Date création: 4 juin 1993
;
;    Description..: Le but est de maintenir les cumulatifs dans le lot et 
;                   le solde dans le client.
;
;/M/ François Déry, 2 juin 1999
;       Conversion en ISQL pour interbase 5.
;
;/M/ Modifié par..: Guy Chabot le 9 août 1994
;    Description..: Ajout de la mise à jour du solde du client/fournisseur.
;
*/

/* Nombre de transaction en erreur sur le lot */
Declare Variable t_nbrtrserr smallint;

Declare Variable t_foucle char(6);

begin
/*
  ; Le cumulatif du lot est mis à jour pour tous les type de factures, sauf
  ; pour les paiements non-appliqués.
*/
  if ( NEW.CARTYPECR != "NA" )
  then begin
    if ( NEW.CARCUMMNT != NEW.CARMNT )
    then t_nbrtrserr = 1;
    else t_nbrtrserr = 0;

    Update CRLOT Set LCRCUMMNT    = LCRCUMMNT + NEW.CARMNT,
                     LCRNBRTRS    = LCRNBRTRS + 1,
                     LCRNBRTRSERR = LCRNBRTRSERR + :t_nbrtrserr
                Where CIECLE = NEW.CIECLE
                  And PECCLE = NEW.PECCLE
                  And LCRCLE = NEW.LCRCLE;
  end
/*
  ; Mise à jour du solde du client par compagnie pour les factures, les
  ; crédit, les notes de crédit et les ajustements. Les encaissements
  ; mettre à jour le solde lorsqu'on ajoute des transactions dans 
  ; l'historique de la pièce référée.
*/
  if (    NEW.CARTYPECR = "FA"
       or NEW.CARTYPECR = "CR"
       or NEW.CARTYPECR = "NC"
       or NEW.CARTYPECR = "AJ" )
  then begin
    Update CRCLI_CIE Set CLCSLDACJ = CLCSLDACJ + NEW.CARMNT
                Where CLICIECLE = NEW.REFCIECLE
                  And CLICLE    = NEW.REFCLENUM
                  And CIECLE    = NEW.CIECLE;
/*
    ; Permet de retrouver le numéro du compte fournisseur du client.
*/
    Select FOUCLE  
      From CRCLIENT 
     Where CLICIECLE = NEW.REFCIECLE
       And CLICLE    = NEW.REFCLENUM
      into :t_foucle;

    Insert into MCREF_SOLDE 
                   ( REFCIECLE, CIECLE, FOUCLE, CLICLE, CLCSLDACJ, FOCSLDACJ )
            Select NEW.REFCIECLE,
                   NEW.CIECLE,
                   :t_foucle,
                   NEW.REFCLENUM,
                   0,
                   0
              From MCHOLDING
             Where CIENMC = "1"
               And Not Exists ( Select REFCIECLE From MCREF_SOLDE
                                      Where REFCIECLE = NEW.REFCIECLE
                                        And CLICLE    = NEW.REFCLENUM
                                        And CIECLE    = NEW.CIECLE 
                                        And FOUCLE    = :t_foucle );
/*
    ; Après création de l'enregistrement, mise à jour du solde
*/
    Update MCREF_SOLDE Set CLCSLDACJ = CLCSLDACJ + NEW.CARMNT
                        Where REFCIECLE = NEW.REFCIECLE
                          And CLICLE    = NEW.REFCLENUM
                          And CIECLE    = NEW.CIECLE
                          And FOUCLE    = :t_foucle;
  end
end !!
set term ; !!
