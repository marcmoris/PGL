set term !! ;
create trigger TCPHDEL for CPCAP_HISTO
before delete
position 0 as
/*
;----------------------------------------------------------------------------
;/T/ Trigger de delete sur CPCAP_HISTO
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 25 Juin 1993
;
;    Description..: Traitement du flag de sélection de la cédule lors
;                   de la suppression d'une ventilation de paiement dans
;                   l'historique.
;
;/M/ François Déry, 2 juin 1999
;       Conversion en ISQL pour interbase 5.
;
;/M/ Modifié par..: Guy Chabot le 12 octobre 1994
;
;    Description..: Introduction du P.N.A. aux payables sur le même principe
;                   ou presque des recevables.
;
;----------------------------------------------------------------------------
*/
begin
 /*
  * Lors de la suppression d'une ventilation de facture d'un paiement dans
  * l'historique, il faut aller mettre le flag de la cédule correspondante
  * à "0" pour indiquer que la cédule n'est plus réservée par un paiement.
  * Le traitement est identique pour les paiements et les paiements annulés.
  */
  if (    OLD.CPHTYPECR = "CH"
       or OLD.CPHTYPECR = "CA" )
  then begin
    Update CPCAP_CEDULE Set CPCFLGSEL = "0"
                        Where FOUCIECLE = OLD.FOUCIECLE
                          And FOUCLE    = OLD.FOUCLE
                          And CAPCLE    = OLD.CAPCLE
                          And CPCCLELIG = OLD.CPCCLELIG;
  end
 /*
  * Mise à jour du solde du fournisseur si le chèque n'est pas un chèque
  * de paiement automatique ni un paiement direct.
  *
  */
  if (    (OLD.CPHTYPECR = "CH"
       or  OLD.CPHTYPECR = "CA")
       and OLD.CPHFLGPA = "0" )
  then begin
    Update CPFOU_CIE Set FOCSLDACJ = FOCSLDACJ + OLD.CPHMNTCAP
                Where FOUCIECLE = OLD.FOUCIECLE
                  And FOUCLE    = OLD.FOUCLE
                  And FOCCIECLE = CPHCLE1;
/*
    ; Permet de retrouver le numéro du compte client du fournisseur.
*/
    Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ + OLD.CPHMNTCAP
                Where REFCIECLE = OLD.FOUCIECLE
                  And FOUCLE    = OLD.FOUCLE
                  And CIECLE    = OLD.CPHCLE1;
  end
end !!
set term ; !!
