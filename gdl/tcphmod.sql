set term !! ;
create trigger TCPHMOD for CPCAP_HISTO
/*
;----------------------------------------------------------------------------
;/T/ Trigger de modification sur CPCAP_HISTO
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 25 Juin 1993
;
;    Description..: Traitement du flag de sélection de la cédule lors
;                   de la journalisation d'une ventilation de paiement dans
;                   l'historique.
;
;/M/ François Déry, 3 juin 1999
;       Conversion en ISQL pour interbase 5.
;----------------------------------------------------------------------------
*/
before update
position 0 as

begin
 /*
  * Lors de la journalisation d'un paiement, on va déréserver la cédule de
  * paiement du compte à payer pour pouvoir la resélectionner si elle
  * n'a pas été payée en entier.
  * Ce traitement s'applique aussi aux paiements annulés.
  */
  if (     ( NEW.CPHTYPECR  = "CH" or NEW.CPHTYPECR = "CA")
       and ( OLD.CPHDATJOU  = "17-NOV-1858"  or OLD.CPHDATJOU is null )
       and   NEW.CPHDATJOU != "17-NOV-1858" )
  then begin
     Update CPCAP_CEDULE Set CPCFLGSEL = "0"
                Where FOUCIECLE = NEW.FOUCIECLE
                  And FOUCLE    = NEW.FOUCLE
                  And CAPCLE    = NEW.CAPCLE
                  And CPCCLELIG = NEW.CPCCLELIG;
  end
 /*
  * Mise à jour du solde du fournisseur si le chèque n'est pas un chèque
  * de paiement automatique ni un paiement direct.
  */
  if (     (    OLD.CPHTYPECR = "CH"
             or OLD.CPHTYPECR = "CA")
       and OLD.CPHFLGPA = "0"
       and OLD.CPHMNTCAP != NEW.CPHMNTCAP )
  then begin
    Update CPFOU_CIE Set FOCSLDACJ = FOCSLDACJ + OLD.CPHMNTCAP - NEW.CPHMNTCAP
                Where FOUCIECLE = OLD.FOUCIECLE
                  And FOUCLE    = OLD.FOUCLE
                  And FOCCIECLE = CPHCLE1;
/*
    ; Permet de retrouver le numéro du compte client du fournisseur.
*/
    Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ + OLD.CPHMNTCAP - NEW.CPHMNTCAP
                Where REFCIECLE = OLD.FOUCIECLE
                  And FOUCLE    = OLD.FOUCLE
                  And CIECLE    = OLD.CPHCLE1;
  end
end !!
set term ; !!
