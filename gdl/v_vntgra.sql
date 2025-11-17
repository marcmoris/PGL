/* VVNTGRA Créer pour remédier un problème de sélection des données de impromptu
  ;/T/ 
  ;
  ;/P/ Programmeur.......: Patrick Langlois
  ;    Date création.....: 26 Mai 1999
  ;    Description.......: Impromptu ne sélectionne pas les données avec le "with" il faIt un produit 
  ;                        cartésien et ensuite il applique de with. Le rapport est trop long  à exécuter.
  ;                        Avec la vue c'est la base de données qui va faire le travail.
  ;
  ;***********************************************************************************************************************************
  ;
  ;/M/ Modifié par.......: Marc Poulin     
  ;    Date modification.: 29 février 2000
  ;    Description.......: Redéfinition de la vue afin d'éliminer les doubles et de sélectionner le bon nombre d'enregistrements.
  ;
  ;
  ;    Référence.........: Demande de changement 999999.
  ;    
  ;    Signet............: MP-00-02-29_D999999.
  ;
  ;-----------------------------------------------------------------------------------------------------------------------------------
  ;
  ;/M/ Francois Déry, 4 juin 1999
  ;     Conversion en isql.
*/   
Create View v_vntgra /* MP-00-02-29_D999999 - Redéfinition compléete de la vue. */
As 
 Select T1.TGRCODGRA   ,
        T1.TYFCODFIN   ,
        T1.TRAEPA      ,  
        T1.TRADATCRE   ,  
        T2.TGRDSCFRA001,
        T3.CIECLE      ,
        T3.CAINUMCAI   ,
        T3.TRANUMTRA002,
        T3.EMTSURMC2VEN,
        T5.EXPDATEXP   ,
        T6.DCIPRIUNMPRD,
        T6.DCINUMLIG   ,
        T6.PJTABR      ,
        T6.PJTANN      ,
        T6.COMNUMCOMINT 
   From PDTRANCHE        T1,
        PDTYPE_GRANIT    T2,
        PDEMBAL_TRANCHE  T3,
        PDLIVRE_CAISSON  T4,
        PDEXPEDITION     T5,
        PDDETAIL_C_I     T6
  Where T1.CIECLE       = T2.CIECLE       AND
        T1.TGRCODGRA    = T2.TGRCODGRA    AND
        T1.CIECLE       = T3.CIECLE       AND 
        T1.TRANUMTRA002 = T3.TRANUMTRA002 AND
        T3.CAINUMCAI    = T4.CAINUMCAI    AND
        T3.CIECLE       = T4.CIECLE       AND
        T4.EXPNUMEXP    = T5.EXPNUMEXP    AND
        T4.CIECLE       = T5.CIECLE       AND
        T3.CIECLE       = T6.CIECLE       AND
        T3.DCINUMLIG    = T6.DCINUMLIG    AND 
        T3.PJTABR       = T6.PJTABR       AND
        T3.PJTANN       = T6.PJTANN       AND 
        T3.COMNUMCOMINT = T6.COMNUMCOMINT ; 
       