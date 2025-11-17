/*
** Programme   : GL951.E
** Module      : Grand livre
**
** /V3.05.02/ Denis Pouliot,   1 juin  1999, SOS( EDS, ALPVMS )
**   État        :  [Terminer]
**   Description :  Revision pour le passage AN2000 INTERBASE 4
**                  Ajouter définition de fonctions manquantes.
**                  Définir "void" les fonctions qui ne retourne rien.
**                  Définir p_efdrat_i  pour un "double" dans le calcul des ratios
**                  Enlever les "$" dans les noms de variables
**                  IL N'Y A PAS DE CORRECTION pour les comparaisons
**                  entre numérique des années pour prendre une chaîne
**                  de caractères comme dans gl950.  Ceci cause des erreurs
**                  (Exemple : Remplacer  san.sanann.long = g_ann000_i
**                                PAR     san.sanann      = g_sql_ann000_s )
**                  Corriger définition des transactions trh_xxxxxxxx
**                  de type "int" par void * trh_xxxxx
**                  Déplacer assignation des trh_xxxxx avant le start_transaction
**                  Remplacer le #if HP par des #if UNIX
**
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 25 Mai 1992
**
** /V3.02.00/ Thomas BRENNEUR, 18 mars 1994, 199
** /V3.02.01/ Thomas BRENNEUR, 29 Avril 1994, 250
** /V3.02.06/ Thomas BRENNEUR, 13 Juin 1994, 274
** /V3.03.02/ Alain Côté, 29 août 1994, 283
** /V3.03.03/ Thomas BRENNEUR, 26 Septembre 1994, 261
** /V3.03.05/ Thomas BRENNEUR, 17 Novembre 1994, 305
** /V3.03.06/ Thomas BRENNEUR, 17 Novembre 1994, 305
** /V3.05.01/ Thomas BRENNEUR, 5 avril 1995, 311
**
** Description : Calcul et impression des états financiers
**
** Paramètres d'entrée  :
**                        .Nom de la base de données
**                        .Numéro de compagnie (de définition des E/F)
**                        .Numéro de la cédule
**                        .Commentaire
**                        .Période comptable
**                        .Nom du fichier d'impression
**
** Paramètres de sortie :
**                        .Status d'exécution du programme
**
** Modification.: - Le 19 octobre 1993 par Alain Côté
**                  Modification dans les paramètres reçus. J'ai mis comme
**                  premier paramètre la nom de la base de données.
**
**                . Le 29 Avril 1994 par Thomas Brenneur version V3.02.01
**                  Correction pour pouvoir calculer les colonnes calcul dans une note
**                  (la définition des colonnes était mal transférée).
**
** Note sur la codification des variables :
**
** Elles sont codées sur 3 zones séparé par un "_" en général : situation_variable_type
**        Avec  Situation       = l     pour locale
**                                g      ''  globale
**                                p      ''  paramètre
**              Variable        = nom de la variable
**              Type            = i     pour int
**                                c      ''  char ( un byte )
**                                s      ''  char[] ( = null terminated string )
**                                ptr    ''  pointeur particulier ( sur une structure généralement )
**                                f      ''  flag ( indicateur d'état )
**                                d      ''  double
**                                str    ''  structure
**                                strdef ''  définition de structure (pour les typedef)
**
** Exemple : l_cnt_i est un entier défini localement.
*/

#include  <stdio.h>
#include  <time.h>
#include  <string.h>
#include  <math.h>
#include  <stdlib.h>
#include  "mc950.h" /* Définitions communes et gestion des messages */

/*
 * Déclaration des paramètres de configuration du programme
 */

#define NOM_PROGRAMME           "GL951"   /* Nom du programme actuel                                                    */
#define DEMANDE_INFO            "?"       /* Valeur du premier paramètre si on veut récupérer les infos de compilation  */

#define VERSION_GL951           "V3.05.01 PGL"  /* Version du programme actuel                                            */

#define NOMBRE_ARGUMENTS        7         /* en incluant le nom du programme                                            */

#define PROSIG_USRLNG           "PROSIG_USRLNG" /* Variable environementale contenant la langue de l'usager             */

#define REPONSE_OUI             "1"     /* Indique "Oui" ou "Yes"                               */
#define REPONSE_NON             "0"     /* Indique "Non" ou "No"                                */

#define COLONNE_01              0       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_02              1       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_03              2       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_04              3       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_05              4       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_06              5       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_07              6       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_08              7       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_09              8       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_10              9       /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_11              10      /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_12              11      /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_13              12      /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_14              13      /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_15              14      /* Numéro de la colonne 1 dans le tableau               */
#define COLONNE_16              15      /* Numéro de la colonne 1 dans le tableau               */
#define NBR_COLONNES            16      /* Nombre maximal de colonne dans un EF                 */

#define COLONNE_RATIO_NON       16      /* Valeure indiquant une colonne de ratio invalide      */

#define NIVEAU_01               0       /* Numéro du niveau 1 dans le tableau                   */
#define NIVEAU_02               1       /* Numéro du niveau 2 dans le tableau                   */
#define NIVEAU_03               2       /* Numéro du niveau 3 dans le tableau                   */
#define NIVEAU_04               3       /* Numéro du niveau 4 dans le tableau                   */
#define NIVEAU_05               4       /* Numéro du niveau 5 dans le tableau                   */
#define NIVEAU_06               5       /* Numéro du niveau 6 dans le tableau                   */
#define NIVEAU_07               6       /* Numéro du niveau 7 dans le tableau                   */
#define NIVEAU_08               7       /* Numéro du niveau 8 dans le tableau                   */
#define NBR_NIVEAUX_TOTAL       8       /* Nombre de niveaux de totalisation                    */

#define CLE_HOLDING             "1"     /* VALEUR DE LA CLÉ DU HOLDING                          */

#define ACTION_FINISH           0       /* Fermeture de la base de donnée                       */
#define ACTION_ROLLBACK_GL951_1 1       /* Rollback de la transaction GL951_1                   */
#define ACTION_ROLLBACK_GL951_2 2       /* Rollback de la transaction GL951_2                   */
#define ACTION_ROLLBACK_GL951_3 3       /* Rollback de la transaction GL951_3                   */

#define EFITYP_NOTE             "N"     /* Type d'état : Note                                   */
#define EFITYP_BILAN            "B"     /* Type d'état : Bilan                                  */
#define EFITYP_AUTRE            "A"     /* Type d'état : Autre                                  */
#define EFITYP_RESULTAT         "E"     /* Type d'état : Etat des résultats                     */

#define EFIIMPINFSUP_NON        "0"     /* Uniquement la description                            */
#define EFIIMPINFSUP_UNA        "1"     /* Unité                                                */
#define EFIIMPINFSUP_CPT        "2"     /* Compte                                               */
#define EFIIMPINFSUP_UNACPT     "3"     /* Unité + Compte                                       */
#define EFIIMPINFSUP_CPTUNA     "4"     /* Compte + Unité                                       */

#define EDOTYP_GLOBAL           "G"     /* Domaine Global des données à sélectionner            */
#define EDOTYP_COLONNE          "C"     /* Domaine de donnée pour la sélection par colonnes     */

/*
** Codes des lignes de détail d'un état financier
*/
#define EFDCOD_NOTE             "NOTE"  /* Identifiant d'une note                               */
#define EFDCOD_CPT              "CPT "  /* Identifiant d'une compte                             */
#define EFDCOD_TOT              "TOT "  /* Identifiant d'un sous-total                          */
#define EFDCOD_SDEB             "SDEB"  /* Identifiant d'un solde de début                      */
#define EFDCOD_SFIN             "SFIN"  /* Identifiant d'un solde de fin                        */
#define EFDCOD_BAL              "BAL "  /* Identifiant d'une balance entre deux comptes         */
#define EFDCOD_TEXT             "TEXT"  /* Identifiant d'une ligne de texte                     */
#define EFDCOD_SLG              "SLG "  /* Identifiant d'une ligne de soulignés                 */
#define EFDCOD_SLGD             "SLGD"  /* Identifiant du soulignement de la description        */
#define EFDCOD_SLGC             "SLGC"  /* Identifiant du soulignement des colonnes             */
#define EFDCOD_PAGE             "PAGE"  /* Identifiant d'un saut de page                        */
#define EFDCOD_JUM              "JUM "  /* Identifiant de comptes jumelés                       */

/*
** Codes des lignes de format d'impression du Haut et Bas de page
*/
#define EFFCOD_TEXT             "TEXT"  /* texte libre                                          */
#define EFFCOD_CIE              "CIE "  /* Nom de la compagnie                                  */
#define EFFCOD_CEN              "CEN "  /* Nom du centre                                        */
#define EFFCOD_UNI              "UNI "  /* Nom de l'unité administrative                        */
#define EFFCOD_PAGE             "PAGE"  /* Numéro de page                                       */
#define EFFCOD_DATE             "DATE"  /* Date du jour                                         */
#define EFFCOD_EFNO             "EFNO"  /* Numéro d'état financier                              */
#define EFFCOD_PEC              "PEC "  /* Numéro de période comptable                          */
#define EFFCOD_PER              "PER "  /* Périodicité                                          */
#define EFFCOD_COMM             "COMM"  /* Commentaire saisi lors du lancement                  */
#define EFFCOD_HRE              "HRE "  /* Heure d'exécution                                    */
#define EFFCOD_TIT              "TIT "  /* Titre de l'etat financier                            */
#define EFFCOD_CED              "CED "  /* Numéro de la cédule                                  */
#define EFFCOD_ASCI             "ASCI"  /* Code ascii                                           */

/*
** Codes des position dans les lignes de format
*/
#define EFFPOS_GAUCHE           "G"   /* Cadré à gauche                                         */
#define EFFPOS_CENTRE           "C"   /* Centré                                                 */
#define EFFPOS_DROITE           "D"   /* Cadré à droite                                         */
#define EFFPOS_POSITION         "P"   /* Position dans la ligne                                 */
#define EFFPOS_PLUS             "+"   /* À la suite de l'élément précédent                      */

#define NOTE_OUI                'O'     /* Pour indiquer que l'EF demandé est une note          */
#define NOTE_NON                'N'     /* Pour indiquer que l'EF demandé n'est pas une note    */

#define SIGNE_PLUS              "+"     /* Signe utilisé pour représenter l'adition             */
#define SIGNE_MOINS             "-"     /* Signe utilisé pour représenter la soustraction       */
#define SIGNE_EGAL              "="     /* Signe utilisé pour représenter le calcul du résultat */

#define CPTTYP_CUMULATIF        "C"     /* Type d'un compte cumulatif                           */
#define CPTTYP_REGULIER         "R"     /* Type d'un compte régulier                            */

#define TYPCOL_B1               "B1  "  /* Pér. bugdet-1                                        */
#define TYPCOL_B101             "B101"  /* Bugdet-1, Période-01                                 */
#define TYPCOL_B102             "B102"  /* Budget-1, période-02                                 */
#define TYPCOL_B103             "B103"  /* Budget-1, période-03                                 */
#define TYPCOL_B104             "B104"  /* Budget-1, période-04                                 */
#define TYPCOL_B105             "B105"  /* Budget-1, période-05                                 */
#define TYPCOL_B106             "B106"  /* Budget-1, période-06                                 */
#define TYPCOL_B107             "B107"  /* Budget-1, période-07                                 */
#define TYPCOL_B108             "B108"  /* Budget-1, période-08                                 */
#define TYPCOL_B109             "B109"  /* Budget-1, période-09                                 */
#define TYPCOL_B110             "B110"  /* Budget-1, période-10                                 */
#define TYPCOL_B111             "B111"  /* Budget-1, période-11                                 */
#define TYPCOL_B112             "B112"  /* Budget-1, période-12                                 */
#define TYPCOL_B113             "B113"  /* Budget-1, période-13                                 */
#define TYPCOL_B114             "B114"  /* Budget-1, période-14                                 */
#define TYPCOL_B1A              "B1A "  /* Annuel budget-1                                      */
#define TYPCOL_B1C              "B1C "  /* Cum. bugdet-1                                        */
#define TYPCOL_B1S1             "B1S1"  /* Budget-1, semestre-1                                 */
#define TYPCOL_B1S2             "B1S2"  /* Budget-1, semestre-2                                 */
#define TYPCOL_B1T1             "B1T1"  /* Budget-1, trimestre-1                                */
#define TYPCOL_B1T2             "B1T2"  /* Budget-1, trimestre-2                                */
#define TYPCOL_B1T3             "B1T3"  /* Budget-1, trimestre-3                                */
#define TYPCOL_B1T4             "B1T4"  /* Budget-1, trimestre-4                                */
#define TYPCOL_B2               "B2  "  /* Pér. budget-2                                        */
#define TYPCOL_B201             "B201"  /* Budget-2, période-01                                 */
#define TYPCOL_B202             "B202"  /* Budget-2, période-02                                 */
#define TYPCOL_B203             "B203"  /* Budget-2, période-03                                 */
#define TYPCOL_B204             "B204"  /* Budget-2, période-04                                 */
#define TYPCOL_B205             "B205"  /* Budget-2, période-05                                 */
#define TYPCOL_B206             "B206"  /* Budget-2, période-06                                 */
#define TYPCOL_B207             "B207"  /* Budget-2, période-07                                 */
#define TYPCOL_B208             "B208"  /* Budget-2, période-08                                 */
#define TYPCOL_B209             "B209"  /* Budget-2, période-09                                 */
#define TYPCOL_B210             "B210"  /* Budget-2, période-10                                 */
#define TYPCOL_B211             "B211"  /* Budget-2, période-11                                 */
#define TYPCOL_B212             "B212"  /* Budget-2, période-12                                 */
#define TYPCOL_B213             "B213"  /* Budget-2, période-13                                 */
#define TYPCOL_B214             "B214"  /* Budget-2, période-14                                 */
#define TYPCOL_B2A              "B2A "  /* Annuel budget-2                                      */
#define TYPCOL_B2C              "B2C "  /* Cum. bugdet-2                                        */
#define TYPCOL_B2S1             "B2S1"  /* Budget-2, semestre-1                                 */
#define TYPCOL_B2S2             "B2S2"  /* Budget-2, semestre-2                                 */
#define TYPCOL_B2T1             "B2T1"  /* Budget-2, trimestre-1                                */
#define TYPCOL_B2T2             "B2T2"  /* Budget-2, trimestre-2                                */
#define TYPCOL_B2T3             "B2T3"  /* Budget-2, trimestre-3                                */
#define TYPCOL_B2T4             "B2T4"  /* Budget-2, trimestre-4                                */
#define TYPCOL_CALC             "CALC"  /* Calcul                                               */
#define TYPCOL_COM              "COM "  /* Commentaire                                          */
#define TYPCOL_CUM              "CUM "  /* Cum. réel                                            */
#define TYPCOL_ECAR             "ECAR"  /* Écart                                                */
#define TYPCOL_ENG              "ENG "  /* Pér. courant engagement                              */
#define TYPCOL_P01              "P01 "  /* Période-01                                           */
#define TYPCOL_P02              "P02 "  /* Période-02                                           */
#define TYPCOL_P03              "P03 "  /* Période-03                                           */
#define TYPCOL_P04              "P04 "  /* Période-04                                           */
#define TYPCOL_P05              "P05 "  /* Période-05                                           */
#define TYPCOL_P06              "P06 "  /* Période-06                                           */
#define TYPCOL_P07              "P07 "  /* Période-07                                           */
#define TYPCOL_P08              "P08 "  /* Période-08                                           */
#define TYPCOL_P09              "P09 "  /* Période-09                                           */
#define TYPCOL_P10              "P10 "  /* Période-10                                           */
#define TYPCOL_P11              "P11 "  /* Période-11                                           */
#define TYPCOL_P12              "P12 "  /* Période-12                                           */
#define TYPCOL_P13              "P13 "  /* Période-13                                           */
#define TYPCOL_P14              "P14 "  /* Période-14                                           */
#define TYPCOL_P01C             "P01C"  /* Période-01                                           */
#define TYPCOL_P02C             "P02C"  /* Période-02                                           */
#define TYPCOL_P03C             "P03C"  /* Période-03                                           */
#define TYPCOL_P04C             "P04C"  /* Période-04                                           */
#define TYPCOL_P05C             "P05C"  /* Période-05                                           */
#define TYPCOL_P06C             "P06C"  /* Période-06                                           */
#define TYPCOL_P07C             "P07C"  /* Période-07                                           */
#define TYPCOL_P08C             "P08C"  /* Période-08                                           */
#define TYPCOL_P09C             "P09C"  /* Période-09                                           */
#define TYPCOL_P10C             "P10C"  /* Période-10                                           */
#define TYPCOL_P11C             "P11C"  /* Période-11                                           */
#define TYPCOL_P12C             "P12C"  /* Période-12                                           */
#define TYPCOL_P13C             "P13C"  /* Période-13                                           */
#define TYPCOL_P14C             "P14C"  /* Période-14                                           */
#define TYPCOL_PER              "PER "  /* Pér. courant réel                                    */
#define TYPCOL_RAT              "RAT "  /* Ratio                                                */
#define TYPCOL_S1               "S1  "  /* Semestre-1                                           */
#define TYPCOL_S2               "S2  "  /* Semestre-2                                           */
#define TYPCOL_S1C              "S1C "  /* Semestre-1                                           */
#define TYPCOL_S2C              "S2C "  /* Semestre-2                                           */
#define TYPCOL_T1               "T1  "  /* Trimestre-1                                          */
#define TYPCOL_T2               "T2  "  /* Trimestre-2                                          */
#define TYPCOL_T3               "T3  "  /* Trimestre-3                                          */
#define TYPCOL_T4               "T4  "  /* Trimestre-4                                          */
#define TYPCOL_T1C              "T1C "  /* Trimestre-1                                          */
#define TYPCOL_T2C              "T2C "  /* Trimestre-2                                          */
#define TYPCOL_T3C              "T3C "  /* Trimestre-3                                          */
#define TYPCOL_T4C              "T4C "  /* Trimestre-4                                          */

#define NBR_PERIODES            14      /* Nombre de périodes comptables                        */
#define PERIODE_01              0
#define PERIODE_02              1
#define PERIODE_03              2
#define PERIODE_04              3
#define PERIODE_05              4
#define PERIODE_06              5
#define PERIODE_07              6
#define PERIODE_08              7
#define PERIODE_09              8
#define PERIODE_10              9
#define PERIODE_11              10
#define PERIODE_12              11
#define PERIODE_13              12
#define PERIODE_14              13

#define ANNEE_COURANTE          "C" /* Identifiant de l'année courante dans la définition d'une colonne d'un EF       */
#define ANNEE_PRECEDENTE        "P" /* Identifiant de l'année précédente dans la définition d'une colonne d'un EF     */
#define ANNEE_MOINS2            "2" /* Identifiant de l'année pré-précédente dans la définition d'une colonne d'un EF */

#define ANNEE_000               0   /* Numéro de l'occurence de l'année courante dans la table des résultats          */
#define ANNEE_001               1   /* Numéro de l'occurence de l'année précédente dans la table des résultats        */
#define ANNEE_002               2   /* Numéro de l'occurence de l'année pré-précédente dans la table des résultats    */
#define NBR_ANNEES              3   /* Nombre d'années prisent en compte pour le calcul des résultats                 */

#define SOLDE_NORMAL            0   /* Type du solde à prendre : 0 = Solde normal   = CPT ou JUM                      */
#define SOLDE_DEBUT             1   /* Type du solde à prendre : 1 = Solde de début = SDEB                            */
#define SOLDE_FIN               2   /* Type du solde à prendre : 2 = Solde de fin   = SFIN                            */

#define MAX_EXPPILE_SIZE        50  /* Maximum pour la pile de transformation de l'expression INFIX en POSTFIX        */
#define MAX_EVLPILE_SIZE        50  /* Maximum pour la pile d'evaluation de l'expression POSTFIX                      */
#define MAX_TOKEN               50  /* Taille maximum du tableau de token qui forme l'expression postfix après analyse*/

#define TOKEN_FIN_EXPRESSION    0   /* Le token trouvé indique qu'il n'y a plus de token dans l'expression            */
#define TOKEN_COLONNE           1   /* Le token trouvé est un identifiant de colonne                                  */
#define TOKEN_CONSTANTE         2   /* Le token trouvé est une constante                                              */
#define TOKEN_SIGNE_PLUS        3   /* Le token trouvé est le signe "+"                                               */
#define TOKEN_SIGNE_MOINS       4   /* Le token trouvé est le signe "-"                                               */
#define TOKEN_SIGNE_MULTIPLIE   5   /* Le token trouvé est le signe "*"                                               */
#define TOKEN_SIGNE_DIVISE      6   /* Le token trouvé est le signe "/"                                               */
#define TOKEN_PARENTHESE_GAUCHE 7   /* Le token trouvé est le signe "("                                               */
#define TOKEN_PARENTHESE_DROITE 8   /* Le token trouvé est le signe ")"                                               */

#define FORMAT_DATE             "%d-%b-%Y"  /* Format d'affichage de la date du systeme                               */
#define FORMAT_DATE_LONG        12          /* Longueur résultant du format FORMAT_DATE                               */
#define FORMAT_HRE              "%H:%M"     /* Format d'affichage de l'heure du systeme                               */
#define FORMAT_HRE_LONG         6           /* Longueur résultant du format FORMAT_HRE                                */
#define FORMAT_NUMERO_PAGE      "%3d"       /* Format d'affichage du numéro de page                                   */
#define FORMAT_FICIMP           "%s\n"      /* Format d'impression des lignes dans le fichier d'impression            */
#define FORMAT_NOMBRE           "%+.2f"     /* Format de conversion des nombres en chaines                            */
#define FORMAT_FORMFEED         ""          /* Code du Form feed  (saut de page)                                      */

#define TYPE_HAUT_PAGE          "H"         /* Type de ligne du format Haut de page                                   */
#define TYPE_BAS_PAGE           "B"         /* Type de ligne du format Bas de page                                    */

#define XELNOM_EFITYP           "EFITYP"    /* Nom de la zone contenant le type d'état financier dans la base         */

#define IMPLIG_NON              "-"         /* Code indiquant de ne pas imprimer la ligne de l'EF                     */
#define IMPLIG_SI_NON_ZERO      "0"         /* Code indiquant d'imprimer la ligne de l'EF s'il y a un resultat <> de 0*/
#define IMPLIG_OUI              "1"         /* Code indiquant d'imprimer la ligne de l'EF                             */

#define CARACTERE_OVERFLOW      '#'         /* Caractere utilisé pour indiquer un dépassement de capacité d'affichage */

#define ARRONDI_NON             "0"         /* Pas d'arrondi                                                          */
#define ARRONDI_1               "1"         /* Arrondi au 1$                                                          */
#define ARRONDI_10              "2"         /* Arrondi au 10$                                                         */
#define ARRONDI_100             "3"         /* Arrondi au 100$                                                        */
#define ARRONDI_1000            "4"         /* Arrondi au 1000$                                                       */
#define ARRONDI_10000           "5"         /* Arrondi au 10000$                                                      */

#define TAILLE_WORK_BUFF        50          /* Taille des buffer de travail des chaines de caractères                 */

#define WILDCARD_ALL            "*"         /* Caractère de substitution indiquant : rechercher tout                      */
#define WILDCARD_ONECHAR        "#"         /* Caractère de substitution indiquant : rechercher une lettre ou un chiffre  */
#define WILDCARD_PATTERN        "#=?"       /* Redéfinition des Méta-caractères pour le MATCHING USING                    */
#define WILDCARD_CIENMC         " =?*"      /* Pattern d'expansion pour les numéros de nomenclatures                      */
#define WILDCARD_DIESE          '#'         /* Caractère de substitution indiquant : rechercher une lettre ou un chiffre  */
#define WILDCARD_PINTERRO       '?'         /* Caractère de substitution indiquant : rechercher une lettre ou un chiffre  */

#define EFCENTCOL_SEP_LIG       '^'         /* Caractère indiquant un saut de ligne dans la définition de l'entête        */
#define ASCI_SEP                '/'         /* Caractère de séparation des codes ascii dans le format                     */

#define NBR_LIGNE_MIN           2           /* Nombre minimum de lignes de données à afficher par page d'état             */

/*
 * Définition des opérateurs et des opérandes pour l'interpréteur de la colonne calcul
 */

char  g_operateur_s[] = {"+-/*()"};
char  g_operand_s[]   = {"ABCDEFGHIJKLMNOP"};

/*
 * Déclaration de la base de donnée et des variables associés au GDML.
 */

DATABASE db_dict = COMPILETIME FILENAME "dict.gdb"
                   RUNTIME FILENAME argv[1];


 void * trh_controle;                          /* Identifiant de la      */
                                               /* transaction "controle" */
 void * trh_gl951_1;                           /* Identifiant de la      */
                                               /* transaction "gl951_1"  */
 void * trh_gl951_2;                           /* Identifiant de la      */
                                               /* transaction "gl951_2"  */
 void * trh_gl951_3;                           /* Identifiant de la      */
                                               /* transaction "gl951_3"  */
/*
 * Définition des structures de données internes
 */

struct eff_ligne_strdef {                              /* FORMAT DU HAUT ET DU BAS DE PAGE           */
BASED ON gleff_ligne.efltypfor       efltypfor       ; /* Type de format (Haut ou Bas)               */
BASED ON gleff_ligne.efllignum       efllignum       ; /* Numéro de ligne                            */
BASED ON gleff_ligne.eflelenum       eflelenum       ; /* Numéro d'élément                           */
BASED ON gleff_ligne.eflelecod       eflelecod       ; /* Code de l'élément                          */
BASED ON gleff_ligne.eflelepos       eflelepos       ; /* Position de l'élément                      */
BASED ON gleff_ligne.eflelecol       eflelecol       ; /* Numéro de colonne                          */
BASED ON gleff_ligne.eflelelab       eflelelab       ; /* Label de l'élément                         */
BASED ON gleff_ligne.efleletxt       efleletxt       ; /* Texte libre                                */
};

typedef struct eff_ligne_strdef      eff_ligne_str        ; /* Définition du type de donnée eff_ligne_str                */
typedef struct eff_ligne_strdef    * eff_ligne_strptr     ; /* Définition du type de donnée eff_ligne_strptr             */

struct etat_financier_strdef {                                  /* STRUCTURE GÉNÉRALE D'UN EF                                 */
BASED ON gletat_financier.eficiecle         eficiecle       ;   /*Compagnie de l'état financier                               */
BASED ON gletat_financier.eficle            eficle          ;   /*Code de l'E/F                                               */
BASED ON gletat_financier.efityp            efityp          ;   /*Type d'E/F                                                  */
BASED ON gletat_financier.efiusrcre         efiusrcre       ;   /*Concepteur de l'E/F                                         */
BASED ON gletat_financier.efiimpinfsup      efiimpinfsup    ;   /*Imp. des unité adm.                                         */
BASED ON gletat_financier.efititcie         efititcie       ;   /*Titre - cie                                                 */
BASED ON gletat_financier.efititef          efititef        ;   /*Titre de l'E/F                                              */
BASED ON gletat_financier.efititper         efititper       ;   /*Titre - périodicité                                         */
BASED ON gletat_financier.efititcom         efititcom       ;   /*Titre - commentaire                                         */
BASED ON gletat_financier.efiflgimp         efiflgimp       ;   /*Imp. de l'E/F                                               */
BASED ON gletat_financier.efinbrlig         efinbrlig       ;   /*Nombre de lignes de détail de l'etat financier              */
BASED ON gletat_financier.effciecle         effciecle       ;   /*Compagnie du format                                         */
BASED ON gletat_financier.effcle            effcle          ;   /*Code du format                                              */
BASED ON gletat_financier.efinbrlig         effnbrlig       ;   /*Nombre de lignes contenu dans le format                     */
BASED ON gletat_financier.efinbrlig         efinbrligent    ;   /*Nombre de lignes utilisés pour les entêtes des colonnes     */
BASED ON gletat_financier.efinbrlig         eficollarmax    ;   /*Largeur de la plus grande colonne                           */
  eff_ligne_strptr                          efiformat       ;   /*Pointeur sur une définition de format (haut/bas de page)    */
  struct  {                                                     /* COLONNES DE L'EF                                           */
    BASED ON glefi_colonne.efcnumcol        efcnumcol       ;   /*Numéro de colonne                                           */
    BASED ON glefi_colonne.efctypcol        efctypcol       ;   /*Type de colonne                                             */
    int                                     efcanncol       ;   /*Identification de l'année                                   */
    BASED ON glefi_colonne.efclarcol        efclarcol       ;   /*Largeur de la colonne                                       */
    BASED ON glefi_colonne.efcentcol        efcentcol       ;   /*En-tête de colonne                                          */
    BASED ON glefi_colonne.efccalcol        efccalcol       ;   /*Calcul(équation)                                            */
    int                                     calcolval_f     ;   /*Equation de calcul valide (ne contient pas de colonne ratio */
    struct  {                                                   /* Définition de la formule de calcul en notation polonaise inversée*/
      char    typtok_c                                      ;   /* Type de token                                              */
      int     indcol_i                                      ;   /* Indice de la colonne à traiter (opérande)                  */
      double  valcst_d                                      ;   /* Valeur constante (opérande)                                */
            } token[MAX_TOKEN]                              ;   /*Équivalent en postfixé de l'expression de efccalcol         */
    BASED ON glefi_colonne.efcimpcol        efcimpcol       ;   /*Imp. colonne dans note                                      */
    int                                     efcecacol1      ;   /*Numéro de la première colonne de calcul pour les écarts     */
    int                                     efcecacol2      ;   /*Numéro de la deuxiemme colonne de calcul pour les écarts    */
    int                                     efcratcol       ;   /*Numéro de la colonne à utiliser pour le calcul des ratios   */
          } colonne[NBR_COLONNES];
  int                                       colrat_f        ;   /*Flag indiquant la présence de colonnes RATIO              */
};

typedef struct etat_financier_strdef    etat_financier_str  ;   /* Définition du type de donnée etat_financier_str    */
typedef struct etat_financier_strdef  * etat_financier_ptr  ;   /* Définition du type de donnée etat_financier_ptr    */

struct efi_detail_strdef {                                      /* SRUCTURE DES LIGNES DE DÉTAIL DE L'EF              */
BASED ON glefi_detail.efdnumlig         efdnumlig             ; /*Numéro de ligne                                     */
BASED ON glefi_detail.efdcod            efdcod                ; /*Code de transaction                                 */
BASED ON glefi_detail.cptcle            cptcle                ; /*No compte                                           */
BASED ON mccompte.cpttyp                cpttyp                ; /*Type de compte : Cumulatif ou Normal                */
BASED ON glefi_detail.ciecle            ciecle                ; /*Numéro de la compagnie                              */
BASED ON glefi_detail.cienmc            cienmc                ; /*Numéro de nomenclature de la compagnie              */
BASED ON glefi_detail.unacle            unacle                ; /*No unité administrative                             */
BASED ON glefi_detail.cencle            cencle                ; /*No centre                                           */
BASED ON glefi_detail.efddsc            efddsc                ; /*Texte                                               */
BASED ON glefi_detail.efdflgimp         efdflgimp             ; /*Code d'imp. de la ligne                             */
BASED ON glefi_detail.efdligref1        efdligref1            ; /*Numéro de la première ligne de référence            */
BASED ON glefi_detail.efdligref2        efdligref2            ; /*Numéro de la deuxiemme ligne de référence           */
BASED ON glefi_detail.efdcol1           sigoper               ; /* Signe de l'opération : +,-,=                       */
  int                                   coloper               ; /*Colonne de l'opération (+,-)                        */
  int                                   colegal               ; /*Colonne qui contient le "="                         */
  int                                   naclig                ; /*Nature de la ligne : Revenu, Depense...             */
BASED ON glefi_detail.efdratb           efdrat[NBR_COLONNES]  ; /*Lignes de références pour le calcul des ratios      */
  double                                mntcol[NBR_COLONNES]  ; /*Résultat de chaque colonne                          */
};

typedef struct efi_detail_strdef     efi_detail_str           ; /* Définition du type de donnée efi_detail_str    */
typedef struct efi_detail_strdef   * efi_detail_strptr        ; /* Définition du type de donnée efi_detail_strptr */

struct mcsolde_annuel_strdef  /* Structure permettant de calculer le solde d'un compte  */
{
  struct sldann_str
  {
BASED ON mcsolde_annuel.sansldouv        sansldouv                ;  /*Solde d'ouverture                */
BASED ON mcsolde_annuel.sancumree1       sancumree[NBR_PERIODES]  ;  /*Cumul réel par période           */
BASED ON mcsolde_annuel.sanbdgann        sanbdgann                ;  /*Budget annuel                    */
BASED ON mcsolde_annuel.sanbdg1          sanbdg[NBR_PERIODES]     ;  /*Budget initial par période       */
BASED ON mcsolde_annuel.sanbdgrevann     sanbdgrevann             ;  /*Budget revisé annuel             */
BASED ON mcsolde_annuel.sanbdgrev1       sanbdgrev[NBR_PERIODES]  ;  /*Budget revisé annuel par période */
BASED ON mcsolde_annuel.sansldouveng     sansldouveng             ;  /*Solde d'ouverture engagement     */
BASED ON mcsolde_annuel.sancumeng1       sancumeng[NBR_PERIODES]  ;  /*Cumul engagement par période     */
  } sldann[NBR_ANNEES];
} g_sldann_str[NBR_COLONNES];


typedef struct element_strdef * element_ptr;

struct element_strdef {                         /*Liste chainée sur les CIE/UNA/CEN à traiter */
BASED ON glece_detail.ciecle          ciecle          ; /*Numéro de la compagnie                      */
BASED ON glece_detail.unacle          unacle          ; /*No unité administrative                     */
BASED ON glece_detail.cencle          cencle          ; /*No centre                                   */
         element_ptr                  element_suivant ; /*Element suivant dans la chaine              */
};

struct {                                          /* Définition des valeurs affichés dans l'entete  */
BASED ON glef_cedule.ececiecle      ececiecle   ; /* Numéro de la compagnie de la cédule            */
BASED ON glef_cedule.ececle         ececle      ; /* Numéro de la cédule                            */
BASED ON mccompagnie.cienom         cienom      ; /* Nom de la compagnie                            */
BASED ON mcunite_adm.unanom         unanom      ; /* Nom de l'unité administrative                  */
BASED ON mccentre.cennom            cennom      ; /* Nom du centre                                  */
BASED ON gletat_financier.eficiecle eficiecle   ; /* Numéro de compagnie de l'état financier        */
BASED ON gletat_financier.eficle    eficle      ; /* Numéro de l'état financier                     */
BASED ON gletat_financier.efititcie titre       ; /* Titre de l'état financier                      */
BASED ON gletat_financier.efititper periodicite ; /* Désignation de la périodicité                  */
BASED ON glef_cedule.peccle         peccle      ; /* Numéro de la période comptable à traiter       */
  char               pecdatdeb[FORMAT_DATE_LONG]; /* Chaine contenant la date de début de la période*/
  char               pecdatfin[FORMAT_DATE_LONG]; /* Chaine contenant la date de fin de la période  */
  int                page                       ; /* Numéro de page                                 */
  char               date[FORMAT_DATE_LONG]     ; /* Date du jour                                   */
  char               heure[FORMAT_HRE_LONG]     ; /* Heure d'exécution                              */
} g_efiformvalu_str;

/*
 * Déclaration de la table permettant de calculer les totaux de l'EF
 */

  double  g_table_calcul_d[NBR_COLONNES][NBR_NIVEAUX_TOTAL];

/*
 * Déclaration de données et structures globales
 */

  char    g_lngcle_c;         /* Langue de l'usager                                     */

