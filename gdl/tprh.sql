set term !! ;
create trigger TPRHSTO for ARPRD_HISTO
/*
* Ajout ou destruction dans la relation ARPRD_HISTO
*
* Programmeur..: Guy Chabot
* Date Création: 28 Février 1993
*
* Modifier.....: Marc Morissette
* Date modif...: 7 juin 1995
* Description..: Migration sur Oracle
*
* /M/ Patrick Langlois, 7 juin 1999
*       Conversion en ISQL
*
* Description..: Ce triggers ne fait que la mise à jour quantités en
*                lien, et la mise à jour des quantités en entrepôt.
*
*     01- Commande             05- Entré d'inventaire
*     02- Réception            06- Sortie d'inventaire
*     03- Retour               07- Ajustement d'inventaire
*     04- Matche de facture    08- Transfert d'inventaire
*     09- Inventaire physique
*
************************************************************************************************************************************
*
*    Modifié par.......: Marc Poulin     
*    Date modification.: 03 mars 2000
*    Description.......: Corriger le calcul du coût moyen sur la table ARPRD_HISTO. Supprimer la division par 10000. Problème 
*                        découvert lors de la correction du point portant sur la conversion selon les devises étrangères.
*
*    Référence.........: Stabilisation du module Achat/Réception Inventaire (point 05).
*
*    Signet............: MP-00-03-03_S05.
*
*-----------------------------------------------------------------------------------------------------------------------------------
*
*/
before insert
position 0 as

declare variable T_CDEQTEREJ DOUBLE PRECISION;
declare variable T_PREQTEPHY DOUBLE PRECISION;

