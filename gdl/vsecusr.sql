/* VSEC_USR Permet de valider la sécurité des usagers vs les compagnies.
   ;---------------------------------------------------------------------------
   ;/T/ Programme de création d'une vue pour gérer la sécurité par Cie.
   ;
   ;/P/ Programmeur..: Lyne Ferland
   ;    Date Création: 26 février 1992
   ;
   ;    Description..:  
   ;
   ;            - On gère la sécurité par compagnie,
   ;              alors on doit respecter les compagnies accessibles pour 
   ;              l'usager VMS (rdb$user_name). On retrouve ces données
   ;              dans la table GSSEC_USR.
   ;
   ;/M/ François Déry, 8 juin 1999
   ;    Conversion en ISQL
*/
Create View vsec_usr 
As
 Select cie.ciecle,
        cie.cienomabr,
        cie.cienom
   From gssec_usr   sus,
        mccompagnie cie
  Where sus.usrcle = User
    And sus.ciecle = cie.ciecle;