struct {                                                /*DONNÉES DE TRAITEMENT DE LA CÉDULE  */
BASED ON glef_cedule.ececiecle        ececiecle       ; /*Compagnie de la cédule              */
BASED ON glef_cedule.ececle           ececle          ; /*Code de la cédule                   */
BASED ON glef_cedule.ecedsc           ecedsc          ; /*Description du lot                  */
BASED ON glef_cedule.peccle           peccle          ; /*Période Comptable                   */
BASED ON glef_cedule.ecetitcom        ecetitcom       ; /*Titre - commentaire                 */
BASED ON glef_cedule.ecelonpag        ecelonpag       ; /*Longueur de la page                 */
BASED ON glef_cedule.ecelarpag        ecelarpag       ; /*Largeur de la page                  */
BASED ON glef_cedule.eceespcol        eceespcol       ; /*Espace entre colonne                */
BASED ON glef_cedule.ecelardsc        ecelardsc       ; /*Largeur description                 */
BASED ON glef_cedule.ecesgng          ecesgng         ; /*Signe de gauche.                    */
BASED ON glef_cedule.ecesgnd          ecesgnd         ; /*Signe de droite.                    */
BASED ON glef_cedule.ececodarr        ececodarr       ; /*Code arrondissement                 */
BASED ON glef_cedule.ecelng           ecelng          ; /*Langue                              */
BASED ON glef_cedule.ecesepdec        ecesepdec       ; /*Séparateur décimale                 */
BASED ON glef_cedule.ecesepmil        ecesepmil       ; /*Séparateur millier                  */
BASED ON glef_cedule.ececon           ececon          ; /*Type de cédule = CONSOLIDE OUI/NON  */
BASED ON glef_cedule.ecenbrlig        ecenbrlig       ; /*Nombre de ligne de FORMAT           */
} g_efcedule_str;


FILE *g_ficimp_fic;       /* Pointeur sur le fichier d'impression           */

char  g_bufimp_s[BUFSIZ]; /* Buffer d'écriture dans le fichier d'impression */

int   g_ann000_i;         /* Année courante à traiter                       */
int   g_ann001_i;         /* Année précédente à traiter                     */
int   g_ann002_i;         /* Année pré-précédente à traiter                 */
int   g_numper_i;         /* Numéro de la période demandée                  */

struct  tm  g_time_str;    /* Structure de travail de la date et de l'heure  */

/*
 * Définitions et données globales pour la routine de transformation d'une chaine INFIX en POSTFIX, et pour la routine
 * d'évaluation de l'expression postfix
 */

char    g_pile_s[MAX_EXPPILE_SIZE];       /* Pile des operateurs                            */
double  g_pile_eval_d[MAX_EVLPILE_SIZE];  /* Pile d'évaluation de l'expression postfix      */
int     g_indpile_i;                      /* Position actuelle dans la pile des operateurs  */
int     g_indpile_ev_i;                   /* Position actuelle dans la pile d'évaluation    */

struct  table_op_strdef /* Table des précédences entres operateurs  */
{
  char  op1;  /* Premier opérateur                                            */
  char  op2;  /* Deuxiemme opérateur                                          */
  int   prcd; /* = 1 si le premier opérateur a précédence devant le deuxiemme */
} g_tblop_str[36] = { {'+','+',TRUE }, {'+','-',TRUE }, {'+','*',FALSE}, {'+','/',FALSE}, {'+','(',FALSE}, {'+',')',TRUE },
                      {'-','+',TRUE }, {'-','-',TRUE }, {'-','*',FALSE}, {'-','/',FALSE}, {'-','(',FALSE}, {'-',')',TRUE },
                      {'*','+',TRUE }, {'*','-',TRUE }, {'*','*',TRUE }, {'*','/',TRUE }, {'*','(',FALSE}, {'*',')',TRUE },
                      {'/','+',TRUE }, {'/','-',TRUE }, {'/','*',TRUE }, {'/','/',TRUE }, {'/','(',FALSE}, {'/',')',TRUE },
                      {'(','+',FALSE}, {'(','-',FALSE}, {'(','*',FALSE}, {'(','/',FALSE}, {'(','(',FALSE}, {'(',')',FALSE},
                      {')','+',TRUE }, {')','-',TRUE }, {')','*',TRUE }, {')','/',TRUE }, {')','(',-1   }, {')',')',TRUE } };

/*
 * On garde en mémoire globale la structure du dernier ef traité pour eviter de le relire
 * si on doit executer plusieurs fois de suite le même EF.
 */

etat_financier_ptr      g_etafin_ptr; /* Pointeur sur la structure d'etat financier globale                           */
efi_detail_strptr       g_efidet_ptr; /* Pointeur sur une structure de détail de l'ef global                          */
int                     g_glbefiexi_f;/* Flag pour indiquer qu'il existe un EF en mémoire globale                     */
int                     g_glbefiuti_f;/* Flag pour indiquer qu'on utilise la définition de l'ef de la mémoire globale */

/*
 * Déclaration des types des Fonctions
 */

extern char       * allouer_buffer ();
extern element_ptr  ajouter_elem ();
extern element_ptr  allouer_elem();
extern int          cadrer_droite_buffer();
extern int          cadrer_gauche_buffer();
extern void         calcul_ef();
extern void         calcul_ligne();
extern void         calcul_solde();
extern void         calcul_solde_colonne();
extern void         calcul_solde_global();
extern void         calcul_total();
extern int          calculer_offset();
extern int          calculer_seuil();
extern int          centrer_buffer();
extern char         ChercheToken();
extern int          col_egal();
extern int          col_operation();
extern int          creer_domaine();
extern void         dberreur();
extern element_ptr  element_suivant();
extern int          est_vide();
extern double       eval_postfix();
extern void         formater_nombre();
extern void         imprimer_ef();
extern int          imprimer_entete();
extern int          imprimer_format();
extern int          imprimer_ligblanche();
extern int          imprimer_ligne();
extern int          IndiceLigne();
extern void         liberer_buffer();
extern int          mc950();
extern int          numero_domaine();
extern int          operand_oui();
extern int          operateur_oui();
extern int          pop_operateur();
extern int          pop_pile_eval();
extern void         postfix();
extern int          positionner_buffer();
extern int          precedence();
extern int          preparer_ef();
extern void         preparer_format();
extern int          push_operateur();
extern int          push_pile_eval();
extern void         remplir_buffer();
extern double       round();
extern double       san_bdg_ann();
extern double       san_bdg_cum_n();
extern double       san_bdg_n();
extern double       san_bdgrev_ann();
extern double       san_bdgrev_cum_n();
extern double       san_bdgrev_n();
extern double       san_cum_n();
extern double       san_cum_ree_eng_n();
extern double       san_cum_ree_n();
extern double       san_sld_ouv();
extern double       san_sld_ouv_eng();
extern char       * strelem();
extern int          strtokcnt();
extern char       * strreplc();
extern void         strtrim();
extern element_ptr  vide_liste();
extern int          vider_buffer();
extern void         vider_domaine();


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

  int     l_usager_valide_f;  /* Flag indiquant si l'usager est valide                                            */
  int     l_prog_autorise_f;  /* Flag indiquant s'il a acces à ce programme                                       */
  int     l_cedule_trouve_f;  /* Flag indiquant que la cédule demandé existe                                      */
  int     l_ecd_trouve_f;     /* Flag indiquant qu'il existe un détail de cédule                                  */
  int     l_numdomaine_i;     /* Identifiant du domaine de donnée                                                 */
  int     l_pecno_i;          /* Période demandée                                                                 */
  int     l_ann000_i;         /* Année demandée                                                                   */
  int     l_nbecddet_i;       /* Nombre de lignes de détail lues dans le détail de la cédule                      */
  int     l_selcnt_i;         /* Nombre de sélection de colonnes trouvés                                          */
  int     l_indcol_i;         /* Indice de la colonne en cours de traitement                                      */
  element_ptr l_elmdom_ptr;   /* Pointeur de la liste de chaque élément à prendre au domaine */

 /*
  * Les BASED ON qui suivent sont définis pour permettent de récupérer les données de la première ligne de cédule dans le cas
  * d'une cédule consolidée.
  */

BASED ON glece_detail.ecdflgselcol  l_ecdflgselcol_s;/* Flag pour indiquer s'il y a des sélections de données par colonne         */
BASED ON glece_detail.ececiecle     l_ececiecle_s;   /* Compagnie de la cédule                                                    */
BASED ON glece_detail.ececle        l_ececle_s;      /* Numéro de la cédule                                                       */
BASED ON glece_detail.ecdnumlig     l_ecdnumlig_i;   /* Numéro de ligne du détail de la cédule (Toujours 1 normalement)           */
BASED ON glece_detail.eficiecle     l_eficiecle_s;   /* Numéro de compagnie de l'état financier utilisé pour la cédule consolidée */
BASED ON glece_detail.eficle        l_eficle_s;      /* Numéro de l'état financier utilisé pour la cédule consolidée              */
BASED ON glece_detail.ecdtitef      l_titef_s;       /* description de l'état financier utilisé pour la cédule consolidée         */
BASED ON glece_detail.ecdnbrcop     l_ecdnbrcop_i;   /* Nombre de copies à imprimer de l'état financier                           */

 /*
  * INITIALISATIONS :
  *   On vient de rentrer dans le programme. Donc il n'y a pas encore d'etat financier en mémoire
  */

  SET_FALSE(g_glbefiexi_f);

 /*
  * Si le 1er paramètre est un "?", alors on affiche la version et la date et heure de compilation
  * Ceci permet de savoir quelle est la version du programme quand il est installé chez un client.
  */

  if (strcmp(argv[1],DEMANDE_INFO)==0)
    {
#if VAXVMS
      printf("GL951 %s, compilé le %s à %s, avec le fichier %s\n",VERSION_GL951,__DATE__,__TIME__,__FILE__);
#else
      printf("GL951 %s\n",VERSION_GL951);
#endif
      mc950(NOM_PROGRAMME,g_lngcle_c,MESSOK); /* Programme terminé avec succes. */
      exit(EXIT_SANS_ERREUR);
    }

 /*
  * Ouverture de la base de donnée,
  * Vérification de la sécurité (l'usager doit être déclaré, valide et avoir acces au programme).
  * Et récupération de la langue de l'usager (Pour les messages)
  */

  READY db_dict DEFAULT CACHE 256 BUFFERS
    ON_ERROR
#if UNIX
      gds__print_status ( gds__status );
#else
      gds_$print_status ( gds_$status );
#endif
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  trh_controle=0;

  START_TRANSACTION trh_controle
    CONCURRENCY READ_ONLY WAIT
    RESERVING gsusager      FOR READ,
              gsusager_prog FOR READ
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  SET_FALSE(l_usager_valide_f);
 /*
  * On récupère la langue de l'usager
  */
  if (getenv(PROSIG_USRLNG))
    g_lngcle_c = getenv(PROSIG_USRLNG)[0];
  else
    g_lngcle_c = FRA; /* 1ere langue par défaut */

 /*
  * On vérifie son droit d'accès
  */
  FOR (TRANSACTION_HANDLE trh_controle)
     usr IN gsusager
        WITH     usr.usrcle    = RDB$USER_NAME
             AND (   usr.usrdatfin.char[6]  > "TODAY"
                  OR usr.usrdatfin          MISSING
                  OR usr.usrdatfin.char[12] = "17-NOV-1858")  /* La base renvoie cette date */
    {                                                         /* si la zone contient 0      */
     /*
      * L'usager existe et est autorisé à se connecter
      */

      SET_TRUE(l_usager_valide_f);

     /*
      * Examen de la sécurité des programmes pour savoir s'il a acces à ce
      * programme.
      */

      SET_TRUE(l_prog_autorise_f);

      FOR (TRANSACTION_HANDLE trh_controle)
          usp IN gsusager_prog
          WITH     usp.usrcle     = RDB$USER_NAME
               AND usp.xprnom     = NOM_PROGRAMME
               AND usp.uspflgacs  = "0" /* 1 = autorisé, 0 = pas d'acces */
        {
         /*
          * L'usager n'a pas acces à ce programme
          */

          SET_FALSE(l_prog_autorise_f);
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_FINISH);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  COMMIT trh_controle
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  if ( !(l_usager_valide_f && l_prog_autorise_f) )
    {
      if (!l_prog_autorise_f) mc950(NOM_PROGRAMME,g_lngcle_c,PRGNONAUT); /* programme non autorisé */
      if (!l_usager_valide_f) mc950(NOM_PROGRAMME,g_lngcle_c,USANONAUT); /* Usager non autorisé    */
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    };

 /*
  *-----------------------------------------------------------------------------
  * Traitement des paramètre d'entrée.
  *-----------------------------------------------------------------------------
  * Ce doit être :  . un numéro de Compagnie -> chaine de 4 caracteres max.
  *                 . un numéro de cédule    -> chaine de 4 caracteres max.
  *                 . un commentaire         -> chaine de x caractères.
  *                 . une période            -> chaine de 4 caractères contenant un numérique de 4 chiffres ( ex 9205 ).
  *                 . un nom de fichier      -> chaine de x caractères.
  *
  * Note : Le numéro de compagnie entré en paramètre permet de retrouver aussi bien la cédule
  *        que l'état financier. Ce numéro de compagnie n'est pas là pour sélectionner des
  *        données. Il est ici uniquement pour retrouver la definition de la cédule, de l'état
  *        financier et du format du haut de page.
  */

  if (    ( argc != NOMBRE_ARGUMENTS )
       || ( atoi (argv[5]) <= 0 || atoi(argv[5]) > 9914 ) ) /* argv[5] = Période comptable */
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,PARAMINV); /* Paramètre invalide */
      exit(EXIT_AVEC_ERREUR);
    }

 /*
  * Mise à jour de la scédule pour y placer la description et la période comptable lue avec les paramètres
  */

  trh_gl951_1=0;

  START_TRANSACTION trh_gl951_1
    CONCURRENCY READ_WRITE WAIT
    RESERVING glef_cedule FOR WRITE
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  SET_FALSE(l_cedule_trouve_f);

  FOR (TRANSACTION_HANDLE trh_gl951_1)
    FIRST 1 ece IN glef_cedule
    WITH     ece.ececiecle = argv[2]  /* argv[2] = numéro de compagnie */
         AND ece.ececle    = argv[3]  /* argv[3] = numéro de la cédule */
    {
      SET_TRUE(l_cedule_trouve_f);

      strncpy(g_efcedule_str.ececiecle,argv[2],sizeof(ece.ececiecle));  /* argv[2] = numéro de la compagnie*/
      strncpy(g_efcedule_str.ececle,   argv[3],sizeof(ece.ececle));     /* argv[3] = numéro de la cédule  */
      strcpy (g_efiformvalu_str.ececle,g_efcedule_str.ececle);          /* Pour l'impression              */
      strcpy (g_efcedule_str.ecedsc,   ece.ecedsc);
      strncpy(g_efcedule_str.peccle,   argv[5],sizeof(ece.peccle));     /* argv[5] = Période comptable    */
      strcpy (g_efiformvalu_str.peccle,argv[5]);                        /* argv[5] = Période comptable    */
      strncpy(g_efcedule_str.ecetitcom,argv[4],sizeof(ece.ecetitcom));  /* argv[4] = Commentaire          */
      g_efcedule_str.ecelonpag       = ece.ecelonpag;
      g_efcedule_str.ecelarpag       = ece.ecelarpag;
      g_efcedule_str.eceespcol       = ece.eceespcol;
      g_efcedule_str.ecelardsc       = ece.ecelardsc;
      strcpy(g_efcedule_str.ecesgng,   ece.ecesgng);
      strcpy(g_efcedule_str.ecesgnd,   ece.ecesgnd);
      strtrim(g_efcedule_str.ecesgnd);
      strcpy(g_efcedule_str.ececodarr, ece.ececodarr);
      strcpy(g_efcedule_str.ecelng,    ece.ecelng);
      strcpy(g_efcedule_str.ecesepdec, ece.ecesepdec);
      strcpy(g_efcedule_str.ecesepmil, ece.ecesepmil);
      strcpy(g_efcedule_str.ececon,    ece.ececon);
      g_efcedule_str.ecenbrlig       = ece.ecenbrlig;

      MODIFY ece USING
        {
          strncpy(ece.peccle,argv[5],sizeof(ece.peccle));         /* argv[5] = Période comptable    */
          strncpy(ece.ecetitcom, argv[4],sizeof(ece.ecetitcom));  /* argv[4] = Commentaire          */
        }
      END_MODIFY
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_1);
          return(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_1);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  COMMIT trh_gl951_1
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Extraction de l'année et du numéro de période
  */

  l_pecno_i = atoi (argv[5]);
  l_ann000_i = l_pecno_i/100;

  if (l_ann000_i < 10)
      l_ann000_i += ANNEE_00;
  else
      l_ann000_i += SIECLE_ACTUEL;

  g_ann000_i = (l_ann000_i - ((l_ann000_i/100)*100)); /* Diviser par 100 et multiplier par 100 enleve les dizaines  */
  l_ann000_i--;                                       /* ce qui permet d'enlever le siècle                          */
  g_ann001_i = (l_ann000_i - ((l_ann000_i/100)*100));
  l_ann000_i--;
  g_ann002_i = (l_ann000_i - ((l_ann000_i/100)*100));

  g_numper_i = l_pecno_i - ((l_pecno_i/100)*100);

  if (g_numper_i < 0 || g_numper_i > NBR_PERIODES )
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,PARAMINV); /* Paramètre invalide */
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

  g_numper_i --; /* On retranche 1 au numéro de période car en C les tableaux commencent à 0 */

 /*
  * Si la scédule n'existe pas, on indique l'erreur et
  * on termine l'exécution du programme.
  */

  if (!l_cedule_trouve_f)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,CEDINC); /* Cédule inconnue */
      fprintf (stderr," %s\n",argv[3]);  /* argv[3] = numerode cédule */
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    };

 /*
  * Ouverture du fichier d'impression. Écrase le contenu précédent si le fichier
  * existe déja.
  */

  g_ficimp_fic = fopen (argv[6],"w"); /* argv[6] = Nom du fichier d'impression */

  if (setvbuf(g_ficimp_fic,g_bufimp_s,_IOFBF,BUFSIZ))
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,ALLBUFIMP); /* Allocation impossible du buffer d'écriture du fichier d'impression */
      FINISH db_dict
        ON_ERROR
#if UNIX
          gds__print_status ( gds__status );
#else
          gds_$print_status ( gds_$status );
#endif
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      exit(EXIT_AVEC_ERREUR);
    }

 /*
  *-----------------------------------------------------------------------------
  * Traitement de la cédule.
  *-----------------------------------------------------------------------------
  *
  * Si ce n'est pas une cédule consolidée,
  *   Alors on retrouve tous les détails de cette cédule, et on appelle
  *         un traitement d'état par ligne de détail.
  *   Sinon, on regroupe tous les détail de la cédule pour en déterminer
  *         le domaine. Et on appelle UN traitement d'état financier
  *         portant sur ce domaine.
  *
  * Note :  On utilise deux transactions. La première, en lecture seulement
  *         permet d'acceder aux données des relations sans être bloqués par
  *         les utilisateurs, et sans les bloquer non plus. La deuxiemme,
  *         est utilisée pour la gestion du domaine et lorsque c'est
  *         nécessaire. C'est à dire : lors de la création du domaine, en
  *         lecture écriture. Et lors du calcul de l'etat en lecture seulement.
  *         De cette façon, on évite les conflits d'acces à la base.
  */

  l_elmdom_ptr = 0;

  trh_gl951_1=0;

  START_TRANSACTION trh_gl951_1
    CONCURRENCY READ_ONLY WAIT
    RESERVING glece_detail      FOR READ,
              glecd_sel_col     FOR READ,
              mccompagnie       FOR READ,
              mcunite_adm       FOR READ,
              mccentre          FOR READ,
              mcperiode_ctb     FOR READ
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Si ce n'est pas une cédule de type CONSOLIDÉ. C'est à dire que chaque détail
  * de la cédule porte sur un état différent ou une selection de donnée
  * differente.
  * Alors, Pour chaque détail de cette cédule, on va déterminer le domaine
  * de donnée et on va traiter l'état financier demandé.
  */

  if ( strcmp(g_efcedule_str.ececon,CONSOLIDE_NON) == 0)
    {
      SET_FALSE (l_ecd_trouve_f);
      FOR (TRANSACTION_HANDLE trh_gl951_1)
        ecd IN glece_detail
        WITH     ecd.ececiecle = g_efcedule_str.ececiecle
             AND ecd.ececle    = g_efcedule_str.ececle
        SORTED BY ecd.ecdnumlig
        {
          SET_TRUE (l_ecd_trouve_f);
          l_numdomaine_i = numero_domaine();
         /*
          * Création du domaine de données Global de l'état financier
          */
          l_elmdom_ptr   = ajouter_elem(l_elmdom_ptr,ecd.ciecle,ecd.unacle,ecd.cencle);
          if (!creer_domaine (l_numdomaine_i,EDOTYP_GLOBAL,0,ecd.ecdcon,l_elmdom_ptr))
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,SELINV); /* Sélection invalide : */
              fprintf(stderr," %s %s / %d\n",g_efcedule_str.ececiecle,g_efcedule_str.ececle,ecd.ecdnumlig);
            }
          else
            {
             /*
              * Si l'usager à fait des sélections de données par colonnes, alors il faut creer un domaine
              * pour chaque colonne.
              */
              if (strcmp(ecd.ecdflgselcol,REPONSE_OUI)==0)
                {
                  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES; l_indcol_i++)
                    {
                      l_selcnt_i = 0;
                      l_elmdom_ptr = vide_liste (l_elmdom_ptr);
                      FOR (TRANSACTION_HANDLE trh_gl951_1)
                              esc IN glecd_sel_col
                        WITH  esc.ececiecle = ecd.ececiecle
                          AND esc.ececle    = ecd.ececle
                          AND esc.ecdnumlig = ecd.ecdnumlig
                          AND esc.escnumcol = l_indcol_i + 1
                        {
                          l_elmdom_ptr = ajouter_elem(l_elmdom_ptr,esc.ciecle,esc.unacle,esc.cencle);
                          l_selcnt_i++;
                        }
                      END_FOR
                        ON_ERROR
                          dberreur(ACTION_ROLLBACK_GL951_1);
                          exit(EXIT_AVEC_ERREUR);
                        END_ERROR;
                     /*
                      * Si l'usager à rentré une sélection pour cette colonne alors on crée un domaine de donné
                      * associé à cette colonne et correspondant à la sélection.
                      */
                      if (l_selcnt_i!=0) creer_domaine (l_numdomaine_i,EDOTYP_COLONNE,l_indcol_i,ecd.ecdcon,l_elmdom_ptr);
                    }
                }

             /*
              * On va rechercher le nom de la compagnie, de l'unité et du centre pour préparer l'impression
              */

              preparer_format(ecd.ciecle,ecd.unacle,ecd.cencle,ecd.ecdtitef,g_efcedule_str.peccle);

             /*
              * Création de la transaction principale de calcul des états financiers.
              */

              trh_gl951_3=0;

              START_TRANSACTION trh_gl951_3
                CONCURRENCY READ_ONLY WAIT
                RESERVING gletat_financier    FOR READ,
                          glefi_colonne       FOR READ,
                          glefi_detail        FOR READ,
                          gleff_ligne         FOR READ,
                          mccompte            FOR READ,
                          mcsolde_annuel      FOR READ,
                          mcsan_rest          FOR READ,
                          mccode_bilingue     FOR READ,
                          glefi_domaine       FOR READ
                ON_ERROR
                  dberreur(ACTION_FINISH);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;
             /*
              * On appelle le calcul et impression de l'état financier demandé en lui passant
              * le domaine qui vient d'être déterminé.
              */

              calcul_ef ( ecd.eficiecle,          /* Compagnie de l'état financier à traiter                        */
                          ecd.eficle,             /* Numéro de l'état financier à traiter                           */
                          NOTE_NON,               /* L'état demandé n'est pas une note                              */
                          ecd.ecdtitef,           /* Titre de l'ef                                                  */
                          l_numdomaine_i,         /* Identifiant du domaine de donnée à traiter                     */
                          g_efcedule_str.peccle,  /* Periode comptable à traiter                                    */
                          ecd.ecdcon,             /* Consolidé OUI ou NON                                           */
                          ecd.ecdnbrcop,          /* Nombre de copies à imprimer                                    */
                          ecd.ecdflgselcol,       /* Flag indiquant qu'il existe une sélection par colonne          */
                          (etat_financier_ptr) 0, /* Adresse de l'E/F d'origine (Pour les notes)                    */
                          (efi_detail_strptr) 0); /* Adresse d'une structure d'une ligne de                         */
                                                  /* détail de l'EF dans laquelle se trouve les                     */
                                                  /* valeurs de retour. Ici, on donne 0 comme                       */
                                                  /* adresse car on ne dois pas récuperer de                        */
                                                  /* valeur.                                                        */
             /*
              * Fermeture de la transaction principale.
              */
              COMMIT trh_gl951_3
                ON_ERROR
                  dberreur(ACTION_FINISH);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;
            }
          l_elmdom_ptr = vide_liste(l_elmdom_ptr);
          vider_domaine(l_numdomaine_i);
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_FINISH);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      if (!l_ecd_trouve_f)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,ECDINEX); /* Détail de cédule inexistant :*/
          fprintf(stderr," %s %s\n",g_efcedule_str.ececiecle,g_efcedule_str.ececle);
        }
    }
  else
    {
     /*
      * On cumule toutes les selections de données de chaque détail pour
      * ne faire qu'un seul grand domaine consolidé.
      */
      l_nbecddet_i = 0;
      SET_FALSE (l_ecd_trouve_f);
      FOR (TRANSACTION_HANDLE trh_gl951_1)
        ecd IN glece_detail
        WITH     ecd.ececiecle = g_efcedule_str.ececiecle
             AND ecd.ececle    = g_efcedule_str.ececle
        SORTED BY ecd.ecdnumlig
        {
          l_nbecddet_i++;
          SET_TRUE (l_ecd_trouve_f);
          l_elmdom_ptr = ajouter_elem(l_elmdom_ptr,ecd.ciecle,ecd.unacle,ecd.cencle);
         /*
          * On récupère le numéro de cédule, la ligne, le flag indiquant la sélection des données par colonne,
          * le numéro d'EF,le titre, et le nombre de copies du premier détail de la cédule.
          * Ce sont ces données qui vont êtres utilisés pour exécuter l'état.
          */
          if ( l_nbecddet_i == 1 )
            {
              strcpy(l_ececiecle_s,     ecd.ececiecle);
              strcpy(l_ececle_s,        ecd.ececle);
                     l_ecdnumlig_i =    ecd.ecdnumlig;
              strcpy(l_ecdflgselcol_s,  ecd.ecdflgselcol);
              strcpy(l_eficiecle_s,     ecd.eficiecle);
              strcpy(l_eficle_s,        ecd.eficle);
              strcpy(l_titef_s,         ecd.ecdtitef);
                     l_ecdnbrcop_i =    ecd.ecdnbrcop;
            }
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_FINISH);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      if (!l_ecd_trouve_f)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,ECDINEX); /* Détail de cédule inexistant :*/
          fprintf(stderr," %s %s\n",g_efcedule_str.ececiecle,g_efcedule_str.ececle);
        }
      else
        {
         /*
          * Création du domaine de données Global de l'état financier
          */
          l_numdomaine_i = numero_domaine();
          if (!creer_domaine (l_numdomaine_i,EDOTYP_GLOBAL,0,CONSOLIDE_OUI,l_elmdom_ptr))
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,SELINV); /* Sélection invalide : */
              fprintf(stderr," %s %s\n",g_efcedule_str.ececiecle,g_efcedule_str.ececle);
            }
          else
            {
             /*
              * Si l'usager à fait des sélections de données par colonnes, alors il faut creer un domaine
              * pour chaque colonne.
              */
              if (strcmp(l_ecdflgselcol_s,REPONSE_OUI)==0)
                {
                  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES; l_indcol_i++)
                    {
                      l_selcnt_i = 0;
                      l_elmdom_ptr = vide_liste (l_elmdom_ptr);
                      FOR (TRANSACTION_HANDLE trh_gl951_1)
                              esc IN glecd_sel_col
                        WITH  esc.ececiecle = l_ececiecle_s
                          AND esc.ececle    = l_ececle_s
                          AND esc.ecdnumlig = l_ecdnumlig_i
                          AND esc.escnumcol = l_indcol_i + 1
                        {
                          l_elmdom_ptr = ajouter_elem(l_elmdom_ptr,esc.ciecle,esc.unacle,esc.cencle);
                          l_selcnt_i++;
                        }
                      END_FOR
                        ON_ERROR
                          dberreur(ACTION_ROLLBACK_GL951_1);
                          exit(EXIT_AVEC_ERREUR);
                        END_ERROR;
                     /*
                      * Si l'usager à rentré une sélection pour cette colonne alors on crée un domaine de donné
                      * associé à cette colonne et correspondant à la sélection.
                      */
                      if (l_selcnt_i!=0) creer_domaine (l_numdomaine_i,EDOTYP_COLONNE,l_indcol_i,CONSOLIDE_OUI,l_elmdom_ptr);
                    }
                }
             /*
              * Création de la transaction principale de calcul des états financiers.
              */
              trh_gl951_3=0;

              START_TRANSACTION trh_gl951_3
                CONCURRENCY READ_ONLY WAIT
                RESERVING gletat_financier    FOR READ,
                          glefi_colonne       FOR READ,
                          glefi_detail        FOR READ,
                          gleff_ligne         FOR READ,
                          mccompte            FOR READ,
                          mcsolde_annuel      FOR READ,
                          mcsan_rest          FOR READ,
                          mccode_bilingue     FOR READ,
                          glefi_domaine       FOR READ
                ON_ERROR
                  dberreur(ACTION_FINISH);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;

             /*
              * Préparation des informations pour l'affichage du format de haut et bas de page
              */

              preparer_format("","","",l_titef_s,g_efcedule_str.peccle);

             /*
              * On appelle le calcul et impression de l'état financier demandé en lui passant
              * le grand domaine consolidé qui vient d'être déterminé.
              */
              calcul_ef ( l_eficiecle_s,          /* Compagnie de l'état financier à traiter                        */
                          l_eficle_s,             /* Numéro de l'état financier à traiter                           */
                          NOTE_NON,               /* L'état demandé n'est pas une note                              */
                          l_titef_s,              /* Titre de l'ef                                                  */
                          l_numdomaine_i,         /* Identifiant du domaine de donnée à traiter                     */
                          g_efcedule_str.peccle,  /* Periode comptable à traiter                                    */
                          CONSOLIDE_OUI,          /* Consolidé OUI ou NON                                           */
                          l_ecdnbrcop_i,          /* Nombre de copies à imprimer                                    */
                          l_ecdflgselcol_s,       /* Flag indiquant qu'il existe une sélection par colonne          */
                          (etat_financier_ptr) 0, /* Adresse de l'E/F d'origine (Pour les notes)                    */
                          (efi_detail_strptr) 0); /* Adresse d'une structure d'une ligne de                         */
                                                  /* détail de l'EF dans laquelle se trouve les                     */
                                                  /* valeurs de retour. Ici, on donne 0 comme                       */
                                                  /* adresse car on ne dois pas récuperer de                        */
                                                  /* valeur.                                                        */
             /*
              * Fermeture de la transaction principale.
              */
              COMMIT trh_gl951_3
                ON_ERROR
                  dberreur(ACTION_FINISH);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;
            }
          l_elmdom_ptr = vide_liste(l_elmdom_ptr);
          vider_domaine(l_numdomaine_i);
        }
    }

 /*
  * Commit des transactions
  */

  COMMIT trh_gl951_1
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Fermeture du fichier d'impression.
  */

  fclose(g_ficimp_fic);

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
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  mc950(NOM_PROGRAMME,g_lngcle_c,MESSOK); /* Programme terminé avec succes. */
  exit(EXIT_SANS_ERREUR);
}

/*
** Fonction    : allouer_elem ()
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 26 Mai 1992
**
** Description : Allocation d'un élément en mémoire
**
** Paramètres d'entrée  :
**                        .Aucuns
**
** Paramètres de sortie :
**                        .Adresse de l'élément alloué
*/

element_ptr allouer_elem()
{
  return (element_ptr) malloc (sizeof(struct element_strdef));
}

/*
** Fonction    : ajouter_elem (liste_ptr,*p_ciecle_s,*p_unacle_s,*p_cencle_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 26 Mai 1992
**
** Description : Ajout d'un élément dans la liste
**
** Paramètres d'entrée  :
**                        .Pointeur sur le premier élément de la liste. 0 si
**                         la liste est vide.
**                        .*p_ciecle_s = Numéro de compagnie
**                        .*p_unacle_s = Numéro d'unité
**                        .*p_cencle_s = Numéro de centre
**
** Paramètres de sortie :
**                        .Pointeur sur la liste
*/

element_ptr ajouter_elem (p_liste_ptr,p_ciecle_s,p_unacle_s,p_cencle_s)
element_ptr   p_liste_ptr;
char        * p_ciecle_s;
char        * p_unacle_s;
char        * p_cencle_s;
{
  element_ptr l_newptrlst_ptr;
 /*
  * On rajoute toujours en tete de liste pour ne pas avoir besoin de
  * rechercher le dernier élément (ce qui permet aussi d'éviter de gérer un pointeur de queue).
  * NOTE : Si la compagnie ou l'unité ou le centre sont à blanc, on les remplace par le caractère de recherche
  *        permettant de trouver toutes les compagnies ou unités ou centres. Et les caractères "#" sont remplacés
  *        par des "?" pour faire des recherches.
  */
  l_newptrlst_ptr = allouer_elem();
  if (l_newptrlst_ptr == NULL)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,MEMINS); /* Mémoire insufisante */
      exit(EXIT_AVEC_ERREUR);
    };

  if (!est_vide(p_ciecle_s))
    strcpy(l_newptrlst_ptr->ciecle,strreplc(p_ciecle_s,WILDCARD_DIESE,WILDCARD_PINTERRO));
  else
    strcpy(l_newptrlst_ptr->ciecle,WILDCARD_ALL);

  if (!est_vide(p_unacle_s))
    strcpy(l_newptrlst_ptr->unacle,strreplc(p_unacle_s,WILDCARD_DIESE,WILDCARD_PINTERRO));
  else
    strcpy(l_newptrlst_ptr->unacle,WILDCARD_ALL);

  if (!est_vide(p_cencle_s))
    strcpy(l_newptrlst_ptr->cencle,strreplc(p_cencle_s,WILDCARD_DIESE,WILDCARD_PINTERRO));
  else
    strcpy(l_newptrlst_ptr->cencle,WILDCARD_ALL);

  l_newptrlst_ptr->element_suivant = p_liste_ptr;
  return (l_newptrlst_ptr);
}

/*
** Fonction    : strreplc (p_string_s,p_chrold_c,p_chrnew_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 19 Mars 1993
**
** Description : Remplacer tous les caractère de la chaine p_string_s qui sont
**               identiques à p_chrold_c par le caractère p_chrnew_c.
**
** Paramètres d'entrée  :
**                        .Adresse de la chaine à inspecter
**                        .Caractère à rechercher
**                        .Caractère de remplacement.
**
** Paramètres de sortie :
**                        .Adresse de la chaine traitée
*/

char * strreplc (p_string_s,p_chrold_c,p_chrnew_c)
char  * p_string_s;
char    p_chrold_c;
char    p_chrnew_c;
{
  int i;

  for (i=0;p_string_s[i];i++)
    {
      if (p_string_s[i]==p_chrold_c)
        p_string_s[i]=p_chrnew_c;
    }
  return (p_string_s);
}

/*
** Fonction    : element_suivant (liste_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 26 Mai 1992
**
** Description : Lire séquentiellement tous les éléments de la liste
**
** Paramètres d'entrée  :
**                        .Pointeur sur l'élément à lire
**
** Paramètres de sortie :
**                        .Adresse de l'élément suivant
*/

element_ptr element_suivant(p_liste_ptr)
element_ptr   p_liste_ptr;
{
  if (p_liste_ptr != 0)
      return(p_liste_ptr->element_suivant);
  else
      return(0);
}

