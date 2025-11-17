set term !! ;
create trigger TBLRDEL for IFRESERVATION
/*
;-------------------------------------------------------------------------------
;
;/T/ Mise-a-jour de l'historique de la reservation
;
;/P/ Programme....: Francois Richard
;    Date creation: 2 novembre 1999
;
;    Description..: Permet de mettre a jour la table d'historique
;
;-------------------------------------------------------------------------------
*/

before delete
position 0 as

begin

   insert into IFHISTO_RESERV
         ( CIECLE, 
           TGRCODGRA,
           IFCCLE,
           BLCCLE,
           BLCRED,
           BLRDATRESDEB,
           BLRDATRESFIN,
           BLRUSRRES )
    select OLD.CIECLE,
           OLD.TGRCODGRA,
           OLD.IFCCLE,
           OLD.BLCCLE,
           OLD.BLCRED,
           OLD.BLRDATRESDEB,
           OLD.BLRDATRESFIN,
           OLD.BLRUSRRES 
    from MCHOLDING where  CIENMC = "1" ;

end !!

set term ; !!

