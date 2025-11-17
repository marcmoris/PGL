/*
** Definitions : MC950.H
** Module      : Module commun
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Mai 1992
**
** Description : Définitions des paramètres communs de configuration.
**
*/

#ifndef MC950H
#define MC950H 1


#define         NOMBRE_LANGUES  2       /* Nombre de languages utilisés par   */
                                        /* l'application. Actuellement :      */
                                        /* Français,Anglais                   */

#define         FRA             '1'
#define         ANG             '2'
#define         ANNEE_00        2000
#define         SIECLE_ACTUEL   1900
#define         NAC_MIXTE       0  /* Sert aux états financiers uniquement. N'éxiste pas dans la base  */
#define         NAC_INDEFINI    9  /* Sert aux états financiers uniquement. N'éxiste pas dans la base  */
#define         NAC_ACTIF       1
#define         NAC_PASSIF      2
#define         NAC_AVOIR       3
#define         NAC_REVENU      4
#define         NAC_DEPENSE     5
#define         CPTCAT_BNR      "BN"
#define         OUI             "1"
#define         NON             "0"
#define         CONSOLIDE_OUI   "1"
#define         CONSOLIDE_NON   "0"
#define         TRUE            1
#define         FALSE           0

/*
 * Définition des variables environementales utilisés
 */

#define PG_USRLNG   "PG_USRLNG" /*  Langue de l'usager  */


/*
 * Définition des codes des messages
 */

#define         MESSERR         1
#define         MESSOK          2
#define         PARAMINV        3
#define         PRGNONAUT       4
#define         USANONAUT       5
#define         ANRREFINC       6
#define         ANRINV          7
#define         RECANRDEP       8
#define         JUSQUA          9
#define         ANRPOSRECNON    10
#define         TRAANN          11
#define         TRASAN          12
#define         NBROCCMAJ       13
#define         NBROCCAJOU      14
#define         TRASRE          15
#define         RECBNR          16
#define         NBROCCAJMO      17
#define         CEDINC          18
#define         COLECAINV       19
#define         COLRATINV       20
#define         CPTINC          21
#define         CREEFQ          22
#define         DETAILINV       23
#define         ECDINEX         24
#define         EFIINC          25
#define         EFIINV          26
#define         EFITROPLAR      27
#define         EXPINV          28
#define         FORMINC         29
#define         LIGREFBALINV    30
#define         LIGREFINV       31
#define         LONGBUFINS      32
#define         LONGMAXEXP      33
#define         MEMINS          34
#define         PAGTROPCOURTE   35
#define         PASDETEFI       36
#define         PECCLEINV       37
#define         RLLBCK          38
#define         SELINV          39
#define         SELINV          39
#define         DIVZERR         40
#define         CPTBNRINT       41
#define         ALLBUFIMP       42
#define         RATNONAUT       43

/*
 * Définition des codes de sortie des programmes
 */

#if VAXVMS

#include <ssdef.h>

#define         EXIT_SANS_ERREUR    SS$_NORMAL
#define         EXIT_AVEC_ERREUR    SS$_ABORT

#else

#define         EXIT_SANS_ERREUR 1L
#define         EXIT_AVEC_ERREUR 0L

#endif

/*
 * Définition de MACROS
 */

#define         SET_TRUE(A)     A=1
#define         SET_FALSE(A)    A=0

#endif
