set term !! ;
create trigger TCARMOD for CRCPT_A_REC
before update
position 0 as

/*
;/T/ Modification d'un compte à recevoir(CRCPT_A_REC)
;
;/P/ Programmeur..: Alain Côté
;    Date création: 4 juin 1993
;
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
;
;-------------------------------------------------------------------------------
*/

/* Nombre de transaction en erreur sur le lot */
Declare Variable t_nbrtrserr smallint;

begin
/*
  ;
  ; Transaction qui n'est pas journalisée.
  ;
*/
  if (    NEW.CARDATJOU = "17-NOV-1858"
       or NEW.CARDATJOU is null )
  then begin
/*
    ; Le cumulatif du lot est mis à jour pour tous les type de factures, sauf
    ; pour les paiements non-appliqués.
*/
    if ( NEW.CARTYPECR != "NA" )
    then begin
      t_nbrtrserr = 0;
      if ( OLD.CARCUMMNT != OLD.CARMNT and
           NEW.CARCUMMNT =  NEW.CARMNT )
      then t_nbrtrserr = t_nbrtrserr - 1;
  
      if ( OLD.CARCUMMNT =  OLD.CARMNT and
           NEW.CARCUMMNT != NEW.CARMNT )
      then t_nbrtrserr = t_nbrtrserr + 1;

      Update CRLOT Set LCRCUMMNT = LCRCUMMNT - OLD.CARMNT + NEW.CARMNT,
                       LCRNBRTRSERR = LCRNBRTRSERR + :t_nbrtrserr
                Where CIECLE = OLD.CIECLE
                  And PECCLE = OLD.PECCLE
                  And LCRCLE = OLD.LCRCLE;
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
      Update CRCLI_CIE Set CLCSLDACJ = CLCSLDACJ - OLD.CARMNT + NEW.CARMNT
                        Where CLICIECLE = OLD.REFCIECLE
                          And CLICLE    = OLD.REFCLENUM
                          And CIECLE    = OLD.CIECLE;
/*
      ; Permet de retrouver le numéro du compte fournisseur du client.
*/
      Update MCREF_SOLDE Set CLCSLDACJ = CLCSLDACJ - OLD.CARMNT + NEW.CARMNT
                        Where REFCIECLE = OLD.REFCIECLE
                          And CLICLE    = OLD.REFCLENUM
                          And CIECLE    = OLD.CIECLE;
    end
  end
end !!
set term ; !!