/*
** Fonction    : vide_liste (p_liste_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 26 Mai 1992
**
** Description : Libération de la mémoire utilisée par la liste
**
** Paramètres d'entrée  :
**                        .Pointeur sur le premier élément de la liste
**
** Paramètres de sortie :
**                        .pointeur valant 0
*/

element_ptr vide_liste (p_liste_ptr)
element_ptr   p_liste_ptr;
{
  element_ptr l_tmpptr_ptr;
  element_ptr l_ptrlst_ptr;

 /*
  * Si le pointeur de tête (p_liste_ptr) est null, c'est que la liste est vide
  * Sinon, depuis le premier élément de la liste, jusqu'au dernier, on libere
  * l'espace mémoire de chaque élément.
  */

  if (p_liste_ptr != NULL)
    {
      l_ptrlst_ptr = p_liste_ptr;
      do  {
            l_tmpptr_ptr = l_ptrlst_ptr->element_suivant;
            free((element_ptr) l_ptrlst_ptr);
            l_ptrlst_ptr = l_tmpptr_ptr;
          } while (l_ptrlst_ptr != NULL);
    }
  return ((element_ptr) NULL);
}

/*
** Fonction    : numero_domaine ()
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 19 Mars 1993
**
** Description : Réservation d'un numéro de domaine dans la base de donnée
**
** Paramètres d'entrée  :
**               .Aucuns
**
** Paramètres de sortie :
**               .Entier identifiant le domaine créé, ou 0 pour indiquer une erreur
*/

int numero_domaine()
{
  int l_efq_trouve_f;                   /* Flag indiquant qu'il existe un numéro séquentiel                     */
  int l_num_domaine_i;                  /* numéro du domaine qui a été généré.                                  */

 /*
  * On se réserve un numéro de domaine dans la relation GLEFI_SEQ. Si
  * l'occurence de GLEFI_SEQ n'existe pas encore, on la crée.
  */

  l_num_domaine_i = 0;

  trh_gl951_2=0;

  START_TRANSACTION trh_gl951_2
    CONCURRENCY READ_WRITE WAIT
    RESERVING glefi_seq FOR WRITE
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  SET_FALSE(l_efq_trouve_f);

  FOR (TRANSACTION_HANDLE trh_gl951_2)
    FIRST 1 efq IN glefi_seq
    {
      SET_TRUE(l_efq_trouve_f);
      l_num_domaine_i = efq.efqnumseq + 1;
      MODIFY efq USING
        efq.efqnumseq = l_num_domaine_i;
      END_MODIFY
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_2);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_2);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  if (!l_efq_trouve_f)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,CREEFQ); /* Création du nunméro séqentiel pour les EF */
      STORE (TRANSACTION_HANDLE trh_gl951_2)
        efq_1 IN glefi_seq USING
        {
          efq_1.efqnumseq = 1;
        }
      END_STORE
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_2);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
      l_num_domaine_i = 1;
    }

  COMMIT trh_gl951_2
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  return(l_num_domaine_i);
}

/*
** Fonction    : creer_domaine (p_numero_domaine_i,p_edotyp_s,p_indcol_i,p_consolide_f,p_liste_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 28 Mai 1992
**
** Description : Création d'un domaine de donnée à partir de la liste des données sélectionnées par l'usager.
**               Si l'état financier doit être consolidé alors, on ajoute aussi toutes les filialles des
**               compagnies sélectionnées.
**
** Paramètres d'entrée  :
**               .Numéro du domaine à créer
**               .Type de domaine (Global ou pour une Colonne)
**               .Numéro de colonne pour un domaine par colonne
**               .Flag indiquant si l'état financier doit être consolidé
**               .Pointeur sur le premier élément de la liste
**
** Paramètres de sortie :
**               .Entier identifiant le domaine créé, ou 0 pour indiquer
**                qu'il n'y a aucun domaine concerné par cette selection.
*/

int creer_domaine(p_numero_domaine_i,p_edotyp_s,p_indcol_i,p_consolide_f,p_liste_ptr)
int           p_numero_domaine_i;
char        * p_edotyp_s;
int           p_indcol_i;
char        * p_consolide_f;
element_ptr   p_liste_ptr;
{
  int l_dom_trouve_f;                   /* Flag indiquant qu'il existe un domaine correspondant à la sélection    */
  int l_domexidej_f;                    /* Flag indiquant qu'il existe déja un triplet semblable dans le domaine  */
  int l_selcnt_i;                       /* Nombre d'occurences de sélection créé dans le domaine                  */

  element_ptr   l_element_suivant_ptr;  /* Pointeur sur l'élément suivant dans la liste                           */

 /*
  * Si le pointeur est nul c'est que la liste est vide. Dans ce cas on retourne
  * un domaine vide.
  */

  if (p_liste_ptr == 0)
    return(0);

  trh_gl951_2=0;

  START_TRANSACTION trh_gl951_2
    CONCURRENCY READ_WRITE WAIT
    RESERVING glefi_domaine     FOR WRITE,
              vsec_usr          FOR READ, /* Attention : Vue logique */
              mccompagnie       FOR READ,
              mcunite_adm       FOR READ
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Si le domaine demandé est un domaine "Non consolidé" alors :
  *  Pour chaque élément contenu dans la liste :
  *       On extrait la compagnie demandée de la base,
  *                   avec le(s) centre(s) demandé (si le holding à une notion de centre)
  *                et avec l'unité ou les unités demandé.
  *       Pour chaque triplet obtenu (cie/una/cen)
  *                on regarde s'il existe déja dans le domaine.
  *                S'il n'y est pas encore, on le rajoute au domaine.
  *
  * Mais s'il est "Consolidé" alors :
  *  Pour chaque élément contenu dans la liste :
  *       On extrait la compagnie demandée de la base, ET TOUTES SES FILIALLES (grace au numéro de nomenclature)
  *                   avec le(s) centre(s) demandé (si le holding à une notion de centre)
  *                et avec l'unité ou les unités demandé.
  *       Pour chaque triplet obtenu (cie/una/cen)
  *                on regarde s'il existe déja dans le domaine.
  *                S'il n'y est pas encore, on le rajoute au domaine.
  *
  * Note : Pour la gestion de la sécurité, on utilise la vue VSEC_USR qui nous renvoie
  *        les compagnies accessibles par l'utilisateur qui a lancé le programme.
  * Note : Dans la deuxiemme partie ( lors du consolidé ) on doit retrouver toutes les
  *        filialles d'une compagnie. On peut les retrouver grâce au numéro de nomenclature.
  *        Mais comme les données sont stockés en CHAR dans la base et non en VARYING,
  *        celle-ci rajoute des blancs à la fin de chaque zone. De ce fait, si on veut
  *        retrouver toutes les compagnies dont la nomenclature commence par "1" sans
  *        utiliser de traitement particulier en C, on ne peut pas utiliser la clause
  *        STARTING WITH. Car Starbase chercherais tout ce qui commence par "1      "
  *        (avec les blancs). C'est pour cela que ici, on indique à la base que le
  *        caractere blanc est un wildcard qui remplace tous les caractères.
  */

  l_element_suivant_ptr = p_liste_ptr;
  SET_FALSE(l_dom_trouve_f);

  if (strcmp(p_consolide_f,CONSOLIDE_NON)==0)
    {
      do
        {
          FOR (TRANSACTION_HANDLE trh_gl951_2)
                  vsec  IN vsec_usr
            CROSS cie   IN mccompagnie
            CROSS una   IN mcunite_adm
            WITH    vsec.ciecle MATCHING  l_element_suivant_ptr->ciecle
                AND cie.ciecle  =         vsec.ciecle
                AND una.ciecle  =         vsec.ciecle
                AND una.unacle  MATCHING  l_element_suivant_ptr->unacle
                AND una.cencle  MATCHING  l_element_suivant_ptr->cencle
            REDUCED TO vsec.ciecle,una.unacle,una.cencle
            {
              SET_TRUE(l_dom_trouve_f);
             /*
              * On ne doit pas retrouver plusieurs fois le même triplet (Cie/Una/Cen) dans le même
              * domaine. Donc avant de l'ajouter on vérifie s'il n'existe pas déja.
              * Note : Avoir plusieurs fois le même triplet dans un domaine à pour effet de
              * multiplier les résultats autant de fois que l'on retrouve un triplet identique !.
              */
              SET_FALSE(l_domexidej_f);
              FOR (TRANSACTION_HANDLE trh_gl951_2)
                FIRST 1 edo IN glefi_domaine
                WITH    edo.edonumseq = p_numero_domaine_i
                    AND edo.edotyp    = p_edotyp_s
                    AND edo.edonumcol = p_indcol_i
                    AND edo.ciecle    = vsec.ciecle
                    AND edo.unacle    = una.unacle
                    AND edo.cencle    = una.cencle
                {
                  SET_TRUE(l_domexidej_f);
                }
              END_FOR
                ON_ERROR
                  dberreur(ACTION_ROLLBACK_GL951_2);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;

              if (!l_domexidej_f)
                {
                 /*
                  * On complète le domaine avec le triplet (cie/una/cen)
                  * trouvé.
                  */
                  STORE (TRANSACTION_HANDLE trh_gl951_2)
                    edo_1 IN glefi_domaine USING
                    {
                      edo_1.edonumseq = p_numero_domaine_i;
                      strcpy(edo_1.edotyp,p_edotyp_s);
                      edo_1.edonumcol = p_indcol_i;
                      strcpy(edo_1.cienmc,cie.cienmc);
                      strcpy(edo_1.ciecle,vsec.ciecle);
                      strcpy(edo_1.unacle,una.unacle);
                      strcpy(edo_1.cencle,una.cencle);
                    }
                  END_STORE
                    ON_ERROR
                      dberreur(ACTION_ROLLBACK_GL951_2);
                      exit(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_2);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
         /*
          * On va chercher l'élément suivant dans la liste
          */
          l_element_suivant_ptr = element_suivant (l_element_suivant_ptr);

        } while (l_element_suivant_ptr != 0);
    }
  else
    {
     /*
      * On effectue une recherche CONSOLIDE
      */
      do
        {
          FOR (TRANSACTION_HANDLE trh_gl951_2)
                  cie   IN mccompagnie
            CROSS cie_1 IN mccompagnie
            CROSS vsec  IN vsec_usr
            CROSS una   IN mcunite_adm
            WITH    cie.ciecle    MATCHING  l_element_suivant_ptr->ciecle
                AND cie_1.cienmc  MATCHING  cie.cienmc USING WILDCARD_CIENMC
                AND vsec.ciecle   =         cie_1.ciecle
                AND una.ciecle    =         vsec.ciecle
                AND una.unacle    MATCHING  l_element_suivant_ptr->unacle
                AND una.cencle    MATCHING  l_element_suivant_ptr->cencle
            REDUCED TO vsec.ciecle,una.unacle,una.cencle
            {
              SET_TRUE(l_dom_trouve_f);
             /*
              * On ne doit pas retrouver plusieurs fois le même triplet (Cie/Una/Cen) dans le même
              * domaine. Donc avant de l'ajouter on vérifie s'il n'existe pas déja.
              * Note : Avoir plusieurs fois le même triplet dans un domaine à pour effet de
              * multiplier les résultats autant de fois que l'on retrouve un triplet identique !.
              */
              SET_FALSE(l_domexidej_f);
              FOR (TRANSACTION_HANDLE trh_gl951_2)
                FIRST 1 edo IN glefi_domaine
                WITH    edo.edonumseq = p_numero_domaine_i
                    AND edo.edotyp    = p_edotyp_s
                    AND edo.edonumcol = p_indcol_i
                    AND edo.ciecle    = vsec.ciecle
                    AND edo.unacle    = una.unacle
                    AND edo.cencle    = una.cencle
                {
                  SET_TRUE(l_domexidej_f);
                }
              END_FOR
                ON_ERROR
                  dberreur(ACTION_ROLLBACK_GL951_2);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;

              if (!l_domexidej_f)
                {
                 /*
                  * On complète le domaine avec le triplet (cie/una/cen)
                  * trouvé.
                  */
                  STORE (TRANSACTION_HANDLE trh_gl951_2)
                    edo_2 IN glefi_domaine USING
                    {
                      edo_2.edonumseq = p_numero_domaine_i;
                      strcpy(edo_2.edotyp,p_edotyp_s);
                      edo_2.edonumcol = p_indcol_i;
                      strcpy(edo_2.cienmc,cie_1.cienmc);
                      strcpy(edo_2.ciecle,vsec.ciecle);
                      strcpy(edo_2.unacle,una.unacle);
                      strcpy(edo_2.cencle,una.cencle);
                    }
                  END_STORE
                    ON_ERROR
                      dberreur(ACTION_ROLLBACK_GL951_2);
                      exit(EXIT_AVEC_ERREUR);
                    END_ERROR;
                }
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_2);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
         /*
          * On va chercher l'élément suivant dans la liste
          */
          l_element_suivant_ptr = element_suivant (l_element_suivant_ptr);

        } while (l_element_suivant_ptr != 0);
    }

  COMMIT trh_gl951_2
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Si aucun domaine ne correspond à la sélection de l'usager on renvoie 0 pour indiquer l'erreur
  */

  if (!l_dom_trouve_f)
    return (0);
  else
    return(p_numero_domaine_i);
}

/*
** Fonction    : vider_domaine (p_numero_domaine_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 28 Mai 1992
**
** Description : suppression d'un domaine de donnée
**
** Paramètres d'entrée  :
**               .Numéro du domaine à supprimer
**
** Paramètres de sortie :
**               .Aucun
*/

void vider_domaine(p_numero_domaine_i)
int   p_numero_domaine_i;
{
  trh_gl951_2=0;

  START_TRANSACTION trh_gl951_2
    CONCURRENCY READ_WRITE WAIT
    RESERVING glefi_domaine     FOR WRITE
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  FOR (TRANSACTION_HANDLE trh_gl951_2)
    edo IN glefi_domaine
    WITH edo.edonumseq = p_numero_domaine_i
    {
      ERASE edo
      ON_ERROR
        dberreur(ACTION_ROLLBACK_GL951_2);
        exit(EXIT_AVEC_ERREUR);
      END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_2);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  COMMIT trh_gl951_2
    ON_ERROR
      dberreur(ACTION_FINISH);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;
}

/*
** Fonction    : preparer_format(p_ciecles,p_unacle_s,p_cencle_s,p_titef_s,p_peccle_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Récupération des titres et désignations pour préparer le format d'impression
**
** Paramètres d'entrée  :
**               .Numéro de compagnie
**               .Numéro d'unité
**               .Numéro de centre
**               .Titre de l'ef provenant de la cédule
**               .Période comptable demandée
**
** Paramètres de sortie :
**               .Aucun
*/

void preparer_format(p_ciecle_s,p_unacle_s,p_cencle_s,p_titef_s,p_peccle_s)
char  * p_ciecle_s;
char  * p_unacle_s;
char  * p_cencle_s;
char  * p_titef_s;
char  * p_peccle_s;
{
 /*
  * Déclaration des variables locales
  */

  int         l_periode_trouve_f; /* Flag indiquant si la période demandée existe */
  time_t      l_time_t;           /* Date et heure d'exécution (en binaire)       */
  struct tm * l_time_str;         /* Date et heure d'exécution décodée            */
 /*
  * Récupération de la compagnie
  */
  if (est_vide(p_ciecle_s))
    {
      if (g_efcedule_str.ecelng[0] == FRA)
        strcpy(g_efiformvalu_str.cienom,"Toutes les compagnies");
      else
        strcpy(g_efiformvalu_str.cienom,"All %%% ANG %%%");
    }
  else
    {
      if (strchr(p_ciecle_s,'*')!=NULL)
        {
          if (g_efcedule_str.ecelng[0] == FRA)
            strcpy(g_efiformvalu_str.cienom,"Toutes les compagnies");
          else
            strcpy(g_efiformvalu_str.cienom,"All %%% ANG %%%");
        }
      else
        {
          FOR (TRANSACTION_HANDLE trh_gl951_1)
            FIRST 1 cie IN mccompagnie
            WITH  cie.ciecle  = p_ciecle_s
            {
              strcpy(g_efiformvalu_str.cienom,cie.cienom);
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_1);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
    }
 /*
  * Récupération de l'unité
  */
  if (est_vide(p_unacle_s))
    {
      if (g_efcedule_str.ecelng[0] == FRA)
        strcpy(g_efiformvalu_str.unanom,"Toutes les unités");
      else
        strcpy(g_efiformvalu_str.unanom,"All %%% ANG %%%");
    }
  else
    {
      if (strchr(p_unacle_s,'*')!=NULL)
        {
          if (g_efcedule_str.ecelng[0] == FRA)
            strcpy(g_efiformvalu_str.unanom,"Toutes les unités");
          else
            strcpy(g_efiformvalu_str.unanom,"All %%% ANG %%%");
        }
      else
        {
          FOR (TRANSACTION_HANDLE trh_gl951_1)
            FIRST 1 una IN mcunite_adm
            WITH  una.unacle = p_unacle_s
            {
              strcpy(g_efiformvalu_str.unanom,una.unanom);
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_1);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
    }
 /*
  * Récupération du centre
  */
  if (est_vide(p_cencle_s))
    {
      if (g_efcedule_str.ecelng[0] == FRA)
        strcpy(g_efiformvalu_str.cennom,"Tous les centres");
      else
        strcpy(g_efiformvalu_str.cennom,"All %%% ANG %%%");
    }
  else
    {
      if (strchr(p_cencle_s,'*')!=NULL)
        {
          if (g_efcedule_str.ecelng[0] == FRA)
            strcpy(g_efiformvalu_str.cennom,"Tous les centres");
          else
            strcpy(g_efiformvalu_str.cennom,"All %%% ANG %%%");
        }
      else
        {
          FOR (TRANSACTION_HANDLE trh_gl951_1)
            FIRST 1 cen IN mccentre
            WITH  cen.cencle = p_cencle_s
            {
              strcpy(g_efiformvalu_str.cennom,cen.cennom);
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_1);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
    }
 /*
  * Titre de l'ef
  */
  strcpy(g_efiformvalu_str.titre,p_titef_s);

 /*
  * Récupération des dates de début et de fin de la période comptable pour generer un titre de périodicité par défaut
  */

  SET_FALSE(l_periode_trouve_f);
  FOR (TRANSACTION_HANDLE trh_gl951_1)
    pec IN mcperiode_ctb
    WITH  pec.peccle = p_peccle_s
    {
      SET_TRUE(l_periode_trouve_f);
#if UNIX
      gds__decode_date (&pec.pecdatdeb,&g_time_str);
#else
      gds_$decode_date (&pec.pecdatdeb,&g_time_str);
#endif
      sprintf (g_efiformvalu_str.pecdatdeb,"%2d-%02d-%02d",g_time_str.tm_mday,g_time_str.tm_mon+1,g_time_str.tm_year);
/*      strftime(g_efiformvalu_str.pecdatdeb,(size_t) FORMAT_DATE_LONG,FORMAT_DATE,g_time_str);*/
#if UNIX
      gds__decode_date (&pec.pecdatfin,&g_time_str);
#else
      gds_$decode_date (&pec.pecdatfin,&g_time_str);
#endif
      sprintf (g_efiformvalu_str.pecdatfin,"%2d-%02d-%02d",g_time_str.tm_mday,g_time_str.tm_mon+1,g_time_str.tm_year);
/*      strftime(g_efiformvalu_str.pecdatfin,(size_t) FORMAT_DATE_LONG,FORMAT_DATE,g_time_str);*/
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_1);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

  if(!l_periode_trouve_f)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,PECCLEINV); /* Période comptable inconnue */
      exit(EXIT_AVEC_ERREUR);
    }

 /*
  * On récupere la date et l'heure du jour
  */

  time (&l_time_t);
  l_time_str = (struct tm *) localtime(&l_time_t);
  sprintf (g_efiformvalu_str.date,"%2d-%02d-%02d",l_time_str->tm_mday,l_time_str->tm_mon+1,l_time_str->tm_year);
  sprintf (g_efiformvalu_str.heure,"%02d:%02d",l_time_str->tm_hour,l_time_str->tm_min);
/*  strftime(g_efiformvalu_str.date,(size_t) FORMAT_DATE_LONG,FORMAT_DATE,l_time_str);
  strftime(g_efiformvalu_str.heure,(size_t) FORMAT_HRE_LONG,FORMAT_HRE,l_time_str);*/
}

/*
** Fonction    : calcul_ef (p_eficiecle_s,p_eficle_s,p_efityp_c,p_titef_s,p_numero_domaine_i,p_peccle_s,
**                          p_consolide_s,p_ecdnbrcop_i,p_ecdflgselcol_s,p_etafinorg_ptr,p_efidet_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 juin 1992
**
** Description : Calcul d'un état financier. On prépare la structure de l'état financier en la lisant depuis la base
**               pour la mettre dans une structure en mémoire. Puis on parcours toutes les lignes de détail de cet EF.
**               la ligne lue contient un compte, on calcul le solde de ce compte pour chaque colonne. Si la ligne est
**               une note, on réappelle le traitement d'un etat financier pour la calculer. Puis quand toutes les données
**               ont étées chargées en mémoire, on peut calculer les résultats qui portent sur l'ensemble de l'état financier
**               A savoir : les jumelés, écarts, balances, ratios, et totaux.
**
** Paramètres d'entrée  :
**              .Compagnie de l'état financier demandé
**              .Numéro de l'état financier demandé
**              .Note ou ef normal ?
**              .Titre de l'ef donné par l'usagé dans la cédule
**              .Identifiant du domaine de donnée
**              .Periode comptable
**              .Consolidé oui ou non ?
**              .Nombre de copies à imprimer
**              .Flag indiquant qu'il existe une sélection de données par colonne
**              .Pointeur sur l'état financier d'origine (pour les notes)
**              .Pointeur sur la ligne de détail qui reçoit le résultat (Pour les notes)
**
** Paramètres de sortie :
**              .Aucun
**
** Modifications........:
**
**                      .Le 18 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Modification du calcul des ratios.
*/

void calcul_ef (p_eficiecle_s,p_eficle_s,p_efityp_c,p_titef_s,p_numero_domaine_i,p_peccle_s,
           p_consolide_s,p_ecdnbrcop_i,p_ecdflgselcol_s,p_etafinorg_ptr,p_efidet_ptr)
char                              * p_eficiecle_s;
char                              * p_eficle_s;
char                                p_efityp_c;
char                              * p_titef_s;
int                                 p_numero_domaine_i;
char                              * p_peccle_s;
char                              * p_consolide_s;
BASED ON glece_detail.ecdnbrcop     p_ecdnbrcop_i;    /* Nombre de copies à imprimer                                    */
char                              * p_ecdflgselcol_s;
etat_financier_ptr                  p_etafinorg_ptr;
efi_detail_strptr                   p_efidet_ptr;
{
 /*
  * Déclaration des variables locales
  */

  etat_financier_ptr    l_etafin_ptr;       /* Pointeur sur la structure de l'entete de l'EF                  */
  efi_detail_strptr     l_efidet_ptr;       /* Pointeur sur le tableau des lignes de détail                   */

  int                   l_efi_valide_f;     /* Flag indiquant que le détail de l'ef est valide                */
  int                   l_col_prec_trouve_f;/* Flag indiquant que la colonne précédente à été trouvée         */

  int                   l_indlig_i;         /* Indice de la ligne en cours de traitement                      */
  int                   l_indlig_ref_i;     /* Indice de la ligne de référence                                */
  int                   l_indlig_tmp_i;     /* Indice de position dans le détail de l'EF (indice temporaire)  */
  int                   l_indlig_refbal1_i; /* Indice de la premiere ligne de référence de la balance         */
  int                   l_indlig_refbal2_i; /* Indice de la deuxiemme ligne de référence de la balance        */
  int                   l_indcol_i;         /* Indice de la colonne en cours de traitement                    */
  int                   l_indcol_prec_i;    /* indice des colonnes précédentes (pour le calcul des ratios)    */
  int                   l_indcol_borne_i;   /* indice de la colonne qui contient un ratio                     */
  int                   l_indniv_i;         /* Indice du niveau de totalisation en cours de traitement        */

  double                l_difsld_d;         /* Difference des soldes entre le jumelé et sa ligne de référence */

 /*
  * On demande la préparation de l'état financier demandé. C'est à dire la lecture de la base pour stocker en mémoire
  * la description de l'état. Ainsi que le traitement et la recherche d'informations connexe comme les type de compte et
  * leur description. Ici, les pointeurs recoivent l'adresse à laquelle ont été placés les structures dans la mémoire.
  */

  l_efi_valide_f = preparer_ef(p_eficiecle_s,p_eficle_s,p_efityp_c,&l_etafin_ptr,&l_efidet_ptr,p_etafinorg_ptr);
  if (!l_efi_valide_f)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,EFIINV); /* Etat financier inconnu ou invalide : */
      fprintf(stderr,"%s %s\n",p_eficiecle_s,p_eficle_s);
      return;
    }

 /*
  *--------------------------------------------------------------------------------------------------------------------------------
  * CALCUL DES RÉSULTATS DE CHAQUE LIGNE (SAUF TOT,ECART,RATIO...)
  *--------------------------------------------------------------------------------------------------------------------------------
  * Puis on parcours le détail de l'état pour calculer les résultats de chaque lignes. Ici on ne calcule que les ligne
  * de type CPT,SDEB,SFIN,JUM et les lignes de type NOTE. Pour les NOTE, on rappèle le traitement d'un ef en lui passant
  * l'adresse du détail de l'ef en cours pour que le traitement de la note y dépose ses résultats. Pour les autre types
  * on appele la fonction calcule_ligne qui va rechercher les soldes du compte demandé et va calculer le résultat de
  * chaque colonne ( sauf les colonnes ecarts,ratios...).
  */

  for (l_indlig_i = 0 ; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
    {
      if (   strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_CPT ) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SDEB) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SFIN) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_JUM ) ==0)
        {
          calcul_ligne(l_etafin_ptr,&l_efidet_ptr[l_indlig_i],p_numero_domaine_i,p_peccle_s,p_consolide_s,p_ecdflgselcol_s);
        }
      else
        {
          if (strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_NOTE)==0)
            {
              calcul_ef ( p_eficiecle_s,                    /* Compagnie de l'état financier à traiter                        */
                          l_efidet_ptr[l_indlig_i].cptcle,  /* Numéro de l'état financier à traiter                           */
                          NOTE_OUI,                         /* L'état demandé est une note                                    */
                          p_titef_s,                        /* Titre de l'ef                                                  */
                          p_numero_domaine_i,               /* Identifiant du domaine de donnée à traiter                     */
                          p_peccle_s,                       /* Periode comptable à traiter                                    */
                          p_consolide_s,                    /* Consolidé OUI ou NON                                           */
                          p_ecdnbrcop_i,                    /* Nombre de copies à imprimer                                    */
                          p_ecdflgselcol_s,                 /* Flag indiquant qu'il existe une sélection par colonne          */
                          l_etafin_ptr,                     /* Adresse de l'E/F d'origine (Pour les notes)                    */
                          &l_efidet_ptr[l_indlig_i]);       /* Adresse d'une structure d'une ligne de                         */
                                                            /* détail de l'EF dans laquelle se trouve les                     */
                                                            /* valeurs de retour. Comme ici, on appele une                    */
                                                            /* note, le calcul de cette note va mettre les                    */
                                                            /* résultats trouvés dans cette structure                         */
            }
        }
    }

 /*
  * Tous les détails contiennent leur résultats. On peut donc maintenant calculer les jumelés,totaux,balances,ratios...
  */

 /*
  *--------------------------------------------------------------------------------------------------------------------------------
  * CALCUL DES JUMELÉS :
  *--------------------------------------------------------------------------------------------------------------------------------
  * Les jumelés permettent d'afficher la différence positive entre deux comptes.
  * Exemple :
  *     Soit les lignes de détail d'un ef :
  *             n°lig Typ CPT   Ref       Résul Col_1   Col_2
  *               10  CPT 1000                  100$    300$
  *               15  JUM 2000  10              200$    140$
  *
  *     Le traitement des jumelés va effectuer la difference des résultats entr la ligne 15 et la ligne 10 (ligne de référence)
  *     Pour la colonne 1 on peut voir que la différence est négative (100$ - 200$ = -100$) donc on ne modifie pas cette
  *     colonne. Mais pour la colonne 2, la difference est positive (300$ - 140$ = +160$) donc on reporte cette différence
  *     dans le compte de la ligne 10 (colonne 2) et on met à 0 le compte de la ligne 15 (colonne 2). Le nouveau détail
  *     devient :
  *             n°lig Typ CPT   Ref       Résul Col_1   Col_2
  *               10  CPT 1000                  100$    160$
  *               15  JUM 2000  10              200$      0$
  */
  for (l_indlig_i = 0 ; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
    {
     /*
      * On traite toutes les lignes de type "jumelé"
      */
      if (strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_JUM)==0)
        {
         /*
          * On a trouvé une ligne à jumeler. On cherche maintenant sa ligne de référence
          */
          for ( l_indlig_ref_i = 0 ;
                   l_indlig_ref_i < l_etafin_ptr->efinbrlig
                && l_efidet_ptr[l_indlig_ref_i].efdnumlig != l_efidet_ptr[l_indlig_i].efdligref1 ;
                l_indlig_ref_i++);
          if (l_indlig_ref_i == l_etafin_ptr->efinbrlig || l_indlig_ref_i == l_indlig_i )
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,LIGREFINV); /* Ligne de référence invalide :  */
              fprintf(stderr,"%d (%s %s-%d).\n",l_efidet_ptr[l_indlig_i].efdligref1,
                                  p_eficiecle_s,p_eficle_s,l_efidet_ptr[l_indlig_i].efdnumlig);
            }
          else
            {
             /*
              * On a trouvé la ligne référencée par le jumelé. On va donc, pour chaque colonne, faire la difference
              * entre la ligne de référence et ligne du jumelé. Le solde, s'il est positif, vient remplacer celui de
              * la ligne de référence. Et le solde du jumelé est mis à 0.
              */
              for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
                {
                    l_difsld_d = l_efidet_ptr[l_indlig_ref_i].mntcol[l_indcol_i] - l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i];
                    if (l_difsld_d >0)
                      {
                        l_efidet_ptr[l_indlig_ref_i].mntcol[l_indcol_i] -= l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i];
                        l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i] = 0;
                      }
                }
            }
        }
    }

 /*
  *--------------------------------------------------------------------------------------------------------------------------------
  * CALCUL DES ÉCARTS :
  *--------------------------------------------------------------------------------------------------------------------------------
  * Avant de pouvoir calculer les écarts, il faut inspecter la définition de l'ef et completer chaque ligne avec un code
  * qui indique sa nature de compte. Toutes les lignes de type CPT,JUM,BAL,SDEB,SFIN on déja été inspectées lors de la
  * préparation de l'état financier. Les lignes de type NOTE obtiennent leur type de compte lors du calcul de la note. Il
  * ne reste plus que les lignes de type TOT à inspecter. Un total sera de type REVENU si toutes les sommes additionnées dans
  * ce total (y compris les sommes des sous-totaux) sont de type REVENU. Il sera de type DÉPENSE si toutes les sommes additionnées
  * dans ce total (y compris les sommes des sous-totaux) sont de type DÉPENSE. Dans les autres cas, ce sera un total de type MIXTE.
  */

 /*
  * On traite tous les niveaux de totalisation
  */
  for (l_indniv_i = NIVEAU_01; l_indniv_i < NBR_NIVEAUX_TOTAL ; l_indniv_i++)
    {
     /*
      * Pour chaque niveau, on parcours toutes les lignes de détail en ne sélectionnant que les lignes de type TOT dont le
      * "=" se trouve sur le niveau en cours.
      */
      for (l_indlig_i = 0 ; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
        {
          if (strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_TOT)==0 && l_efidet_ptr[l_indlig_i].colegal == l_indniv_i)
            {
             /*
              * À partir de ce sous-total, on remonte dans la définition du détail jusqu'à trouver un "=" ou le début du
              * détail ou que le flag du type de total soit à MIXTE
              */
              l_efidet_ptr[l_indlig_i].naclig = NAC_INDEFINI;
              for ( l_indlig_tmp_i = l_indlig_i -1;
                       l_indlig_tmp_i >= 0
                    && l_efidet_ptr[l_indlig_i].naclig!=NAC_MIXTE
                    && !(   l_efidet_ptr[l_indlig_tmp_i].colegal==l_indniv_i
                         && strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_TOT)==0);
                    l_indlig_tmp_i--)
                {
                 /*
                  * Si la ligne observée est de type CPT,JUM,NOTE,SDEB,SFIN ou TOT et que l'opération (+ ou -) se trouve dans
                  * le nivau en cours. Alors en fonction du type de compte trouvé on va déterminer le type de la ligne
                  * du total que l'on est en train de traiter.
                  */
                  if (  (    strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_CPT ) ==0
                          || strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_JUM ) ==0
                          || strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_NOTE) ==0
                          || strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_SDEB) ==0
                          || strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_SFIN) ==0
                          || strcmp(l_efidet_ptr[l_indlig_tmp_i].efdcod,EFDCOD_TOT ) ==0)
                      &&  l_efidet_ptr[l_indlig_tmp_i].coloper == l_indniv_i)
                    {
                      if (   l_efidet_ptr[l_indlig_tmp_i].naclig == NAC_REVENU
                          && l_efidet_ptr[l_indlig_i].naclig     == NAC_INDEFINI)
                        {
                          l_efidet_ptr[l_indlig_i].naclig = NAC_REVENU;
                          continue;
                        }
                      if (   l_efidet_ptr[l_indlig_tmp_i].naclig == NAC_DEPENSE
                          && l_efidet_ptr[l_indlig_i].naclig     == NAC_INDEFINI)
                        {
                          l_efidet_ptr[l_indlig_i].naclig = NAC_DEPENSE;
                          continue;
                        }
                      if (   (    l_efidet_ptr[l_indlig_tmp_i].naclig != NAC_DEPENSE
                               && l_efidet_ptr[l_indlig_tmp_i].naclig != NAC_REVENU)
                          || (    l_efidet_ptr[l_indlig_tmp_i].naclig == NAC_REVENU
                               && l_efidet_ptr[l_indlig_i].naclig     == NAC_DEPENSE)
                          || (    l_efidet_ptr[l_indlig_tmp_i].naclig == NAC_DEPENSE
                               && l_efidet_ptr[l_indlig_i].naclig     == NAC_REVENU))
                        {
                          l_efidet_ptr[l_indlig_i].naclig = NAC_MIXTE;
                        }
                    }
                }
            }
        }
    }

 /*
  * On peut maintenant calculer les écarts. Le principe de calcul est le suivant : Le résultat de la colonne écart est la
  * différence entre les deux colonnes qui la précède. Et le signe de ce résultat (à l'affichage) va dépendre du type de compte
  * de la ligne.
  * Exemple :
  *  A)              col_1   col_2   col_écart      Ici, on peut voir que la colonne écart est calculé avec la formule :
  *     + cpt revenu   100      50       50                                   écart = col_1 - col_2
  *     + cpt revenu   200     260      -60                      (En général la deuxiemme colonne est un budget)
  *     =   tot        300     310      -10         De plus les signes des montants affichés correspondent aux signes
  *                                                 calculé car les comptes sont des comptes de revenus. Ce qui veut dire
  *                                                 que si l'écart est positif, c'est qu'il y a plus de revenu que prévu.
  *                                                 C'est un écart FAVORABLE
  *
  *  B)              col_1   col_2   col_écart      la colonne écart est toujours calculé avec la formule :
  *     + cpt dépense  110      70      -40 ( 40)                             écart = col_1 - col_2
  *     + cpt dépense  180     210       30 (-30)   Mais cette fois-ci, les montants affichés sont l'inverse du montant calculé
  *     =   tot        290     280      -10 ( 10)   car on calcule des écarts sur des dépenses. les montants entre-parenthèses
  *                                                 sont les montants calculés. Et un écart calculé de $50 indique en fait une
  *                                                 dépense supplémentaire de $50. C'est donc un écart DÉFAVORABLE.
  *                                                 C'est pour cela que le signe est inversé.
  *
  *  C)              col_1   col_2   col_écart      Ici, lors du total général, les valeurs utilisés pour calculer le total sont
  *     + Tot revenu   300     310      -10 (-10)   les valeurs réèles. Pas les valeurs affichés. Ici, on ne peut pas modifier le
  *     - Tot dépense  290     280      -10 ( 10)   signe du total car ce total est mixte : il est composé de compte de differents
  *     =   tot         10      30      -20 (-20)   types. En fait, les modifications de signes ne se font qu'à l'affichage et ne
  *                                                 sont la que pour indiquer un écart FAVORABLE ou DÉFAVORABLE.
  */

 /*
  * On parcours toutes les lignes de l'état financier sauf les BAL,TOT et les NOTES car les écarts dans les notes sont déja
  * calculés. Les TOT et BAL sont calculés par la suite.
  */
  for (l_indlig_i = 0 ; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
    {
      if (   strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_CPT ) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_JUM ) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SDEB) ==0
          || strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SFIN) ==0)
        {
         /*
          * On parcours toutes les colonnes en recherchant les colonnes écarts. Puis on calcule la difference
          * entre les deux colonnes trouvé lors de la préparation de l'ef. Cette difference est stocké dans le
          * résultat de la colonne écart. NOTE : Le changement de signe en fonction du type de compte ne se fait
          * qu'à l'affichage.
          */
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
            {
              if (strcmp(l_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_ECAR)==0)
                {
                  l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i]
                      =   l_efidet_ptr[l_indlig_i].mntcol[l_etafin_ptr->colonne[l_indcol_i].efcecacol2]
                        - l_efidet_ptr[l_indlig_i].mntcol[l_etafin_ptr->colonne[l_indcol_i].efcecacol1];
                }
            }
        }
    }

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * Calcul des totaux et sous-totaux 1er passage.
  *---------------------------------------------------------------------------------------------------------------------------------
  */

  calcul_total (l_etafin_ptr,l_efidet_ptr);

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * CALCUL DES BALANCES.
  *---------------------------------------------------------------------------------------------------------------------------------
  * Chaque ligne de type balance contient deux numéro de ligne de référence. Pour calculer la balance on effectue, pour chaque
  * colonne, la différence entre la premiere et la deuxiemme ligne de référence
  */
  for (l_indlig_i = 0; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
    {
      if ( strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_BAL ) ==0)
        {
         /*
          * Recherche des indices des lignes de références
          */
          for ( l_indlig_refbal1_i = 0 ;
                   l_indlig_refbal1_i < l_etafin_ptr->efinbrlig
                && l_efidet_ptr[l_indlig_refbal1_i].efdnumlig != l_efidet_ptr[l_indlig_i].efdligref1 ;
                l_indlig_refbal1_i++);
          for ( l_indlig_refbal2_i = 0 ;
                   l_indlig_refbal2_i < l_etafin_ptr->efinbrlig
                && l_efidet_ptr[l_indlig_refbal2_i].efdnumlig != l_efidet_ptr[l_indlig_i].efdligref2 ;
                l_indlig_refbal2_i++);
          if (l_indlig_refbal1_i == l_etafin_ptr->efinbrlig || l_indlig_refbal2_i == l_etafin_ptr->efinbrlig)
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,LIGREFBALINV); /* Ligne de référence de balance invalide :  */
              fprintf(stderr,"%s %s-%d.\n",p_eficiecle_s,p_eficle_s,l_efidet_ptr[l_indlig_i].efdnumlig);
            }
          else
            {
             /*
              * Pour chaque colonne, on fait la difference entre la première et la deuxiemme ligne de référence
              */
              for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
                {
                  l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i] =    l_efidet_ptr[l_indlig_refbal1_i].mntcol[l_indcol_i]
                                                                  - l_efidet_ptr[l_indlig_refbal2_i].mntcol[l_indcol_i];
                }
            }
        }
    }

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * CALCUL DES TOTAUX ET SOUS-TOTAUX 2EME PASSAGE.
  *---------------------------------------------------------------------------------------------------------------------------------
  * On doit absolument calculer une deuxiemme fois les totaux car les balances se calculent à partir des totaux et modifient
  * ceux-ci.
  */

  calcul_total (l_etafin_ptr,l_efidet_ptr);

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * CALCUL RATIOS
  *---------------------------------------------------------------------------------------------------------------------------------
  * Pour chaque ligne de détail de l'ef, s'il utilise des colonnes de type ratio, l'usager doit indiquer le numéro de la ligne
  * de référence permettant de calculer le résultat du ratio. la ligne de référence, est la ligne qui va être le 100% du ratio.
  *
  * Exemple :
  *    Soit le détail d'état financier suivant : ( A,B,C sont des colonnes et les colonnes B et C sont des ratios )
  *     +---+--------+--------------+-----------+-----------+-----------+----------------------+---------------------+
  *     |Lig|        |              |     A     |     B     |     C     |   Bornes des Ratios  |  Niveau de Calcul   |
  *     +---+--------+--------------+-----------+-----------+-----------+----------------------+---------------------+
  *     | 1 |TEXT    | Revenus      |           |           |           | B        C           |   +                 |
  *     | 2 |  cpt1  |   revenu01   |   1230.00 |           |  13.56%   |          4           |   +                 |
  *     | 3 |  cpt2  |   revenu02   |   7840.00 |           |  86.43%   |          4           |   +                 |
  *     | 4 |   TOT1 |      total   |   9070.00 |           | 100.00%   |          4           |   =   +             |
  *     | 5 |        |              |           |           |           |                      |                     |
  *     | 6 |TEXT    | Dépenses     |           |           |           |                      |                     |
  *     | 7 |  cpt3  |   dépense01  |    678.00 |   7.47%   |  35.47%   | 4        9           |   +                 |
  *     | 8 |  cpt4  |   dépense02  |   1233.00 |  13.59%   |  64.52%   | 4        9           |   +                 |
  *     | 9 |   TOT2 |      total   |   1911.00 |  21.06%   | 100.00%   | 4        9           |   =   -             |
  *     |10 |        |              |           |           |           |                      |                     |
  *     |11 |   TOT3 | Profit(Perte)|   7159.00 |           |           |                      |       =   +         |
  *     +---+--------+--------------+-----------+-----------+-----------+----------------------+---------------------+
  *
  * Cet exemple montre la façon de faire pour calculer le ratio de chaque poste de dépense en fonction du total des revenus.
  * Pour calculer le ratio de chaque poste de revenus par rapport au total des revenus. Et le ratio de chaque poste de dépense
  * en fonction du total des dépenses.
  *
  * Dans cet exemple, on à défini deux colonnes de ratios : la colonne B et la colonne C. Pour ces deux colonnes, et pour
  * chaque ligne concernée on est venu indiquer la ligne de référence. Donc, ici, si on regarde les bornes des ratio, pour
  * la colonne B, on peut voir qu'il n'y a pas de ratio à calculer pour les lignes 2 à 4, et que la ligne 4 est la ligne
  * de référence pour le calcul des lignes 7 à 9. De la même façon, pour la colonne C on va calculer les ratios des lignes
  * 2 à 4 par rapport à la ligne 4, et les ratios des lignes 7 à 9 par rapport à la ligne 9.
  *
  */

 /*
  * S'il y a des ratios à calculer alors...
  */
  if (l_etafin_ptr->colrat_f)
    {
     /*
      * On parcours toutes les lignes de l'état financier
      */
      for (l_indlig_i = 0; l_indlig_i < l_etafin_ptr->efinbrlig ; l_indlig_i++)
        {
         /*
          * On parcours toutes les colonnes.
          * Note : on commence à la colonne 2 car la première colonne ne peut jamais être un ratio !.
          */
          for(l_indcol_i = COLONNE_02 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
            {
             /*
              * Si la colonne est un ratio et qu'il existe une ligne de référence pour cette ligne et cette colonne
              */
              if (      strcmp(l_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_RAT)==0
                    &&  l_efidet_ptr[l_indlig_i].efdrat[l_indcol_i] != COLONNE_RATIO_NON)
                {
                 /*
                  * On recherche l'indice de la ligne dans le détail de l'état financier avec le numéro de la ligne
                  * de référence du ratio pour cette colonne.
                  * Et on calcul le ratio
                  */
                  if ( (l_indlig_ref_i = IndiceLigne(l_efidet_ptr[l_indlig_i].efdrat[l_indcol_i],l_etafin_ptr,l_efidet_ptr)) < l_etafin_ptr->efinbrlig)
                    {
                      if ( l_efidet_ptr[l_indlig_ref_i].mntcol[l_etafin_ptr->colonne[l_indcol_i].efcratcol] != 0 )
                        {
                          l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i]
                                      = round (   (   l_efidet_ptr[l_indlig_i].mntcol[l_etafin_ptr->colonne[l_indcol_i].efcratcol]
                                                    / l_efidet_ptr[l_indlig_ref_i].mntcol[l_etafin_ptr->colonne[l_indcol_i].efcratcol]
                                                  ) * 100.00,
                                                  2);
                        }
                      else
                        {
                          l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i] = 0;
                          mc950(NOM_PROGRAMME,g_lngcle_c,DIVZERR); /* Erreur de division par zero */
                        }
                    }
                }
            }
        }
    }

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * IMPRESSION DE L'ETAT FINANCIER
  *---------------------------------------------------------------------------------------------------------------------------------
  * L'ef à été calculé. On peut donc l'imprimer si l'impression a été demandée par l'usager.
  */

  if (strcmp(l_etafin_ptr->efiflgimp,REPONSE_OUI)==0)
    imprimer_ef (l_etafin_ptr,l_efidet_ptr,p_ecdnbrcop_i);

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * RETOUR DES RÉSULTATS DE LA NOTE
  *---------------------------------------------------------------------------------------------------------------------------------
  * L'ef à été calculé. Si c'était une note, il faut renvoyer le résultat final à l'état financier appelant.
  */
  if(p_efityp_c == NOTE_OUI)
    {
     /*
      * On recherche le dernier total calculé
      */
      for ( l_indlig_i = l_etafin_ptr->efinbrlig -1 ;
            l_indlig_i >= 0 && strcmp(l_efidet_ptr[l_indlig_i].efdcod,EFDCOD_TOT)!=0;
            l_indlig_i --);
      if (l_indlig_i >= 0)
        {
          p_efidet_ptr->naclig = l_efidet_ptr[l_indlig_i].naclig;
          for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES; l_indcol_i++)
            p_efidet_ptr->mntcol[l_indcol_i] = l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i];
        }
    }

 /*
  *---------------------------------------------------------------------------------------------------------------------------------
  * MISE EN MÉMOIRE DE L'ETAT FINANCIER POUR GAGNER DE LA PERFORMANCE
  *---------------------------------------------------------------------------------------------------------------------------------
  * Si l'etat financier que l'on vient de calculer n'est pas une note. Et si on ne l'a pas déja lu de la mémoire globale,
  * alors, on enregistre sa définition complète en mémoire globale pour que le traitement suivant (s'il utilise le même état)
  * ne le re-prépare pas.
  */

  if(p_efityp_c == NOTE_NON)
    {
     /*
      * Si on a pas utilisé la définition de la mémoire globale
      */
      if (!g_glbefiuti_f)
        {
         /*
          * S'il existe déja une définition en mémoire on la libère
          */
          if (g_glbefiexi_f)
            {
              free(g_etafin_ptr->efiformat);
              free(g_etafin_ptr);
              free(g_efidet_ptr);
            }
         /*
          * Pour mettre la définition de l'ef en mémoire globale, il suffit de mettre les adresse de celle-ci dans
          * les pointeurs globaux.
          */
          g_etafin_ptr = l_etafin_ptr;
          g_efidet_ptr = l_efidet_ptr;
          SET_TRUE(g_glbefiexi_f);
        }
    }
  else
    {
     /*
      * C'est une note. On ne conserve pas sa définition en mémoire
      */
      free(l_etafin_ptr->efiformat);
      free(l_etafin_ptr);
      free(l_efidet_ptr);
    }
}