begin
  /*
  *
  * Commande d'achat
  *
  */

  /*
  *
  * Produit inventorié. conserve la quantité en inventaire dans l'historique
  *
  */
  if     (     NEW.PRDTYP = 'I'
     and (     NEW.PRHTYP = '02'
            or NEW.PRHTYP = '03'
            or NEW.PRHTYP = '04'
            or NEW.PRHTYP = '05'
            or NEW.PRHTYP = '06'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' ))
  then begin
    select PRE.PREQTEPHY
      from ARPRD_ENT PRE
        where PRE.CIECLE = NEW.CIECLE
          and PRE.PRDCLE = NEW.PRDCLE
          and PRE.ENTCLE = NEW.ENTCLE
      into NEW.PRHQTEINVAVA;

  end
  /*
  *
  * Produit inventorié calcul du cout moyen courant.
  *
  */
  if      (    NEW.PRDTYP = 'I'
      and (    NEW.PRHTYP = '02'
            or NEW.PRHTYP = '03'
            or NEW.PRHTYP = '04'
            or NEW.PRHTYP = '05'
            or NEW.PRHTYP = '06'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' ))
  then begin
    select PRE.PREQTEPHY
      from ARPRD_ENT PRE
      where PRE.CIECLE = NEW.CIECLE
        and PRE.PRDCLE = NEW.PRDCLE
        and PRE.ENTCLE = NEW.ENTCLE
     into :T_PREQTEPHY;


    IF (:T_PREQTEPHY = 0 or :T_PREQTEPHY is null)
    then begin
    /* si la quantité physique est 0 alors l'on ne calcul pas le cout moyen */
    select 0
      from ARPRD_ENT PRE
      where PRE.CIECLE = NEW.CIECLE
        and PRE.PRDCLE = NEW.PRDCLE
        and PRE.ENTCLE = NEW.ENTCLE
      into NEW.PRHCOUMYN;
    end
    else begin
      /* si la quantité physique est 0 alors l'on ne calcul pas le cout moyen */
      select prosig_round((PRE.PREVAL / PRE.PREQTEPHY) * 100000)
      from ARPRD_ENT PRE
      where PRE.CIECLE = NEW.CIECLE
        and PRE.PRDCLE = NEW.PRDCLE
        and PRE.ENTCLE = NEW.ENTCLE
      into NEW.PRHCOUMYN;

    end
  end

  /*
  *
  * Produit non inventorié calcul du cout moyen courant.
  *
  */
  if      (    NEW.PRDTYP = 'N'
      and (    NEW.PRHTYP = '02'
            or NEW.PRHTYP = '03'
            or NEW.PRHTYP = '04'
            or NEW.PRHTYP = '05'
            or NEW.PRHTYP = '06'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' ))
  then begin
    select PRE.PREQTEPHYPNI
      from ARPRD_ENT PRE
      where PRE.CIECLE = NEW.CIECLE
        and PRE.PRDCLE = NEW.PRDCLE
        and PRE.ENTCLE = NEW.ENTCLE
      into :T_PREQTEPHY;


    IF (:T_PREQTEPHY = 0 or :T_PREQTEPHY is null)
    then begin
    /* si la quantité physique est 0 alors on ne calcul pas le cout moyen */
    select 0
      from ARPRD_ENT PRE
      where PRE.CIECLE = NEW.CIECLE
        and PRE.PRDCLE = NEW.PRDCLE
        and PRE.ENTCLE = NEW.ENTCLE
     into NEW.PRHCOUMYN;
    end
    else begin
      /* si la quantité physique est 0 alors l'on ne calcul pas le cout moyen */
      select prosig_round((PRE.PREVAL / PRE.PREQTEPHYPNI) * 100000)
        from ARPRD_ENT PRE
        where PRE.CIECLE = NEW.CIECLE
          and PRE.PRDCLE = NEW.PRDCLE
          and PRE.ENTCLE = NEW.ENTCLE
       into NEW.PRHCOUMYN;
    end
  end

  /*
  *
  * M.a.j de la quantité commandé et du dernier prix
  *
  */
  update ARPRD_ENT PRE
    set PRE.PREQTECOM  =  PRE.PREQTECOM + NEW.PRHQTETRS,
        PRE.PREDERCOU  = NEW.PRHDERCOU
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '01';
   /*
   *
   * Réception de commande,  Produit inventorié.
   *
   */
  update ARPRD_ENT PRE
     set  PRE.PREQTEPHY     =  PRE.PREQTEPHY + NEW.PRHQTETRS,
          PRE.PREVAL        =  PRE.PREVAL    + NEW.PRHVAL,
          PRE.PREDERCOU     = NEW.PRHDERCOU
    where  PRE.CIECLE = NEW.CIECLE
      and  PRE.PRDCLE = NEW.PRDCLE
      and  PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '02'
      and NEW.PRDTYP = 'I';
   /*
   *
   * Réception de commande,  Produit non inventorié.
   *
   */
  update ARPRD_ENT PRE
     set PRE.PREQTEPHYPNI = PRE.PREQTEPHYPNI + NEW.PRHQTETRS,
         PRE.PREVAL      =  PRE.PREVAL       + NEW.PRHVAL,
         PRE.PREDERCOU   = NEW.PRHDERCOU
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '02'
      and NEW.PRDTYP = 'N';


  if (NEW.PRHTYP = '02')
  then begin
    select CDEQTEREJ
      from ARCMD_DETAIL CDE WHERE CDE.CIECLE = NEW.CIECLE
                              and CDE.CMDCLE = prosig_extract(1,9,NEW.PRHNUMREF2," ")
                              and CDE.CMDAJT = prosig_extract(10,3,NEW.PRHNUMREF2," ")
                              and CDE.CDECLE = NEW.PRHITM
    into :T_CDEQTEREJ;
  end

  update ARPRD_ENT PRE
    set PRE.PREQTECOM = PRE.PREQTECOM - (NEW.PRHQTETRS + :T_CDEQTEREJ )
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '02'
      and NEW.PRHFLGCPL = '1';


  update ARPRD_ENT PRE
    set PRE.PREQTECOM = PRE.PREQTECOM - NEW.PRHQTETRS
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '02'
      and NEW.PRHFLGCPL != '1';

   /*
   *
   * Retour sur réception non-facturée, Produit inventorié.
   *
   */
  update ARPRD_ENT PRE
    set PRE.PREQTEPHY     = PRE.PREQTEPHY - NEW.PRHQTETRS,
        PRE.PREVAL        = PRE.PREVAL    - NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '03'
      and NEW.PRDTYP = 'I';

   /*
   *
   * Retour sur réception non-facturée, Produit non inventorié.
   *
   */
  update ARPRD_ENT PRE
    set PRE.PREQTEPHYPNI = PRE.PREQTEPHYPNI - NEW.PRHQTETRS,
        PRE.PREVAL       = PRE.PREVAL       - NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '03'
      and NEW.PRDTYP = 'N';


  /*
  *
  * Réévaluation de la valeur d'inventaire sur matche de facture. Produit inventorié.
  *
  */
  update ARPRD_ENT PRE
    set  PRE.PREVAL      = PRE.PREVAL + NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '04'
      and NEW.PRDTYP = 'I';

  update ARPRD_ENT PRE
    set  PRE.PREDERCOU    = NEW.PRHDERCOU
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '04'
      and NEW.PRDTYP = 'I'
      and 0 != NEW.PRHDERCOU;
  /*
  *
  * Réévaluation de la valeur d'inventaire sur matche de facture. Produit non inventorié.
  *
  */
  update ARPRD_ENT PRE
    set  PRE.PREVAL       = PRE.PREVAL + NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '04'
      and NEW.PRDTYP = 'N';

  update ARPRD_ENT PRE
    set  PRE.PREDERCOU    = NEW.PRHDERCOU
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '04'
      and NEW.PRDTYP = 'I'
      and 0 != NEW.PRHDERCOU;


   /*
   *
   * Entrée, Ajustement, Transfert d'inventaire et Inventaire physique
   * Produit inventorié.
   *
   */
  update ARPRD_ENT PRE
    set PRE.PREQTEPHY    = PRE.PREQTEPHY + NEW.PRHQTETRS ,
        PRE.PREVAL       = PRE.PREVAL    + NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and (    NEW.PRHTYP = '05'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' )
      and NEW.PRDTYP = 'I';


   /*
   *
   * Sortie d'inventaire.  Produit inventorié.
   *
   */
  update ARPRD_ENT PRE
    set PRE.PREQTEPHY    = PRE.PREQTEPHY - NEW.PRHQTETRS,
        PRE.PREVAL       = PRE.PREVAL    - NEW.PRHVAL
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and NEW.PRHTYP = '06'
      and NEW.PRDTYP = 'I';

    /*
    *
    * Calcul du coût moyen pour les réceptions, les retours et les matches
    * de facture.
    * Produit inventorié.
    *
    */

  update ARPRD_ENT PRE
    set  PRE.PRECOUMYN = prosig_round((PRE.PREVAL / PRE.PREQTEPHY) * 100000)
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and (    NEW.PRHTYP = '02'
            or NEW.PRHTYP = '03'
            or NEW.PRHTYP = '04'
            or NEW.PRHTYP = '05'
            or NEW.PRHTYP = '06'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' )
      and NEW.PRDTYP = 'I'
      and PRE.PREQTEPHY > 0;


    /*
    *
    * Calcul du coût moyen pour les réceptions, les retours et les matches
    * de facture.
    * Produit non inventorié.
    *
    */

  update ARPRD_ENT PRE
    set PRE.PRECOUMYN = prosig_round((PRE.PREVAL / PRE.PREQTEPHYPNI) * 100000)
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and (    NEW.PRHTYP = '02'
            or NEW.PRHTYP = '03'
            or NEW.PRHTYP = '04'
            or NEW.PRHTYP = '05'
            or NEW.PRHTYP = '06'
            or NEW.PRHTYP = '07'
            or NEW.PRHTYP = '08'
            or NEW.PRHTYP = '09' )
      and NEW.PRDTYP = 'N'
      and PRE.PREQTEPHYPNI > 0;

   /*
    *
    * Calcul du coût moyen - Ne pas permettre de coût moyen négatif.
    *
    */

  update ARPRD_ENT PRE
    set  PRE.PRECOUMYN = PRE.PRECOUMYN * -1 
    where PRE.CIECLE = NEW.CIECLE
      and PRE.PRDCLE = NEW.PRDCLE
      and PRE.ENTCLE = NEW.ENTCLE
      and PRE.PRECOUMYN < 0;


 /*
 *
 * Que pour le module d'achat réception.
 *
 */
  if (NEW.PRHTYP <= '04')
  then begin
    insert into ARPRD_FOU (
      CIECLE          ,
      PRDCLE          ,
      FOUCIECLE       ,
      FOUCLE          ,
      PDFPRDCLEFOU    ,
      PDFDERCOU       ,
      PDFQTECOM       ,
      PDFNBRLIV       ,
      PDFNBRJRSCMDLIV )
    select NEW.CIECLE    ,
           NEW.PRDCLE    ,
           NEW.FOUCIECLE ,
           NEW.FOUCLE    ,
           ' '           ,
           0             ,
           0             ,
           0             ,
           0
      from MCHOLDING where  CIENMC = "1" and
                         not exists ( select pdf.ciecle
                                     from ARPRD_FOU PDF
                                     where PDF.CIECLE    = NEW.CIECLE
                                       and PDF.PRDCLE    = NEW.PRDCLE
                                       and PDF.FOUCIECLE = NEW.FOUCIECLE
                                       and PDF.FOUCLE    = NEW.FOUCLE );


    update ARPRD_FOU PDF
      set PDF.PDFDATDERACH = NEW.PRHDATREF ,
          PDF.PDFQTECOM    =  PDF.PDFQTECOM + NEW.PRHQTETRS
      where PDF.CIECLE    = NEW.CIECLE
        and PDF.PRDCLE    = NEW.PRDCLE
        and PDF.FOUCIECLE = NEW.FOUCIECLE
        and PDF.FOUCLE    = NEW.FOUCLE
        and NEW.PRHTYP = '01';

    if (NEW.PRHTYP = '02')
    then begin
      select CDEQTEREJ
        from ARCMD_DETAIL CDE WHERE CDE.CIECLE = NEW.CIECLE
                                and CDE.CMDCLE = prosig_extract(1,9,NEW.PRHNUMREF2," ")
                                and CDE.CMDAJT = prosig_extract(10,3,NEW.PRHNUMREF2," ")
                                and CDE.CDECLE = NEW.PRHITM
      into :T_CDEQTEREJ;
    end

    update ARPRD_FOU PDF
      set PDF.PDFNBRLIV       = PDF.PDFNBRLIV + 1                   ,
          PDF.PDFNBRJRSCMDLIV = PDF.PDFNBRJRSCMDLIV +  NEW.PRHNBRJRS,
          PDF.PDFQTECOM       = PDF.PDFQTECOM       - (NEW.PRHQTETRS + :T_CDEQTEREJ )
      where PDF.CIECLE     = NEW.CIECLE
        and PDF.PRDCLE     = NEW.PRDCLE
        and PDF.FOUCIECLE  = NEW.FOUCIECLE
        and PDF.FOUCLE     = NEW.FOUCLE
        and NEW.PRHTYP     = '02'
        and NEW.PRHFLGCPL  = '1';

    update ARPRD_FOU PDF
      set PDF.PDFNBRLIV       = PDF.PDFNBRLIV + 1                   ,
          PDF.PDFNBRJRSCMDLIV = PDF.PDFNBRJRSCMDLIV + NEW.PRHNBRJRS,
          PDF.PDFQTECOM       = PDF.PDFQTECOM       - NEW.PRHQTETRS
      where PDF.CIECLE     = NEW.CIECLE
        and PDF.PRDCLE     = NEW.PRDCLE
        and PDF.FOUCIECLE  = NEW.FOUCIECLE
        and PDF.FOUCLE     = NEW.FOUCLE
        and NEW.PRHTYP     = '02'
        and NEW.PRHFLGCPL != '1';

    update ARPRD_FOU PDF
      set PDF.PDFDERCOU    = NEW.PRHDERCOU
      where PDF.CIECLE    = NEW.CIECLE
        and PDF.PRDCLE    = NEW.PRDCLE
        and PDF.FOUCIECLE = NEW.FOUCIECLE
        and PDF.FOUCLE    = NEW.FOUCLE;
  end
end !!
set term ; !!

/*-----------------------------------------------------------------------------
  Desctruction d'une historique de type "04"
*/
set term !! ;
create trigger TPRHDEL for ARPRD_HISTO
before delete
position 0 as

begin
  if ( OLD.PRHTYP = '04' )
  then begin
  /*
  *
  * Réévaluation de la valeur d'inventaire sur matche de facture. Produit inventorié.
  *
  */
  update ARPRD_ENT PRE
    set  PRE.PREVAL      = PRE.PREVAL - OLD.PRHVAL
    where PRE.CIECLE = OLD.CIECLE
      and PRE.PRDCLE = OLD.PRDCLE
      and PRE.ENTCLE = OLD.ENTCLE
      and OLD.PRDTYP = 'I';

  /*
  *
  * Réévaluation de la valeur d'inventaire sur matche de facture. Produit non inventorié.
  *
  */
  update ARPRD_ENT PRE
    set  PRE.PREVAL       = PRE.PREVAL - OLD.PRHVAL
    where PRE.CIECLE = OLD.CIECLE
      and PRE.PRDCLE = OLD.PRDCLE
      and PRE.ENTCLE = OLD.ENTCLE
      and OLD.PRHTYP = '04'
      and OLD.PRDTYP = 'N';

    /*
    *
    * Calcul du coût moyen pour les réceptions, les retours et les matches
    * de facture.
    * Produit inventorié.
    *
    */

  update ARPRD_ENT PRE
    set  PRE.PRECOUMYN = prosig_round((PRE.PREVAL / PRE.PREQTEPHY) * 100000)
    where PRE.CIECLE = OLD.CIECLE
      and PRE.PRDCLE = OLD.PRDCLE
      and PRE.ENTCLE = OLD.ENTCLE
      and OLD.PRDTYP = 'I'
      and PRE.PREQTEPHY > 0;


    /*
    *
    * Calcul du coût moyen pour les réceptions, les retours et les matches
    * de facture.
    * Produit non inventorié.
    *
    */

  update ARPRD_ENT PRE
    set PRE.PRECOUMYN = prosig_round((PRE.PREVAL / PRE.PREQTEPHYPNI) * 100000)
    where PRE.CIECLE = OLD.CIECLE
      and PRE.PRDCLE = OLD.PRDCLE
      and PRE.ENTCLE = OLD.ENTCLE
      and PRE.PREQTEPHYPNI > 0;

   /*
    *
    * Calcul du coût moyen - Ne pas permettre de coût moyen négatif.
    *
    */

  update ARPRD_ENT PRE
    set  PRE.PRECOUMYN = PRE.PRECOUMYN * -1 
    where PRE.CIECLE = OLD.CIECLE
      and PRE.PRDCLE = OLD.PRDCLE
      and PRE.ENTCLE = OLD.ENTCLE
      and PRE.PRECOUMYN < 0;

  end
end !!
set term ; !!

