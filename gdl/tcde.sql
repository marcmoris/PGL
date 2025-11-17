set term !! ;
create trigger TCDEMOD for ARCMD_DETAIL
/* 
* Modification dans la table ARCMD_DETAIL
*
* Programmeur..: Guy Chabot
* Date création: 20 octobre 1994
*
* Modifier.....: Marc Morissette 
* Date modif...: 7 juin 1995 
* Description..: Migration sur Oracle
*
* /M/ Patrick Langlois, 7 juin 1999
*       Conversion en ISQL* 
*
* Description..: Le but du déclencheur est de maintenir le statut de la
*                commande par ses lignes de détail.
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
  if (   OLD.CDESTU <> 'C' 
     and OLD.CDESTU <> 'X'
     and (     NEW.CDESTU = 'C' 
           or  NEW.CDESTU = 'X' ))
  then begin

    update ARCOMMANDE CMD
      set CMD.CMDNBRITECMP = CMD.CMDNBRITECMP + 1
      where CMD.CIECLE = OLD.CIECLE
        and CMD.CMDCLE = OLD.CMDCLE
        and CMD.CMDAJT = OLD.CMDAJT;

    update ARCOMMANDE CMD
      set CMD.CMDSTU = 'C'
      where CMD.CIECLE = OLD.CIECLE
        and CMD.CMDCLE = OLD.CMDCLE
        and CMD.CMDAJT = OLD.CMDAJT
        and CMD.CMDNBRITE = CMD.CMDNBRITECMP;

    update ARCOMMANDE CMD
      set CMD.CMDSTU = 'S'
      where CMD.CIECLE = OLD.CIECLE
        and CMD.CMDCLE = OLD.CMDCLE
        and CMD.CMDAJT = OLD.CMDAJT
        and CMD.CMDNBRITE != CMD.CMDNBRITECMP;

  end

  if  (  NEW.CDESTU <> 'C'
     and NEW.CDESTU <> 'X'
     and (     OLD.CDESTU = 'C' 
           or  OLD.CDESTU = 'X' ))
  then begin
    update ARCOMMANDE CMD
      set CMD.CMDNBRITECMP = CMD.CMDNBRITECMP - 1
      where CMD.CIECLE = OLD.CIECLE
        and CMD.CMDCLE = OLD.CMDCLE
        and CMD.CMDAJT = OLD.CMDAJT;

    update ARCOMMANDE CMD
      set CMD.CMDSTU = 'S'
      where CMD.CIECLE = OLD.CIECLE
        and CMD.CMDCLE = OLD.CMDCLE
        and CMD.CMDAJT = OLD.CMDAJT
        and CMD.CMDNBRITE != CMD.CMDNBRITECMP;

  end
end !!
set term ; !!