/*
** Fonction    : preparer_ef (p_eficiecle_s,p_eficle_s,p_efityp_c,p_etafin_ptr,p_efidet_ptr,p_etafinorg_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 01 juin 1992
**
** Description : Lecture de la définition de l'état financier et de son détail et préparation des tables
**               en mémoire.
**
** Paramètres d'entrée  :
**               .Compagnie de l'état financier demandé
**               .Numéro de l'état financier demandé
**               .L'état financier demandé est-il une note ? (O/N)
**               .Adresse du pointeur qui va contenir l'adresse de la structure d'entete de l'ef
**               .Adresse du pointeur qui va contenir l'adresse de la structure du détail l'ef
**               .Etat financier d'origine (pour les notes)
**
** Paramètres de sortie :
**               .Entier indiquant le status d'exécution de la fonction :
**                      1 = l'état financier existe et est valide, la structure a été créée en mémoire
**                      0 = l'état financier n'éxiste pas, ou sa structure est invalide
**
** Modifications........:
**
**                      .Le 23 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Modification de la colonne calcul : ajout des valeurs constantes
**                          - Modification du calcul des ratios
*/

int preparer_ef(p_eficiecle_s,p_eficle_s,p_efityp_c,p_etafin_ptr,p_efidet_ptr,p_etafinorg_ptr)
char                  * p_eficiecle_s;
char                  * p_eficle_s;
char                    p_efityp_c;
etat_financier_ptr    * p_etafin_ptr;
efi_detail_strptr     * p_efidet_ptr;
etat_financier_ptr      p_etafinorg_ptr;
{
 /*
  * Déclaration des variables locales
  */

  etat_financier_ptr    l_etafin_ptr;         /* Pointeur sur la structure de l'entete de l'EF                                  */
  efi_detail_strptr     l_efidet_ptr;         /* Pointeur sur le tableau des lignes de détail                                   */

  int                   l_efi_trouve_f;       /* Flag indiquant que l'etat financier demandé existe                             */
  int                   l_eficol_trouve_f;    /* Flag indiquant qu'il existe des colonnes pour cet état financier               */
  int                   l_efi_valide_f;       /* Flag indiquant que le détail de l'ef est valide                                */
  int                   l_cpt_trouve_f;       /* Flag indiquant que le compte demandé existe                                    */
  int                   l_col_prec_trouve_f;  /* Flag indiquant que les colonne de calcul des écart (ou ratio) ont été trouvés  */
  int                   l_format_trouve_f;    /* Flag indiquant que le Format demandé existe                                    */

  int                   l_indlig_i;           /* indice des lignes de l'état financier                                          */
  int                   l_indligform_i;       /* indice des lignes du format d'impression                                       */
  int                   l_indcol_i;           /* indice des colonnes de l'état financier                                        */
  int                   l_indcol_prec_i;      /* indice des colonnes précédentes de la colonne écart.                           */
  int                   l_nbrligent_i;        /* Nombre de lignes utilisées pour l'entête                                       */

  int                   l_indtok_i;           /* Indice dans le tableau de token de l'expression de la colonne calcul           */

  char                  l_lngcle_s[2];        /* Langue de l'usager                                                             */

  SET_TRUE(l_efi_valide_f);
 /*
  * S'il existe déja un EF en mémoire,si l'EF demandé n'est pas une note, et que l'EF demandé est le même que celui de la mémoire
  * Alors on utilise cet EF plutôt que de le relire depuis la base.
  */
  l_indlig_i = l_indcol_i = 0;
  if(   g_glbefiexi_f
     && p_efityp_c == NOTE_NON
     && strcmp(p_eficiecle_s,g_etafin_ptr->eficiecle)==0
     && strcmp(p_eficle_s,g_etafin_ptr->eficle)==0 )
    {
     /*
      * Avant de l'utiliser, il faut remettre les tables de calcul à 0
      */
      for (l_indlig_i = 0 ; l_indlig_i < g_etafin_ptr->efinbrlig ;  l_indlig_i ++)
        for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
          g_efidet_ptr[l_indlig_i].mntcol[l_indcol_i]=0;
     /*
      * Et on renvoi les pointeurs de la structure globale plutot que de créer une structure locale
      */
      l_etafin_ptr = g_etafin_ptr;
      l_efidet_ptr = g_efidet_ptr;
      SET_TRUE(g_glbefiuti_f);
    }
  else
    {
     /*
      * Il faut lire et préparer l'état financier demandé car soit celui-ci est une note, ou bien ce n'est pas le même qui est
      * en mémoire.
      * Pour ce faire :
      *                 .On libère l'espace mémoire inutile,
      *                 .On s'alloue de la mémoire pour la structure d'entete,
      *                 .On va lire l'entete de l'état financier depuis la base, et on récupère aussi le nombre de lignes de
      *                  détail de cet EF,
      *                 .On recopie l'entete dans la structure en mémoire,
      *                 .On s'alloue de la mémoire pour créer un tableau qui va contenir toutes les lignes de détail,
      *                 .On lit le détail depuis la base pour les mettres dans le tableau. Avec lecture du compte pour
      *                  savoir si c'est un compte de revenu ou de dépense. Et pour avoir sa description,
      *                 .Puis on parcours le tableau pour determiner le type de chaque ligne de détail (pour les écarts) :
      *                  Revenus,Dépense,Mixte.
      */

      l_etafin_ptr = malloc (sizeof( etat_financier_str));
      if (l_etafin_ptr == NULL)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,MEMINS); /* Mémoire insufisante */
          exit(EXIT_AVEC_ERREUR);
        };

      SET_FALSE(l_efi_trouve_f);
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        FIRST 1 efi IN gletat_financier
        WITH     efi.eficiecle = p_eficiecle_s
             AND efi.eficle    = p_eficle_s
        {
          SET_TRUE(l_efi_trouve_f);
         /*
          * On recopie l'entete dans la structure en mémoire
          */
          strcpy(l_etafin_ptr->eficiecle,   efi.eficiecle);
          strtrim(l_etafin_ptr->eficiecle);
          strcpy(l_etafin_ptr->eficle,      efi.eficle);
          strtrim(l_etafin_ptr->eficle);
          strcpy(l_etafin_ptr->efityp,      efi.efityp);
          strcpy(l_etafin_ptr->efiusrcre,   efi.efiusrcre);
          strcpy(l_etafin_ptr->efiimpinfsup,efi.efiimpinfsup);
          strcpy(l_etafin_ptr->efititcie,   efi.efititcie);
          strcpy(l_etafin_ptr->efititef,    efi.efititef);
          strcpy(l_etafin_ptr->efititper,   efi.efititper);
          strcpy(l_etafin_ptr->efititcom,   efi.efititcom);
          strcpy(l_etafin_ptr->efiflgimp,   efi.efiflgimp);
                 l_etafin_ptr->efinbrlig =  efi.efinbrlig;
          strcpy(l_etafin_ptr->effciecle,   efi.effciecle);
          strcpy(l_etafin_ptr->effcle,      efi.effcle);
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;

      if (!l_efi_trouve_f)
        {
         /*
          * Si l'état financier n'a pas été trouvé, on retourne à la fonction d'origine plutôt que d'arrêter tout le
          * traitement. Ceci permet de traiter quand même en partie la cédule.
          */
          mc950(NOM_PROGRAMME,g_lngcle_c,EFIINC); /* Etat financier inconnu : */
          fprintf(stderr,"%s %s\n",p_eficiecle_s,p_eficle_s);
         /*
          * On désalloue la mémoire réservée
          */
          free(l_etafin_ptr);
          return(FALSE);
        };

     /*
      * Si l'état financier en cours de préparation n'est pas une note. Alors on va chercher les définitions
      * des 16 colonnes possibles dans la base de donnée. Sinon, on recopie ces définition depuis
      * l'état financier d'origine.
      */

      if(p_efityp_c == NOTE_NON)
        {
          SET_FALSE(l_eficol_trouve_f);
          l_indcol_i = COLONNE_01;
          l_etafin_ptr->efinbrligent = 0;
          l_etafin_ptr->eficollarmax = 0;

          FOR (TRANSACTION_HANDLE trh_gl951_3)
            FIRST NBR_COLONNES efc IN glefi_colonne
            WITH     efc.eficiecle = p_eficiecle_s
                 AND efc.eficle    = p_eficle_s
            SORTED BY efc.efcnumcol
            {
              SET_TRUE(l_eficol_trouve_f);
                     l_etafin_ptr->colonne[l_indcol_i].efcnumcol = efc.efcnumcol;
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efctypcol,  efc.efctypcol);

                   if (strcmp(efc.efcanncol,ANNEE_COURANTE  )==0) l_etafin_ptr->colonne[l_indcol_i].efcanncol = ANNEE_000;
              else if (strcmp(efc.efcanncol,ANNEE_PRECEDENTE)==0) l_etafin_ptr->colonne[l_indcol_i].efcanncol = ANNEE_001;
              else                                                l_etafin_ptr->colonne[l_indcol_i].efcanncol = ANNEE_002;

                     l_etafin_ptr->colonne[l_indcol_i].efclarcol = efc.efclarcol;
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efcentcol,  efc.efcentcol);
             /*
              * Chaque entête de colonne est inpecté pour déterminer le nombre de lignes maximal que va avoir l'entête
              * des colonnes. Si un usager à entré "Période" dans l'entête d'une des colonnes, et "Cumulatif^Annuel^-----"
              * dans une autre colonne. Alors le nombre de lignes à utiliser sera de 3. Car l'entete "Cumulatif^Annuel^-----"
              * demande 2 sauts de lignes. De plus on inspecte chaque largeur de colonnes pour déterminer le nombre de
              * caractères de la colonne la plus large.
              */
              l_nbrligent_i = strtokcnt(efc.efcentcol,EFCENTCOL_SEP_LIG) + 1;
              if (l_nbrligent_i > l_etafin_ptr->efinbrligent) l_etafin_ptr->efinbrligent = l_nbrligent_i;
              l_etafin_ptr->eficollarmax = (efc.efclarcol > l_etafin_ptr->eficollarmax) ? efc.efclarcol : l_etafin_ptr->eficollarmax;

             /*
              * On ne peut pas interpreter l'expression de la colonne calcul sans faire un traitement sur cette expression.
              * Celle-ci est saisie sous forme INFIX par l'usager. C'est à dire de la façon standard pour l'ecriture d'une
              * expression : (a+b)*c. Mais pour pouvoir l'interpreter facilement, il faut d'abord la transformer en expression
              * de type POSTFIX (notation dite : "Polonaise inversée"). L'expression précédente devient en postfix : ab+c*.
              * Note : Voir la routine eval_postfix() pour voir comment est évalué cette expression.
              */

              strcpy(l_etafin_ptr->colonne[l_indcol_i].efccalcol,  efc.efccalcol);

              if (strcmp(efc.efctypcol,TYPCOL_CALC)==0)
                postfix(  efc.efccalcol,
                          l_etafin_ptr,
                          l_indcol_i);

              strcpy(l_etafin_ptr->colonne[l_indcol_i].efcimpcol,  efc.efcimpcol);

              l_indcol_i++;
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_3);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;

         /*
          * Inspection des colonnes de l'etat financier pour déterminer les colonnes utilisées pour calculer les
          * écarts.
          */
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
            {
              if (strcmp(l_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_ECAR)==0)
                {
                  SET_FALSE(l_col_prec_trouve_f);
                  for ( l_indcol_prec_i = l_indcol_i - 1;
                        l_indcol_prec_i >= COLONNE_02 && !l_col_prec_trouve_f;
                        l_indcol_prec_i--)
                    {
                      if (   !est_vide(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol)
                          && strcmp(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol,TYPCOL_ECAR)!=0)
                        {
                          SET_TRUE(l_col_prec_trouve_f);
                          l_etafin_ptr->colonne[l_indcol_i].efcecacol1 = l_indcol_prec_i;
                        }
                    }
                  if (!l_col_prec_trouve_f)
                    {
                      mc950(NOM_PROGRAMME,g_lngcle_c,COLECAINV); /* Colonne écart invalide (pas de colonnes possibles pour le calcul)*/
                      fprintf(stderr,"%d\n",l_indcol_i);
                      strcpy(l_etafin_ptr->colonne[l_indcol_i].efctypcol,"\0");
                    }
                  else
                    {
                      SET_FALSE(l_col_prec_trouve_f);
                     /*
                      * Note : il n'est pas nécéssaire ici d'initialiser l_indcol_prec_i car la précédente boucle l'a déja
                      *        fait. Sa valeur de sortie est égale à la valeur d'entrée dans cette boucle.
                      */
                      for (;l_indcol_prec_i >= COLONNE_01 && !l_col_prec_trouve_f;
                            l_indcol_prec_i --)
                        {
                          if (   !est_vide(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol)
                              && strcmp(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol,TYPCOL_ECAR)!=0)
                            {
                              SET_TRUE(l_col_prec_trouve_f);
                              l_etafin_ptr->colonne[l_indcol_i].efcecacol2 = l_indcol_prec_i;
                            }
                        }
                      if (!l_col_prec_trouve_f)
                        {
                          mc950(NOM_PROGRAMME,g_lngcle_c,COLECAINV); /* Colonne écart invalide (pas de colonnes possibles pour le calcul)*/
                          fprintf(stderr,"%d\n",l_indcol_i);
                          strcpy(l_etafin_ptr->colonne[l_indcol_i].efctypcol,"\0");
                        }
                    }
                }
            }
         /*
          * Inspection des colonnes de l'etat financier pour déterminer la colonne qui va donner le montant à utiliser
          * pour calculer le ratios.
          *
          * Principe :
          *           On parcours toutes les colonnes de l'état financier,
          *           Si on trouve une colonne ratio
          *           Alors on recherche la colonne qui précède ce ratio mais qui n'est pas non plus un ratio
          *           C'est cette colonne qui va servir de référence dans le calcul.
          */
          SET_FALSE(l_etafin_ptr->colrat_f);
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
            {
              if (strcmp(l_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_RAT)==0)
                {
                  l_etafin_ptr->colonne[l_indcol_i].efcratcol = COLONNE_RATIO_NON;
                 /*
                  * Si la colonne trouvée est un Ratio, alors on recherche la colonne précédente (non vide) à partir de laquelle on va
                  * calculer le ratio.
                  */
                  SET_FALSE(l_col_prec_trouve_f);
                  for ( l_indcol_prec_i = l_indcol_i - 1;
                        l_indcol_prec_i >= COLONNE_01 && !l_col_prec_trouve_f;
                        l_indcol_prec_i--)
                    {
                      if (   !est_vide(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol)
                          && strcmp(l_etafin_ptr->colonne[l_indcol_prec_i].efctypcol,TYPCOL_RAT)!=0)
                        {
                          SET_TRUE(l_col_prec_trouve_f);
                          l_etafin_ptr->colonne[l_indcol_i].efcratcol = l_indcol_prec_i;
                        }
                    }
                  if (!l_col_prec_trouve_f)
                    {
                      mc950(NOM_PROGRAMME,g_lngcle_c,COLRATINV); /* Colonne ratio invalide (pas de colonnes possibles pour le calcul)*/
                      fprintf(stderr,"%d\n",l_indcol_i);
                      strcpy(l_etafin_ptr->colonne[l_indcol_i].efctypcol,"\0");
                    }
                  else
                    {
                      SET_TRUE(l_etafin_ptr->colrat_f);
                    }
                }
            }
        }
      else
        {
          l_etafin_ptr->efinbrligent = p_etafinorg_ptr->efinbrligent;
          l_etafin_ptr->eficollarmax = p_etafinorg_ptr->eficollarmax;
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
            {
                     l_etafin_ptr->colonne[l_indcol_i].efcnumcol   = p_etafinorg_ptr->colonne[l_indcol_i].efcnumcol;
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efctypcol   , p_etafinorg_ptr->colonne[l_indcol_i].efctypcol);
                     l_etafin_ptr->colonne[l_indcol_i].efcanncol   = p_etafinorg_ptr->colonne[l_indcol_i].efcanncol;
                     l_etafin_ptr->colonne[l_indcol_i].efclarcol   = p_etafinorg_ptr->colonne[l_indcol_i].efclarcol;
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efcentcol   , p_etafinorg_ptr->colonne[l_indcol_i].efcentcol);
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efccalcol   , p_etafinorg_ptr->colonne[l_indcol_i].efccalcol);
                     l_etafin_ptr->colonne[l_indcol_i].calcolval_f = p_etafinorg_ptr->colonne[l_indcol_i].calcolval_f;
              if (strcmp(p_etafinorg_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_CALC) ==0)
                {
                  for (l_indtok_i = 0; l_indtok_i <= MAX_TOKEN ; l_indtok_i++)
                    {
                      l_etafin_ptr->colonne[l_indcol_i].token[l_indtok_i].typtok_c
                                    = p_etafinorg_ptr->colonne[l_indcol_i].token[l_indtok_i].typtok_c;
                      l_etafin_ptr->colonne[l_indcol_i].token[l_indtok_i].indcol_i
                                    = p_etafinorg_ptr->colonne[l_indcol_i].token[l_indtok_i].indcol_i;
                      l_etafin_ptr->colonne[l_indcol_i].token[l_indtok_i].valcst_d
                                    = p_etafinorg_ptr->colonne[l_indcol_i].token[l_indtok_i].valcst_d;
                    }
                }
              strcpy(l_etafin_ptr->colonne[l_indcol_i].efcimpcol  , p_etafinorg_ptr->colonne[l_indcol_i].efcimpcol);
                     l_etafin_ptr->colonne[l_indcol_i].efcecacol1 = p_etafinorg_ptr->colonne[l_indcol_i].efcecacol1;
                     l_etafin_ptr->colonne[l_indcol_i].efcecacol2 = p_etafinorg_ptr->colonne[l_indcol_i].efcecacol2;
                     l_etafin_ptr->colonne[l_indcol_i].efcratcol  = p_etafinorg_ptr->colonne[l_indcol_i].efcratcol;
            }
        }
     /*
      * On réserve de la mémoire pour y placer un tableau contenant toutes les lignes de détail de l'état financier
      */

      if (l_etafin_ptr->efinbrlig < 1)
        {
         /*
          * S'il n'y a pas de détail pour cet état financier on retourne à la fonction précédente in indiquant l'erreur
          */
          mc950(NOM_PROGRAMME,g_lngcle_c,PASDETEFI); /* Pas de détail dans l'état financier : */
          fprintf(stderr,"%s %s\n",p_eficiecle_s,p_eficle_s);
          return(FALSE);
        };

      l_efidet_ptr = (efi_detail_strptr) calloc(l_etafin_ptr->efinbrlig,sizeof(struct efi_detail_strdef));
      if (l_efidet_ptr == NULL)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,MEMINS); /* Mémoire insufisante */
          exit(EXIT_AVEC_ERREUR);
        };

      l_indlig_i = 0;
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        efd IN glefi_detail
        WITH     efd.eficiecle = p_eficiecle_s
             AND efd.eficle    = p_eficle_s
        SORTED BY efd.efdnumlig
        {
                  l_efidet_ptr[l_indlig_i].efdnumlig          = efd.efdnumlig;
          strcpy( l_efidet_ptr[l_indlig_i].efdcod    ,          efd.efdcod);
          strcpy( l_efidet_ptr[l_indlig_i].cptcle    ,          efd.cptcle);
          strcpy( l_efidet_ptr[l_indlig_i].ciecle    ,          efd.ciecle);
          strcpy( l_efidet_ptr[l_indlig_i].cienmc    ,          efd.cienmc);
          strcpy( l_efidet_ptr[l_indlig_i].unacle    ,          efd.unacle);
          strcpy( l_efidet_ptr[l_indlig_i].cencle    ,          efd.cencle);
          strcpy( l_efidet_ptr[l_indlig_i].efddsc    ,          efd.efddsc);
          strcpy( l_efidet_ptr[l_indlig_i].efdflgimp ,          efd.efdflgimp);
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_01] = 0;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_02] = efd.efdratb;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_03] = efd.efdratc;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_04] = efd.efdratd;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_05] = efd.efdrate;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_06] = efd.efdratf;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_07] = efd.efdratg;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_08] = efd.efdrath;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_09] = efd.efdrati;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_10] = efd.efdratj;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_11] = efd.efdratk;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_12] = efd.efdratl;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_13] = efd.efdratm;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_14] = efd.efdratn;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_15] = efd.efdrato;
                  l_efidet_ptr[l_indlig_i].efdrat[COLONNE_16] = efd.efdratp;
                  l_efidet_ptr[l_indlig_i].efdligref1         = efd.efdligref1;
                  l_efidet_ptr[l_indlig_i].efdligref2         = efd.efdligref2;

          if      (col_operation(efd.efdcol1))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_01;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol1);
                                                }
          else if (col_operation(efd.efdcol2))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_02;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol2);
                                                }
          else if (col_operation(efd.efdcol3))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_03;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol3);
                                                }
          else if (col_operation(efd.efdcol4))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_04;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol4);
                                                }
          else if (col_operation(efd.efdcol5))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_05;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol5);
                                                }
          else if (col_operation(efd.efdcol6))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_06;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol6);
                                                }
          else if (col_operation(efd.efdcol7))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_07;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol7);
                                                }
          else if (col_operation(efd.efdcol8))  {
                                                  l_efidet_ptr[l_indlig_i].coloper = NIVEAU_08;
                                                  strcpy(l_efidet_ptr[l_indlig_i].sigoper,efd.efdcol8);
                                                }

          if      (col_egal(efd.efdcol1)) l_efidet_ptr[l_indlig_i].colegal = 0;
          else if (col_egal(efd.efdcol2)) l_efidet_ptr[l_indlig_i].colegal = 1;
          else if (col_egal(efd.efdcol3)) l_efidet_ptr[l_indlig_i].colegal = 2;
          else if (col_egal(efd.efdcol4)) l_efidet_ptr[l_indlig_i].colegal = 3;
          else if (col_egal(efd.efdcol5)) l_efidet_ptr[l_indlig_i].colegal = 4;
          else if (col_egal(efd.efdcol6)) l_efidet_ptr[l_indlig_i].colegal = 5;
          else if (col_egal(efd.efdcol7)) l_efidet_ptr[l_indlig_i].colegal = 6;
          else if (col_egal(efd.efdcol8)) l_efidet_ptr[l_indlig_i].colegal = 7;

         /*
          * Si la ligne est un compte, on va chercher sa description et son type. On ne peut malheureusement
          * pas faire cette requette en même temps que la requete de recherche des lignes de détail. Car les
          * lignes ne sont pas toutes des lignes de comptes, et on ne peut pas faire de CROSS optionnel.
          */
          if (   strcmp(efd.efdcod,EFDCOD_CPT)  == 0
              || strcmp(efd.efdcod,EFDCOD_SDEB) == 0
              || strcmp(efd.efdcod,EFDCOD_SFIN) == 0
              || strcmp(efd.efdcod,EFDCOD_JUM)  == 0 )
            {
              SET_FALSE(l_cpt_trouve_f);
              FOR (TRANSACTION_HANDLE trh_gl951_3)
                FIRST 1 cpt IN mccompte
                WITH  cpt.cptcle = efd.cptcle
                {
                  SET_TRUE(l_cpt_trouve_f);
                  l_efidet_ptr[l_indlig_i].naclig = cpt.naccle;
                  if (est_vide(l_efidet_ptr[l_indlig_i].efddsc))
                    {
                      if (g_efcedule_str.ecelng[0] == FRA)
                        strcpy(l_efidet_ptr[l_indlig_i].efddsc,cpt.cptdscfra);
                      else
                        strcpy(l_efidet_ptr[l_indlig_i].efddsc,cpt.cptdscang);
                    }
                  strcpy(l_efidet_ptr[l_indlig_i].cpttyp,cpt.cpttyp);
                }
              END_FOR
                ON_ERROR
                  dberreur(ACTION_ROLLBACK_GL951_3);
                  exit(EXIT_AVEC_ERREUR);
                END_ERROR;
             /*
              * Si le compte demandé n'existe pas, on indique que la définition de l'ef est erronnée. On ne sort pas
              * tout de suite du FOR car en GDML il ne faut pas rompre une boucle FOR (pour ce faire il faudrait
              * utiliser des STREAMS).
              */
              if (!l_cpt_trouve_f)
                {
                  SET_FALSE(l_efi_valide_f);
                  mc950(NOM_PROGRAMME,g_lngcle_c,CPTINC); /* Numéro de compte inconnu : */
                  fprintf(stderr,"%s\n",efd.cptcle);
                  mc950(NOM_PROGRAMME,g_lngcle_c,DETAILINV); /* Ligne de détail invalide  */
                  fprintf(stderr," %s %s-%d.\n",p_eficiecle_s,p_eficle_s,efd.efdnumlig);
                }
            }
         /*
          * Initialisation des résultats de chaque colonne de la ligne
          */
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
            l_efidet_ptr[l_indlig_i].mntcol[l_indcol_i]=0;

         /*
          * Incrémentation du compteur de lignes.
          */
          l_indlig_i ++;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;

     /*
      * Récupération du format du haut et du bas de page de l'état financier. On commence tout-d'abord par compter le nombre de
      * lignes contenus dans ce format, puis on réserve de la mémoire pour ce nombre de lignes, et enfin, on charge le format
      * en mémoire.
      *
      * Note : Ici, on ne peut pas utiliser les possibilités du COUNT du SQL. En effet, le programme GL951 utilise plusieurs
      *        transactions differentes, et le SQL (sur  StarBase) ne reconnait que la transaction par defaut du système
      *        (gds$_trans).
      */

      SET_FALSE(l_format_trouve_f);
      l_etafin_ptr->effnbrlig = 0;
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        efl IN gleff_ligne
        WITH     efl.effciecle = l_etafin_ptr->effciecle
             AND efl.effcle    = l_etafin_ptr->effcle
        {
          SET_TRUE(l_format_trouve_f);
          l_etafin_ptr->effnbrlig++;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;

     /*
      * Si le format demandé existe, on réserve de la mémoire pour en contenir toutes ses lignes. Sinon, on indique
      * que le format demandé est inconnu.
      */

      if (!l_format_trouve_f)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,FORMINC); /* Format inconnu : */
          fprintf(stderr,"%s %s\n",l_etafin_ptr->effciecle,l_etafin_ptr->effcle);
        }
      else
        {
          l_etafin_ptr->efiformat = calloc(l_etafin_ptr->effnbrlig,sizeof(eff_ligne_str));
          if (l_etafin_ptr->efiformat == NULL)
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,MEMINS); /* Mémoire insufisante */
              exit(EXIT_AVEC_ERREUR);
            };

         /*
          * Chargement du format en mémoire
          */
          l_indligform_i = 0;
          FOR (TRANSACTION_HANDLE trh_gl951_3)
            FIRST l_etafin_ptr->effnbrlig efl IN gleff_ligne
            WITH     efl.effciecle = l_etafin_ptr->effciecle
                 AND efl.effcle    = l_etafin_ptr->effcle
            SORTED BY efl.efltypfor,
                      efl.efllignum,
                      efl.eflelenum
            {
              strcpy(l_etafin_ptr->efiformat[l_indligform_i].efltypfor,   efl.efltypfor);
              l_etafin_ptr->efiformat[l_indligform_i].efllignum         = efl.efllignum;
              l_etafin_ptr->efiformat[l_indligform_i].eflelenum         = efl.eflelenum;
              strcpy(l_etafin_ptr->efiformat[l_indligform_i].eflelecod,   efl.eflelecod);
              strcpy(l_etafin_ptr->efiformat[l_indligform_i].eflelepos,   efl.eflelepos);
              l_etafin_ptr->efiformat[l_indligform_i].eflelecol         = efl.eflelecol -1; /*le -1 est la parce que en C un tableau commence à 0 */
              strcpy(l_etafin_ptr->efiformat[l_indligform_i].eflelelab,   efl.eflelelab);
              strcpy(l_etafin_ptr->efiformat[l_indligform_i].efleletxt,   efl.efleletxt);
              l_indligform_i++;
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_3);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
     /*
      * On indique que l'état financier traité est en mémoire locale ( et non en mémoire globale )
      */
      SET_FALSE(g_glbefiuti_f);
    }
 /*
  * Préparation du titre par defaut de l'ef
  */
  if(est_vide(g_efiformvalu_str.titre))
    {
     /*
      * On va chercher le nom correspondant au code Bilingue du type d'etat financier pour génerer ce titre par defaut
      */
      l_lngcle_s[0]=g_lngcle_c;
      l_lngcle_s[1]='\0';

      FOR (TRANSACTION_HANDLE trh_gl951_3)
        cbi IN mccode_bilingue
        WITH    cbi.xelnom = XELNOM_EFITYP
            AND cbi.cbicle = l_etafin_ptr->efityp
        {
          if (g_efcedule_str.ecelng[0] == FRA)
            strcpy(g_efiformvalu_str.titre,cbi.cbidscfra);
          else
            strcpy(g_efiformvalu_str.titre,cbi.cbidscang);
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
 /*
  * Préparation de la périodicité pour l'impression si l'ef n'est pas une note
  */
  if(strcmp(l_etafin_ptr->efityp,EFITYP_BILAN)==0)
    {
      g_efiformvalu_str.periodicite[0]='\0';
      if (g_efcedule_str.ecelng[0] == FRA)
        sprintf(g_efiformvalu_str.periodicite,"Au %s",g_efiformvalu_str.pecdatfin);
      else
        sprintf(g_efiformvalu_str.periodicite,"At %s",g_efiformvalu_str.pecdatfin);
    }

  if(strcmp(l_etafin_ptr->efityp,EFITYP_RESULTAT)==0 || strcmp(l_etafin_ptr->efityp,EFITYP_AUTRE)==0)
    {
      g_efiformvalu_str.periodicite[0]='\0';
      if (g_efcedule_str.ecelng[0] == FRA)
        sprintf(g_efiformvalu_str.periodicite,"Du %s Au %s",g_efiformvalu_str.pecdatdeb,g_efiformvalu_str.pecdatfin);
      else
        sprintf(g_efiformvalu_str.periodicite,"From %s To %s",g_efiformvalu_str.pecdatdeb,g_efiformvalu_str.pecdatfin);
    }
 /*
  * Si la définition est erronnée, on renvoie 0 pour indiquer qu'il ne faut pas traiter cet état.
  * Sinon on renvoi les pointeurs des structures crées en mémoire.
  */
  if (l_efi_valide_f)
    {
      *p_etafin_ptr  = l_etafin_ptr;
      *p_efidet_ptr  = l_efidet_ptr;
      return (TRUE);
    }
  else
    return (FALSE);
}

/*
** Fonction    : postfix (p_infix_s,p_etafin_ptr,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description : Évalue l'expression contenue dans la chaine p_infix_s et la transforme en chaine POSTFIX (notation polonaise
**               inversée) pour la placer dans le tableau contenu dans la colonne.
**               Exemple : L'expression "((a+b)*c)/(d-e)" est transformée en "ab+c*de-/"
** NOTE        : Dans l'expression INFIX, les operandes doivent êtres de 1 caractère seulement et doivent appartenir à
**               l'interval : [A,P]. Et les opérateurs sont : +,-,*,/,(,). L'expression ne doit pas contenir de blancs.
**
** Paramètres d'entrée  :
**              .Adresse de la chaine INFIX
**              .Adresse de la chaine POSTFIX
**              .Longueur maximale de l'expression postfixée
**
** Paramètres de sortie :
**               .Aucun
**
** Modifications........:
**
**                      .Le 21 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Ajout de la possibilité de mettre des valeurs constantes dans la chaine infix.
**                            Ex: (a*b)/100.
**                            Ces constantes peuvent avoir des décimales et êtres signées. Elles doivent avoir le
**                            format suivant : 999 ou 999.999 ou -999 ou -999.999 (le nombre de 9 est indéterminé).
**                            Note :  Les nombres négatifs doivent êtres placés entre parenthèses : a*(-100)
*/

void postfix (p_infix_s,p_etafin_ptr,p_indcol_i)
char                * p_infix_s;
etat_financier_ptr    p_etafin_ptr;
int                   p_indcol_i;
{
  int     l_indinfx_i;    /* Position actuelle dans l'expression infix      */
  int     l_indpstfx_i;   /* Position actuelle dans l'expression postfix    */
  int     l_indcol_i;     /* Indice de la colonne à utiliser dans le calcul */
  double  l_valcst_d;     /* Valeur constante à utiliser dans le calcul     */
  int     l_typtok_c;     /* Type de token trouvé dans la chaine infix      */
  int     l_typtok1_c;    /* Type de token trouvé dans la pile              */
  char    l_symbole_c;    /* Opérateur éxtrait de la pile                   */
  char    l_operateur_c;  /* Opérateur éxtrait de la pile                   */

  g_indpile_i = -1;     /* On vide la pile  */
  l_indinfx_i = 0;
  l_indpstfx_i = 0;
  SET_TRUE(p_etafin_ptr->colonne[p_indcol_i].calcolval_f);
 /*
  * On évalue l'expression infix et on traite chaque élément (token) de cette expression
  */
  while((l_typtok_c = ChercheToken(p_infix_s,&l_indinfx_i,&l_symbole_c,&l_indcol_i,&l_valcst_d)))
    {
     /*
      * Si le token lu est une opérande, on l'enregistre dans l'expression postfixée
      */
      if(     l_typtok_c == TOKEN_COLONNE
          ||  l_typtok_c == TOKEN_CONSTANTE)
        {
         /*
          * Si l'opérande est une colonne et que celle-ci soit un ratio, alors on marque l'expression comm étant "Invalide".
          * En effet, les ratios sont calculés APRÈS la colonne calcul. Donc le résultat d'un ratio n'est pas disponible
          * lors de l'évaluation de l'expression.
          */
          if (    l_typtok_c == TOKEN_COLONNE
              &&  strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_RAT)==0)
            {
              SET_FALSE(p_etafin_ptr->colonne[p_indcol_i].calcolval_f);
              break;
            }
          else
            {
              p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = l_typtok_c;
              p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].indcol_i = l_indcol_i;
              p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].valcst_d = l_valcst_d;
              l_indpstfx_i++;
              if (l_indpstfx_i == MAX_TOKEN)
                {
                  mc950(NOM_PROGRAMME,g_lngcle_c,LONGMAXEXP); /* Expression de calcul trop grande : */
                  fprintf(stderr,"%s\n",p_infix_s);
                  p_etafin_ptr->colonne[p_indcol_i].token[0].typtok_c = TOKEN_FIN_EXPRESSION;
                }
            }
        }
      else
        {
          l_operateur_c = ' ';
         /*
          * Sinon, c'est un opérateur. Et dans ce cas, on compare l'opérateur lu avec celui qui se trouve en tête de pile.
          * Si l'opérateur qui se trouve en tête de pile a précédence envers l'opérateur lu, alors on le dépile et on le
          * rajoute à l'expression postfixée. On recommence tant que l'opérateur qui se trouve en tête de pile a précédence
          * envers l'opérateur lu.
          */
          while (pop_operateur(&l_operateur_c) && precedence(l_operateur_c,l_symbole_c))
            {
              switch (l_operateur_c)
                {
                  case '+': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_PLUS;
                            break;
                  case '-': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_MOINS;
                            break;
                  case '*': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_MULTIPLIE;
                            break;
                  case '/': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_DIVISE;
                            break;
                  case '(': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_PARENTHESE_GAUCHE;
                            break;
                  case ')': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_PARENTHESE_DROITE;
                }
              p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].indcol_i = 0;
              p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].valcst_d = 0;
              l_indpstfx_i++;
              if (l_indpstfx_i == MAX_TOKEN)
                {
                  mc950(NOM_PROGRAMME,g_lngcle_c,LONGMAXEXP); /* Expression de calcul trop grande : */
                  fprintf(stderr,"%s\n",p_infix_s);
                  p_etafin_ptr->colonne[p_indcol_i].token[0].typtok_c = TOKEN_FIN_EXPRESSION;
                }
              l_operateur_c = ' ';
            }
         /*
          * Si la pile n'est pas vide, on remet l'opérateur extrait qui n'a pas été utilisé
          */
          if ( g_indpile_i > -1 || l_operateur_c != ' ' )
            {
              push_operateur(l_operateur_c);
            }
         /*
          * On empile l'opérateur lu après avoir dépilé tous les opérateurs qui avaient précédence sur lui. On l'empile aussi
          * si la pile est vide.
          */
          if ( g_indpile_i == -1 || l_typtok_c != TOKEN_PARENTHESE_DROITE)
            {
              if (!push_operateur(l_symbole_c)) exit(EXIT_AVEC_ERREUR);
            }
          else
            {
              pop_operateur(&l_operateur_c);
            }
        }
    }
 /*
  * L'expression infix est vide. Alors on dépile tous les opérateurs restants à traiter pour les rajouter
  * dans l'expression postfix (on ne fait ce traitement que si l'expression est valide)
  */
  while(pop_operateur(&l_operateur_c) && p_etafin_ptr->colonne[p_indcol_i].calcolval_f)
    {
      switch (l_operateur_c)
        {
          case '+': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_PLUS;
                    break;
          case '-': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_MOINS;
                    break;
          case '*': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_MULTIPLIE;
                    break;
          case '/': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_SIGNE_DIVISE;
                    break;
          case '(': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_PARENTHESE_GAUCHE;
                    break;
          case ')': p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_PARENTHESE_DROITE;
        }
      p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].indcol_i = 0;
      p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].valcst_d = 0;
      l_indpstfx_i++;
      if (l_indpstfx_i == MAX_TOKEN)
        {
          mc950(NOM_PROGRAMME,g_lngcle_c,LONGMAXEXP); /* Expression de calcul trop grande : */
          fprintf(stderr,"%s\n",p_infix_s);
          p_etafin_ptr->colonne[p_indcol_i].token[0].typtok_c = TOKEN_FIN_EXPRESSION;
        }
    }

  if (p_etafin_ptr->colonne[p_indcol_i].calcolval_f)
    {
      p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c = TOKEN_FIN_EXPRESSION;
    }
  else
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,RATNONAUT); /* Vous ne pouvez pas utiliser une colonne RATIO dans une expression de calcul :*/
      fprintf(stderr,"%s\n",p_infix_s);
      p_etafin_ptr->colonne[p_indcol_i].token[0].typtok_c = TOKEN_FIN_EXPRESSION;
    }
}

