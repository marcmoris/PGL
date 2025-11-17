/*
** Programme   : GL950.E
** Module      : Grand livre
**               Recalcul des soldes
**
** /V3.05.02/ Denis Pouliot,   1 juin 1999, SOS( EDS, ALPVMS )
**   État        :  [Terminer]
**   Description :  Revision pour le passage AN2000 INTERBASE 4
**                  Ajouter include sur string.h et déclaration de mc950()
**                  corriger les comparaisons
**                  entre les références sur années pour utiliser une chaîne
**                  de caractère (l_sql_anrxxx_s) au lieu de comparer sous forme
**                  de numérique.
**                  ( Exemples : Remplacer san.sanann.long = l_anrsui_i
**                                  PAR    san.sanann      = l_sql_anrsui_s )
**
**                  Corriger le calcul de l_parann_i pour initailiser
**                  à zéro si plus petit que 99
**                  Remplacer les #if HP par des #if UNIX
**
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Mai 1992
**
** Description : Actualisation des soldes d'ouverture pour l'année demandée
**               en paramètre.
**
** Paramètres d'entrée  :
**
**              .Nom de la base de données
**              .Année financière ou Période à mettre à jour
**
** Paramètres de sortie :
**
**              .Status d'exécution
**
** Modification.: - Alain Côté le 17 février 1993
**                  Extraction de l'année de la période recu en paramètre.
**
**                - Le 22 Février 1993 par Thomas BRENNEUR
**                  Correction du calcul du BNR.
**
**                - Le 29 Juillet 1993 par Thomas BRENNEUR
**                  Adaptation pour PGL
**
**                - Le 19 octobre 1993 par Alain Côté
**                  Modification dans les paramètres reçus. J'ai mis comme
**                  premier paramètre la nom de la base de données.
**
*/

#include  <stdio.h>
#include  <stdlib.h>
#include  <string.h>
#include  "mc950.h" /* Définitions communes et gestion des messages */

/*
 * Déclaration des paramètres de configuration du programme
 */

#define NOMBRE_ARGUMENTS        3
#define NOM_PROGRAMME           "GL950"

#define PROSIG_USRLNG           "PROSIG_USRLNG" /* Variable environementale contenant la langue de l'usager             */

/*
 * Déclaration de la base de donnée et des variables associés au GDML.
 */

DATABASE db_dict = COMPILETIME FILENAME "dict.gdb"
                   RUNTIME FILENAME argv[1];

BASED ON mcannee_ref.anrann     g_anrann_s;    /* Année de référence                */

/*
 * Déclaration de la zone de communication pour le SQL.
 */
EXEC SQL BEGIN DECLARE SECTION;
EXEC SQL END   DECLARE SECTION;

/*
 * Déclaration des types des Fonctions
 */

extern int          mc950();


/*
 *------------------------------------------------------------------------------
 * PROGRAMME PRINCIPAL
 *------------------------------------------------------------------------------
 */

