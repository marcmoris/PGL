set term !! ;
create trigger TDEVMOD for MCDEVISE
before update
position 0 as
/*
;----------------------------------------------------------------------------
;/T/ Programme permettant de gérer les enregistrements de MCDEV_HISTO
;    lors de la modification d'une devise
;
;/P/ Programmeur..: Marc Morissette
;    Date Création: 20 Octobre 1993
;
;/M/ François Déry, 3 juin 1999
;       conversion en ISQL
;-------------------------------------------------------------------------------
*/
begin
  if ( OLD.DEVTAU != NEW.DEVTAU )
  then Begin
    Insert Into MCDEV_HISTO 
              ( DEVCLE, DEVTAU, DEVDATMAJ )
        Values( NEW.DEVCLE,
                OLD.DEVTAU,
                NEW.DEVDATMAJ );
  end
end !!
set term ; !!