/*
** Fonction    : ChercheToken(p_infix_s,p_indinfx_i,p_symbole_c,p_indcol_i,p_valcst_d)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 22 Mars 1994
**
** Description : Évalue l'expression contenue dans la chaine p_infix_s et en fait une analyse syntaxique. Cette analyse sépare
**               chaque élément de l'expression et renvoie l'élément trouvé avec son type (un seul élément à chaque appel).
**               Cette routine distingue 8 types d'éléments :
**                    .Les identifiants           = lettre identifiant une colonne de l'EF,
**                    .Les constantes             = constante numérique (ex 1234.56)
**                    .Le signe plus              = "+"
**                    .Le signe moins             = "-"
**                    .Le signe multiplier        = "*"
**                    .Le signe diviser           = "/"
**                    .Le signe parenthèse gauche = "("
**                    .Le signe parenthèse droite = ")"
**
**               Exemple d'expression : (A/B)*100
**
** Paramètres d'entrée  :
**              .Adresse de la chaine INFIX
**              .Adresse de l'entier qui contient la position du dernier élément trouvé dans l'expression
**              .Adresse du caractère dans lequel mettre l'opérateur lu
**              .Adresse de l'entier dans lequel mettre le numéro de la colonne lue
**              .Adresse du double dans lequel mettre la constante lue
**
** Paramètres de sortie :
**               .Type de token trouvé ou 0 pour indiquer la fin de l'expression
*/

char ChercheToken(p_infix_s,p_indinfx_i,p_symbole_c,p_indcol_i,p_valcst_d)
char    * p_infix_s;
int     * p_indinfx_i;
char    * p_symbole_c;
int     * p_indcol_i;
double  * p_valcst_d;
{
 /*
  * Déclaration des variables locales
  */

  int     l_indfin_i;                   /* Position du pointeur de recherche dans l'expression infix                    */
  char    l_wrkbuf_s[TAILLE_WORK_BUFF]; /* Buffer de travail local                                                      */

  *p_symbole_c = ' ';
  *p_indcol_i  = 0;
  *p_valcst_d  = 0;

 /*
  * Si le caractère pointé par p_indinfx_i est un identifiant de colonne ou un opérateur, alors on retourne cette
  * lettre ou cet opérateur  avec son type.
  * Dans le cas ou l'opérateur trouvé est un "-", alors il faut continuer l'analyse pour savoir si ce "-" est un
  * opérateur ou le signe "-" d'une constante. Ex : (-100)
  */

  if (     operand_oui(p_infix_s[*p_indinfx_i])
        || (   operateur_oui(p_infix_s[*p_indinfx_i])
            && p_infix_s[*p_indinfx_i]!= '-' ) )
    {
      *p_symbole_c = p_infix_s[*p_indinfx_i];
      switch (p_infix_s[*p_indinfx_i])
        {
          case 'A': *p_indcol_i = COLONNE_01;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'B': *p_indcol_i = COLONNE_02;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'C': *p_indcol_i = COLONNE_03;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'D': *p_indcol_i = COLONNE_04;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'E': *p_indcol_i = COLONNE_05;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'F': *p_indcol_i = COLONNE_06;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'G': *p_indcol_i = COLONNE_07;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'H': *p_indcol_i = COLONNE_08;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'I': *p_indcol_i = COLONNE_09;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'J': *p_indcol_i = COLONNE_10;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'K': *p_indcol_i = COLONNE_11;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'L': *p_indcol_i = COLONNE_12;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'M': *p_indcol_i = COLONNE_13;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'N': *p_indcol_i = COLONNE_14;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'O': *p_indcol_i = COLONNE_15;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);
          case 'P': *p_indcol_i = COLONNE_16;
                    (*p_indinfx_i)++;
                    return (TOKEN_COLONNE);

          case '+': (*p_indinfx_i)++;
                    return (TOKEN_SIGNE_PLUS);
          case '*': (*p_indinfx_i)++;
                    return (TOKEN_SIGNE_MULTIPLIE);
          case '/': (*p_indinfx_i)++;
                    return (TOKEN_SIGNE_DIVISE);
          case '(': (*p_indinfx_i)++;
                    return (TOKEN_PARENTHESE_GAUCHE);
          case ')': (*p_indinfx_i)++;
                    return (TOKEN_PARENTHESE_DROITE);

          default:  (*p_indinfx_i)++;
                    return (TOKEN_FIN_EXPRESSION);
        }
    }
  else
    {
     /*
      * Si le caractère inspecté est un chiffre, ou bien,
      * Si le - est placé en début de chaine ou s'il est précédé du signe '(', alors c'est que l'élément inspecté
      * est une valeur constante négative. Ex: "-100+A" ou "A*(-100)".
      */
      if (    (     p_infix_s[*p_indinfx_i] >= '0'
                &&  p_infix_s[*p_indinfx_i] <= '9')
          ||  (     p_infix_s[*p_indinfx_i] == '-'
                &&  *p_indinfx_i == 0  )
          ||  (     p_infix_s[*p_indinfx_i] == '-'
                &&  p_infix_s[*p_indinfx_i-1] == '('))
        {
         /*
          * On extrait la valeur constante de l'expression
          */
          for ( l_indfin_i = 0;
                    p_infix_s[*p_indinfx_i+l_indfin_i] == '-'
                ||  p_infix_s[*p_indinfx_i+l_indfin_i] == '.'
                ||  (     p_infix_s[*p_indinfx_i+l_indfin_i] >= '0'
                      &&  p_infix_s[*p_indinfx_i+l_indfin_i] <= '9' )
                &&  p_infix_s[*p_indinfx_i+l_indfin_i] != ' '
                &&  p_infix_s[*p_indinfx_i+l_indfin_i] != '\0';
                l_indfin_i++ );
          strncpy(l_wrkbuf_s,&p_infix_s[*p_indinfx_i],l_indfin_i);
          l_wrkbuf_s[l_indfin_i+1]='\0';
          if (sscanf(l_wrkbuf_s, "%lf",p_valcst_d))
            {
              *p_indinfx_i += l_indfin_i;
              return (TOKEN_CONSTANTE);
            }
          else
            {
              *p_indinfx_i += l_indfin_i;
              return (TOKEN_FIN_EXPRESSION);
            }
        }
      else
        {
         /*
          * L'élément n'est pas une valeur constante c'est donc un '-' ou une erreur de syntaxe
          */

          if ( p_infix_s[*p_indinfx_i] == '-' )
            {
              *p_symbole_c = p_infix_s[*p_indinfx_i];
              (*p_indinfx_i)++;
              return (TOKEN_SIGNE_MOINS);
            }
          else
            {
              (*p_indinfx_i)++;
              return (TOKEN_FIN_EXPRESSION);
            }
        }
    }
}

/*
** Fonction     : push_operateur(p_char_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description  : Empile l'opérateur donné en paramètre. Renvoie FALSE si la
**              : pile atteind 50 éléments
**
** Paramètres d'entrée  :
**              .Caractère à empiler
**
** Paramètres de sortie :
**               .FALSE si la pile est pleine. Sinon TRUE
*/

int push_operateur (p_char_c)
char  p_char_c;
{
  if (g_indpile_i==MAX_EXPPILE_SIZE)
    return (FALSE);
  else
    g_pile_s[++g_indpile_i] = p_char_c;
  return (TRUE);
}

/*
** Fonction     : pop_operateur(p_char_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description  : Dépile l'opérateur du dessus de la pile et le met à
**              : l'adresse donnée en parametre. Renvoie FALSE si la pile est
**              : vide.
**
** Paramètres d'entrée  :
**              .Adresse à laquelle il faut placer le caractère éxtrait de la pile
**
** Paramètres de sortie :
**               .FALSE si la pile est vide. Sinon TRUE
*/

int pop_operateur (p_char_c)
char  * p_char_c;
{
  if (g_indpile_i==-1)
    return (FALSE);
  else
    *p_char_c = g_pile_s[g_indpile_i--];
  return (TRUE);
}

/*
** Fonction     : operateur_oui(p_char_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description  : Cette fonction accepte un caractere et renvoie TRUE si
**              : ce caractere est un operateur.
**
** Paramètres d'entrée  :
**              .Caractère à inspecter
**
** Paramètres de sortie :
**               .FALSE si le caractère n'est pas un opérateur. Sinon TRUE
*/

int operateur_oui(p_char_c)
char  p_char_c;
{
  int   i;
  int   retour;

  for ( i=0 ;
        g_operateur_s[i]!=p_char_c && g_operateur_s[i]!='\0' ;
        i++);
  if (g_operateur_s[i]=='\0')
    retour = FALSE;
  else
    retour = TRUE;
  return (retour);
}

/*
** Fonction     : operand_oui(p_char_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description  : Cette fonction accepte un caractere et renvoie TRUE si
**              : ce caractere est un operand.
**
** Paramètres d'entrée  :
**              .Caractère à inspecter
**
** Paramètres de sortie :
**               .FALSE si le caractère n'est pas une opérande. Sinon TRUE
*/

int operand_oui(p_char_c)
char  p_char_c;
{
  int   i;

  for ( i=0 ;
        g_operand_s[i]!=p_char_c && g_operand_s[i]!='\0' ;
        i++);
  if (g_operand_s[i]=='\0')
    return (FALSE);
  else
    return (TRUE);
}

/*
** Fonction     : precedence(p_op1_c,p_op2_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description  : Cette fonction accepte deux opérateurs et renvoie TRUE si
**              : l'opérateur de gauche (op1) a précédence devant l'opérateur
**              : de droite (op2)
**
** Paramètres d'entrée  :
**              .Opérateur à comparer
**              .Opérateur de comparaison
**
** Paramètres de sortie :
**               .FALSE si l'opérateur à comparer n'a pas de précédence sur l'opérateur
**                de comparaison.
*/

int precedence(p_op1_c,p_op2_c)
char  p_op1_c;  /* Premier opérateur    */
char  p_op2_c;  /* deuxiemme opérateur  */
{
  int i;

  for ( i = 0 ;
        i < 36 && (p_op1_c != g_tblop_str[i].op1 || p_op2_c != g_tblop_str[i].op2 ) ;
        i++);

  if (i==36)
    return(-1);
  else
    return(g_tblop_str[i].prcd);
}

/*
** Fonction    : calcul_total (p_etafin_ptr,p_efidet_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 25 juin 1992
**
** Description : Calcul des totaux de l'état financier.
**
** Paramètres d'entrée  :
**              .Pointeur sur la structure de l'EF en mémoire
**              .Pointeur sur le détail de l'EF en mémoire
**
** Paramètres de sortie :
**               .Aucun. Les valeurs calculées sont directement placés dans les structures déja existantes en mémoire.
*/

void calcul_total (p_etafin_ptr,p_efidet_ptr)
etat_financier_ptr  p_etafin_ptr;
efi_detail_strptr   p_efidet_ptr;
{
 /*
  * Déclaration des variables locales
  */
  int   l_indlig_i; /* Indice de la ligne en cours de traitement                      */
  int   l_indcol_i; /* Indice de la colonne en cours de traitement                    */
  int   l_indniv_i; /* Indice du niveau de totalisation en cours de traitement        */

 /*
  * Remise à zéro de la table de calcul
  */
  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
    {
      for (l_indniv_i = NIVEAU_01; l_indniv_i < NBR_NIVEAUX_TOTAL ; l_indniv_i++)
        {
          g_table_calcul_d[l_indcol_i][l_indniv_i] = 0;
        }
    }

 /*
  * On parcours chaque ligne du détail de l'ef. Pour les ligne de type CPT,SDEB,SFIN,JUM,TOT,BAL on parcours chaque colonne
  * en aditionnant ou soustrayant dans le niveau demandé suivant le signe de l'opération. Pour les lignes de type TOT, on
  * aditionne ou on soustrait le montant calculé dans le niveau de totalisation avant de remettre à zéro le niveau de calcul.
  */
  for (l_indlig_i=0; l_indlig_i < p_etafin_ptr->efinbrlig ; l_indlig_i++)
    {
      if (   strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_CPT)  == 0
          || strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SDEB) == 0
          || strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_SFIN) == 0
          || strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_BAL)  == 0
          || strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_NOTE) == 0
          || strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_JUM)  == 0 )
        {
          if (strcmp(p_efidet_ptr[l_indlig_i].sigoper,SIGNE_PLUS)==0)
            {
              for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
                {
                  if (!est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol))
                      g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].coloper] += p_efidet_ptr[l_indlig_i].mntcol[l_indcol_i];
                }
            }
          else
            {
              for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
                {
                  if (!est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol))
                      g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].coloper] -= p_efidet_ptr[l_indlig_i].mntcol[l_indcol_i];
                }
            }
        }
      else
        {
          if (strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_TOT) == 0)
            {
              if (strcmp(p_efidet_ptr[l_indlig_i].sigoper,SIGNE_PLUS)==0)
                {
                  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
                    {
                      if (!est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol))
                        {
                          g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].coloper]
                              += g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal];
                          p_efidet_ptr[l_indlig_i].mntcol[l_indcol_i] =
                              g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal];
                          g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal] = 0;
                        }
                    }
                }
              else
                {
                  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i++)
                    {
                      if (!est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol))
                        {
                          g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].coloper]
                              -= g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal];
                          p_efidet_ptr[l_indlig_i].mntcol[l_indcol_i] =
                              g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal];
                          g_table_calcul_d[l_indcol_i][p_efidet_ptr[l_indlig_i].colegal] = 0;
                        }
                    }
                }
            }
        }
    }
}

/*
** Fonction    : IndiceLigne(p_efdrat_d,p_etafin_ptr,p_efidet_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 5 Avril 1994
**
** Description : Recherche de l'indice dans la table d'une ligne de l'état financier
**
** Paramètres d'entrée  :
**              .Numéro de ligne à chercher,
**              .Pointeur sur l'état financier en cours de traitement.
**              .Pointeur sur les lignes de détail de l'état financier en cours de traitement.
**
** Paramètres de sortie :
**               .Entier contenant l'indice trouvé ou le nombre de lignes de détail + 1 si la fonction ne trouve pas la ligne
*/

int IndiceLigne(p_efdrat_d,p_etafin_ptr,p_efidet_ptr)
double              p_efdrat_d;
etat_financier_ptr  p_etafin_ptr;
efi_detail_strptr   p_efidet_ptr;
{
 /*
  * Déclaration des variables locales
  */
  int   l_indlig_i;   /* Indice de la ligne en cours de traitement                      */

 /*
  * On parcourt toutes les lignes de détail de l'état financier jusqu'à trouver la ligne qui correspond au numéro
  * donné en paramètre. Et si on trouve, on renvoie l'indice de cette ligne.
  */
  for ( l_indlig_i = 0 ;
            l_indlig_i < p_etafin_ptr->efinbrlig
        &&  p_efidet_ptr[l_indlig_i].efdnumlig != p_efdrat_d;
        l_indlig_i++);
  return l_indlig_i;
}

/*
** Fonction    : calcul_ligne (p_etafin_ptr,p_efidet_ptr,p_numero_domaine_i,p_peccle_s,p_consolide_s,p_ecdflgselcol_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 juin 1992
**
** Description : Calcul d'une ligne de détail d'un état financier. On ne calcule que les lignes de type CPT,SDEB,SFIN,JUM.
**               Ce traitement consiste à calculer le solde du compte demandé pour l'année demandé et pour l'année
**               précédente. Puis de calculer, en fonction de ce solde, le résultat de chaque colonne de l'état financier
**               pour cette ligne de détail. On ne calcul pas les colonnes de type écart,ratios.
**
** Paramètres d'entrée  :
**              .Pointeur sur la structure de l'EF en mémoire
**              .Pointeur sur le détail de l'EF en mémoire
**              .Identifiant du domaine de donnée à traiter
**              .Période comptable demandée
**              .Consolidation du résultat oui ou non ?
**              .Flag indiquant s'il existe une sélection de données par colonne
**
** Paramètres de sortie :
**              .Aucun. Les valeurs calculées sont directement placés dans les structures déja existantes en mémoire.
**
** Modifications........:
**
**                      .Le 15 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Augmentation de la performance.
**                          - Ajout des colonnes P01C à P14C et T1C à T4C et S1C et S2C
**                      .Le 17 Novembre 1994 par Thomas Brenneur version V3.03.05
**                          - Les colonnes de Réel et d'engagement doivent tenir compte de la
**                            période comptable demandée lors du lancement. Si la période (Année+période) est
**                            postérieur à la période demandée, alors la colonne doit être à 0.
*/

void calcul_ligne(p_etafin_ptr,p_efidet_ptr,p_numero_domaine_i,p_peccle_s,p_consolide_s,p_ecdflgselcol_s)
etat_financier_ptr    p_etafin_ptr;
efi_detail_strptr     p_efidet_ptr;
int                   p_numero_domaine_i;
char                * p_peccle_s;
char                * p_consolide_s;
char                * p_ecdflgselcol_s;
{
 /*
  * Déclaration des variables locales
  */

  int     l_indcol_i; /* Indice de la colonne en cours de calcul                                                              */
  int     l_indper_i; /* Indice de la période en cours de calcul                                                              */
  int     l_flgsld_f; /* Flag indiquant le type du solde à prendre : 0 = Solde normal, 1 = Solde de début , 2 = Solde de fin  */
  int     l_scale_i;  /* Echelle pour l'arrondi des résultats : 1,10,100,1000,10000...                                        */

 /*
  * Calcul du solde du compte demandé. Les résultats sont placés dans la structure g_sldann_str
  */

  calcul_solde (p_etafin_ptr,p_efidet_ptr->cptcle,p_efidet_ptr->cpttyp,p_efidet_ptr->ciecle,p_efidet_ptr->cienmc,
                p_efidet_ptr->unacle,p_efidet_ptr->cencle,p_numero_domaine_i,p_consolide_s,p_ecdflgselcol_s);
 /*
  * On détermine le type de la ligne pour savoir quel solde utiliser
  */

  if ( strcmp(p_efidet_ptr->efdcod,EFDCOD_CPT)==0 || strcmp(p_efidet_ptr->efdcod,EFDCOD_JUM)==0)  l_flgsld_f = SOLDE_NORMAL;
  if ( strcmp(p_efidet_ptr->efdcod,EFDCOD_SDEB)==0 )                                              l_flgsld_f = SOLDE_DEBUT;
  if ( strcmp(p_efidet_ptr->efdcod,EFDCOD_SFIN)==0 )                                              l_flgsld_f = SOLDE_FIN;

 /*
  * Puis on calcule le résultat de cette ligne pour chaque colonne de l'état financier (sauf les écarts, ratios,calcul)
  */


 /*
  * Note : pour les colonnes P1 à P14, P1C à P14C, S1, S2, S1C, S2C, T1 à T4, T1C à T4C, on doit tenir compte de l'année
  * demandé dans la colonne ainsi que de la période comptable. Ceci veut dire que si l'usager défini un état financier
  * avec les colonnes suivantes : P11 année courante et P11 année précédente, et s'il demande de calculer l'état à la
  * période 9405, alors, la colonne P11 année courante va afficher des 0 alors que la colonne P11 année précédente va
  * afficher les résultats de la période 11 de l'année précédente.
  * Ce comportement est normal. Il faut respecter le principe comptable. En effet, comptablement, en 9405 la période
  * 9411 ne peut pas contenir d'informations alors que la période 9311 peut en contenir.
  */

  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
    {
      if (est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)) continue;

 /* Calcul                   */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_CALC) ==0)
        {
          continue;
        }

 /* Cum. réel                */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_CUM) ==0)
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                        = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                        = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                        = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Pér. courant réel        */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_PER) ==0)
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                        = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    if (g_numper_i == PERIODE_01)
                        p_efidet_ptr->mntcol[l_indcol_i]
                          = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    else
                        p_efidet_ptr->mntcol[l_indcol_i]
                          = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i - 1,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                        = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-01               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P01) ==0
          && (      g_numper_i >= PERIODE_01
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_01,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_01,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-02               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P02) ==0
          && (      g_numper_i >= PERIODE_02
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_02,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_01,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_02,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-03               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P03) ==0
          && (      g_numper_i >= PERIODE_03
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_02,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-04               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P04) ==0
          && (      g_numper_i >= PERIODE_04
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_04,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_04,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-05               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P05) ==0
          && (      g_numper_i >= PERIODE_05
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_05,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_04,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_05,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-06               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P06) ==0
          && (      g_numper_i >= PERIODE_06
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_05,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-07               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P07) ==0
          && (      g_numper_i >= PERIODE_07
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_07,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_07,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-08               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P08) ==0
          && (      g_numper_i >= PERIODE_08
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_08,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_07,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_08,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-09               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P09) ==0
          && (      g_numper_i >= PERIODE_09
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_08,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-10               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P10) ==0
          && (      g_numper_i >= PERIODE_10
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_10,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_10,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-11               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P11) ==0
          && (      g_numper_i >= PERIODE_11
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_11,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_10,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_11,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-12               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P12) ==0
          && (      g_numper_i >= PERIODE_12
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_12,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_11,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_12,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-13               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P13) ==0
          && (      g_numper_i >= PERIODE_13
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_13,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_12,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_13,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Période-14               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P14) ==0
          && (      g_numper_i >= PERIODE_14
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_14,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_13,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_14,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P01 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P01C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_01) ? g_numper_i : PERIODE_01;
                    else
                        l_indper_i = PERIODE_01;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P02 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P02C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_02) ? g_numper_i : PERIODE_02;
                    else
                        l_indper_i = PERIODE_02;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P03 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P03C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_03) ? g_numper_i : PERIODE_03;
                    else
                        l_indper_i = PERIODE_03;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P04 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P04C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_04) ? g_numper_i : PERIODE_04;
                    else
                        l_indper_i = PERIODE_04;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P05 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P05C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_05) ? g_numper_i : PERIODE_05;
                    else
                        l_indper_i = PERIODE_05;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P06 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P06C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_06) ? g_numper_i : PERIODE_06;
                    else
                        l_indper_i = PERIODE_06;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P07 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P07C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_07) ? g_numper_i : PERIODE_07;
                    else
                        l_indper_i = PERIODE_07;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P08 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P08C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_08) ? g_numper_i : PERIODE_08;
                    else
                        l_indper_i = PERIODE_08;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P09 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P09C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_09) ? g_numper_i : PERIODE_09;
                    else
                        l_indper_i = PERIODE_09;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P10 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P10C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_10) ? g_numper_i : PERIODE_10;
                    else
                        l_indper_i = PERIODE_10;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

  /* Cumulatif à P11 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P11C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_11) ? g_numper_i : PERIODE_11;
                    else
                        l_indper_i = PERIODE_11;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P12 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P12C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_12) ? g_numper_i : PERIODE_12;
                    else
                        l_indper_i = PERIODE_12;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P13 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P13C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_13) ? g_numper_i : PERIODE_13;
                    else
                        l_indper_i = PERIODE_13;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à P14 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_P14C) ==0 )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_14) ? g_numper_i : PERIODE_14;
                    else
                        l_indper_i = PERIODE_14;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Pér. bugdet-1            */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Bugdet-1, Période-01     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B101) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_01,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-02     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B102) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_02,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-03     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B103) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-04     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B104) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_04,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-05     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B105) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_05,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-06     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B106) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-07     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B107) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_07,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-08     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B108) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_08,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-09     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B109) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-10     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B110) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_10,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-11     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B111) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_11,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

