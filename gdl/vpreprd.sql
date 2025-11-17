/* Vue sur ARPRD_ENT et ARPRODUIT
*
* Programmeur..: Guy Chabot
* Date création: 21 Février 1994
*
* Modifier.....: Marc Morissette 
* Date modif...: 20 avril 1995
* Description..: Migration sur Oracle
*
* Description..: Le but de cette vue est de réunir deux tables pour 
*                regrouper les informations qu'ils contiennent.
*
*                Les deux tables ont sur chaque transaction une relation
*                1 à 1 et n'est jamais mis à jour dans un panorama.
* 
* /M/ Patrick Langlois, 7 juin 1999
*     Conversion en ISQL 
*
*
*/

create view VPRE_PRD
as
select PRE.CIECLE,
       PRE.PRDCLE,
       PRE.ENTCLE,
       PRE.ENLCLE,
       PRE.PREQTEDEM,
       PRE.PREQTECOM,
       PRE.PREQTEPHY,
       PRE.PRECOUMYN,
       PRE.PREDERCOU,
       PRE.PREPOICOM,
       PRE.PREFLGGESMAX,
       PRE.PREQTEMAX,
       PRE.PREFLGAUTNEG,
       PRE.PREVAL,
       PRD.PRDTYP,
       PRD.PRDCAT,
       PRD.PRDSTU,
       PRD.PRDDSC1,
       PRD.PRDDSC2,
       PRD.PRDDSC3,
       PRD.PRDUNI,
       PRD.PRDPDSUNI,
       PRD.PRDVOLUNI,
       PRD.PRDCPTINV,
       PRD.PRDUNAINV,
       PRD.PRDFLGRESFOR,
       PRD.PRDMULACC,
       PRD.PRDGRPINV
   from ARPRD_ENT      PRE ,
        ARPRODUIT      PRD
   where PRE.CIECLE = PRD.CIECLE and
         PRE.PRDCLE = PRD.PRDCLE;