int main(argc,argv)
int     argc;               /* Nombre d'arguments lus                         */
char  **argv;               /* Table de pointeur sur chaque argument lu       */
{
 /*
  * Déclaration des variables locales.
  */

  int     l_usager_valide_f;  /* Flag indiquant si l'usager est valide                  */
  int     l_annee_trouve_f;   /* Flag indiquant si une année de ref. existe             */
  int     l_cie_trouve_f;     /* Flag indiquant si au moins une compagnie existe        */
  int     l_sldbnr_f;         /* Flag indiquant si un BNR existe pour cette CIE/CEN     */
  int     l_sldcpt_f;         /* Flag indiquant si le compte existe pour l'année suivante */

  int     l_parann_i;         /* Année lue en paramètre                                 */
  int     l_anrann_i;         /* Année lue dans MCANNE_REF                              */
  int     l_anrcou_i;         /* Année en cours de traitement                           */
  int     l_anrsui_i;         /* Année qui reçoit les soldes d'ouverture                */

  int     l_anr_i;            /* Compteur sur les années de référence                   */
  int     l_cnt_i;            /* Compteur du nombre d'occurences créées ou modifiées    */

  char    l_lngcle_c;         /* Langue de l'usager                                     */
  char  * l_symval_s;         /* Pointeur sur la chaine contenant la langue de l'usager */

 /*
  * Déclaration des 'Host variables' pour la requète SQL
  */

BASED ON mcannee_ref.anrann     l_sql_anrcou_s;     /* Année en cours                               */
BASED ON mcannee_ref.anrann     l_sql_anrsui_s;     /* Année en suivante                            */

BASED ON mccompte.naccle        l_sql_naccle_i;     /* Nature de compte                             */
BASED ON mccompte.cptcle        l_sql_cptbnr_s;     /* Compte de BNR de la compagnie                */

BASED ON mcsolde_annuel.sanann  l_sql_sanann_s;     /* Année du solde                               */
BASED ON mcsolde_annuel.ciecle  l_sql_ciecle_s;     /* Compagnie du solde                           */
BASED ON mcsan_rest.srecieint   l_sql_srecieint_s;  /* Compagnie d'intercentre du solde restrictif  */
BASED ON mcsan_rest.sreunaint   l_sql_sreunaint_s;  /* Centre d'intercentre du solde restrictif     */
BASED ON mcsolde_annuel.cptcle  l_sql_cptcle_s;     /* Numéro de compte du solde                    */
BASED ON mccompagnie.cieunabil  l_sql_cieunabil_s;  /* Unité de bilan                               */

  double  l_sql_cum_d;        /* Valeur du cumul des soldes                                         */
  double  l_sql_sldbnr_d;     /* Soldes des revenus moins solde des dépenses                        */

BASED ON mcsolde_annuel.ciecle  l_sql_ciecle_old_s;    /* Compagnie du solde précédent              */
BASED ON mcsan_rest.srecieint   l_sql_srecieint_old_s; /* Compagnie d'inter du solde rest. précédent*/
BASED ON mcsan_rest.sreunaint   l_sql_sreunaint_old_s; /* Unité d'inter du solde rest. précédent    */
BASED ON mccompagnie.cieunabil  l_sql_cieunabil_old_s; /* Unité de bilan de la compagnie précédente */

  int   l_sql_nac_revenu_i  = NAC_REVENU; /* Il faut définir une valeur pour les define car le SQL  */
  int   l_sql_nac_depense_i = NAC_DEPENSE;/* ne reconnait pas les définitions du compilateur        */

BASED ON mccompte.cptcat        l_sql_cptcatbnr_s;     /* Catégorie du compte                       */

 /*
  * Ouverture de la base de donnée,
  * Récupération de la langue de l'usager (Pour les messages)
  */

  READY db_dict
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

  START_TRANSACTION
    CONCURRENCY READ_WRITE WAIT
    RESERVING gsusager       FOR READ,
              mcannee_ref    FOR PROTECTED WRITE,
              mcsolde_annuel FOR WRITE,
              mcsan_rest     FOR WRITE,
              mccompte       FOR READ
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      FINISH db_dict;
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

   /*
    * On récupère la langue de l'usager
    */
    if (getenv(PROSIG_USRLNG))
      l_lngcle_c = getenv(PROSIG_USRLNG)[0];
    else
      l_lngcle_c = FRA; /* 1ere langue par défaut */

 /*
  * Vérification du paramètre d'entrée.
  * Ce doit être une année sur 2 caractères ( ex : 92 ).
  */

  if ( argc != NOMBRE_ARGUMENTS )
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,PARAMINV); /* Paramètre invalide */
      ROLLBACK;
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  l_parann_i = atoi(argv[2]);

 /*
  * On recoit une année ou un période en paramètre. Il faut extraire l'année
  * de la période. La variable l_parann_i est un entier, si on divise la
  * valeur par 100 et qu'on l'affecte à celle-ci, le résultat est tronqué. (AC).
  */

  if ( l_parann_i > 99 )
    l_parann_i = l_parann_i / 100;
  else
   {
     /*   On est en 2000    */
     if ( l_parann_i > 0 )
       l_parann_i = 0;
   }

  if (l_parann_i  < 0)
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,PARAMINV);  /* Paramètre invalide */
      ROLLBACK;
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  if (l_parann_i < 10)
      l_parann_i += ANNEE_00;
  else
      l_parann_i += SIECLE_ACTUEL;

 /*
  * Recherche de l'année de référence actuelle. Si celle-ci est inférieur
  * à l'année demandée en paramètre, alors il va falloir mettre à jour
  * tous les soldes d'ouvertures depuis l'année de référence, jusqu'à
  * l'année demandée. Puis avec les comptes revenus et dépenses, on va
  * recalculer le compte BNR pour chaque compagnie.
  */

  SET_FALSE(l_annee_trouve_f);

  FOR FIRST 1 anr IN mcannee_ref
    {
      SET_TRUE(l_annee_trouve_f);
      strcpy (g_anrann_s,anr.anrann);
    }
  END_FOR
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      ROLLBACK;
      FINISH db_dict;
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

  if (!l_annee_trouve_f)
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,ANRREFINC); /* Année de référence inconnue */
      ROLLBACK
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      FINISH db_dict;
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  l_anrann_i = atoi(g_anrann_s);

  if (l_anrann_i  < 0)
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,ANRINV); /* année de référence invalide */
      ROLLBACK
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  if (l_anrann_i < 10)
      l_anrann_i += ANNEE_00;
  else
      l_anrann_i += SIECLE_ACTUEL;

  if ( l_anrann_i < l_parann_i )
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,RECANRDEP); /* Recalcul de l'année de référence depuis : */
      fprintf(stderr," %d\n",l_anrann_i);
      mc950(NOM_PROGRAMME,l_lngcle_c,JUSQUA); /* Jusqu'a : */
      fprintf(stderr," %d\n",l_parann_i);
    }
  else
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,ANRPOSRECNON); /* Année de référence postérieur à l'année demandée, pas de recalcul. */
      COMMIT
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
      return(EXIT_SANS_ERREUR);
    }

 /*
  * On parcours toutes les années à traiter
  */

  l_cnt_i = 0;

  for (l_anr_i = l_anrann_i ; l_anr_i < l_parann_i ; l_anr_i++)
    {
     /*
      * Pour tous les soldes des comptes (autres que revenus ou dépenses) de
      * l'année de référence qui possèdent déja un solde dans l'année suivante,
      * On recalcul le solde d'ouverture de l'année suivante.
      * Remarque : On n'utilise que les 2 derniers chiffres de l'année. Et
      *            comme l_anr_i est un entier, le diviser par 100 fait
      *            disparaitre les decimales.
      */

      l_anrcou_i = (l_anr_i - (l_anr_i/100)*100);
      l_anrsui_i = ((l_anr_i+1) - ((l_anr_i+1)/100)*100);
      sprintf(l_sql_anrcou_s,"%02d",l_anrcou_i);
      sprintf(l_sql_anrsui_s,"%02d",l_anrsui_i);

      mc950(NOM_PROGRAMME,l_lngcle_c,TRAANN); /* Traitement des années : */
      fprintf(stderr," %s - %s\n",l_sql_anrcou_s,l_sql_anrsui_s);

      mc950(NOM_PROGRAMME,l_lngcle_c,TRASAN); /* Traitement des soldes annuels */

      /*
       * Cette étape permet de mettre le solde d'ouverture du compte BNR
       * à zéro. Cette opération est nécessaire puisque lorsque le compte
       * de BNR n'existe pas dans l'année précédente, le solde d'ouverture
       * n'est pas bon. Si ce compte existait, alors l'étape suivante
       * calculera les bons soldes d'ouverture.
       */

      FOR cpt IN mccompte
          CROSS san IN mcsolde_annuel
          WITH cpt.cptcat = CPTCAT_BNR
              AND cpt.cptcle = san.cptcle
              AND san.sanann = l_sql_anrsui_s
        {
          MODIFY san USING
            {
              san.sansldouv = 0;
            }
          END_MODIFY
            ON_ERROR
#if UNIX
                  gds__print_status ( gds__status );
#else
                  gds_$print_status ( gds_$status );
#endif
                  ROLLBACK;
                  FINISH db_dict;
                  return(EXIT_AVEC_ERREUR);
                END_ERROR;

        }
      END_FOR
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          ROLLBACK;
          FINISH db_dict;
          return(EXIT_AVEC_ERREUR);
        END_ERROR;

       /*
        * Calcul du solde d'ouverture des comptes de bilan, incluant le compte
        * de bnr.
        *
        */
      FOR cpt IN mccompte
          CROSS san   IN mcsolde_annuel
          WITH    cpt.naccle       != NAC_REVENU
              AND cpt.naccle       != NAC_DEPENSE
              AND san.sanann        = l_sql_anrcou_s
              AND san.cptcle        = cpt.cptcle
        {
          SET_FALSE(l_sldcpt_f);
          FOR san_1 IN mcsolde_annuel
              WITH san_1.sanann      = l_sql_anrsui_s
               AND san_1.cptcle      = san.cptcle
               AND san_1.ciecle      = san.ciecle
               AND san_1.unacle      = san.unacle
            {
             /*
              * Le solde d'ouverture de l'année suivante est égal à la somme
              * du solde d'ouverture de l'année actuelle et des 14 périodes
              * de cette année. Le même calcul est appliqué pour les engagements.
              */
              SET_TRUE(l_sldcpt_f);
              MODIFY  san_1 USING
                {
                  san_1.sansldouv     =   san.sansldouv
                                        + san.sancumree1
                                        + san.sancumree2
                                        + san.sancumree3
                                        + san.sancumree4
                                        + san.sancumree5
                                        + san.sancumree6
                                        + san.sancumree7
                                        + san.sancumree8
                                        + san.sancumree9
                                        + san.sancumree10
                                        + san.sancumree11
                                        + san.sancumree12
                                        + san.sancumree13
                                        + san.sancumree14;

                  san_1.sansldouveng  =   san.sansldouveng
                                        + san.sancumeng1
                                        + san.sancumeng2
                                        + san.sancumeng3
                                        + san.sancumeng4
                                        + san.sancumeng5
                                        + san.sancumeng6
                                        + san.sancumeng7
                                        + san.sancumeng8
                                        + san.sancumeng9
                                        + san.sancumeng10
                                        + san.sancumeng11
                                        + san.sancumeng12
                                        + san.sancumeng13
                                        + san.sancumeng14;
                }
              END_MODIFY
                ON_ERROR
#if UNIX
                  gds__print_status ( gds__status );
#else
                  gds_$print_status ( gds_$status );
#endif
                  ROLLBACK;
                  FINISH db_dict;
                  return(EXIT_AVEC_ERREUR);
                END_ERROR;

            }
          END_FOR
            ON_ERROR
#if UNIX
              gds__print_status ( gds__status );
#else
              gds_$print_status ( gds_$status );
#endif
              ROLLBACK;
              FINISH db_dict;
              return(EXIT_AVEC_ERREUR);
            END_ERROR;

          if (!l_sldcpt_f)
            {
              STORE san_1 IN mcsolde_annuel USING
                {
                  strcpy( san_1.sanann, l_sql_anrsui_s);
                  strcpy( san_1.cptcle, san.cptcle);
                  strcpy( san_1.ciecle, san.ciecle);
                  strcpy( san_1.unacle, san.unacle);
                  san_1.sansldouv     =   san.sansldouv
                                        + san.sancumree1
                                        + san.sancumree2
                                        + san.sancumree3
                                        + san.sancumree4
                                        + san.sancumree5
                                        + san.sancumree6
                                        + san.sancumree7
                                        + san.sancumree8
                                        + san.sancumree9
                                        + san.sancumree10
                                        + san.sancumree11
                                        + san.sancumree12
                                        + san.sancumree13
                                        + san.sancumree14;

                  san_1.sansldouveng  =   san.sansldouveng
                                        + san.sancumeng1
                                        + san.sancumeng2
                                        + san.sancumeng3
                                        + san.sancumeng4
                                        + san.sancumeng5
                                        + san.sancumeng6
                                        + san.sancumeng7
                                        + san.sancumeng8
                                        + san.sancumeng9
                                        + san.sancumeng10
                                        + san.sancumeng11
                                        + san.sancumeng12
                                        + san.sancumeng13
                                        + san.sancumeng14;
                 /*
                  * Initialisation des autres variables numériques de l'occurence pour ne pas générer de "missing value"
                  * dans la base.
                  */
                  san_1.sancumree1  = 0;
                  san_1.sancumree2  = 0;
                  san_1.sancumree3  = 0;
                  san_1.sancumree4  = 0;
                  san_1.sancumree5  = 0;
                  san_1.sancumree6  = 0;
                  san_1.sancumree7  = 0;
                  san_1.sancumree8  = 0;
                  san_1.sancumree9  = 0;
                  san_1.sancumree10 = 0;
                  san_1.sancumree11 = 0;
                  san_1.sancumree12 = 0;
                  san_1.sancumree13 = 0;
                  san_1.sancumree14 = 0;
                  san_1.sanbdgann   = 0;
                  san_1.sanbdg1     = 0;
                  san_1.sanbdg2     = 0;
                  san_1.sanbdg3     = 0;
                  san_1.sanbdg4     = 0;
                  san_1.sanbdg5     = 0;
                  san_1.sanbdg6     = 0;
                  san_1.sanbdg7     = 0;
                  san_1.sanbdg8     = 0;
                  san_1.sanbdg9     = 0;
                  san_1.sanbdg10    = 0;
                  san_1.sanbdg11    = 0;
                  san_1.sanbdg12    = 0;
                  san_1.sanbdg13    = 0;
                  san_1.sanbdg14    = 0;
                  san_1.sanbdgrevann = 0;
                  san_1.sanbdgrev1   = 0;
                  san_1.sanbdgrev2   = 0;
                  san_1.sanbdgrev3   = 0;
                  san_1.sanbdgrev4   = 0;
                  san_1.sanbdgrev5   = 0;
                  san_1.sanbdgrev6   = 0;
                  san_1.sanbdgrev7   = 0;
                  san_1.sanbdgrev8   = 0;
                  san_1.sanbdgrev9   = 0;
                  san_1.sanbdgrev10  = 0;
                  san_1.sanbdgrev11  = 0;
                  san_1.sanbdgrev12  = 0;
                  san_1.sanbdgrev13  = 0;
                  san_1.sanbdgrev14  = 0;
                  san_1.sancumeng1   = 0;
                  san_1.sancumeng2   = 0;
                  san_1.sancumeng3   = 0;
                  san_1.sancumeng4   = 0;
                  san_1.sancumeng5   = 0;
                  san_1.sancumeng6   = 0;
                  san_1.sancumeng7   = 0;
                  san_1.sancumeng8   = 0;
                  san_1.sancumeng9   = 0;
                  san_1.sancumeng10  = 0;
                  san_1.sancumeng11  = 0;
                  san_1.sancumeng12  = 0;
                  san_1.sancumeng13  = 0;
                  san_1.sancumeng14  = 0;
                }
              END_STORE
                ON_ERROR
#if UNIX
                  gds__print_status ( gds__status );
#else
                  gds_$print_status ( gds_$status );
#endif
                  ROLLBACK;
                  FINISH db_dict;
                  return(EXIT_AVEC_ERREUR);
                END_ERROR;
            }
          l_cnt_i++;

        }
      END_FOR
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          ROLLBACK;
          FINISH db_dict;
          return(EXIT_AVEC_ERREUR);
        END_ERROR;

      mc950(NOM_PROGRAMME,l_lngcle_c,NBROCCMAJ); /* Nombre d'occurences mises à jour : */
      fprintf(stderr," %d\n",l_cnt_i);

     /*
      * Le traitement est identique pour les SOLDES RESTRICTIFS
      */

      mc950(NOM_PROGRAMME,l_lngcle_c,TRASRE); /* Traitement des soldes restrictifs */

      l_cnt_i = 0;

      FOR cpt IN mccompte
          CROSS sre   IN mcsan_rest
          CROSS sre_1 IN mcsan_rest
          WITH    cpt.naccle       != NAC_REVENU
              AND cpt.naccle       != NAC_DEPENSE
              AND sre.cptcle        = cpt.cptcle
              AND sre.sanann        = l_sql_anrcou_s
              AND sre_1.sanann      = l_sql_anrsui_s
              AND sre_1.cptcle      = sre.cptcle
              AND sre_1.ciecle      = sre.ciecle
              AND sre_1.unacle      = sre.unacle
              AND sre_1.srecieint   = sre.srecieint
              AND sre_1.sreunaint   = sre.sreunaint
        {
         /*
          * Le solde d'ouverture de l'année suivante est égal à la somme
          * du solde d'ouverture de l'année actuelle et des 14 périodes
          * de cette année.
          */

          MODIFY  sre_1 USING
            {
              sre_1.sresldouv     =   sre.sresldouv
                                    + sre.srecumree1
                                    + sre.srecumree2
                                    + sre.srecumree3
                                    + sre.srecumree4
                                    + sre.srecumree5
                                    + sre.srecumree6
                                    + sre.srecumree7
                                    + sre.srecumree8
                                    + sre.srecumree9
                                    + sre.srecumree10
                                    + sre.srecumree11
                                    + sre.srecumree12
                                    + sre.srecumree13
                                    + sre.srecumree14;
            }
          END_MODIFY
            ON_ERROR
#if UNIX
              gds__print_status ( gds__status );
#else
              gds_$print_status ( gds_$status );
#endif
              ROLLBACK;
              FINISH db_dict;
              return(EXIT_AVEC_ERREUR);
            END_ERROR;

          l_cnt_i++;

        }
      END_FOR
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          ROLLBACK;
          FINISH db_dict;
          return(EXIT_AVEC_ERREUR);
        END_ERROR;

      mc950(NOM_PROGRAMME,l_lngcle_c,NBROCCMAJ); /* Nombre d'occurences mises a jour : */
      fprintf(stderr," %d\n",l_cnt_i);

      FOR cpt IN mccompte
          CROSS   sre IN mcsan_rest
          WITH    cpt.naccle     != NAC_REVENU
              AND cpt.naccle     != NAC_DEPENSE
              AND sre.sanann      = l_sql_anrcou_s
              AND sre.cptcle      = cpt.cptcle
              AND NOT ANY sre_1 IN mcsan_rest
                            WITH    sre_1.sanann      = l_sql_anrsui_s
                                AND sre_1.cptcle      = sre.cptcle
                                AND sre_1.ciecle      = sre.ciecle
                                AND sre_1.unacle      = sre.unacle
                                AND sre_1.srecieint   = sre.srecieint
                                AND sre_1.sreunaint   = sre.sreunaint
        {
          STORE sre_2 IN mcsan_rest USING
            {
              strcpy( sre_2.sanann,     l_sql_anrsui_s);
              strcpy( sre_2.cptcle,     sre.cptcle);
              strcpy( sre_2.ciecle,     sre.ciecle);
              strcpy( sre_2.unacle,     sre.unacle);
              strcpy( sre_2.srecieint,  sre.srecieint);
              strcpy( sre_2.sreunaint,  sre.sreunaint);
              sre_2.sresldouv     =   sre.sresldouv
                                    + sre.srecumree1
                                    + sre.srecumree2
                                    + sre.srecumree3
                                    + sre.srecumree4
                                    + sre.srecumree5
                                    + sre.srecumree6
                                    + sre.srecumree7
                                    + sre.srecumree8
                                    + sre.srecumree9
                                    + sre.srecumree10
                                    + sre.srecumree11
                                    + sre.srecumree12
                                    + sre.srecumree13
                                    + sre.srecumree14;
             /*
              * Initialisation des autres variables numériques pour ne pas générer de
              * "missing value" dans InterBase
              */
              sre_2.srecumree1   = 0;
              sre_2.srecumree2   = 0;
              sre_2.srecumree3   = 0;
              sre_2.srecumree4   = 0;
              sre_2.srecumree5   = 0;
              sre_2.srecumree6   = 0;
              sre_2.srecumree7   = 0;
              sre_2.srecumree8   = 0;
              sre_2.srecumree9   = 0;
              sre_2.srecumree10  = 0;
              sre_2.srecumree11  = 0;
              sre_2.srecumree12  = 0;
              sre_2.srecumree13  = 0;
              sre_2.srecumree14  = 0;
              sre_2.sresldouveng = 0;
              sre_2.srecumeng1   = 0;
              sre_2.srecumeng2   = 0;
              sre_2.srecumeng3   = 0;
              sre_2.srecumeng4   = 0;
              sre_2.srecumeng5   = 0;
              sre_2.srecumeng6   = 0;
              sre_2.srecumeng7   = 0;
              sre_2.srecumeng8   = 0;
              sre_2.srecumeng9   = 0;
              sre_2.srecumeng10  = 0;
              sre_2.srecumeng11  = 0;
              sre_2.srecumeng12  = 0;
              sre_2.srecumeng13  = 0;
              sre_2.srecumeng14  = 0;
            }
          END_STORE
            ON_ERROR
#if UNIX
              gds__print_status ( gds__status );
#else
              gds_$print_status ( gds_$status );
#endif
              ROLLBACK;
              FINISH db_dict;
              return(EXIT_AVEC_ERREUR);
            END_ERROR;

          l_cnt_i++;

        }
      END_FOR
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          ROLLBACK;
          FINISH db_dict;
          return(EXIT_AVEC_ERREUR);
        END_ERROR;

      mc950(NOM_PROGRAMME,l_lngcle_c,NBROCCAJOU); /* Nombre d'occurences ajoutées : */
      fprintf(stderr," %d\n",l_cnt_i);

     /*
      * Recalcul des BNR :
      *   Pour chaque compagnie du holding, on cumule les comptes de revenus
      *   et les comptes de dépenses. La différence de ces deux cumuls va
      *   donner le nouveau solde du BNR. Ce solde est mis a jour dans le
      *   compte spécifié par CPTCAT qui indique le compte de BNR dans la charte
      *   et avec l'unite CIEUNABIL de la compagnie.
      *
      * NOTE :  Cette partie est faite en SQL pour pouvoir utiliser les
      *         facilités des "Group by".
      *         Mais pour utiliser le SQL, on doit absolument utiliser la transaction par defaut.
      *         car GPRE ne reconnait que cette transaction lorsque'il traite des requetes SQL.
      */

      mc950(NOM_PROGRAMME,l_lngcle_c,RECBNR); /* Recalcul des BNR */
      fprintf(stderr," (mcsolde_annuel).\n");

      l_cnt_i = 0;
      l_sql_sldbnr_d = 0;
      l_sql_cum_d = 0;

     /*
      * On recherche le compte de BNR contenu dans la charte
      */

      strcpy (l_sql_cptcatbnr_s,CPTCAT_BNR);

      EXEC SQL
        SELECT cpt.cptcle
        INTO   :l_sql_cptbnr_s
        FROM   mccompte cpt
        WHERE  cpt.cptcat = :l_sql_cptcatbnr_s;

      if(SQLCODE)
       {
        mc950(NOM_PROGRAMME,l_lngcle_c,CPTBNRINT); /* Compte de BNR introuvé */
#if UNIX
        gds__print_status ( gds__status );
#else
        gds_$print_status ( gds_$status );
#endif
        ROLLBACK;
        FINISH db_dict;
        return(EXIT_AVEC_ERREUR);
       }

     /*
      * Déclaration du curseur. Celui-ci est groupé par compagnie et
      * type de compte pour ne récuperer que deux occurences par
      * compagnie. Une qui va nous renvoyer le cumul des comptes de
      * revenus, et une autre qui va récuperer le cumul des comptes de
      * dépenses.
      */

      EXEC SQL
        DECLARE calcul_bnr CURSOR FOR
        SELECT  cpt.naccle,
                san.sanann,
                san.ciecle,
                sum(  san.sansldouv
                    + san.sancumree1
                    + san.sancumree2
                    + san.sancumree3
                    + san.sancumree4
                    + san.sancumree5
                    + san.sancumree6
                    + san.sancumree7
                    + san.sancumree8
                    + san.sancumree9
                    + san.sancumree10
                    + san.sancumree11
                    + san.sancumree12
                    + san.sancumree13
                    + san.sancumree14),
                cie.cieunabil
        FROM    mccompte cpt,
                mcsolde_annuel san,
                mccompagnie cie
        WHERE     (   cpt.naccle  = :l_sql_nac_revenu_i
                   OR cpt.naccle  = :l_sql_nac_depense_i)
              AND san.sanann  = :l_sql_anrcou_s
              AND san.cptcle  = cpt.cptcle
              AND cie.ciecle  = san.ciecle
        GROUP BY  san.ciecle,
                  cpt.naccle,
                  san.sanann,
                  cie.cieunabil;

     /*
      * Ouverture du curseur, et récupération de la première occurence
      * pour initialiser le traitement
      */

      EXEC SQL
        OPEN calcul_bnr;
      EXEC SQL
        FETCH calcul_bnr  INTO  :l_sql_naccle_i,
                                :l_sql_sanann_s,
                                :l_sql_ciecle_s,
                                :l_sql_cum_d,
                                :l_sql_cieunabil_s;

      strcpy(l_sql_ciecle_old_s,    l_sql_ciecle_s);
      strcpy(l_sql_cieunabil_old_s, l_sql_cieunabil_s);
      l_sql_sldbnr_d = 0;

     /*
      * Pour chaque occurence récupérée,
      *   Si on est toujours dans la même compagnie, alors on
      *         calcule le solde des revenus moins dépense.
      *   Sinon, on va modifier le BNR de la compagnie avec le nouveau
      *          solde calculé précédement, en créant le solde du compte si
      *          celui-ci n'existe pas encore.
      */

      while ( !SQLCODE )
        {
          /*
           * On calcul le BNR avec le cumul retourné par le curseur, en
           * en fonction du type de compte
           */
          if (l_sql_naccle_i == NAC_REVENU)
            l_sql_sldbnr_d += l_sql_cum_d;
          else
            l_sql_sldbnr_d -= l_sql_cum_d;

          EXEC SQL
            FETCH calcul_bnr  INTO  :l_sql_naccle_i,
                                    :l_sql_sanann_s,
                                    :l_sql_ciecle_s,
                                    :l_sql_cum_d,
                                    :l_sql_cieunabil_s;

          if (   strcmp(l_sql_ciecle_old_s,l_sql_ciecle_s)!=0
              || SQLCODE )
            {
              SET_FALSE(l_sldbnr_f);
              FOR FIRST 1 san_1 IN mcsolde_annuel
                WITH    san_1.sanann        = l_sql_anrsui_s
                    AND san_1.cptcle        = l_sql_cptbnr_s
                    AND san_1.ciecle        = l_sql_ciecle_old_s
                    AND san_1.unacle        = l_sql_cieunabil_old_s
                {
                 /*
                  * Il existe déja un solde du compte de BNR de l'année
                  * suivante pour cette compagnie : Donc on le met
                  * à jour avec la nouvelle valeur.
                  */
                  SET_TRUE(l_sldbnr_f);
                  l_cnt_i++;
                  MODIFY san_1 USING
                    san_1.sansldouv = san_1.sansldouv + l_sql_sldbnr_d;
                  END_MODIFY
                    ON_ERROR
#if UNIX
                      gds__print_status ( gds__status );
#else
                      gds_$print_status ( gds_$status );
#endif
                      ROLLBACK;
                      FINISH db_dict;
                      return(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
              END_FOR
                ON_ERROR
#if UNIX
                  gds__print_status ( gds__status );
#else
                  gds_$print_status ( gds_$status );
#endif
                  ROLLBACK;
                  FINISH db_dict;
                  return(EXIT_AVEC_ERREUR);
                END_ERROR;
             /*
              * S'il n'y a pas eu de mise-à-jour, c'est que le solde du
              * compte de BNR pour cette nouvelle année n'a pas encore
              * été créé.
              */
              if (!l_sldbnr_f)
                {
                  l_cnt_i++;
                  STORE san_1 IN mcsolde_annuel USING
                    strcpy(san_1.sanann,l_sql_anrsui_s);
                    strcpy(san_1.cptcle,l_sql_cptbnr_s);
                    strcpy(san_1.ciecle,l_sql_ciecle_old_s);
                    strcpy(san_1.unacle,l_sql_cieunabil_old_s);
                    san_1.sansldouv = l_sql_sldbnr_d;
                    san_1.sancumree1   = 0;
                    san_1.sancumree2   = 0;
                    san_1.sancumree3   = 0;
                    san_1.sancumree4   = 0;
                    san_1.sancumree5   = 0;
                    san_1.sancumree6   = 0;
                    san_1.sancumree7   = 0;
                    san_1.sancumree8   = 0;
                    san_1.sancumree9   = 0;
                    san_1.sancumree10  = 0;
                    san_1.sancumree11  = 0;
                    san_1.sancumree12  = 0;
                    san_1.sancumree13  = 0;
                    san_1.sancumree14  = 0;
                    san_1.sanbdgann    = 0;
                    san_1.sanbdg1      = 0;
                    san_1.sanbdg2      = 0;
                    san_1.sanbdg3      = 0;
                    san_1.sanbdg4      = 0;
                    san_1.sanbdg5      = 0;
                    san_1.sanbdg6      = 0;
                    san_1.sanbdg7      = 0;
                    san_1.sanbdg8      = 0;
                    san_1.sanbdg9      = 0;
                    san_1.sanbdg10     = 0;
                    san_1.sanbdg11     = 0;
                    san_1.sanbdg12     = 0;
                    san_1.sanbdg13     = 0;
                    san_1.sanbdg14     = 0;
                    san_1.sanbdgrevann = 0;
                    san_1.sanbdgrev1   = 0;
                    san_1.sanbdgrev2   = 0;
                    san_1.sanbdgrev3   = 0;
                    san_1.sanbdgrev4   = 0;
                    san_1.sanbdgrev5   = 0;
                    san_1.sanbdgrev6   = 0;
                    san_1.sanbdgrev7   = 0;
                    san_1.sanbdgrev8   = 0;
                    san_1.sanbdgrev9   = 0;
                    san_1.sanbdgrev10  = 0;
                    san_1.sanbdgrev11  = 0;
                    san_1.sanbdgrev12  = 0;
                    san_1.sanbdgrev13  = 0;
                    san_1.sanbdgrev14  = 0;
                    san_1.sansldouveng = 0;
                    san_1.sancumeng1   = 0;
                    san_1.sancumeng2   = 0;
                    san_1.sancumeng3   = 0;
                    san_1.sancumeng4   = 0;
                    san_1.sancumeng5   = 0;
                    san_1.sancumeng6   = 0;
                    san_1.sancumeng7   = 0;
                    san_1.sancumeng8   = 0;
                    san_1.sancumeng9   = 0;
                    san_1.sancumeng10  = 0;
                    san_1.sancumeng11  = 0;
                    san_1.sancumeng12  = 0;
                    san_1.sancumeng13  = 0;
                    san_1.sancumeng14  = 0;
                  END_STORE
                    ON_ERROR
#if UNIX
                      gds__print_status ( gds__status );
#else
                      gds_$print_status ( gds_$status );
#endif
                      ROLLBACK;
                      FINISH db_dict;
                      return(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
              strcpy(l_sql_ciecle_old_s,    l_sql_ciecle_s);
              strcpy(l_sql_cieunabil_old_s, l_sql_cieunabil_s);
              l_sql_sldbnr_d = 0;
            }
        }

      EXEC SQL
        CLOSE calcul_bnr;

      mc950(NOM_PROGRAMME,l_lngcle_c,NBROCCAJMO); /* Nombre d'occurences ajoutées ou modifiées : */
      fprintf(stderr,"%d\n",l_cnt_i);


     /*
      * Recalcul des soldes RESTRICTIFS des BNR :
      *   Le principe est le même que pour les soldes normaux. Mais ici, au
      *   lieu de cumuler par compagnie, on cumule par compagnie/
      *   compagnie_inter. C'est à dire, que l'on cumule les écritures
      *   intercompagnies qui portent sur les comptes revenus et dépenses.
      *   Pour générer un solde restrictif par cie/cie_inter sur le compte
      *   de BNR de la compagnie/unite. L'unité de destination du solde
      *   restrictif est l'unité de bilan de la compagnie.
      */

      mc950(NOM_PROGRAMME,l_lngcle_c,RECBNR); /* Recalcul des BNR */
      fprintf(stderr," (mcsan_rest).\n");

      l_cnt_i = 0;
      l_sql_sldbnr_d = 0;

     /*
      * Déclaration du curseur. Celui-ci est groupé par
      * compagnie/cie_inter et type de compte.
      */

      EXEC SQL
        DECLARE calcul_bnr_rest CURSOR FOR
        SELECT  cpt.naccle,
                sre.sanann,
                sre.ciecle,
                sre.srecieint,
                sum(  sre.sresldouv
                    + sre.srecumree1
                    + sre.srecumree2
                    + sre.srecumree3
                    + sre.srecumree4
                    + sre.srecumree5
                    + sre.srecumree6
                    + sre.srecumree7
                    + sre.srecumree8
                    + sre.srecumree9
                    + sre.srecumree10
                    + sre.srecumree11
                    + sre.srecumree12
                    + sre.srecumree13
                    + sre.srecumree14),
                cie.cieunabil
        FROM    mccompte cpt,
                mcsan_rest sre,
                mccompagnie cie
        WHERE     (   cpt.naccle  = :l_sql_nac_revenu_i
                   OR cpt.naccle  = :l_sql_nac_depense_i)
              AND sre.sanann  = :l_sql_anrcou_s
              AND sre.cptcle  = cpt.cptcle
              AND cie.ciecle  = sre.ciecle
        GROUP BY  sre.ciecle,
                  sre.srecieint,
                  cpt.naccle,
                  sre.sanann,
                  cie.cieunabil;
     /*
      * Ouverture du curseur, et récupération de la première occurence
      * pour initialiser le traitement
      */

      EXEC SQL
        OPEN calcul_bnr_rest;
      EXEC SQL
        FETCH calcul_bnr_rest INTO  :l_sql_naccle_i,
                                    :l_sql_sanann_s,
                                    :l_sql_ciecle_s,
                                    :l_sql_srecieint_s,
                                    :l_sql_cum_d,
                                    :l_sql_cieunabil_s;

      strcpy(l_sql_ciecle_old_s,    l_sql_ciecle_s);
      strcpy(l_sql_srecieint_old_s, l_sql_srecieint_s);
      strcpy(l_sql_cieunabil_old_s, l_sql_cieunabil_s);

     /*
      * Pour chaque occurence récupérée,
      *   Si on est toujours dans la même cie/cie_inter alors on
      *         calcule le solde des revenus moins dépense.
      *   Sinon, on va modifier le BNR de la cie/cie_inter avec
      *          le nouveau solde restrictif calculé précédement, en créant le
      *          solde du compte si celui-ci n'existe pas encore.
      */

      while (!SQLCODE)
        {
         /*
          * On calcul le BNR avec le cumul retourné par le curseur, en
          * en fonction du type de compte
          */
          if (l_sql_naccle_i == NAC_REVENU)
            l_sql_sldbnr_d += l_sql_cum_d;
          else
            l_sql_sldbnr_d -= l_sql_cum_d;

          EXEC SQL
            FETCH calcul_bnr_rest INTO  :l_sql_naccle_i,
                                        :l_sql_sanann_s,
                                        :l_sql_ciecle_s,
                                        :l_sql_srecieint_s,
                                        :l_sql_cum_d,
                                        :l_sql_cieunabil_s;

          if (   strcmp(l_sql_ciecle_old_s,   l_sql_ciecle_s)   !=0
              || strcmp(l_sql_srecieint_old_s,l_sql_srecieint_s)!=0
              || SQLCODE)
            {
              SET_FALSE(l_sldbnr_f);
              FOR FIRST 1 sre_1 IN mcsan_rest
                WITH    sre_1.sanann        = l_sql_anrsui_s
                    AND sre_1.cptcle        = l_sql_cptbnr_s
                    AND sre_1.ciecle        = l_sql_ciecle_old_s
                    AND sre_1.unacle        = l_sql_cieunabil_old_s
                    AND sre_1.srecieint     = l_sql_srecieint_old_s
                    AND sre_1.sreunaint     = l_sql_cieunabil_old_s
                {
                 /*
                  * Il existe déja un solde restrictif du compte de BNR de
                  * l'année suivante pour cette cie/cie_inter
                  * Donc on le met à jour avec la nouvelle valeur.
                  */
                  SET_TRUE(l_sldbnr_f);
                  l_cnt_i++;
                  MODIFY sre_1 USING
                    sre_1.sresldouv = sre_1.sresldouv + l_sql_sldbnr_d;
                  END_MODIFY
                    ON_ERROR
#if UNIX
                      gds__print_status ( gds__status );
#else
                      gds_$print_status ( gds_$status );
#endif
                      ROLLBACK;
                      FINISH db_dict;
                      return(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
              END_FOR
                ON_ERROR
#if UNIX
                  gds__print_status ( gds__status );
#else
                  gds_$print_status ( gds_$status );
#endif
                  ROLLBACK;
                  FINISH db_dict;
                  return(EXIT_AVEC_ERREUR);
                END_ERROR;
             /*
              * S'il n'y a pas eu de mise-à-jour, c'est que le solde restrictif
              * du compte de BNR pour cette nouvelle année n'a pas encore
              * été créé.
              */
              if (!l_sldbnr_f)
                {
                  l_cnt_i++;
                  STORE sre_1 IN mcsan_rest USING
                    strcpy(sre_1.sanann,    l_sql_anrsui_s);
                    strcpy(sre_1.cptcle,    l_sql_cptbnr_s);
                    strcpy(sre_1.ciecle,    l_sql_ciecle_old_s);
                    strcpy(sre_1.unacle,    l_sql_cieunabil_old_s);
                    strcpy(sre_1.srecieint, l_sql_srecieint_old_s);
                    strcpy(sre_1.sreunaint, l_sql_cieunabil_old_s);
                    sre_1.sresldouv = l_sql_sldbnr_d;
                    sre_1.srecumree1    = 0;
                    sre_1.srecumree2    = 0;
                    sre_1.srecumree3    = 0;
                    sre_1.srecumree4    = 0;
                    sre_1.srecumree5    = 0;
                    sre_1.srecumree6    = 0;
                    sre_1.srecumree7    = 0;
                    sre_1.srecumree8    = 0;
                    sre_1.srecumree9    = 0;
                    sre_1.srecumree10   = 0;
                    sre_1.srecumree11   = 0;
                    sre_1.srecumree12   = 0;
                    sre_1.srecumree13   = 0;
                    sre_1.srecumree14   = 0;
                    sre_1.sresldouveng  = 0;
                    sre_1.srecumeng1    = 0;
                    sre_1.srecumeng2    = 0;
                    sre_1.srecumeng3    = 0;
                    sre_1.srecumeng4    = 0;
                    sre_1.srecumeng5    = 0;
                    sre_1.srecumeng6    = 0;
                    sre_1.srecumeng7    = 0;
                    sre_1.srecumeng8    = 0;
                    sre_1.srecumeng9    = 0;
                    sre_1.srecumeng10   = 0;
                    sre_1.srecumeng11   = 0;
                    sre_1.srecumeng12   = 0;
                    sre_1.srecumeng13   = 0;
                    sre_1.srecumeng14   = 0;
                  END_STORE
                    ON_ERROR
#if UNIX
                      gds__print_status ( gds__status );
#else
                      gds_$print_status ( gds_$status );
#endif
                      ROLLBACK;
                      FINISH db_dict;
                      return(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
              strcpy(l_sql_ciecle_old_s,    l_sql_ciecle_s);
              strcpy(l_sql_srecieint_old_s, l_sql_srecieint_s);
              strcpy(l_sql_cieunabil_old_s, l_sql_cieunabil_s);
              l_sql_sldbnr_d = 0;
            }
        }

      EXEC SQL
        CLOSE calcul_bnr_rest;

      mc950(NOM_PROGRAMME,l_lngcle_c,NBROCCAJMO); /* Nombre d'occurences ajoutées ou modifiées : */
      fprintf(stderr,"%d\n",l_cnt_i);

    }

 /*
  * Fin de la transaction. On a traité toutes les années concernées.
  * Alors on enregistre la nouvelle année de référence.
  */

  SET_FALSE(l_annee_trouve_f);

  FOR FIRST 1 anr IN mcannee_ref
    {
      SET_TRUE(l_annee_trouve_f);
      MODIFY anr USING
        strcpy(anr.anrann,l_sql_anrsui_s);
      END_MODIFY
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          ROLLBACK;
          FINISH db_dict;
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      ROLLBACK;
      FINISH db_dict;
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

  if (!l_annee_trouve_f)
    {
      mc950(NOM_PROGRAMME,l_lngcle_c,ANRREFINC); /* Année de référence inconnue */
      ROLLBACK
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  COMMIT
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      FINISH db_dict;
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Fermeture de la base.
  */

  FINISH db_dict
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      return(EXIT_AVEC_ERREUR);
    END_ERROR;

  mc950(NOM_PROGRAMME,l_lngcle_c,MESSOK); /* Programme terminé avec succes. */
  return(EXIT_SANS_ERREUR);
}

#include "mc950.e" /* Affichage des messages */