/* Budget-1, période-12     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B112) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_12,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

/* Budget-1, période-13     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B113) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_13,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, période-14     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B114) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_14,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Annuel budget-1          */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1A) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_ann (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Cum. bugdet-1            */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1C) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdg_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, semestre-1     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1S1) ==0 )
        {
          for ( l_indper_i = PERIODE_01 ; l_indper_i<=PERIODE_06 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, semestre-2     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1S2) ==0 )
        {
          for ( l_indper_i = PERIODE_07 ; l_indper_i<=PERIODE_12 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, trimestre-1    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1T1) ==0 )
        {
          for ( l_indper_i = PERIODE_01 ; l_indper_i<=PERIODE_03 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, trimestre-2    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1T2) ==0 )
        {
          for ( l_indper_i = PERIODE_04 ; l_indper_i<=PERIODE_06 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, trimestre-3    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1T3) ==0 )
        {
          for ( l_indper_i = PERIODE_07 ; l_indper_i<=PERIODE_09 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-1, trimestre-4    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B1T4) ==0 )
        {
          for ( l_indper_i = PERIODE_10 ; l_indper_i<=PERIODE_12 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdg_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Pér. budget-2            */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-01     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B201) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_01,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-02     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B202) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_02,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-03     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B203) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-04     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B204) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_04,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-05     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B205) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_05,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-06     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B206) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-07     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B207) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_07,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-08     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B208) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_08,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-09     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B209) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-10     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B210) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_10,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-11     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B211) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_11,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-12     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B212) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_12,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-13     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B213) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_13,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, période-14     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B214) ==0 )
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_14,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Annuel budget-2          */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2A) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_ann (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Cum. bugdet-2            */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2C) ==0)
        {
          p_efidet_ptr->mntcol[l_indcol_i]
            = san_bdgrev_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, semestre-1     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2S1) ==0 )
        {
          for ( l_indper_i = PERIODE_01 ; l_indper_i<=PERIODE_06 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, semestre-2     */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2S2) ==0 )
        {
          for ( l_indper_i = PERIODE_07 ; l_indper_i<=PERIODE_12 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, trimestre-1    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2T1) ==0 )
        {
          for ( l_indper_i = PERIODE_01 ; l_indper_i<=PERIODE_03 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, trimestre-2    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2T2) ==0 )
        {
          for ( l_indper_i = PERIODE_04 ; l_indper_i<=PERIODE_06 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, trimestre-3    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2T3) ==0 )
        {
          for ( l_indper_i = PERIODE_07 ; l_indper_i<=PERIODE_09 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Budget-2, trimestre-4    */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_B2T4) ==0 )
        {
          for ( l_indper_i = PERIODE_10 ; l_indper_i<=PERIODE_12 ; l_indper_i++ )
            p_efidet_ptr->mntcol[l_indcol_i]
              += san_bdgrev_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
          continue;
        }

 /* Engagement               */

      if (strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_ENG) ==0)
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_eng_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv_eng (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_eng_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,g_numper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Semestre-1               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_S1) ==0
          && (      g_numper_i >= PERIODE_01
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_01 ;
                              l_indper_i<=PERIODE_06
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_06) ? g_numper_i : PERIODE_06;
                    else
                        l_indper_i = PERIODE_06;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Semestre-2               */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_S2) ==0
          && (      g_numper_i >= PERIODE_07
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_07 ;
                              l_indper_i<=PERIODE_12
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_12) ? g_numper_i : PERIODE_12;
                    else
                        l_indper_i = PERIODE_12;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à S1 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_S1C) ==0
          && (      g_numper_i >= PERIODE_01
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_06) ? g_numper_i : PERIODE_06;
                    else
                        l_indper_i = PERIODE_06;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à S2 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_S2C) ==0
          && (      g_numper_i >= PERIODE_07
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_12) ? g_numper_i : PERIODE_12;
                    else
                        l_indper_i = PERIODE_12;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Trimestre-1              */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T1) ==0
          && (      g_numper_i >= PERIODE_01
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_01 ;
                              l_indper_i<=PERIODE_03
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_03) ? g_numper_i : PERIODE_03;
                    else
                        l_indper_i = PERIODE_03;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Trimestre-2              */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T2) ==0
          && (      g_numper_i >= PERIODE_04
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_04 ;
                              l_indper_i<=PERIODE_06
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_03,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_06) ? g_numper_i : PERIODE_06;
                    else
                        l_indper_i = PERIODE_06;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Trimestre-3              */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T3) ==0
          && (      g_numper_i >= PERIODE_07
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_07 ;
                              l_indper_i<=PERIODE_09
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_06,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_09) ? g_numper_i : PERIODE_09;
                    else
                        l_indper_i = PERIODE_09;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Trimestre-4              */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T4) ==0
          && (      g_numper_i >= PERIODE_10
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_NORMAL:
                    for ( l_indper_i = PERIODE_10 ;
                              l_indper_i<=PERIODE_12
                          &&  (     l_indper_i <= g_numper_i
                                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000
                              );
                          l_indper_i++
                        )
                      p_efidet_ptr->mntcol[l_indcol_i]
                        += san_cum_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,PERIODE_09,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_12) ? g_numper_i : PERIODE_12;
                    else
                        l_indper_i = PERIODE_12;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à T1 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T1C) ==0
          && (      g_numper_i >= PERIODE_01
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_03) ? g_numper_i : PERIODE_03;
                    else
                        l_indper_i = PERIODE_03;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à T2 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T2C) ==0
          && (      g_numper_i >= PERIODE_04
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_06) ? g_numper_i : PERIODE_06;
                    else
                        l_indper_i = PERIODE_06;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à T3 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T3C) ==0
          && (      g_numper_i >= PERIODE_07
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_09) ? g_numper_i : PERIODE_09;
                    else
                        l_indper_i = PERIODE_09;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }

 /* Cumulatif à T4 */

      if (   strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_T4C) ==0
          && (      g_numper_i >= PERIODE_10
                ||  p_etafin_ptr->colonne[l_indcol_i].efcanncol != ANNEE_000 ) )
        {
          switch (l_flgsld_f)
            {
              case  SOLDE_DEBUT:
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_sld_ouv (p_etafin_ptr->colonne[l_indcol_i].efcanncol,p_ecdflgselcol_s,l_indcol_i);
                    break;
              case  SOLDE_NORMAL:
              case  SOLDE_FIN:
                    if ( p_etafin_ptr->colonne[l_indcol_i].efcanncol == ANNEE_000 )
                        l_indper_i = (g_numper_i < PERIODE_12) ? g_numper_i : PERIODE_12;
                    else
                        l_indper_i = PERIODE_12;
                    p_efidet_ptr->mntcol[l_indcol_i]
                      = san_cum_ree_n (p_etafin_ptr->colonne[l_indcol_i].efcanncol,l_indper_i,p_ecdflgselcol_s,l_indcol_i);
                    break;
            }
          continue;
        }
    }

 /*
  * On effectue l'arrondi sur le résultat de chaque colonne en fonction du paramètre de la cédule
  */

  if ( strcmp(g_efcedule_str.ececodarr,ARRONDI_NON)!=0 )
    {
           if (strcmp(g_efcedule_str.ececodarr,ARRONDI_1)==0)      l_scale_i =  0;
      else if (strcmp(g_efcedule_str.ececodarr,ARRONDI_10)==0)     l_scale_i = -1;
      else if (strcmp(g_efcedule_str.ececodarr,ARRONDI_100)==0)    l_scale_i = -2;
      else if (strcmp(g_efcedule_str.ececodarr,ARRONDI_1000)==0)   l_scale_i = -3;
      else if (strcmp(g_efcedule_str.ececodarr,ARRONDI_10000)==0)  l_scale_i = -4;

      for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
          p_efidet_ptr->mntcol[l_indcol_i] = round(p_efidet_ptr->mntcol[l_indcol_i],l_scale_i)
                                           / pow((double)10,fabs((double)l_scale_i));
    }

 /*
  * On repasse une seconde fois pour calculer les colonnes CALCUL
  */

  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
    {
      if (    strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_CALC)==0
          &&  p_etafin_ptr->colonne[l_indcol_i].calcolval_f) /* Calcul valide                  */
        {
          p_efidet_ptr->mntcol[l_indcol_i] = eval_postfix(p_etafin_ptr,l_indcol_i,p_efidet_ptr);
        }
    }
}

/*
** Fonction    : san_sld_ouv (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le solde d'ouverture de l'année demandée. Les résultats proviennent de la structure g_sldann_str
**
** Paramètres d'entrée  :
**              .Année
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**               .Double qui contient la valeur trouvée
*/

double san_sld_ouv (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ( (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)  ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sansldouv
                                                      : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sansldouv);
}

/*
** Fonction    : san_cum_n (p_efcanncol_s,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le solde de la période demandée pour l'année demandée.
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_cum_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sancumree[p_numper_i]
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sancumree[p_numper_i]);
}

/*
** Fonction    : san_cum_ree_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le solde réel à la période demandée pour l'année demandée. C'est à dire la somme du solde
**               d'ouverture plus la somme de toutes les périodes jusqu'à la période demandée (incluse).
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_cum_ree_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  double  l_total_d;  /* Cumule des valeurs                 */
  int     l_indper_i; /* Indice de la période en traitement */

  l_total_d = (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sansldouv
                                                        : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sansldouv;
  for ( l_indper_i=PERIODE_01 ; l_indper_i<=p_numper_i ; l_indper_i++)
    l_total_d += (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)  ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sancumree[l_indper_i]
                                                            : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sancumree[l_indper_i];
  return (l_total_d);
}

/*
** Fonction    : san_bdg_ann (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget annuel de l'année demandée
**
** Paramètres d'entrée  :
**              .Année
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdg_ann (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdgann
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdgann);
}

/*
** Fonction    : san_bdg_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget de la période demandée pour l'année demandée.
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdg_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdg[p_numper_i]
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdg[p_numper_i]);
}

/*
** Fonction    : san_bdg_cum_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget cumulé depuis le début de l'année jusqu'à la période demandée.
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdg_cum_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  double  l_total_d;  /* Cumule des valeurs                 */
  int     l_indper_i; /* Indice de la période en traitement */

  l_total_d = 0;

  for ( l_indper_i=PERIODE_01 ; l_indper_i<=p_numper_i ; l_indper_i++)
    l_total_d += (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)  ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdg[l_indper_i]
                                                            : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdg[l_indper_i];
  return (l_total_d);
}

/*
** Fonction    : san_bdgrev_ann (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget révisé annuel de l'année demandée
**
** Paramètres d'entrée  :
**              .Année
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdgrev_ann (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdgrevann
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdgrevann);
}

/*
** Fonction    : san_bdgrev_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget révisé de la période demandée pour l'année demandée.
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdgrev_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdgrev[p_numper_i]
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdgrev[p_numper_i]);
}

/*
** Fonction    : san_bdgrev_cum_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le budget révisé cumulé depuis le début de l'année jusqu'à la période demandée.
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_bdgrev_cum_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  double  l_total_d;  /* Cumule des valeurs                 */
  int     l_indper_i; /* Indice de la période en traitement */

  l_total_d = 0;

  for ( l_indper_i=PERIODE_01 ; l_indper_i<=p_numper_i ; l_indper_i++)
    l_total_d += (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)  ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sanbdgrev[l_indper_i]
                                                            : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sanbdgrev[l_indper_i];
  return (l_total_d);
}

/*
** Fonction    : san_sld_ouv_eng (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le solde d'ouverture des engagements de l'année demandée.
**               Les résultats proviennent de la structure g_sldann_str
**
** Paramètres d'entrée  :
**              .Année
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_sld_ouv_eng (p_efcanncol_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  return ((strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sansldouveng
                                                    : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sansldouveng);
}

/*
** Fonction    : san_cum_ree_eng_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 11 juin 1992
**
** Description : Renvoie le solde réel d'engagements à la période demandée pour l'année demandée. C'est à dire la somme du solde
**               d'ouverture plus la somme de toutes les périodes jusqu'à la période demandée (incluse).
**
** Paramètres d'entrée  :
**              .Année
**              .Numéro de période
**              .Flag indiquant s'il y a des sélections par colonnes
**              .Colonne en traitement
**
** Paramètres de sortie :
**              .Double qui contient la valeur trouvée
*/

double san_cum_ree_eng_n (p_efcanncol_i,p_numper_i,p_ecdflgselcol_s,p_indcol_i)
int     p_efcanncol_i;
int     p_numper_i;
char  * p_ecdflgselcol_s;
int     p_indcol_i;
{
  double  l_total_d;  /* Cumule des valeurs                 */
  int     l_indper_i; /* Indice de la période en traitement */

  l_total_d = (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0) ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sansldouveng
                                                        : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sansldouveng;
  for ( l_indper_i=PERIODE_01 ; l_indper_i<=p_numper_i ; l_indper_i++)
    l_total_d += (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)  ? g_sldann_str[COLONNE_01].sldann[p_efcanncol_i].sancumeng[l_indper_i]
                                                            : g_sldann_str[p_indcol_i].sldann[p_efcanncol_i].sancumeng[l_indper_i];
  return (l_total_d);
}

/*
** Fonction    : eval_postfix (p_etafin_ptr,p_indcol_i,p_efidet_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 juin 1992
**
** Description : Évalue l'expression contenue dans la chaine p_postfix_s
**
** Paramètres d'entrée  :
**              .Adresse de la description de l'état financier contenant l'expression à évaluer
**              .Numéro de la colonne calcul à évaluer
**              .Adresse de la structure contenant les résultats de la ligne de détail de l'ef
**
** Paramètres de sortie :
**               .Double contenant le résultat du calcul
**
** Modifications........:
**
**                      .Le 23 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Modification de la colonne calcul : ajout des valeurs constantes
*/

double eval_postfix (p_etafin_ptr,p_indcol_i,p_efidet_ptr)
etat_financier_ptr      p_etafin_ptr;
int                     p_indcol_i;
efi_detail_strptr       p_efidet_ptr;
{
 /*
  * Déclaration des variables locales
  */


  char    l_typtok_c;     /* Type de token de l'expression à évaluer                                                          */
  double  l_op1_d;        /* Pour chaque opération, on a besoin de 2 opérandes. Ces variables (op1 et op2) sont ces opérandes */
  double  l_op2_d;        /* éxtraites de la pile. Op1 = est l'élément de tête de pile, et Op2 est l'élément suivant          */

  int     l_indpstfx_i;   /* Position actuelle dans l'expression postfix                                                      */

  int     l_divzerr_f;    /* Flag indiquant qu'une division par 0 à été demandée                                              */
 /*
  * On vide la pile de travail
  */

  g_indpile_ev_i = -1;
 /*
  * On parcours toute l'expression postfix
  */
  SET_FALSE(l_divzerr_f);
  for ( l_indpstfx_i = 0;
            p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c != TOKEN_FIN_EXPRESSION
        &&  l_indpstfx_i <= MAX_TOKEN
        && !l_divzerr_f ;
        l_indpstfx_i++)
    {
      l_typtok_c = p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].typtok_c;
     /*
      * Si le token trouvé dans l'expression est une opérande, alors on va rechercher la valeur correspondante dans la colonne
      * du détail de l'état financier ou la valeur constante et on l'insère dans la pile
      */
      if (  l_typtok_c == TOKEN_COLONNE || l_typtok_c == TOKEN_CONSTANTE )
        {
          if (l_typtok_c == TOKEN_COLONNE)
            push_pile_eval(p_efidet_ptr->mntcol[p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].indcol_i]);
          else
            push_pile_eval(p_etafin_ptr->colonne[p_indcol_i].token[l_indpstfx_i].valcst_d);
        }
      else
        {
         /*
          * Le token trouvé est un opérateur. Dans ce cas, on dépile les deux opérandes du calcul, on effectue
          * le calcul demandé par l'opérateur et on rempile le résultat.
          */
          pop_pile_eval(&l_op1_d);
          pop_pile_eval(&l_op2_d);
          switch (l_typtok_c)
            {
              case TOKEN_SIGNE_PLUS:
                        push_pile_eval (l_op2_d + l_op1_d);
                        break;
              case TOKEN_SIGNE_MOINS:
                        push_pile_eval (l_op2_d - l_op1_d);
                        break;
              case TOKEN_SIGNE_MULTIPLIE:
                        push_pile_eval (l_op2_d * l_op1_d);
                        break;
              case TOKEN_SIGNE_DIVISE:
                        if (l_op1_d == 0)
                          {
                            SET_TRUE(l_divzerr_f);
                            mc950(NOM_PROGRAMME,g_lngcle_c,DIVZERR); /* Erreur de division par zero */
                          }
                        else
                          {
                            push_pile_eval (l_op2_d / l_op1_d);
                          }
                        break;
              default:
                        mc950(NOM_PROGRAMME,g_lngcle_c,EXPINV); /* Expression de calcul invalide : */
                        fprintf(stderr,"%s\n",p_etafin_ptr->colonne[p_indcol_i].efccalcol);
                        return(0);
            }
        }
    }
 /*
  * L'expression à été évaluée dans son entier. On retourne le résultat qui se trouve
  * à la première position de la pile.
  */
  if(!l_divzerr_f)
    {
      pop_pile_eval(&l_op1_d);
      return (l_op1_d);
    }
  else
    {
      return ((double) 0);
    }
}

/*
** Fonction     : push_pile_eval(p_nombre_d)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 16 juin 1992
**
** Description  : Empile le double passé en paramètre dans la pile d'évaluation
**
** Paramètres d'entrée  :
**              .Double à empiler
**
** Paramètres de sortie :
**               .FALSE si la pile est pleine. Sinon TRUE
*/

int push_pile_eval (p_nombre_d)
double  p_nombre_d;
{
  if (g_indpile_ev_i==MAX_EVLPILE_SIZE)
    return (FALSE);
  else
    g_pile_eval_d[++g_indpile_ev_i] = p_nombre_d;
  return (TRUE);
}

/*
** Fonction     : pop_pile_eval(p_nombre_d)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 16 juin 1992
**
** Description  : Dépile le nombre du dessus de la pile et le met à
**              : l'adresse donnée en parametre. Renvoie FALSE si la pile est
**              : vide.
**
** Paramètres d'entrée  :
**              .Double à dépiler
**
** Paramètres de sortie :
**               .FALSE si la pile est vide. Sinon TRUE
*/

int pop_pile_eval (p_nombre_d)
double * p_nombre_d;
{
  if (g_indpile_ev_i==-1)
    return (FALSE);
  else
    *p_nombre_d = g_pile_eval_d[g_indpile_ev_i--];
  return (TRUE);
}

/*
** Fonction    : calcul_solde (p_etafin_ptr,p_cptcle_s,p_cpttyp_s,p_ciecle_s,p_cienmc_s,p_unacle_s,
**                             p_cencle_s,p_numero_domaine_i,p_consolide_s,p_ecdflgselcol_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 04 juin 1992
**
** Description : Préparation et calcul du solde d'un compte. On initialise les tables de calcul. On
**               prépare les données à selectionner pour tenir compte des comptes cumulatifs, et de
**               la sélection globale (si l'usager ne précise pas de compagnie, ou d'unité ou de centre...)
**               Et en fonction de l'éxistance de sélection par colonne, on calcule un solde global
**               du compte pour toute la ligne. Ou bien on calcule un solde par colonne.
**
** Paramètres d'entrée  :
**              .p_etafin_ptr         = Pointeur sur l'état financier en cours de calcul
**              .p_cptcle_s           = Compte demandé
**              .p_cpttyp_s           = Type du compte demandé (cumulatif ou non cumulatif)
**              .p_ciecle_s           = Compagnie (provenant du détail de l'ef )              \
**              .p_cienmc_s           = Numéro de nomenclature (provenant du détail de l'ef ) |
**              .p_unacle_s           = Unité (provenant du détail de l'ef )                  |--> Réduction du domaine
**              .p_cencle_s           = Centre (provenant du détail de l'ef )                 /
**              .p_numero_domaine_i   = Identifiant du domaine de donnée
**              .p_consolide_s        = Doit-on consolider le résultat ?
**              .Flag indiquant s'il on doit faire une sélection de données par colonne
**
** Paramètres de sortie :
**              .aucuns
**
** Modifications........:
**
**                      .Le 15 mars 1994 par Thomas Brenneur version V3.02.00
**                          -Augmentation de la performance.
*/

void calcul_solde (p_etafin_ptr,p_cptcle_s,p_cpttyp_s,p_ciecle_s,p_cienmc_s,p_unacle_s,
              p_cencle_s,p_numero_domaine_i,p_consolide_s,p_ecdflgselcol_s)
etat_financier_ptr    p_etafin_ptr;
char                * p_cptcle_s;
char                * p_cpttyp_s;
char                * p_ciecle_s;
char                * p_cienmc_s;
char                * p_unacle_s;
char                * p_cencle_s;
int                   p_numero_domaine_i;
char                * p_consolide_s;
char                * p_ecdflgselcol_s;
{
 /*
  * Déclaration des variables locales.
  */

  int i;
  int l_indper_i; /*  Indice de la période en cours de traitement */
  int l_indcol_i; /*  Indice de la colonne en cours de traitement */
  int l_indann_i; /*  Indice de l'année en cours de traitement    */

BASED ON mccompte.cptcle                  l_cptcle_s;  /*No compte                               */
BASED ON mccompagnie.ciecle               l_ciecle_s;  /*Numéro de la compagnie                  */
BASED ON mccompagnie.cienmc               l_cienmc_s;  /*Numéro de nomenclature de la compagnie  */
BASED ON mccentre.cencle                  l_cencle_s;  /*No centre                               */
BASED ON mcunite_adm.unacle               l_unacle_s;  /*No unité administrative                 */

 /*
  * Initialisation de la structure de calcul
  */

  for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES; l_indcol_i++)
    {
      for (l_indann_i = ANNEE_000; l_indann_i < NBR_ANNEES ; l_indann_i++)
        {
          g_sldann_str[l_indcol_i].sldann[l_indann_i].sansldouv = 0;     /*Solde d'ouverture                */
          g_sldann_str[l_indcol_i].sldann[l_indann_i].sanbdgann = 0;     /*Budget annuel                    */
          g_sldann_str[l_indcol_i].sldann[l_indann_i].sanbdgrevann = 0;  /*Budget revisé annuel             */
          g_sldann_str[l_indcol_i].sldann[l_indann_i].sansldouveng = 0;  /*Solde d'ouverture engagement     */

          for (l_indper_i = PERIODE_01 ; l_indper_i<NBR_PERIODES; l_indper_i++)
            {
              g_sldann_str[l_indcol_i].sldann[l_indann_i].sancumree[l_indper_i] = 0;  /*Cumul réel par période           */
              g_sldann_str[l_indcol_i].sldann[l_indann_i].sanbdg[l_indper_i] = 0;     /*Budget initial par période       */
              g_sldann_str[l_indcol_i].sldann[l_indann_i].sanbdgrev[l_indper_i] = 0;  /*Budget revisé annuel par période */
              g_sldann_str[l_indcol_i].sldann[l_indann_i].sancumeng[l_indper_i] = 0;  /*Cumul engagement par période     */
            }
        }
    }

 /*
  * On inspecte la compagnie, le centre et l'unité présents dans le détail de l'EF.
  * Si ceux-ci sont à blanc. Ce qui veut dire qu'il n'y a pas de réduction de domaine. On les remplace
  * par la chaine "*" (équivalent de TOUS) à cause de l'utilisation du MATCHING.
  * De même, si le compte demandé est un compte cumulatif, on termine la chaine par un '\0' pour pouvoir utiliser la clause
  * STARTING lors de la recherche des comptes.
  * Ceci permet d'écrire une seule requete GDML seulement. En utilisant le MATCHING plutôt que le "="
  *
  * Note :  si l'état financier est consolidé, et qu'il y a une réduction de domaine dans un détail. C'est à dire
  *         que l'usager à saisi une compagnie/unite/centre avec le compte. Alors il faut CONSOLIDER le résultat
  *         de ce compte. Ceci veut dire que pour cette ligne uniquement, en plus de prendre les soldes de la compagnie
  *         donnée par le détail, il faut aussi rechercher les soldes de toutes les filiales de cette compagnie. Pour ce faire
  *         on utilise le numéro de nomenclature de la compagnie demandée, ce qui nous permet d'obtenir toute son
  *         arboréscence.
  */

  strcpy(l_ciecle_s,p_ciecle_s);

  if (est_vide(p_ciecle_s))
      strcpy(l_cienmc_s,"*");
  else
    {
      if (strcmp(p_consolide_s,CONSOLIDE_OUI)  ==0)/* On demande de consolider le résultat */
        {
         /*
          * Dans ce cas, on rajoute "*" à la fin du numéro de nomenclature pour rechercher toute l'arboréscence
          */
          strcpy(l_cienmc_s,p_cienmc_s);
          for (i=0; l_cienmc_s[i] != '\0' ;i++)
            {
              if (l_cienmc_s[i]==' ')
                {
                  l_cienmc_s[i]='*';
                  l_cienmc_s[i+1]='\0';
                }
            }
        }
      else
        strcpy(l_cienmc_s,p_cienmc_s);
    }

  if (est_vide(p_unacle_s))
    strcpy(l_unacle_s,"*");
  else
    strcpy(l_unacle_s,p_unacle_s);

  if (est_vide(p_cencle_s))
    strcpy(l_cencle_s,"*");
  else
    strcpy(l_cencle_s,p_cencle_s);

  strcpy(l_cptcle_s,p_cptcle_s);

 /*
  *  Si le compte demandé est un compte cumulatif, on tronque la chaine pour ne conserver que la partie significative
  *  du compte. Exemple :
  *                         Contenu de la chaine "101000", c'est un compte cumulatif permettant de regrouper tous les
  *                         comptes qui commencent par "101".
  *                         La chaine tronquée devient "101".
  */

  if (strcmp(p_cpttyp_s,CPTTYP_CUMULATIF)==0)
    {
      for (i = strlen(l_cptcle_s) - 1; i >= 0 && (l_cptcle_s[i]==' ' || l_cptcle_s[i]=='0') ; i--);
      l_cptcle_s[i+1]='\0';
    }

 /*
  * Si l'usager n'à pas demandé de sélection de données dans les colonnes, alors on calcul un seul solde
  * du compte. Qui va servir pour calculer toutes les colonnes. Sinon, on doit calculer un solde par colonne
  * en tenant compte de la sélection demandée par l'usager.
  */

  if (strcmp(p_ecdflgselcol_s,REPONSE_NON)==0)
    {
      calcul_solde_global (p_numero_domaine_i,l_cienmc_s,l_unacle_s,l_cencle_s,l_cptcle_s,p_consolide_s);
    }
  else
    {
      for (l_indcol_i = COLONNE_01; l_indcol_i < NBR_COLONNES; l_indcol_i++)
        if (!est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol))
          {
            calcul_solde_colonne (p_numero_domaine_i,l_cienmc_s,l_unacle_s,l_cencle_s,l_cptcle_s,p_consolide_s,l_indcol_i);
          }
    }
}

/*
** Fonction    : calcul_solde_global (p_numero_domaine_i,p_cienmc_s,p_unacle_s,p_cencle_s,p_cptcle_s,p_consolide_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 10 Mars 1993
**
** Description : Sommarisation des données sélectionnées pour calculer le solde d'un compte. On va chercher pour le compte
**               demandé, pour l'année courante et pour l'année précédente tous les soldes correspondants au domaine de
**               donnée. Ce domaine est réduit par la sélection faite dans le détail de l'état financier. On va aussi
**               chercher les soldes restrictifs correspondants si on désire consolider le compte. Tous ces soldes sont
**               cumulés et permettent d'obtenir pour le compte demandé les résultats de l'année courante et les
**               résultats de l'année précédente.
**               NOTE : Le solde calculé ici est GLOBAL. C'est le même quelque-soit la colonne.
**
** Paramètres d'entrée  :
**              .p_numero_domaine_i   = Identifiant du domaine de donnée
**              .p_cienmc_s           = Numéro de nomenclature (provenant du détail de l'ef )
**              .p_unacle_s           = Unité (provenant du détail de l'ef )
**              .p_cencle_s           = Centre (provenant du détail de l'ef )
**              .p_cptcle_s           = Compte demandé
**              .p_consolide_s        = Doit-on consolider le résultat ?
**
** Paramètres de sortie :
**              .aucuns
**
** Modifications........:
**
**                      .Le 15 mars 1994 par Thomas Brenneur version V3.02.00
**                          -Augmentation de la performance.
*/

void calcul_solde_global (p_numero_domaine_i,p_cienmc_s,p_unacle_s,p_cencle_s,p_cptcle_s,p_consolide_s)
int     p_numero_domaine_i;
char  * p_cienmc_s;
char  * p_unacle_s;
char  * p_cencle_s;
char  * p_cptcle_s;
char  * p_consolide_s;
{
 /*
  * Déclaration des variables locales
  */

  int l_indann_i; /* Indice de l'année en cours de traitement.  */

 /*
  * La requete suivante permet de retrouver toutes les occurences de la relation mcsolde_annuel
  * correspondants au domaine de donnée demandé et pour le compte demandé.
  * On cumule les résultats de chaque occurence (en séparant par année) pour obtenir les montants
  * non consolidés du compte.
  * Tous les résultats sont cumulés dans la première occurence de la table g_sldann_str (COLONNE_01)
  *
  * Note : Les numéros d'alias de edo ne sont pas arbitraires. ils sont là pour ne pas nuire aux STORE
  *        sur les autres edo
  */

  FOR (TRANSACTION_HANDLE trh_gl951_3)
    edo IN glefi_domaine
    WITH    edo.edonumseq = p_numero_domaine_i
        AND edo.edotyp    = EDOTYP_GLOBAL
        AND edo.cienmc    MATCHING p_cienmc_s
        AND edo.unacle    MATCHING p_unacle_s
        AND edo.cencle    MATCHING p_cencle_s
  {
    FOR (TRANSACTION_HANDLE trh_gl951_3)
        san IN mcsolde_annuel
        WITH  (     san.sanann.long = g_ann000_i
                OR  san.sanann.long = g_ann001_i
                OR  san.sanann.long = g_ann002_i )
            AND san.cptcle    STARTING WITH p_cptcle_s
            AND san.ciecle    = edo.ciecle
            AND san.unacle    = edo.unacle
        {
         /*
          * On détermine l'année trouvée pour faire la correspondance avec l'occurence de la
          * table des soldes
          */
               if (san.sanann.long == g_ann000_i) l_indann_i = ANNEE_000;
          else if (san.sanann.long == g_ann001_i) l_indann_i = ANNEE_001;
          else                                    l_indann_i = ANNEE_002;

         /*
          * Soldes
          */
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouv             +=  san.sansldouv;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_01] +=  san.sancumree1;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_02] +=  san.sancumree2;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_03] +=  san.sancumree3;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_04] +=  san.sancumree4;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_05] +=  san.sancumree5;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_06] +=  san.sancumree6;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_07] +=  san.sancumree7;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_08] +=  san.sancumree8;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_09] +=  san.sancumree9;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_10] +=  san.sancumree10;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_11] +=  san.sancumree11;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_12] +=  san.sancumree12;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_13] +=  san.sancumree13;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_14] +=  san.sancumree14;
         /*
          * Budgets
          */
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgann           +=  san.sanbdgann;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_01]  +=  san.sanbdg1;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_02]  +=  san.sanbdg2;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_03]  +=  san.sanbdg3;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_04]  +=  san.sanbdg4;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_05]  +=  san.sanbdg5;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_06]  +=  san.sanbdg6;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_07]  +=  san.sanbdg7;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_08]  +=  san.sanbdg8;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_09]  +=  san.sanbdg9;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_10]  +=  san.sanbdg10;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_11]  +=  san.sanbdg11;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_12]  +=  san.sanbdg12;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_13]  +=  san.sanbdg13;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_14]  +=  san.sanbdg14;
         /*
          * Budgets revisés
          */
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrevann          +=  san.sanbdgrevann;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_01] +=  san.sanbdgrev1;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_02] +=  san.sanbdgrev2;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_03] +=  san.sanbdgrev3;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_04] +=  san.sanbdgrev4;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_05] +=  san.sanbdgrev5;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_06] +=  san.sanbdgrev6;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_07] +=  san.sanbdgrev7;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_08] +=  san.sanbdgrev8;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_09] +=  san.sanbdgrev9;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_10] +=  san.sanbdgrev10;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_11] +=  san.sanbdgrev11;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_12] +=  san.sanbdgrev12;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_13] +=  san.sanbdgrev13;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_14] +=  san.sanbdgrev14;
         /*
          * Engagements
          */
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouveng          +=  san.sansldouveng;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_01] +=  san.sancumeng1;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_02] +=  san.sancumeng2;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_03] +=  san.sancumeng3;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_04] +=  san.sancumeng4;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_05] +=  san.sancumeng5;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_06] +=  san.sancumeng6;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_07] +=  san.sancumeng7;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_08] +=  san.sancumeng8;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_09] +=  san.sancumeng9;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_10] +=  san.sancumeng10;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_11] +=  san.sancumeng11;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_12] +=  san.sancumeng12;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_13] +=  san.sancumeng13;
          g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_14] +=  san.sancumeng14;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_3);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Si les résultats doivent êtres consolidés, alors on va rechercher toutes les intercompagnies de ce compte
  * pour en diminuer les résultats calculés précédement. Pour ce faire, on recherche toutes les occurences de la
  * relation mcsan_rest dont le triplet CIE/UNA/CEN appartient au domaine ET dont le triplet CIE_INTER/UNA_INTER/CEN_INTER
  * appartient AUSSI au domaine.
  */

  if (strcmp(p_consolide_s,CONSOLIDE_OUI) ==0) /* On demande de consolider le résultat */
    {
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        sre   IN mcsan_rest
        WITH    (     sre.sanann.long = g_ann000_i
                  OR  sre.sanann.long = g_ann001_i
                  OR  sre.sanann.long = g_ann002_i )
            AND sre.cptcle      STARTING WITH p_cptcle_s
        {
          FOR (TRANSACTION_HANDLE trh_gl951_3)
                  edo_5 IN glefi_domaine
            CROSS edo_6 IN glefi_domaine
            WITH  edo_5.edonumseq =         p_numero_domaine_i
              AND edo_5.edotyp    =         EDOTYP_GLOBAL
              AND edo_5.cienmc    MATCHING  p_cienmc_s
              AND edo_5.cencle    MATCHING  p_cencle_s
              AND edo_5.unacle    MATCHING  p_unacle_s
              AND edo_5.ciecle    =         sre.ciecle
              AND edo_5.unacle    =         sre.unacle
              AND edo_6.edonumseq =         p_numero_domaine_i
              AND edo_6.edotyp    =         EDOTYP_GLOBAL
              AND edo_6.cienmc    MATCHING  p_cienmc_s
              AND edo_6.cencle    MATCHING  p_cencle_s
              AND edo_6.unacle    MATCHING  p_unacle_s
              AND edo_6.ciecle    =         sre.srecieint
              AND edo_6.unacle    =         sre.sreunaint
            {
             /*
              * On détermine l'année trouvée pour faire la correspondance avec l'occurence de la
              * table des soldes
              */
                   if (sre.sanann.long == g_ann000_i) l_indann_i = ANNEE_000;
              else if (sre.sanann.long == g_ann001_i) l_indann_i = ANNEE_001;
              else                                    l_indann_i = ANNEE_002;

             /*
              * Soldes
              */
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouv             -=  sre.sresldouv;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_01] -=  sre.srecumree1;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_02] -=  sre.srecumree2;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_03] -=  sre.srecumree3;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_04] -=  sre.srecumree4;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_05] -=  sre.srecumree5;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_06] -=  sre.srecumree6;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_07] -=  sre.srecumree7;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_08] -=  sre.srecumree8;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_09] -=  sre.srecumree9;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_10] -=  sre.srecumree10;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_11] -=  sre.srecumree11;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_12] -=  sre.srecumree12;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_13] -=  sre.srecumree13;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_14] -=  sre.srecumree14;
             /*
              * Engagements
              */
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouveng          -=  sre.sresldouveng;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_01] -=  sre.srecumeng1;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_02] -=  sre.srecumeng2;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_03] -=  sre.srecumeng3;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_04] -=  sre.srecumeng4;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_05] -=  sre.srecumeng5;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_06] -=  sre.srecumeng6;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_07] -=  sre.srecumeng7;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_08] -=  sre.srecumeng8;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_09] -=  sre.srecumeng9;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_10] -=  sre.srecumeng10;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_11] -=  sre.srecumeng11;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_12] -=  sre.srecumeng12;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_13] -=  sre.srecumeng13;
              g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_14] -=  sre.srecumeng14;
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_3);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }

 /*
  * Pour respecter ses échelles (scales), PowerHouse multiplie ses résultats par 100 en les mettants
  * dans des Floats. Donc lors du calcul du solde, on doit diviser tous les montants par 100.
  */

  for (l_indann_i = ANNEE_000; l_indann_i < NBR_ANNEES ; l_indann_i++)
    {
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouv             /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_01] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_02] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_03] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_04] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_05] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_06] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_07] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_08] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_09] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_10] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_11] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_12] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_13] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumree[PERIODE_14] /= 100;
     /*
      * Budgets
      */
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgann           /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_01]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_02]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_03]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_04]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_05]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_06]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_07]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_08]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_09]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_10]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_11]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_12]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_13]  /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdg[PERIODE_14]  /= 100;
     /*
      * Budgets revisés
      */
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrevann          /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_01] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_02] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_03] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_04] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_05] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_06] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_07] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_08] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_09] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_10] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_11] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_12] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_13] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sanbdgrev[PERIODE_14] /= 100;
     /*
      * Engagements
      */
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sansldouveng          /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_01] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_02] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_03] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_04] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_05] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_06] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_07] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_08] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_09] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_10] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_11] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_12] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_13] /= 100;
      g_sldann_str[COLONNE_01].sldann[l_indann_i].sancumeng[PERIODE_14] /= 100;
    }
}

