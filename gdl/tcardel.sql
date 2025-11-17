set term !! ;
create trigger TCARDEL for CRCPT_A_REC
before delete 
position 0 as

/*
;/T/ Destruction d'un compte à recevoir(CRCPT_A_REC)
;
;/P/ Programmeur..: Alain Côté
;    Date Création: 4 juin 1993
;
;    Description..: Le but est de maintenir les cumulatifs dans le lot et 
;                   le solde dans le client.
;
;                   On ne peut pas détruire un document qui est journalisé,
;                   par les écrans, c'est pour cette raison que dans le
;                   trigger on ne vérifie pas l'état du document.
;
;/M/ François Déry, 2 juin 1999
;       Conversion en ISQL pour interbase 5.
*/

/* Nombre de transaction en erreur sur le lot */
Declare Variable t_nbrtrserr smallint;

begin
/*  
    ; Le cumulatif du lot est mis à jour pour tous les type de factures, sauf
    ; pour les paiements non-appliqués.
*/
  if ( OLD.CARTYPECR != "NA" )
  then begin
    if ( OLD.CARCUMMNT != OLD.CARMNT )
    then t_nbrtrserr = 1;
    else t_nbrtrserr = 0;

    Update CRLOT Set LCRNBRTRS    = LCRNBRTRS - 1,
                     LCRCUMMNT    = LCRCUMMNT - OLD.CARMNT,
                     LCRNBRTRSERR = LCRNBRTRSERR - :t_nbrtrserr 
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
  if (    OLD.CARTYPECR = "FA"
       or OLD.CARTYPECR = "CR"
       or OLD.CARTYPECR = "NC"
       or OLD.CARTYPECR = "AJ" )
  then begin
    Update CRCLI_CIE Set CLCSLDACJ = CLCSLDACJ - OLD.CARMNT
                Where CLICIECLE = OLD.REFCIECLE
                  And CLICLE    = OLD.REFCLENUM
                  And CIECLE    = OLD.CIECLE;
/*
    ;
    ; Permet de retrouver le numéro du compte fournisseur du client.
    ;
*/
    Update MCREF_SOLDE Set CLCSLDACJ = CLCSLDACJ - OLD.CARMNT
                        Where REFCIECLE = OLD.REFCIECLE
                          And CLICLE    = OLD.REFCLENUM
                          And CIECLE    = OLD.CIECLE;
  end
end !!
set term ; !!
