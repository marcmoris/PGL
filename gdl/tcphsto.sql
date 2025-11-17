set term !! ;
create trigger TCPHSTO for CPCAP_HISTO
/*
;----------------------------------------------------------------------------
;/T/ Trigger de store sur CPCAP_HISTO
;
;/P/ Programmeur..: Thomas BRENNEUR
;    Date Création: 25 Juin 1993
;
;    Description..: Traitement du flag de sélection de la cédule lors
;                   de la création d'une ventilation de paiement dans
;                   l'historique.
;
;/M/ François Déry, 3 juin 1999
;         Conversion en ISQL pour interbase 5.
;
;/M/ Modifié par..: Guy Chabot le 13 octobre 1994
;
;    Description..: Introduction du P.N.A. aux payables sur le même principe
;                   ou presque des recevables.
;
;----------------------------------------------------------------------------
*/
before insert
position 0 as

Declare Variable t_clicle char(6);

begin
 /*
  * Lors de l'ajout d'une ventilation de facture d'un paiement dans
  * l'historique, il faut aller mettre le flag de la cédule correspondante
  * à "1" pour indiquer que la cédule est actuellement en paiement.
  * Le traitement est identique pour les paiements et les paiements annulés.
  *
  * Note : Si le traitement qui effectue cette création est la préparation
  *        des chèques (CP702) alors on ne change pas le flag de la cédule
  *        car celui-ci est déja à "1" (réservé).
  */
  if (    ( NEW.CPHTYPECR = "CH" or NEW.CPHTYPECR = "CA") )
  then begin
    Update CPCAP_CEDULE Set CPCFLGSEL = "1" 
                Where FOUCIECLE = NEW.FOUCIECLE
                  And FOUCLE    = NEW.FOUCLE
                  And CAPCLE    = NEW.CAPCLE
                  And CPCCLELIG = NEW.CPCCLELIG;
  end
 /*
  * Mise à jour du solde du fournisseur si le chèque n'est pas un chèque
  * de paiement automatique ni un paiement direct.
  */
  if (    (NEW.CPHTYPECR = "CH"
       or  NEW.CPHTYPECR = "CA")
       and NEW.CPHFLGPA = "0" )
  then begin
    Update CPFOU_CIE Set FOCSLDACJ = FOCSLDACJ - NEW.CPHMNTCAP
                Where FOUCIECLE = NEW.FOUCIECLE
                  And FOUCLE    = NEW.FOUCLE
                  And FOCCIECLE = NEW.CPHCLE1;
/*
    ; Permet de retrouver le numéro du compte client du fournisseur.
*/
    Select CLICLE 
      From CPFOURNISSEUR 
     Where FOUCIECLE = NEW.FOUCIECLE
       And FOUCLE    = NEW.FOUCLE
      into :t_clicle ;

    Insert into MCREF_SOLDE 
                   ( REFCIECLE, CIECLE, FOUCLE, CLICLE, CLCSLDACJ, FOCSLDACJ )
            Select NEW.FOUCIECLE,
                   NEW.CPHCLE1,
                   NEW.FOUCLE,
                   :t_clicle,
                   0,
                   0
              From MCHOLDING
             Where CIENMC = "1"
               And Not Exists ( Select REFCIECLE From MCREF_SOLDE
                                      Where REFCIECLE = NEW.FOUCIECLE
                                        And FOUCLE    = NEW.FOUCLE
                                        And CIECLE    = NEW.CPHCLE1
                                        And CLICLE    = :t_clicle );

/*
      ; Après création de l'enregistrement, mise à jour du solde
*/
    Update MCREF_SOLDE Set FOCSLDACJ = FOCSLDACJ - NEW.CPHMNTCAP
                        Where REFCIECLE = NEW.FOUCIECLE
                          And FOUCLE    = NEW.FOUCLE
                          And CIECLE    = NEW.CPHCLE1
                          And CLICLE    = :t_clicle;
  end
end !!
set term ; !!