/*
** Fonction    : calcul_solde_colonne (p_numero_domaine_i,p_cienmc_s,p_unacle_s,p_cencle_s,p_cptcle_s,p_consolide_s,p_indcol_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 10 Mars 1993
**
** Description : Sommarisation des données sélectionnées pour calculer le solde d'un compte. On va chercher pour le compte
**               demandé, pour l'année courante et pour l'année précédente tous les soldes correspondants au domaine de
**               donnée. Ce domaine est réduit par la sélection faite dans le détail de l'état financier. On va aussi
**               chercher les soldes restrictifs correspondants si on désire consolider le compte. Tous ces soldes sont
**               cumulés et permettent d'obtenir pour le compte demandé les résultats de l'année courante et les
**               résultats de l'année précédente.
**
**               NOTE : Le solde calculé ici est PAR COLONNE. Donc, on réduit le domaine de donnée avec la sélection
**                      demandé pour chaque colonne de l'état financier.
**
** Paramètres d'entrée  :
**              .p_numero_domaine_i   = Identifiant du domaine de donnée
**              .p_cienmc_s           = Numéro de nomenclature (provenant du détail de l'ef )
**              .p_unacle_s           = Unité (provenant du détail de l'ef )
**              .p_cencle_s           = Centre (provenant du détail de l'ef )
**              .p_cptcle_s           = Compte demandé
**              .p_consolide_s        = Doit-on consolider le résultat ?
**              .p_indcol_i           = Numéro de la colonne en cours de traitement
**
** Paramètres de sortie :
**              .aucuns
**
** Modifications........:
**
**                      .Le 15 mars 1994 par Thomas Brenneur version V3.02.00
**                          -Augmentation de la performance.
*/

void calcul_solde_colonne (p_numero_domaine_i,p_cienmc_s,p_unacle_s,p_cencle_s,p_cptcle_s,p_consolide_s,p_indcol_i)
int     p_numero_domaine_i;
char  * p_cienmc_s;
char  * p_unacle_s;
char  * p_cencle_s;
char  * p_cptcle_s;
char  * p_consolide_s;
int     p_indcol_i;
{
 /*
  * Déclaration des variables locales
  */

  int l_indann_i; /* Indice de l'année en cours de traitement.  */

 /*
  * La requete suivante permet de retrouver toutes les occurences de la relation mcsolde_annuel
  * correspondants au domaine de donnée demandé et pour le compte demandé.
  * On cumule les résultats de chaque occurence (en séparant par année) pour obtenir les montants
  * non consolidés du compte. On ne sélectionne les soldes que s'ils font partie de la sélection de la
  * colonne. Chaque résultat est mis dans la colonne correspondante de g_sldann_str
  *
  * Note : Les numéros d'alias de edo ne sont pas arbitraires. ils sont là pour ne pas nuire aux STORE
  *        sur les autres edo
  */

  FOR (TRANSACTION_HANDLE trh_gl951_3)
          edo IN glefi_domaine
    CROSS edo_5 IN glefi_domaine
    WITH    edo.edonumseq   = p_numero_domaine_i
        AND edo.edotyp      = EDOTYP_GLOBAL
        AND edo.cienmc      MATCHING p_cienmc_s
        AND edo.unacle      MATCHING p_unacle_s
        AND edo.cencle      MATCHING p_cencle_s
        AND edo_5.edonumseq = p_numero_domaine_i
        AND edo_5.edotyp    = EDOTYP_COLONNE
        AND edo_5.edonumcol = p_indcol_i
        AND edo_5.ciecle    = edo.ciecle
        AND edo_5.unacle    = edo.unacle
        AND edo_5.cencle    = edo.cencle
    {
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        san IN mcsolde_annuel
        WITH  (     san.sanann.long = g_ann000_i
                OR  san.sanann.long = g_ann001_i
                OR  san.sanann.long = g_ann002_i )
          AND san.cptcle  STARTING WITH p_cptcle_s
          AND san.ciecle  =             edo_5.ciecle
          AND san.unacle  =             edo_5.unacle
        {
         /*
          * On détermine l'année trouvée pour faire la correspondance avec l'occurence de la
          * table des soldes
          */
               if (san.sanann.long == g_ann000_i) l_indann_i = ANNEE_000;
          else if (san.sanann.long == g_ann001_i) l_indann_i = ANNEE_001;
          else                                    l_indann_i = ANNEE_002;

         /*
          * Soldes
          */
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouv             +=  san.sansldouv;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_01] +=  san.sancumree1;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_02] +=  san.sancumree2;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_03] +=  san.sancumree3;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_04] +=  san.sancumree4;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_05] +=  san.sancumree5;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_06] +=  san.sancumree6;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_07] +=  san.sancumree7;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_08] +=  san.sancumree8;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_09] +=  san.sancumree9;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_10] +=  san.sancumree10;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_11] +=  san.sancumree11;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_12] +=  san.sancumree12;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_13] +=  san.sancumree13;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_14] +=  san.sancumree14;
         /*
          * Budgets
          */
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgann           +=  san.sanbdgann;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_01]  +=  san.sanbdg1;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_02]  +=  san.sanbdg2;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_03]  +=  san.sanbdg3;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_04]  +=  san.sanbdg4;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_05]  +=  san.sanbdg5;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_06]  +=  san.sanbdg6;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_07]  +=  san.sanbdg7;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_08]  +=  san.sanbdg8;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_09]  +=  san.sanbdg9;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_10]  +=  san.sanbdg10;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_11]  +=  san.sanbdg11;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_12]  +=  san.sanbdg12;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_13]  +=  san.sanbdg13;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_14]  +=  san.sanbdg14;
         /*
          * Budgets revisés
          */
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrevann          +=  san.sanbdgrevann;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_01] +=  san.sanbdgrev1;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_02] +=  san.sanbdgrev2;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_03] +=  san.sanbdgrev3;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_04] +=  san.sanbdgrev4;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_05] +=  san.sanbdgrev5;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_06] +=  san.sanbdgrev6;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_07] +=  san.sanbdgrev7;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_08] +=  san.sanbdgrev8;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_09] +=  san.sanbdgrev9;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_10] +=  san.sanbdgrev10;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_11] +=  san.sanbdgrev11;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_12] +=  san.sanbdgrev12;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_13] +=  san.sanbdgrev13;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_14] +=  san.sanbdgrev14;
         /*
          * Engagements
          */
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouveng          +=  san.sansldouveng;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_01] +=  san.sancumeng1;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_02] +=  san.sancumeng2;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_03] +=  san.sancumeng3;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_04] +=  san.sancumeng4;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_05] +=  san.sancumeng5;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_06] +=  san.sancumeng6;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_07] +=  san.sancumeng7;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_08] +=  san.sancumeng8;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_09] +=  san.sancumeng9;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_10] +=  san.sancumeng10;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_11] +=  san.sancumeng11;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_12] +=  san.sancumeng12;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_13] +=  san.sancumeng13;
          g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_14] +=  san.sancumeng14;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }
  END_FOR
    ON_ERROR
      dberreur(ACTION_ROLLBACK_GL951_3);
      exit(EXIT_AVEC_ERREUR);
    END_ERROR;

 /*
  * Si les résultats doivent êtres consolidés, alors on va rechercher toutes les intercompagnies de ce compte
  * pour en diminuer les résultats calculés précédement. Pour ce faire, on recherche toutes les occurences de la
  * relation mcsan_rest dont le triplet CIE/UNA/CEN appartient au domaine ET dont le triplet CIE_INTER/UNA_INTER/CEN_INTER
  * appartient AUSSI au domaine.
  */

  if (strcmp(p_consolide_s,CONSOLIDE_OUI) ==0) /* On demande de consolider le résultat */
    {
      FOR (TRANSACTION_HANDLE trh_gl951_3)
        sre IN mcsan_rest
        WITH    (     sre.sanann.long = g_ann000_i
                  OR  sre.sanann.long = g_ann001_i
                  OR  sre.sanann.long = g_ann002_i )
              AND sre.cptcle      STARTING WITH p_cptcle_s
        {
          FOR (TRANSACTION_HANDLE trh_gl951_3)
                  edo_5 IN glefi_domaine
            CROSS edo_6 IN glefi_domaine
            CROSS edo_7 IN glefi_domaine
            CROSS edo_8 IN glefi_domaine
            WITH    edo_5.edonumseq =         p_numero_domaine_i
                AND edo_5.edotyp    =         EDOTYP_GLOBAL
                AND edo_5.cienmc    MATCHING  p_cienmc_s
                AND edo_5.cencle    MATCHING  p_cencle_s
                AND edo_5.unacle    MATCHING  p_unacle_s
                AND edo_6.edonumseq =         p_numero_domaine_i
                AND edo_6.edotyp    =         EDOTYP_COLONNE
                AND edo_6.edonumcol =         p_indcol_i
                AND edo_6.ciecle    =         edo_5.ciecle
                AND edo_6.unacle    =         edo_5.unacle
                AND edo_6.cencle    =         edo_5.cencle
                AND edo_6.ciecle    =         sre.ciecle
                AND edo_6.unacle    =         sre.unacle
                AND edo_7.edonumseq =         p_numero_domaine_i
                AND edo_7.edotyp    =         EDOTYP_GLOBAL
                AND edo_7.cienmc    MATCHING  p_cienmc_s
                AND edo_7.cencle    MATCHING  p_cencle_s
                AND edo_7.unacle    MATCHING  p_unacle_s
                AND edo_8.edonumseq =         p_numero_domaine_i
                AND edo_8.edotyp    =         EDOTYP_COLONNE
                AND edo_8.edonumcol =         p_indcol_i
                AND edo_8.ciecle    =         edo_7.ciecle
                AND edo_8.unacle    =         edo_7.unacle
                AND edo_8.cencle    =         edo_7.cencle
                AND edo_8.ciecle    =         sre.srecieint
                AND edo_8.unacle    =         sre.sreunaint
            {
             /*
              * On détermine l'année trouvée pour faire la correspondance avec l'occurence de la
              * table des soldes
              */
                   if (sre.sanann.long == g_ann000_i) l_indann_i = ANNEE_000;
              else if (sre.sanann.long == g_ann001_i) l_indann_i = ANNEE_001;
              else                                    l_indann_i = ANNEE_002;

             /*
              * Soldes
              */
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouv             -=  sre.sresldouv;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_01] -=  sre.srecumree1;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_02] -=  sre.srecumree2;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_03] -=  sre.srecumree3;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_04] -=  sre.srecumree4;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_05] -=  sre.srecumree5;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_06] -=  sre.srecumree6;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_07] -=  sre.srecumree7;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_08] -=  sre.srecumree8;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_09] -=  sre.srecumree9;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_10] -=  sre.srecumree10;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_11] -=  sre.srecumree11;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_12] -=  sre.srecumree12;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_13] -=  sre.srecumree13;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_14] -=  sre.srecumree14;
             /*
              * Engagements
              */
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouveng          -=  sre.sresldouveng;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_01] -=  sre.srecumeng1;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_02] -=  sre.srecumeng2;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_03] -=  sre.srecumeng3;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_04] -=  sre.srecumeng4;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_05] -=  sre.srecumeng5;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_06] -=  sre.srecumeng6;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_07] -=  sre.srecumeng7;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_08] -=  sre.srecumeng8;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_09] -=  sre.srecumeng9;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_10] -=  sre.srecumeng10;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_11] -=  sre.srecumeng11;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_12] -=  sre.srecumeng12;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_13] -=  sre.srecumeng13;
              g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_14] -=  sre.srecumeng14;
            }
          END_FOR
            ON_ERROR
              dberreur(ACTION_ROLLBACK_GL951_3);
              exit(EXIT_AVEC_ERREUR);
            END_ERROR;
        }
      END_FOR
        ON_ERROR
          dberreur(ACTION_ROLLBACK_GL951_3);
          exit(EXIT_AVEC_ERREUR);
        END_ERROR;
    }

 /*
  * Pour respecter ses échelles (scales), PowerHouse multiplie ses résultats par 100 en les mettants
  * dans des Floats. Donc lors du calcul du solde, on doit diviser tous les montants par 100.
  */

  for (l_indann_i = ANNEE_000; l_indann_i < NBR_ANNEES; l_indann_i++)
    {
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouv             /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_01] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_02] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_03] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_04] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_05] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_06] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_07] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_08] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_09] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_10] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_11] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_12] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_13] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumree[PERIODE_14] /= 100;
     /*
      * Budgets
      */
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgann           /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_01]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_02]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_03]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_04]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_05]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_06]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_07]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_08]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_09]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_10]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_11]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_12]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_13]  /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdg[PERIODE_14]  /= 100;
     /*
      * Budgets revisés
      */
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrevann          /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_01] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_02] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_03] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_04] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_05] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_06] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_07] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_08] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_09] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_10] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_11] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_12] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_13] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sanbdgrev[PERIODE_14] /= 100;
     /*
      * Engagements
      */
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sansldouveng          /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_01] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_02] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_03] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_04] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_05] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_06] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_07] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_08] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_09] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_10] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_11] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_12] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_13] /= 100;
      g_sldann_str[p_indcol_i].sldann[l_indann_i].sancumeng[PERIODE_14] /= 100;
    }
}

/*
** Fonction    : est_vide (p_string_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 4 juin 1992
**
** Description : Si la chaine en entrée ne contient que des " " ou un \0, on renvoie 1 sinon on renvoie 0
**
** Paramètres d'entrée  :
**               .Chaine à inspecter
**
** Paramètres de sortie :
**               .FALSE ou TRUE
*/

int est_vide(p_string_s)
char  * p_string_s;
{
  int i;
  for (i=0; p_string_s[i] != '\0' && p_string_s[i] == ' '; i++);
  if ( strlen(p_string_s) != i )
    return (FALSE);
  else
    return (TRUE);
}

/*
** Fonction    : col_operation (p_colonne_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 3 Mai 1992
**
** Description : Si la chaine en entrée est un "+" ou un "-" (dépendant du signe utilisé pour cette machine)
**               on renvoie un 1. sinon, on renvoie 0. Ceci permet de savoir si la colonne correspondant au
**               niveau de calcul demandé est un niveau d'operation.
**
** Paramètres d'entrée  :
**               .Colonne à inspecter
**
** Paramètres de sortie :
**               .0 ou 1
*/

int col_operation(p_colonne_s)
char  * p_colonne_s;
{
  if (strcmp(p_colonne_s,SIGNE_PLUS) == 0 || strcmp(p_colonne_s,SIGNE_MOINS) == 0 )
      return (TRUE);
  else
      return (FALSE);
}

/*
** Fonction    : col_egal (p_colonne_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 3 Mai 1992
**
** Description : Si la chaine en entrée est un "=" (dépendant du signe égal utilisé pour cette machine)
**               on renvoie un 1. sinon, on renvoie 0. Ceci permet de savoir si la colonne correspondant au
**               niveau de calcul demandé est un niveau de total.
**
** Paramètres d'entrée  :
**               .Colonne à inspecter
**
** Paramètres de sortie :
**               .0 ou 1
*/

int col_egal(p_colonne_s)
char  * p_colonne_s;
{
  if (strcmp(p_colonne_s,SIGNE_EGAL) == 0)
      return (TRUE);
  else
      return (FALSE);
}

/*
** Fonction    : imprimer_ef(p_etafin_ptr,p_efidet_ptr,p_ecdnbrcop_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 16 Juillet 1992
**
** Description : Impression (dans le fichier) de l'état financier en cours
**
** Paramètres d'entrée  :
**               .Adresse de l'état financier à imprimer
**               .Adresse des lignes de l'etat financier
**               .Nombre de copies à imprimer
**
** Paramètres de sortie :
**               .Aucun
*/

void imprimer_ef(p_etafin_ptr,p_efidet_ptr,p_ecdnbrcop_i)
etat_financier_ptr    p_etafin_ptr;
efi_detail_strptr     p_efidet_ptr;
BASED ON glece_detail.ecdnbrcop p_ecdnbrcop_i;  /* Nombre de copies à imprimer  */
{
  char  * l_buflig_s;   /* Buffer qui va contenir la ligne à imprimer                                           */
  char  * l_buftmp_s;   /* Buffer de travail                                                                    */

  int     l_indlig_i;   /* Indice de la ligne du format                                                         */
  int     l_indligtmp_i;/* Indice de la ligne pour imprimer les lignes vides jusqu'au bas de page               */
  int     l_nblig_i;    /* Nombre de lignes déja imprimées                                                      */
  int     l_seuil_i;    /* Numéro de la ligne à laquelle il faut imprimer le bas de page                        */
  int     l_offset_i;   /* Position à laquelle placer la page de l'ef dans la page physique                     */
  int     l_formfeed_f; /* Flag indiquant qu'il faut sauter une page                                            */
  int     l_ecdnbrcop_i;/* Indice de la copie en cours d'impression                                             */
 /*
  * Réservation de deux buffer de travail en mémoire
  */
  l_buflig_s = allouer_buffer(g_efcedule_str.ecelarpag);
  l_buftmp_s = allouer_buffer(g_efcedule_str.ecelarpag);

 /*
  * Initialisation
  */

  l_offset_i = calculer_offset(p_etafin_ptr);

 /*
  * Calcul du seuil. C'est à dire le numéro de ligne à laquelle il faut imprimer le bas de page. Si la page ne contient
  * pas assez de lignes pour contenir le haut de page, l'entête et le bas de page. Alors l'état financier n'est pas
  * imprimé.
  */

  l_seuil_i = calculer_seuil(p_etafin_ptr);

  if (l_seuil_i == 0)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,PAGTROPCOURTE); /* Longueur de page trop courte pour imprimer cet état financier */
      fprintf(stderr,"%s %s\n",p_etafin_ptr->eficiecle,p_etafin_ptr->eficle);
     /*
      * Libération des buffers de travail
      */
      liberer_buffer(l_buflig_s);
      liberer_buffer(l_buftmp_s);
    }

 /*
  * Impression de l'état financier. On effectue cette impression autant de fois que le nombre de copies demandées.
  */

  for (l_ecdnbrcop_i = 0; l_ecdnbrcop_i < p_ecdnbrcop_i ; l_ecdnbrcop_i++)
    {
      g_efiformvalu_str.page = 1;
      SET_TRUE(l_formfeed_f);
      for (l_indlig_i = 0 ; l_indlig_i < p_etafin_ptr->efinbrlig ; l_indlig_i++)
        {
         /*
          * Si on vient de sauter une page, alors il faut imprimer le haut de page et l'entete
          */
          if (l_formfeed_f)
            {
              l_nblig_i = 0;
              l_nblig_i += imprimer_format(TYPE_HAUT_PAGE,p_etafin_ptr,l_buflig_s,l_buftmp_s);
              l_nblig_i += imprimer_entete(p_etafin_ptr,l_buflig_s,l_buftmp_s,l_offset_i);
              SET_FALSE (l_formfeed_f);
            }
         /*
          * Suivant le type de ligne, on imprime la ligne ou on saute une page
          */
          if (strcmp(p_efidet_ptr[l_indlig_i].efdcod,EFDCOD_PAGE)==0)
              SET_TRUE(l_formfeed_f);
          else
            {
              l_nblig_i += imprimer_ligne(p_etafin_ptr,&p_efidet_ptr[l_indlig_i],l_buflig_s,l_buftmp_s,l_offset_i);
              if (l_nblig_i >= l_seuil_i) SET_TRUE(l_formfeed_f);
            }
         /*
          * Si on saute une page, alors on imprime le bas de page et un saut de page
          */
          if (l_formfeed_f)
            {
             /*
              * On imprime des lignes blanches jusqu'à atteindre le bas de page. Puis on imprime le bas de page
              */
              for (l_indligtmp_i = l_nblig_i; l_indligtmp_i < l_seuil_i ; l_indligtmp_i ++ )
                {
                  l_nblig_i += imprimer_ligblanche(l_buflig_s);
                }
              l_nblig_i += imprimer_format(TYPE_BAS_PAGE,p_etafin_ptr,l_buflig_s,l_buftmp_s);
              fprintf(g_ficimp_fic,FORMAT_FORMFEED);
              g_efiformvalu_str.page++;
            }
        }
     /*
      * On imprime le dernier bas de page puis on saute une page pour pouvoir imprimer l'etat suivant
      */
      for (l_indligtmp_i = l_nblig_i; l_indligtmp_i < l_seuil_i ; l_indligtmp_i ++ )
        {
          l_nblig_i += imprimer_ligblanche(l_buflig_s);
        }
      l_nblig_i += imprimer_format(TYPE_BAS_PAGE,p_etafin_ptr,l_buflig_s,l_buftmp_s);
      fprintf(g_ficimp_fic,FORMAT_FORMFEED);
    }

 /*
  * Libération des buffers de travail
  */
  liberer_buffer(l_buflig_s);
  liberer_buffer(l_buftmp_s);
}

/*
** Fonction    : calculer_offset(p_etafin_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Juillet 1992
**
** Description : Calcul de la position à laquelle placer la page de l'EF dans la page Physique
**
** Paramètres d'entrée  :
**               .Adresse de l'état financier à imprimer
**
** Paramètres de sortie :
**               .Position à laquelle placer la page de l'ef dans la page physique
*/

int calculer_offset(p_etafin_ptr)
etat_financier_ptr    p_etafin_ptr;
{
 /*
  * Déclaration des variables locales
  */

  int     l_layout_i;         /* Largeur du "Layout"  ( = description + n*( largeur colonne + espacement))    */
  int     l_indcol_i;         /* Indice de la colonne en cours de traitement                                  */
  int     l_offset_i;         /* Position de début à laquelle placer la description de la ligne               */

 /*
  * Calcul du "Layout" de la page. C'est à dire : Calcul de la largeur de la description plus la largeur de chaque colonnes
  * (avec l'espacement entre chaque colonnes). Ceci permet de centrer le rapport dans la largeur de page spécifiée par
  * les paramètres de la cédule.
  */

  l_layout_i = g_efcedule_str.ecelardsc;

  for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++ )
    {
     /*
      * On comptes toutes les colonnes qui contiennent quelque chose. Mais pour les notes on ne compte que les
      * colonnes qui doivent êtres imprimées
      */
      if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
          && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
              ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
        {
          l_layout_i += g_efcedule_str.eceespcol + p_etafin_ptr->colonne[l_indcol_i].efclarcol;
        }
    }

  if (l_layout_i >= g_efcedule_str.ecelarpag)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,EFITROPLAR); /* Définition des colonnes trop large pour la largeur de page demandée */
      l_offset_i = 0;
    }
  else
    {
     /*
      * Calcul de la position à laquelle on place la page de l'ef dans la page physique
      */
      l_offset_i = (g_efcedule_str.ecelarpag - l_layout_i) /2;
    }
  return (l_offset_i);
}

/*
** Fonction    : calculer_seuil(p_etafin_ptr)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Juillet 1992
**
** Description : Calcul de la position à partir de laquelle il faut imprimer le bas de page dans la ligne.
**
** Paramètres d'entrée  :
**               .Adresse de l'état financier à imprimer
**
** Paramètres de sortie :
**               .Position à laquelle placer le bas de page dans la page physique
*/

int calculer_seuil(p_etafin_ptr)
etat_financier_ptr    p_etafin_ptr;
{
  int     l_nbligfrm_i; /* Nombre de lignes du format                                                           */
  int     l_indlig_i;   /* Indice de la ligne du format                                                         */
  int     l_seuil_i;    /* Numéro de la ligne à laquelle il faut imprimer le bas de page                        */

 /*
  * On compte le nombre de lignes formant le bas de page. Et on calcule la position de ce bas de page en fonction de
  * la longueur physique de la page.
  */
  l_nbligfrm_i = 0;
  for(l_indlig_i=0 ; l_indlig_i < p_etafin_ptr->effnbrlig ; l_indlig_i ++)
    {
      if (strcmp(p_etafin_ptr->efiformat[l_indlig_i].efltypfor,TYPE_BAS_PAGE)==0) l_nbligfrm_i ++;
    }

  l_seuil_i = g_efcedule_str.ecelonpag - l_nbligfrm_i;

  l_nbligfrm_i = 0;

 /*
  * et on compte le nombre de lignes formant le haut de page.
  */
  for(l_indlig_i=0 ; l_indlig_i < p_etafin_ptr->effnbrlig ; l_indlig_i ++)
    {
      if (strcmp(p_etafin_ptr->efiformat[l_indlig_i].efltypfor,TYPE_HAUT_PAGE)==0) l_nbligfrm_i ++;
    }

 /*
  * Si la somme des lignes utilisés par le haut de page, l'entête, et le bas de page ne laisse pas assez de place
  * pour afficher l'état financier alors on retourne une erreur au programme appelant.
  */

  if (l_seuil_i <= 0 || (l_seuil_i - l_nbligfrm_i - p_etafin_ptr->efinbrligent <= NBR_LIGNE_MIN )) l_seuil_i = 0;

  return (l_seuil_i);
}

/*
** Fonction    : imprimer_format(p_typform_s,p_etafin_ptr,p_buflig_s,p_buftmp_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 10 Juillet 1992
**
** Description : Impression du haut ou bas de page
**
** Paramètres d'entrée  :
**               .Type de form à imprimer (Haut ou Bas)
**               .Adresse de l'état financier à imprimer
**               .Adresse du buffer de la ligne d'impression
**               .Adresse d'un buffer de travail
**
** Paramètres de sortie :
**               .Nombre de lignes imprimées
*/

int imprimer_format(p_typform_s,p_etafin_ptr,p_buflig_s,p_buftmp_s)
char                * p_typform_s;
etat_financier_ptr    p_etafin_ptr;
char                * p_buflig_s;
char                * p_buftmp_s;
{
 /*
  * Déclaration des variables locales
  */

  int     i;                  /* Variable de travail                                                          */
  int     l_indlig_i;         /* Indice de l'occurence du tableau qui contient la forme d'impression          */
  int     l_ligpre_i;         /* Dernier numéro de ligne traité                                               */
  int     l_ligimp_i;         /* Nombre de lignes imprimées                                                   */
  int     l_pos_bl_i;         /* Position actuelle du curseur dans le buffer p_buflig_s                       */
  int     l_pos_bt_i;         /* Position actuelle du curseur dans le buffer p_buftmp_s                       */

  int     l_premiere_ligne_f; /* Flag indiquant que l'on est en train de traiter la première ligne du format  */
  int     l_buffer_vide_f;    /* Flag indiquant si le buffer contient quelque chose à imprimer                */

  eff_ligne_strptr l_forme_ptr;  /* Pointeur sur la forme en cours de traitement                           */

  char    l_wrkbuf_s[TAILLE_WORK_BUFF]; /* Buffer de travail local                                                      */
  char    l_space_s[2];                 /* Contient le caractere d'espacement entre le label et la donnée à afficher    */
  char    l_ascchr_c;                   /* Charactère contenant le code ascii demandé par le code "ASCI" du format      */

 /*
  * On transfert l'adresse de la table de la forme pou éviter de devoir référencer chaque zone par
  * p_etafin_ptr->efiformat->xxxxxx
  */

  l_forme_ptr = p_etafin_ptr->efiformat;

 /*
  * On lis chaque ligne de la forme correspondante à l'état financier en cours
  */

  SET_TRUE(l_premiere_ligne_f);
  SET_TRUE(l_buffer_vide_f);
  l_pos_bl_i = vider_buffer(p_buflig_s,g_efcedule_str.ecelarpag);
  l_pos_bt_i = vider_buffer(p_buftmp_s,g_efcedule_str.ecelarpag);
  l_ligimp_i = 0;

  for(l_indlig_i=0 ; l_indlig_i < p_etafin_ptr->effnbrlig ; l_indlig_i ++)
    {
     /*
      * On ne sélectionne que les lignes de Haut de page ou de Bas de page suivant p_typform_s
      */
      if (strcmp(p_typform_s,l_forme_ptr[l_indlig_i].efltypfor)==0)
        {
         if(l_premiere_ligne_f)
          {
            l_ligpre_i = l_forme_ptr[l_indlig_i].efllignum;
            SET_FALSE(l_premiere_ligne_f);
          }
          if (l_ligpre_i != l_forme_ptr[l_indlig_i].efllignum)
            {
             /*
              * S'il y a changement de ligne, on transfert le buffer dans le fichier d'impression
              */
              fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
              l_ligimp_i++;
              l_ligpre_i = l_forme_ptr[l_indlig_i].efllignum;
              l_pos_bl_i = vider_buffer(p_buflig_s,g_efcedule_str.ecelarpag);
              SET_TRUE(l_buffer_vide_f);
            }
         /*
          * On prépare le label en enlevant les blanc de la fin de la chaine. Et si le label est vide, alors la
          * chaine l_space_s est vidée elle aussi. Cette chaine permet de mettre un espace entre le label et la
          * chaine à afficher.
          */
          SET_FALSE(l_buffer_vide_f);
          strtrim(l_forme_ptr[l_indlig_i].eflelelab);
          strtrim(l_forme_ptr[l_indlig_i].efleletxt);
          if(est_vide(l_forme_ptr[l_indlig_i].eflelelab))
            l_space_s[0] = '\0';
          else
            strcpy(l_space_s," ");
         /*
          * Puis on inspecte le code de la ligne pour rajouter la zone désirée dans le buffer de travail.
          * NOTE : On construit toujours la ligne de la façon suivante : LABEL + zonne demandée + TEXTE_LIBRE
          *        Ceci permet à l'usager d'avoir un maximum de souplesse. Par exemple pour imprimer un numéro
          *        de page de cette façon "- 2 -", il suffit de déclarer un élément de type PAGE avec "-" dans le
          *        LABEL et " -" dans le TEXTE_LIBRE.
          */
               if(strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_TEXT)==0)
                  {
                    sprintf(p_buftmp_s,"%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,
                            l_space_s,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_CIE)==0)
                  {
                   /*
                    * On prend le nom de la compagnie dans l'EF s'il est défini. Sinon on prend celui de formvalu
                    */
                    if (!est_vide(p_etafin_ptr->efititcie))
                      {
                        strtrim(p_etafin_ptr->efititcie);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                p_etafin_ptr->efititcie,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                    else
                      {
                        strtrim(g_efiformvalu_str.cienom);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                g_efiformvalu_str.cienom,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_CEN)==0)
                  {
                    strtrim(g_efiformvalu_str.cennom);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.cennom,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_UNI)==0)
                  {
                    strtrim(g_efiformvalu_str.unanom);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.unanom,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_PAGE)==0)
                  {
                    sprintf(l_wrkbuf_s,FORMAT_NUMERO_PAGE,g_efiformvalu_str.page);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            l_wrkbuf_s,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_DATE)==0)
                  {
                    strtrim(g_efiformvalu_str.date);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.date,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_EFNO)==0)
                  {
                    strtrim(p_etafin_ptr->eficiecle);
                    strtrim(p_etafin_ptr->eficle);
                    sprintf(p_buftmp_s,"%s%s%s %s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            p_etafin_ptr->eficiecle,p_etafin_ptr->eficle,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_PEC)==0)
                  {
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.peccle,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_PER)==0)
                  {
                   /*
                    * On prend la périodicité l'EF si elle est défini. Sinon on prend celle de formvalu
                    */
                    if (!est_vide(p_etafin_ptr->efititper))
                      {
                        strtrim(p_etafin_ptr->efititper);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                p_etafin_ptr->efititper,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                    else
                      {
                        strtrim(g_efiformvalu_str.periodicite);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                g_efiformvalu_str.periodicite,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_COMM)==0)
                  {
                    strtrim(p_etafin_ptr->efititcom);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            p_etafin_ptr->efititcom,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_HRE)==0)
                  {
                    strtrim(g_efiformvalu_str.heure);
                    sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.heure,l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_TIT)==0)
                  {
                   /*
                    * On prend le titre l'EF si il est défini. Sinon on prend celui de formvalu
                    */
                    if (!est_vide(p_etafin_ptr->efititef))
                      {
                        strtrim(p_etafin_ptr->efititef);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                p_etafin_ptr->efititef,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                    else
                      {
                        strtrim(g_efiformvalu_str.titre);
                        sprintf(p_buftmp_s,"%s%s%s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                                g_efiformvalu_str.titre,l_forme_ptr[l_indlig_i].efleletxt);
                      }
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_CED)==0)
                  {
                    strtrim(g_efiformvalu_str.ececiecle);
                    strtrim(g_efiformvalu_str.ececle);
                    sprintf(p_buftmp_s,"%s%s%s %s%s",l_forme_ptr[l_indlig_i].eflelelab,l_space_s,
                            g_efiformvalu_str.ececiecle,g_efiformvalu_str.ececle,
                            l_forme_ptr[l_indlig_i].efleletxt);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelecod,EFFCOD_ASCI)==0)
                  {
                    i=0;
                   /*
                    * Dans le cas du code ASCI, la zone efeeletxt contient une chaine de la forme : "27/91/51/123/98".
                    * Cette chaine est la liste des codes ascii séparés par un "/". Donc pour traiter le code ASCI
                    * du format, on inspecte cette chaine pour extraire chacun des éléments (séparés par "/") et les
                    * convertir en valeur ascii.
                    */
                    while(    i < TAILLE_WORK_BUFF
                           && strcmp(strelem(l_wrkbuf_s,TAILLE_WORK_BUFF,l_forme_ptr[l_indlig_i].efleletxt,ASCI_SEP,i),"\0")!=0)
                      {
                        p_buftmp_s[i] = (char) atoi(l_wrkbuf_s);
                        i++;
                      }
                    p_buftmp_s[i] = '\0';
                  }
         /*
          * On place l'élément à imprimer dans le buffer principal suivant la position demandée
          * par l'usager :  G = cadré à gauche.
          *                 C = Centré (dans la largeur de la page).
          *                 D = Cadré à droite.
          *                 P = Position : Numéro de colonne à laquelle doit être placée l'élément.
          *                 + = À la suite de l'élément précédent.
          * NOTE : l_pos_bl_i contient la position du curseur après l'opération dans le buffer principal.
          */
               if (strcmp(l_forme_ptr[l_indlig_i].eflelepos,EFFPOS_GAUCHE)==0)
                  {
                    l_pos_bl_i = cadrer_gauche_buffer (p_buflig_s,p_buftmp_s);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelepos,EFFPOS_CENTRE)==0)
                  {
                    l_pos_bl_i = centrer_buffer (p_buflig_s,p_buftmp_s,l_pos_bl_i);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelepos,EFFPOS_DROITE)==0)
                  {
                    l_pos_bl_i = cadrer_droite_buffer (p_buflig_s,p_buftmp_s);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelepos,EFFPOS_POSITION)==0)
                  {
                    l_pos_bl_i = positionner_buffer (p_buflig_s,p_buftmp_s,l_forme_ptr[l_indlig_i].eflelecol);
                  }
          else if (strcmp(l_forme_ptr[l_indlig_i].eflelepos,EFFPOS_PLUS)==0)
                  {
                    l_pos_bl_i = positionner_buffer (p_buflig_s,p_buftmp_s,l_pos_bl_i);
                  }
        }
    }
 /*
  * On imprime la dernière ligne du format (Qui n'a pas été imprimée à cause de la sortie de la boucle)
  */
  if (!l_buffer_vide_f)
    {
      fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
      l_ligimp_i++;
      l_pos_bl_i = vider_buffer(p_buflig_s,g_efcedule_str.ecelarpag);
      SET_TRUE(l_buffer_vide_f);
    }

 /*
  * On retourne le nombre de lignes imprimées
  */

  return (l_ligimp_i);
}

