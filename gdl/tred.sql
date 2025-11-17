set term !! ;
create trigger TREDMOD for ARREC_DETAIL 
/*
* Modification dans la table ARREC_DETAIL
*
* Programmeur..: Guy Chabot
* Date création: 20 octobre 1994
*
* Modifier.....: Marc Morissette 
* Date modif...: 7 juin 1995 
* Description..: Migration sur Oracle
*
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL 
*
* Description..: Le but du déclencheur est de maintenir le statut de la
*                réception par ses lignes de détail.
*
*
*/
after update 
position 0 as 

begin
  /*
  * 
  * Si je complète ou j'annule une ligne de détail alors je vérifie
  * s'il existe d'autre ligne avec le statut à blanc ou à 'C'. Sinon
  * la réception est considérée complète.
  * 
  */
  if  (  OLD.REDSTU <> 'C' 
     and OLD.REDSTU <> 'X'
     and NEW.REDSTU  = 'C')
  then begin

    update ARRECEPTION REC
      set REC.RECNBRITECMP = REC.RECNBRITECMP + 1
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE;

    update ARRECEPTION REC
      set REC.RECSTU = 'C'
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE
        and REC.RECNBRITE = REC.RECNBRITECMP;
  
    update ARRECEPTION REC
      set REC.RECSTU = 'S'
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE
        and REC.RECNBRITE != REC.RECNBRITECMP;
  end

  if  (  OLD.REDSTU <> 'C'
     and OLD.REDSTU <> 'X'
     and NEW.REDSTU  = 'X')
  then begin

    update ARRECEPTION REC
      set REC.RECNBRITECMP = REC.RECNBRITECMP + 1
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE;

    update ARRECEPTION REC
      set REC.RECSTU = 'X'
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE
        and REC.RECNBRITE = REC.RECNBRITECMP;

    update ARRECEPTION REC
      set REC.RECSTU = 'S'
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE
        and REC.RECNBRITE != REC.RECNBRITECMP;
  end

  if   (  NEW.REDSTU <> 'C'
     and NEW.REDSTU <> 'X'
     and (     OLD.REDSTU = 'C' 
           or  OLD.REDSTU = 'X' ))
  then begin
    update ARRECEPTION REC
      set REC.RECNBRITECMP = REC.RECNBRITECMP - 1
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE;

    update ARRECEPTION REC
      set REC.RECSTU = 'S'
      where REC.CIECLE = OLD.CIECLE
        and REC.RECCLE = OLD.RECCLE
        and REC.RECNBRITE != REC.RECNBRITECMP;
  end
end !! 
set term ; !!
