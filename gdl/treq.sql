set term !! ;
create trigger TREQSTO for ARREQUISITION 
/*
* Ajout, modificatio, et destruction  dans la table ARREQUISITION
*
* Programmeur..: Guy Chabot
* Date création: 16 septembre 1994
*
* Description..: Le but est de maintenir les cumulatifs de la réquisition
*                par fournisseurs, si celui-ci existe.
*
* 
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL 
*
*
*/

/*
* Création dans la table ARREQUISITION
*/

after insert 
position 0 as 

begin 
  if ( NEW.FOUCLE is not null ) 
  then begin
    insert into ARREQ_FOU (
     CIECLE     ,
     REQCLE     ,
     FOUCIECLE  ,
     FOUCLE     ,
     RADCLE     ,
     REFCLETYP  ,
     RQFMNTTOT  ,
     RQFMNTNET  ,
     RQFMNTTPS  ,
     RQFMNTTVQ  ,
     RQFMNTCTI  ,
     RQFMNTRTI  ,
     RQFMNTESC  ,
     RQFNBRITE  ,
     RQFPDSTOT  ,
     RQFVOLTOT  )
   select NEW.CIECLE       ,
          NEW.REQCLE       ,
          NEW.FOUCIECLE    ,
          NEW.FOUCLE       ,
          NEW.RADCLE       ,
          'F', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
    from MCHOLDING where  CIENMC = "1"  
            and not exists ( select RQF.CIECLE from ARREQ_FOU RQF 
                                  where RQF.CIECLE    = NEW.CIECLE
                                    and RQF.REQCLE    = NEW.REQCLE
                                    and RQF.FOUCIECLE = NEW.FOUCIECLE
      			            and RQF.FOUCLE    = NEW.FOUCLE
      				    and RQF.RADCLE    = NEW.RADCLE );

    update ARREQ_FOU RQF
    set RQF.RQFMNTTOT = RQF.RQFMNTTOT + NEW.REQMNTTOT ,
        RQF.RQFMNTNET = RQF.RQFMNTNET + NEW.REQMNTNET ,
        RQF.RQFMNTTPS = RQF.RQFMNTTPS + NEW.REQMNTTPS ,
        RQF.RQFMNTTVQ = RQF.RQFMNTTVQ + NEW.REQMNTTVQ ,
        RQF.RQFMNTCTI = RQF.RQFMNTCTI + NEW.REQMNTCTI ,
        RQF.RQFMNTRTI = RQF.RQFMNTRTI + NEW.REQMNTRTI ,
        RQF.RQFMNTESC = RQF.RQFMNTESC + NEW.REQMNTESC ,
        RQF.RQFNBRITE = RQF.RQFNBRITE + 1
      where RQF.CIECLE    = NEW.CIECLE
        and RQF.REQCLE    = NEW.REQCLE
        and RQF.FOUCIECLE = NEW.FOUCIECLE
      	and RQF.FOUCLE    = NEW.FOUCLE
   	and RQF.RADCLE    = NEW.RADCLE;
  end
end !! 
set term ; !!

             
             
set term !! ;             
create trigger TREQMOD for ARREQUISITION
/*
* Modification dans la table ARREQUISITION
*
* Particularité: Il est possible de modifier le numéro du fournisseur
*                et même de le placer à blanc.
*
*/

after update 
position 0 as 
begin

if (   NEW.FOUCLE  is not null 
    or OLD.FOUCLE  is not null )