/*
** Fonction    : imprimer_entete(p_etafin_ptr,p_buflig_s,p_buftmp_s,p_offset_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Juillet 1992
**
** Description : Impression de l'entete des colonnes
**
** Paramètres d'entrée  :
**               .Adresse de l'état financier à imprimer
**               .Adresse du buffer de la ligne d'impression
**               .Adresse d'un buffer de travail
**               .Position à laquelle positionner la page de l'EF dans la page physique
**
** Paramètres de sortie :
**               .Nombre de lignes imprimées
*/

int imprimer_entete(p_etafin_ptr,p_buflig_s,p_buftmp_s,p_offset_i)
etat_financier_ptr    p_etafin_ptr;
char                * p_buflig_s;
char                * p_buftmp_s;
int                   p_offset_i;
{
 /*
  * Déclaration des variables locales
  */

  int     l_indlig_i;         /* Numéro de la ligne d'entête en cours de traitement                           */
  int     l_ligimp_i;         /* Nombre de lignes imprimées                                                   */
  int     l_indcol_i;         /* Indice de la colonne en cours de traitement                                  */
  int     l_indpos_i;         /* Position actuelle du curseur dans le buffer d'impression                     */

  char *  l_bufcol_s;         /* Buffer de travail de l'entête de chaque colonne                              */

 /*
  * Allocation de mémoire pour le buffer de travail
  */

  l_bufcol_s = allouer_buffer (p_etafin_ptr->eficollarmax);
  vider_buffer (l_bufcol_s,p_etafin_ptr->eficollarmax);

 /*
  * On parcours toutes les lignes de l'entête dont le nombre est donné par p_etafin_ptr->efinbrligent.
  * Pour chaque ligne de cet entête, et à chaque colonne, on demande à la fonction 'strelem' d'extraire
  * l'élément correspondant de l'entête.
  *
  * Exemple : Si on traite la colonne 1 de la 2eme ligne d'entête et que cette colonne a pour entête
  *           le texte suivant : "Cumulatif^Annuel^------------"
  *           Alors la fonction va retourner la chaine "Annuel"
  *
  * Chaque entête de colonne est centré dans la lagreur de celle-ci. Et le début de l'entete est placé à
  * la position de l'offset plus la largeur de la description des comptes plus la longeur de l'espacement
  * entre les colonnes.
  */

  for (l_indlig_i = 0; l_indlig_i < p_etafin_ptr->efinbrligent; l_indlig_i++)
    {
      l_indpos_i = vider_buffer (p_buflig_s,g_efcedule_str.ecelarpag)+p_offset_i+g_efcedule_str.ecelardsc+g_efcedule_str.eceespcol;

      for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i++ )
        {
          if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
              && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
                  ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
            {
             /*
              * Chaque entete de colonne est centré dans la largeur de la colonne avant d'être placé dans la page
              */
              vider_buffer (p_buftmp_s,p_etafin_ptr->colonne[l_indcol_i].efclarcol);
              strtrim(strelem(l_bufcol_s,p_etafin_ptr->eficollarmax,p_etafin_ptr->colonne[l_indcol_i].efcentcol,
                              EFCENTCOL_SEP_LIG,l_indlig_i));
              centrer_buffer(p_buftmp_s,l_bufcol_s,(int) 0);
              l_indpos_i = positionner_buffer(p_buflig_s,p_buftmp_s,l_indpos_i);
              l_indpos_i += g_efcedule_str.eceespcol;
            }
        }
      fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
    }
  liberer_buffer (l_bufcol_s);
  return (l_indlig_i);
}

/*
** Fonction    : imprimer_ligne(p_etafin_ptr,p_efidet_ptr,p_buflig_s,p_buftmp_s,p_offset_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 15 Juillet 1992
**
** Description : Impression d'une ligne de résultat de l'état financier
**
** Paramètres d'entrée  :
**               .Adresse de l'état financier à imprimer
**               .Adresse de la ligne de l'etat à imprimer
**               .Adresse du buffer de la ligne d'impression
**               .Adresse d'un buffer de travail
**               .Position à laquelle positionner la page de l'EF dans la page physique
**
** Paramètres de sortie :
**               .Nombre de lignes imprimées
**
** Modifications........:
**
**                      .Le 21 mars 1994 par Thomas Brenneur version V3.02.00
**                          - Ajout d'une colonne "Commentaires"
*/

int imprimer_ligne(p_etafin_ptr,p_efidet_ptr,p_buflig_s,p_buftmp_s,p_offset_i)
etat_financier_ptr    p_etafin_ptr;
efi_detail_strptr     p_efidet_ptr;
char                * p_buflig_s;
char                * p_buftmp_s;
int                   p_offset_i;
{
 /*
  * Déclaration des variables locales
  */

  int     l_ligimp_i;         /* Nombre de lignes imprimées                                                   */
  int     l_indcol_i;         /* Indice de la colonne en cours de traitement                                  */
  int     l_indpos_i;         /* Position actuelle du curseur dans le buffer d'impression                     */

  double  l_abssum_d;         /* Somme en valeur absolue des résultats de toutes les colonnes de la ligne     */

  l_indpos_i = vider_buffer(p_buflig_s,g_efcedule_str.ecelarpag);
  l_ligimp_i=0;
 /*
  * L'usager à t-il demandé d'imprimer la ligne ?
  */
  if (strcmp(p_efidet_ptr->efdflgimp,IMPLIG_NON)!=0)
    {
     /*
      * Pour ces types de lignes, il faut imprimer le résultat de chaque colonne
      */
      if (   strcmp(p_efidet_ptr->efdcod,EFDCOD_CPT)   == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_SDEB)  == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_SFIN)  == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_BAL)   == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_JUM)   == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_TOT)   == 0
          || strcmp(p_efidet_ptr->efdcod,EFDCOD_NOTE)  == 0 )
        {
          if (strcmp(p_efidet_ptr->efdflgimp,IMPLIG_SI_NON_ZERO)==0)
            {
             /*
              * Dans le cas ou on doit imprimer la ligne seulement si au moins un des résultats des colonnes est différent
              * de zéro, on calcul la somme en valeur absolue des résultats de chaque colonnes. Si la somme est differente
              * de zéro il faut imprimer la ligne.
              * NOTE: On ne sélectionne que les colonnes non vides, qui ne sont pas des colonnes de type "Commentaire", ou,
              * pour les notes, celles qui doivent êtres imprimées.
              */
              l_abssum_d = 0;
              for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
                {
                  if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
                      && strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_COM) != 0
                      && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
                          ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
                    {
                      l_abssum_d += fabs(p_efidet_ptr->mntcol[l_indcol_i]);
                    }
                }
            }
         /*
          * Impression de la ligne si autorisé par le code d'impression ou le calcul de la somme des résultats
          */
          if (   strcmp(p_efidet_ptr->efdflgimp,IMPLIG_OUI)==0
              || ( strcmp(p_efidet_ptr->efdflgimp,IMPLIG_SI_NON_ZERO)==0 && l_abssum_d != 0 ) )
            {

             /*
              * Ajout de la description dans le buffer à partir de la position de départ de la page calculée par calculer_offset()
              * La description est imprimée sur la longueur donnée par le paramètre de la cédule (ecelardsc).
              * En fonction de l'option demandée par l'usager, on affiche :
              *                                                                Description,
              *                                                             ou Unité + description,
              *                                                             ou Compte + description,
              *                                                             ou Unité + compte + description,
              *                                                             ou Compte + Unité + description.
              */

              if (    strcmp(p_efidet_ptr->efdcod,EFDCOD_TOT)  != 0
                  &&  strcmp(p_efidet_ptr->efdcod,EFDCOD_NOTE) != 0 )
                {
                  vider_buffer (p_buftmp_s,g_efcedule_str.ecelardsc);

                        if (strcmp(p_etafin_ptr->efiimpinfsup,EFIIMPINFSUP_NON)==0)
                          cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->efddsc);
                  else  if (strcmp(p_etafin_ptr->efiimpinfsup,EFIIMPINFSUP_UNA)==0)
                          positionner_buffer(p_buftmp_s,p_efidet_ptr->efddsc,
                                              cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->unacle) + 1);
                  else  if (strcmp(p_etafin_ptr->efiimpinfsup,EFIIMPINFSUP_CPT)==0)
                          positionner_buffer(p_buftmp_s,p_efidet_ptr->efddsc,
                                              cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->cptcle) + 1);
                  else  if (strcmp(p_etafin_ptr->efiimpinfsup,EFIIMPINFSUP_UNACPT)==0)
                          positionner_buffer(p_buftmp_s,p_efidet_ptr->efddsc,
                                              positionner_buffer(p_buftmp_s,p_efidet_ptr->cptcle,
                                                                  cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->unacle) + 1) +1);
                  else  if (strcmp(p_etafin_ptr->efiimpinfsup,EFIIMPINFSUP_CPTUNA)==0)
                          positionner_buffer(p_buftmp_s,p_efidet_ptr->efddsc,
                                              positionner_buffer(p_buftmp_s,p_efidet_ptr->unacle,
                                                                  cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->cptcle) + 1) +1);

                  l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,p_offset_i) + g_efcedule_str.eceespcol;
                }
              else
                {
                  vider_buffer (p_buftmp_s,g_efcedule_str.ecelardsc);
                  cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->efddsc);
                  l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,p_offset_i) + g_efcedule_str.eceespcol;
                }

             /*
              * Apres avoir placé la description, on va placer chaque résultat de chaque colonne, dans la largeur
              * spécifié par le paramètre de la définition des colonnes (efclarcol), et séparé par la largeur
              * donnée par le paramètre de la cédule (eceespcol).
              */
              for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
                {
                  if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
                      && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
                          ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
                    {
                     /*
                      * On initialise le buffer à la largeur de la colonne
                      * Avant de formater le résultat à imprimer :
                      *   Si la colonne est une colonne de type "Commentaire", alors on imprime des blanc au lieu d'afficher
                      *   le contenu du tableau.
                      *   Ou si la colonne est un ratio, alors on imprime un résultat que si le ratio de cette ligne à vraiement
                      *   été calculé (la colonne contient une ligne de référence).
                      */
                      vider_buffer (p_buftmp_s,p_etafin_ptr->colonne[l_indcol_i].efclarcol);
                      if  (     strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_COM) != 0
                            &&  (     strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_RAT) != 0
                                  ||  (      strcmp(p_etafin_ptr->colonne[l_indcol_i].efctypcol,TYPCOL_RAT) == 0
                                        &&  p_efidet_ptr->efdrat[l_indcol_i] != 0
                                      )
                                )
                          )
                        {
                          formater_nombre (p_buftmp_s,p_efidet_ptr->mntcol[l_indcol_i],
                                            p_etafin_ptr->colonne[l_indcol_i].efctypcol,p_efidet_ptr->naclig);
                        }
                      l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,l_indpos_i) + g_efcedule_str.eceespcol;
                    }
                }
             /*
              * On envoie la ligne à l'impression
              */
              fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
              l_ligimp_i++;
            }
        }
     /*
      * Si la ligne est de type texte
      */
      if (strcmp(p_efidet_ptr->efdcod,EFDCOD_TEXT)==0)
        {
          vider_buffer (p_buftmp_s,g_efcedule_str.ecelardsc);
          cadrer_gauche_buffer (p_buftmp_s,p_efidet_ptr->efddsc);
          positionner_buffer (p_buflig_s,p_buftmp_s,p_offset_i);
          fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
          l_ligimp_i++;
        }
     /*
      * Si la ligne est de type souligné
      */
      if (strcmp(p_efidet_ptr->efdcod,EFDCOD_SLG)==0)
        {
          vider_buffer (p_buftmp_s,g_efcedule_str.ecelardsc);
          remplir_buffer (p_buftmp_s,p_efidet_ptr->efddsc[0]);
          l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,p_offset_i) + g_efcedule_str.eceespcol;
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
            {
              if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
                  && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
                      ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
                {
                  vider_buffer (p_buftmp_s,p_etafin_ptr->colonne[l_indcol_i].efclarcol);
                  remplir_buffer (p_buftmp_s,p_efidet_ptr->efddsc[0]);
                  l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,l_indpos_i) + g_efcedule_str.eceespcol;
                }
            }
         /*
          * On envoie la ligne à l'impression
          */
          fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
          l_ligimp_i++;
        }
     /*
      * Si la ligne est de type souligné de la description seulement
      */
      if (strcmp(p_efidet_ptr->efdcod,EFDCOD_SLGD)==0)
        {
          vider_buffer (p_buftmp_s,g_efcedule_str.ecelardsc);
          remplir_buffer (p_buftmp_s,p_efidet_ptr->efddsc[0]);
          l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,p_offset_i);
         /*
          * On envoie la ligne à l'impression
          */
          fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
          l_ligimp_i++;
        }
     /*
      * Si la ligne est de type souligné des colonnes seulement
      */
      if (strcmp(p_efidet_ptr->efdcod,EFDCOD_SLGC)==0)
        {
          l_indpos_i = p_offset_i + g_efcedule_str.ecelardsc + g_efcedule_str.eceespcol;
          for (l_indcol_i = COLONNE_01 ; l_indcol_i < NBR_COLONNES ; l_indcol_i ++)
            {
              if (   !est_vide(p_etafin_ptr->colonne[l_indcol_i].efctypcol)
                  && (    strcmp(p_etafin_ptr->efityp,EFITYP_NOTE)!=0
                      ||  strcmp(p_etafin_ptr->colonne[l_indcol_i].efcimpcol,REPONSE_OUI)==0))
                {
                  vider_buffer (p_buftmp_s,p_etafin_ptr->colonne[l_indcol_i].efclarcol);
                  remplir_buffer (p_buftmp_s,p_efidet_ptr->efddsc[0]);
                  l_indpos_i = positionner_buffer (p_buflig_s,p_buftmp_s,l_indpos_i) + g_efcedule_str.eceespcol;
                }
            }
         /*
          * On envoie la ligne à l'impression
          */
          fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
          l_ligimp_i++;
        }
     /*
      * Si c'est une ligne blanche
      */
      if (est_vide(p_efidet_ptr->efdcod))
        {
          fprintf(g_ficimp_fic,FORMAT_FICIMP,p_buflig_s);
          l_ligimp_i++;
        }
    }
  return(l_ligimp_i);
}

/*
** Fonction    : imprimer_ligblanche(p_buflig_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 24 Juillet 1992
**
** Description : Impression d'une ligne blanche
**
** Paramètres d'entrée  :
**               .Adresse du buffer de la ligne d'impression
**
** Paramètres de sortie :
**               .Nombre de lignes imprimées
*/

int imprimer_ligblanche(p_buflig_s)
char                * p_buflig_s;
{
  vider_buffer(p_buflig_s,g_efcedule_str.ecelarpag);
  fprintf(g_ficimp_fic,FORMAT_FICIMP,"");
  return ((int) 1);
}

/*
** Fonction    : formater_nombre (p_buffer_s,p_nombre_d,p_typcol_s,p_naclig_i);
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 16 Juillet 1992
**
** Description : Conversion d'un montant numérique en chaine de caractères avec formatage.
**
** Paramètres d'entrée  :
**              .Adresse du buffer de réception du nombre mis en forme
**              .Nombre à mettre en forme
**              .Type de colonne d'ou provient le nombre
**              .Nature de la ligne d'ou provient le nombre (Depense,Revenu,...)
**
** Paramètres de sortie :
**               .Aucun
*/

void formater_nombre (p_buffer_s,p_nombre_d,p_typcol_s,p_naclig_i)
char  * p_buffer_s;
double  p_nombre_d;
char  * p_typcol_s;
int     p_naclig_i;
{
 /*
  * Déclaration des variables locales
  */

  int       l_nbrcar_i;         /* Nombre de caracères de la chaine qui reçoit le nombre convertis          */
  int       l_indcar_i;         /* Position actuelle dans le buffer de travail                              */
  int       l_indbuf1_i;        /* Position actuelle dans le 1er buffer (l_buf1_s)                          */
  int       l_indbuf2_i;        /* Position actuelle dans le 2eme buffer (l_buf2_s)                         */
  int       l_indmil_i;         /* Indique si on a atteint une séparation de milliers                       */

  int       l_pointdec_passe_f; /* Flag indiquant si opn a passé le point décimal                           */

  char      l_buf1_s[TAILLE_WORK_BUFF]; /* Buffer de travail des chaines de caractères                      */
  char      l_buf2_s[TAILLE_WORK_BUFF]; /* Buffer de travail des chaines de caractères                      */

 /*
  * Si la colonne d'ou provient le nombre est une colonne de type ECART et que la nature de la ligne d'ou provient le
  * nombre est de type DEPENSE, alors on inverse le nombre pour correspondre au type d'écart : Favorable ou Defavorable
  * (Voir calcul des écarts).
  */

  if (strcmp(p_typcol_s,TYPCOL_ECAR)==0 && p_naclig_i == NAC_DEPENSE)
    {
      p_nombre_d *= -1;
    }

 /*
  * Conversion du nombre en chaine de caractères
  */

  l_nbrcar_i = sprintf(l_buf1_s,FORMAT_NOMBRE,p_nombre_d);

  if (l_nbrcar_i >= TAILLE_WORK_BUFF)
    {
      mc950(NOM_PROGRAMME,g_lngcle_c,LONGBUFINS); /* Longeur du buffer de travail insufisante */
      exit(EXIT_AVEC_ERREUR);
    }
 /*
  * On place les signe de séparation des milliers et de décimales ( note ce traitement inverse la chaine )
  */

  l_indmil_i = 0;
  l_indbuf2_i = 0;
  SET_FALSE(l_pointdec_passe_f);

  for (l_indbuf1_i = l_nbrcar_i - 1; l_indbuf1_i > 0 ; l_indbuf1_i --)
    {
      if (l_indmil_i == 3 && l_pointdec_passe_f)
        {
          l_buf2_s[l_indbuf2_i] = g_efcedule_str.ecesepmil[0];
          l_indbuf2_i++;
          if (l_indbuf2_i >= TAILLE_WORK_BUFF)
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,LONGBUFINS); /* Longeur du buffer de travail insufisante */
              exit(EXIT_AVEC_ERREUR);
            }
          l_indmil_i = 0;
        }
      if (l_buf1_s[l_indbuf1_i]=='.')
        {
          l_buf2_s[l_indbuf2_i] = g_efcedule_str.ecesepdec[0];
          l_indbuf2_i++;
          if (l_indbuf2_i >= TAILLE_WORK_BUFF)
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,LONGBUFINS); /* Longeur du buffer de travail insufisante */
              exit(EXIT_AVEC_ERREUR);
            }
          l_indmil_i = 0;
          SET_TRUE(l_pointdec_passe_f);
        }
      else
        {
          l_buf2_s[l_indbuf2_i] = l_buf1_s[l_indbuf1_i];
          l_indbuf2_i++;
          if (l_indbuf2_i >= TAILLE_WORK_BUFF)
            {
              mc950(NOM_PROGRAMME,g_lngcle_c,LONGBUFINS); /* Longeur du buffer de travail insufisante */
              exit(EXIT_AVEC_ERREUR);
            }
          l_indmil_i++;
        }
    }
  l_buf2_s[l_indbuf2_i]='\0';

 /*
  * On inverse la chaine obtenu précédement
  */

  l_indbuf1_i =0;

  for ( l_indcar_i = l_indbuf2_i - 1;
            l_indcar_i >= 0
        && !(   l_buf2_s[l_indcar_i] == g_efcedule_str.ecesepdec[0]
             && strcmp(g_efcedule_str.ececodarr,ARRONDI_NON)!=0);
        l_indcar_i --)
    {
      l_buf1_s[l_indbuf1_i++] = l_buf2_s[l_indcar_i];
    }
  l_buf1_s[l_indbuf1_i]='\0';

 /*
  * Rajout du signe
  */

  if (p_nombre_d >= 0)
    l_nbrcar_i = sprintf(l_buf2_s," %s ",l_buf1_s);
  else
    l_nbrcar_i = sprintf(l_buf2_s,"%s%s%s",g_efcedule_str.ecesgng,l_buf1_s,g_efcedule_str.ecesgnd);

 /*
  * Si la longueur de la chaine dépasse la largeur de la colonne, on imprime que des "#"
  */

  if (l_nbrcar_i > strlen(p_buffer_s))
    remplir_buffer (p_buffer_s,CARACTERE_OVERFLOW);
  else
    cadrer_droite_buffer(p_buffer_s,l_buf2_s);
}

/*
** Fonction    : allouer_buffer (p_larpag_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Allocation d'un buffer en mémoire dynamique
**
** Paramètres d'entrée  :
**              .Longueur à donner au buffer
**
** Paramètres de sortie :
**               .Adresse de la position de ce buffer
*/

char * allouer_buffer (p_larpag_i)
int     p_larpag_i;
{
  return ((char *)malloc (p_larpag_i));
}

/*
** Fonction    : liberer_buffer (p_larpag_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Libération de l'espace mémoire du buffer
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**
** Paramètres de sortie :
**               .Aucun
*/

void liberer_buffer (p_buffer_s)
char  * p_buffer_s;
{
  free (p_buffer_s);
}

/*
** Fonction    : vider_buffer (p_buffer_s,p_larpag_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Mise à blanc de l'espace mémoire occupé par le buffer
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Longueur du buffer
**
** Paramètres de sortie :
**               .0 = Position du curseur dans le buffer
*/

int vider_buffer (p_buffer_s,p_larpag_i)
char  * p_buffer_s;
int     p_larpag_i;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  for (l_indchar_i = 0; l_indchar_i < p_larpag_i ; l_indchar_i ++)  p_buffer_s[l_indchar_i]=' ';
  p_buffer_s[p_larpag_i]='\0';
  return (0);
}

/*
** Fonction    : remplir_buffer (p_buffer_s,p_car_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 16 Juillet 1992
**
** Description : Remplissage du buffer avec le caractere donné en paramètre
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Caractère à utiliser pour remplir le buffer
**
** Paramètres de sortie :
**               .Aucun
*/

void remplir_buffer (p_buffer_s,p_car_c)
char  * p_buffer_s;
char    p_car_c;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  for (l_indchar_i = 0; p_buffer_s[l_indchar_i]!='\0' ; l_indchar_i ++)  p_buffer_s[l_indchar_i]=p_car_c;
}

/*
** Fonction    : strtrim (p_string_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Supression des blanc de la fin de la chaine.
**
** Paramètres d'entrée  :
**              .Adresse de la chaine
**
** Paramètres de sortie :
**               .Aucun
*/

void strtrim (p_string_s)
char  * p_string_s;
{
  int l_indchar_i;  /* Position courante dans la chaine */
  for ( l_indchar_i = strlen(p_string_s) ; l_indchar_i > 0 && p_string_s[l_indchar_i -1]==' ' ; l_indchar_i -- );
  p_string_s[l_indchar_i]='\0';
}

/*
** Fonction    : cadrer_gauche_buffer (p_buffer_s,p_string_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Cadrage à gauche de la chaine p_string_s dans le buffer p_buffer_s
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Adresse de la chaine à cadrer
**
** Paramètres de sortie :
**               .Position du curseur dans le buffer après l'opération
*/

int cadrer_gauche_buffer (p_buffer_s,p_string_s)
char  * p_buffer_s;
char  * p_string_s;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  for ( l_indchar_i = 0 ; p_buffer_s[l_indchar_i]!='\0' && p_string_s[l_indchar_i]!='\0' ; l_indchar_i ++)
    p_buffer_s[l_indchar_i] = p_string_s[l_indchar_i];
  return (l_indchar_i);
}

/*
** Fonction    : centrer_buffer (p_buffer_s,p_string_s,p_pos_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Centrage de la chaine p_string_s dans le buffer p_buffer_s
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Adresse de la chaine à centrer
**              .Position actuelle du curseur dans le buffer
**
** Paramètres de sortie :
**               .Position du curseur dans le buffer après l'opération
*/

int centrer_buffer (p_buffer_s,p_string_s,p_pos_i)
char  * p_buffer_s;
char  * p_string_s;
int     p_pos_i;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  int l_buflen_i;   /* Longueur du buffer               */
  int l_strlen_i;   /* Longueur de la chaine            */
  int l_offset_i;   /* Position de centrage             */

  l_buflen_i = strlen(p_buffer_s);
  l_strlen_i = strlen(p_string_s);

  if (l_strlen_i >= l_buflen_i) return (cadrer_gauche_buffer(p_buffer_s,p_string_s));
  if (l_strlen_i == 0) return(p_pos_i);

  l_offset_i = (l_buflen_i - l_strlen_i)/2;

  for ( l_indchar_i = l_offset_i ; p_buffer_s[l_indchar_i]!='\0' && p_string_s[l_indchar_i - l_offset_i]!='\0' ; l_indchar_i ++)
    p_buffer_s[l_indchar_i] = p_string_s[l_indchar_i - l_offset_i];

  return (l_indchar_i);
}

/*
** Fonction    : cadrer_droite_buffer (p_buffer_s,p_string_s)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : Cadrage à droite de la chaine p_string_s dans le buffer p_buffer_s
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Adresse de la chaine à cadrer
**
** Paramètres de sortie :
**               .Position du curseur dans le buffer après l'opération
*/

int cadrer_droite_buffer (p_buffer_s,p_string_s)
char  * p_buffer_s;
char  * p_string_s;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  int l_buflen_i;   /* Longueur du buffer               */
  int l_strlen_i;   /* Longueur de la chaine            */
  int l_offset_i;   /* Position de centrage             */

  l_buflen_i = strlen(p_buffer_s);
  l_strlen_i = strlen(p_string_s);

  if (l_strlen_i >= l_buflen_i) return (cadrer_gauche_buffer(p_buffer_s,p_string_s));
  if (l_strlen_i == 0) return(l_buflen_i);

  l_offset_i = l_buflen_i - l_strlen_i;

  for ( l_indchar_i = l_offset_i ; p_buffer_s[l_indchar_i]!='\0' && p_string_s[l_indchar_i - l_offset_i]!='\0' ; l_indchar_i ++)
    p_buffer_s[l_indchar_i] = p_string_s[l_indchar_i - l_offset_i];

  return (l_indchar_i);
}

/*
** Fonction    : positionner_buffer (p_buffer_s,p_string_s,p_pos_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 8 Juillet 1992
**
** Description : positionnement à la position p_pos_i de la chaine p_string_s dans le buffer p_buffer_s
**
** Paramètres d'entrée  :
**              .Adresse du buffer
**              .Adresse de la chaine à cadrer
**              .Position à laquelle placer p_string_s dans le buffer
**
** Paramètres de sortie :
**               .Position du curseur dans le buffer après l'opération
*/

int positionner_buffer (p_buffer_s,p_string_s,p_pos_i)
char  * p_buffer_s;
char  * p_string_s;
int     p_pos_i;
{
  int l_indchar_i;  /* Position courante dans le buffer */
  int l_buflen_i;   /* Longueur du buffer               */
  int l_strlen_i;   /* Longueur de la chaine            */

  l_buflen_i = strlen(p_buffer_s);
  l_strlen_i = strlen(p_string_s);

  if (p_pos_i >= l_buflen_i) return (l_buflen_i);
  if (l_strlen_i == 0) return(p_pos_i);

  for ( l_indchar_i = p_pos_i ; p_buffer_s[l_indchar_i]!='\0' && p_string_s[l_indchar_i - p_pos_i]!='\0' ; l_indchar_i ++)
    p_buffer_s[l_indchar_i] = p_string_s[l_indchar_i - p_pos_i];

  return (l_indchar_i);
}

/*
** Fonction    : strtokcnt (p_string_s,p_car_c)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 1 Mars 1993
**
** Description : Dénombrement du nombre de caractères p_car_c présents dans la chaine p_string_s
**
** Paramètres d'entrée  :
**              .Adresse de la chaine dans laquelle on effectue le dénombrement
**              .Caractère à rechercher
**
** Paramètres de sortie :
**              .Nombre de caractères p_car_c contenu dans p_string_s
*/

int strtokcnt (p_string_s,p_car_c)
char  * p_string_s;
char    p_car_c;
{
  int i;
  int j;

  i = j = 0;

  while (p_string_s[j]!='\0')
    {
      if (p_string_s[j]==p_car_c) i++;
      j++;
    }

  return (i);
}

/*
** Fonction    : strelem (p_buffer_s,p_maxlen_i,p_string_s,p_sepele_c,p_elenum_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 1 Mars 1993
**
** Description : On découpe la chaine p_string_s en éléments séparés les uns des autres par le caractère
**               contenu dans p_sepele_c. Et on renvoie l'élément numéro p_elenum_i. Si le numéro de
**               l'élément demandé est plus grand que le nombre d'éléments contenu dans la chaine à découper,
**               alors la fonction retourne une chaine vide.
**               Note : Le premier élément de la chaine porte le numéro 0 (zéro).
**
** Paramètres d'entrée  :
**              .Adresse du buffer qui reçoit l'élément
**              .Longueur maximale du buffer de réception (p_buffer_s)
**              .Adresse de la chaine à découper
**              .Caractère séparateur d'éléments
**              .Numéro de l'élément à renvoyer
**
** Paramètres de sortie :
**              .Adresse du buffer qui reçoit l'élément.
*/

char * strelem (p_buffer_s,p_maxlen_i,p_string_s,p_sepele_c,p_elenum_i)
char  * p_buffer_s;
int     p_maxlen_i;
char  * p_string_s;
char    p_sepele_c;
int     p_elenum_i;
{
  int l_indele_i;   /* Elément en cours d'extraction                                            */
  int l_indcar1_i;  /* Position courante dans la chaine à découper depuis le dernier séparateur */
  int l_indcar2_i;  /* Position du dernier séparateur dans la chaine à découper                 */
  int l_strlen_i;   /* Longueur de la chaine à inspecter                                        */

  l_indele_i = l_indcar2_i = 0;
  l_strlen_i = strlen(p_string_s);

  while ( l_indele_i <= p_elenum_i )
    {
      l_indcar1_i = 0;
      while (   p_string_s[l_indcar1_i + l_indcar2_i] != p_sepele_c
             && (l_indcar1_i + l_indcar2_i) < l_strlen_i
             && l_indcar1_i < p_maxlen_i )
        {
          p_buffer_s[l_indcar1_i] = p_string_s[l_indcar1_i + l_indcar2_i];
          l_indcar1_i++;
        }
      p_buffer_s[l_indcar1_i] = '\0';
      l_indcar2_i += l_indcar1_i + 1;
      l_indele_i++;
    }

  return(p_buffer_s);
}

/*
** Fonction    : round (p_nbr_d,p_exp_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 21 Avril 1993
**
** Description :  Arrondi d'un nombre. La valeur contenue dans p_nbr_d est arrondi à p_exp_i chiffre de la virgule.
**                Exemple :   round(10.45,0) = 10.00
**                            round(10.51,0) = 11.00
**                            round(10.5181,2) = 10.52
**                            round(148.40,-2) = 100
**                            round(151.40,-2) = 200
**
** Paramètres d'entrée  :
**              .Nombre à arrondir
**              .Echelle de l'arrondi.
**
** Paramètres de sortie :
**              .Nombre après l'arrondissement.
*/

double round(p_nbr_d,p_exp_i)
double  p_nbr_d;
int     p_exp_i;
{
  if (p_nbr_d != 0)
    {
      p_nbr_d *= pow((double)10,(double)p_exp_i);
      p_nbr_d += 0.05;
      if ( fabs(ceil(p_nbr_d)-p_nbr_d) < fabs(floor(p_nbr_d)-p_nbr_d) )
          p_nbr_d = ceil(p_nbr_d);
      else
          p_nbr_d = floor(p_nbr_d);
      return ( p_nbr_d / pow((double)10,(double)p_exp_i) );
    }
  else
    return ( (double)0 );
}

/*
** Fonction    : dberreur (p_numero_action_i)
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 29 Mai 1992
**
** Description : Traitement à effectuer en fonction du numéro d'action
**               Cette fonction a pour but de regrouper les séqences
**               d'actions identiques.
**
** Paramètres d'entrée  :
**               .Numéro de l'action à entreprende
**
** Paramètres de sortie :
**               .Aucun
*/

void dberreur (p_numero_action_i)
int   p_numero_action_i;
{
 /*
  * Affichage du message d'erreur de StarBase
  */

#if UNIX
  gds__print_status ( gds__status );
#else
  gds_$print_status ( gds_$status );
#endif

 /*
  * Suivant le numero d'Action, on va faire un rollback,on affiche
  * un message...
  */

  switch (p_numero_action_i)
    {
      case ACTION_FINISH:
              FINISH db_dict;
              break;
      case ACTION_ROLLBACK_GL951_1:
              ROLLBACK trh_gl951_1;
              mc950(NOM_PROGRAMME,g_lngcle_c,RLLBCK); /* Rollback...*/
              FINISH db_dict;
              break;
      case ACTION_ROLLBACK_GL951_2:
              ROLLBACK trh_gl951_2;
              mc950(NOM_PROGRAMME,g_lngcle_c,RLLBCK); /* Rollback...*/
              FINISH db_dict;
              break;
      case ACTION_ROLLBACK_GL951_3:
              ROLLBACK trh_gl951_3;
              mc950(NOM_PROGRAMME,g_lngcle_c,RLLBCK); /* Rollback...*/
              FINISH db_dict;
              break;
    }
}

#include "mc950.e" /* Affichage des messages */
