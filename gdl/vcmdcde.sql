/* Vue sur ARCOMMANDE et ARCMD_DETAIL
*
* Modifier.....: Marc Morissette 
* Date modif...: 20 avril 1995
* Description..: Migration sur Oracle
*
* 
* Description..: Fichier pour sélectionner le détail de la commande
*                et ses ajustements.
* 
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL 
*
*
*/

create view VCMD_CDE
as
select CMD.CIECLE,
       CMD.CMDCLE,
       CMD.CMDAJT,
       CMD.CMDSTU,
       CDE.CDECLE,
       CDE.PRDCLE,
       CDE.PRDTYP,
       CDE.CDEQTECOM,
       CDE.CDEQTEREC,
       CDE.CDEQTEREJ,
       CDE.CDETAXTYPTPS,
       CDE.CDETAXCODTPS,
       CDE.CDETAXTYPTVQ,
       CDE.CDETAXCODTVQ,
       CDE.CDETERESCACH,
       CDE.CDESTU,
       CDE.CDEDSCPRD,
       CDE.CDEPRIUNI,
       CDE.CPTCLE,
       CDE.UNACLE,
       CDE.PRJCLE,
       CDE.PRACLE,
      CDE.IMMCLE,
       CDE.CDEMNTTOT,
       CDE.CDEMNTTPS,
       CDE.CDEMNTTVQ,
       CDE.CDEMNTCTI,
       CDE.CDEMNTRTI,
       CDE.CDEMNTESC,
       CDE.CDEMNTENG,
       CDE.CDEMNTDES,
       CDE.CDEMNTNET,
       CDE.DEVTAU,
       CDE.CDEDATIMP
  from   ARCOMMANDE   CMD ,
         ARCMD_DETAIL CDE 
  where  CMD.CIECLE = CDE.CIECLE
    and  CMD.CMDCLE = CDE.CMDCLE
    and  CMD.CMDAJT = CDE.CMDAJT
    and  (     CMD.CMDSTU = 'A'
           or  CMD.CMDSTU = 'S' )
    and  (     ' ' = prosig_nvlc(CDE.CDESTU) 
           or  'S' = CDE.CDESTU );