then begin
  if (OLD.FOUCLE <> NEW.FOUCLE)
  then begin
    if (OLD.FOUCLE is not null)
    then begin
      update ARREQ_FOU RQF
      set RQF.RQFMNTTOT = RQF.RQFMNTTOT - OLD.REQMNTTOT ,
          RQF.RQFMNTNET = RQF.RQFMNTNET - OLD.REQMNTNET ,
          RQF.RQFMNTTPS = RQF.RQFMNTTPS - OLD.REQMNTTPS ,
          RQF.RQFMNTTVQ = RQF.RQFMNTTVQ - OLD.REQMNTTVQ ,
          RQF.RQFMNTCTI = RQF.RQFMNTCTI - OLD.REQMNTCTI ,
          RQF.RQFMNTRTI = RQF.RQFMNTRTI - OLD.REQMNTRTI ,
          RQF.RQFMNTESC = RQF.RQFMNTESC - OLD.REQMNTESC ,
          RQF.RQFNBRITE = RQF.RQFNBRITE - 1
        where RQF.CIECLE    = OLD.CIECLE
          and RQF.REQCLE    = OLD.REQCLE
          and RQF.FOUCIECLE = OLD.FOUCIECLE
          and RQF.FOUCLE    = OLD.FOUCLE
 	  and RQF.RADCLE    = OLD.RADCLE;
    end
    if (NEW.FOUCLE is not null)
    then begin
      insert into ARREQ_FOU (
        CIECLE     ,
        REQCLE     ,
        FOUCIECLE  ,
        FOUCLE     ,
        RADCLE     ,
        REFCLETYP  ,
        RQFMNTTOT  ,
        RQFMNTNET  ,
        RQFMNTTPS  ,
        RQFMNTTVQ  ,
        RQFMNTCTI  ,
        RQFMNTRTI  ,
        RQFMNTESC  ,
        RQFNBRITE  ,
        RQFPDSTOT  ,
        RQFVOLTOT  )
       select OLD.CIECLE       ,
              OLD.REQCLE       ,
              NEW.FOUCIECLE    ,
              NEW.FOUCLE       ,
              NEW.RADCLE       ,
              'F', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0                
        from MCHOLDING where  CIENMC = "1" and
                not exists ( select rqf.ciecle from ARREQ_FOU RQF 
                                      where RQF.CIECLE    = OLD.CIECLE
                                        and RQF.REQCLE    = OLD.REQCLE
                                        and RQF.FOUCIECLE = NEW.FOUCIECLE
         			        and RQF.FOUCLE    = NEW.FOUCLE
          				and RQF.RADCLE    = NEW.RADCLE );
    
      update ARREQ_FOU RQF
        set RQF.RQFMNTTOT = RQF.RQFMNTTOT + NEW.REQMNTTOT ,
            RQF.RQFMNTNET = RQF.RQFMNTNET + NEW.REQMNTNET ,
            RQF.RQFMNTTPS = RQF.RQFMNTTPS + NEW.REQMNTTPS ,
            RQF.RQFMNTTVQ = RQF.RQFMNTTVQ + NEW.REQMNTTVQ ,
            RQF.RQFMNTCTI = RQF.RQFMNTCTI + NEW.REQMNTCTI ,
            RQF.RQFMNTRTI = RQF.RQFMNTRTI + NEW.REQMNTRTI ,
            RQF.RQFMNTESC = RQF.RQFMNTESC + NEW.REQMNTESC ,
            RQF.RQFNBRITE = RQF.RQFNBRITE + 1
          where RQF.CIECLE    = NEW.CIECLE
            and RQF.REQCLE    = NEW.REQCLE
            and RQF.FOUCIECLE = NEW.FOUCIECLE
            and RQF.FOUCLE    = NEW.FOUCLE
            and RQF.RADCLE    = NEW.RADCLE;
    
    end
  end
  else begin
    if ( NEW.FOUCLE is not null)
    then begin
      update ARREQ_FOU RQF
        set RQF.RQFMNTTOT = RQF.RQFMNTTOT - OLD.REQMNTTOT + NEW.REQMNTTOT ,
            RQF.RQFMNTNET = RQF.RQFMNTNET - OLD.REQMNTNET + NEW.REQMNTNET ,
            RQF.RQFMNTTPS = RQF.RQFMNTTPS - OLD.REQMNTTPS + NEW.REQMNTTPS ,
            RQF.RQFMNTTVQ = RQF.RQFMNTTVQ - OLD.REQMNTTVQ + NEW.REQMNTTVQ ,
            RQF.RQFMNTCTI = RQF.RQFMNTCTI - OLD.REQMNTCTI + NEW.REQMNTCTI ,
            RQF.RQFMNTRTI = RQF.RQFMNTRTI - OLD.REQMNTRTI + NEW.REQMNTRTI ,
            RQF.RQFMNTESC = RQF.RQFMNTESC - OLD.REQMNTESC + NEW.REQMNTESC 
          where RQF.CIECLE    = OLD.CIECLE
            and RQF.REQCLE    = OLD.REQCLE
            and RQF.FOUCIECLE = OLD.FOUCIECLE
            and RQF.FOUCLE    = OLD.FOUCLE
            and RQF.RADCLE    = OLD.RADCLE;
    end
  end
end
end !! 
set term ; !!
             
             
set term !! ;             
create trigger TREQDEL for ARREQUISITION
/*
*  Destruction dans la table 
*/
after delete 
position 0 as 
begin
  if (  OLD.FOUCLE is not null )
  then begin
    update ARREQ_FOU RQF
    set RQF.RQFMNTTOT = RQF.RQFMNTTOT - OLD.REQMNTTOT ,
        RQF.RQFMNTNET = RQF.RQFMNTNET - OLD.REQMNTNET ,
        RQF.RQFMNTTPS = RQF.RQFMNTTPS - OLD.REQMNTTPS ,
        RQF.RQFMNTTVQ = RQF.RQFMNTTVQ - OLD.REQMNTTVQ ,
        RQF.RQFMNTCTI = RQF.RQFMNTCTI - OLD.REQMNTCTI ,
        RQF.RQFMNTRTI = RQF.RQFMNTRTI - OLD.REQMNTRTI ,
        RQF.RQFMNTESC = RQF.RQFMNTESC - OLD.REQMNTESC ,
        RQF.RQFNBRITE = RQF.RQFNBRITE - 1
      where RQF.CIECLE    = OLD.CIECLE
        and RQF.REQCLE    = OLD.REQCLE
        and RQF.FOUCIECLE = OLD.FOUCIECLE
      	and RQF.FOUCLE    = OLD.FOUCLE
 	and RQF.RADCLE    = OLD.RADCLE;
  end
end !! 
set term ; !!
