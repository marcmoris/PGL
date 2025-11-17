/*
** Fonction    : MC950.E
** Module      : Module commun
**
** Auteur      : Thomas BRENNEUR
** Créé le     : 13 Mai 1992
**
** Description : Affichage des messages d'erreur en fonction de la langue de
**               l'usager.
**
** Paramètres d'entrée  :
**
**              .Nom du programme appelant,
**              .Langue de l'usager,
**              .Severité du message (information,succès,attention,erreur...),
**              .Numéro du message.
**
** Paramètres de sortie :
**
**              .Code d'erreur à renvoyer au système d'exploitation
**               si necessaire
*/

#include <stdio.h>

#include "mc950.h" /* Paramètres de configuration communs */

/*
 * Niveau de sévérité
 */

#define INFORMATION     0
#define SUCCES          1
#define ATTENTION       2
#define ERREUR          3

/*
 * Table des significations des sévérités
 */

struct str_severite
{
  int severite;                         /* Code de sévérité                */
  struct {
   char lngcle;                         /* Code de langue                  */
   char code;                           /* Code de la sevérité             */
  } element[NOMBRE_LANGUES];            /* severite (1 par langue)         */
};

struct str_severite table_severite[] =
{
 { INFORMATION, {{FRA,'I'},
                 {ANG,'I'}} },
 { SUCCES     , {{FRA,'S'},
                 {ANG,'S'}} },
 { ATTENTION  , {{FRA,'A'},
                 {ANG,'W'}} },
 { ERREUR     , {{FRA,'E'},
                 {ANG,'E'}} }
};

/*****************************************************************************
 *                              Table des messages.
 *                        * * *  A T T E N T I O N  * * *
 *
 *     Les numéros des messages sont définis par des codes alphanumériques.
 *                 Ces codes sont définis dans le fichier GL950.H
 * Si vous rajoutez un message, il faut donc aussi modifier le fichier GL950.H
 * Et il faut ABSOLUMENT terminer la table par le message de code 0 = fin
 *****************************************************************************
 */

struct str_message
{
  int  code_message;
  int  severite;                /* Sévérité du message               */
  struct {
   char lngcle;                 /* Code de langue                    */
   char *txt_mess;              /* Texte                             */
  } mess_lang[NOMBRE_LANGUES];   /* Texte du message ( 1 par langue ) */
};

struct str_message table_message[] =
{
 {MESSERR,  ERREUR,     {{FRA,"MESSERR, Une erreur est survenue lors de l'exéccution du programme.\n"},
                         {ANG,"MESSERR, An error has occured during program execution.\n"}}},
 {MESSOK,   SUCCES,     {{FRA,"MESSOK, Programme terminé avec succes.\n"},
                         {ANG,"MESSOK, Program terminated successfully.\n"}}},
 {PARAMINV, ERREUR,     {{FRA,"PARAMINV, paramètre invalide.\n"},
                         {ANG,"PARAMINV, invalid parameter.\n"}}},
 {PRGNONAUT,ERREUR,     {{FRA,"PRGNONAUT, programme non autorisé.\n"},
                         {ANG,"PRGNONAUT, unauthorized program.\n"}}},
 {USANONAUT,ERREUR,     {{FRA,"USANONAUT, usager non autorisé.\n"},
                         {ANG,"USANONAUT, unauthorized user.\n"}}},
 {ANRREFINC,ERREUR,     {{FRA,"ANRREFINC, année de référence inconnue.\n"},
                         {ANG,"ANRREFINC, reference year not found.\n"}}},
 {ANRINV,   ERREUR,     {{FRA,"ANRINV, année de référence invalide.\n"},
                         {ANG,"ANRINV, invalid reference year.\n"}}},
 {RECANRDEP,INFORMATION,{{FRA,"RECANRDEP, recalcul de l'année de référence depuis : "},
                         {ANG,"RECANRDEP, compute of reference year from : "}}},
 {JUSQUA,   INFORMATION,{{FRA,"JUSQUA, jusqu'a : "},
                         {ANG,"JUSQUA, to : "}}},
 {ANRPOSRECNON,ATTENTION,{{FRA,"ANRPOSRECNON, année de référence postérieure à l'année demandée, pas de recalcul.\n"},
                          {ANG,"ANRPOSRECNON, Reference year prior to year requested, no recalc.\n"}}},
 {TRAANN,   INFORMATION,{{FRA,"TRAANN, traitement des années : "},
                         {ANG,"TRANN, processing years : "}}},
 {TRASAN,   INFORMATION,{{FRA,"TRASAN, traitement des soldes annuels.\n"},
                         {ANG,"TRASAN, annual balance processing.\n"}}},
 {NBROCCMAJ,INFORMATION,{{FRA,"NBROCCMAJ, nombre d'occurences mises à jour : "},
                         {ANG,"NBROCCMAJ, number of occurences updated : "}}},
 {NBROCCAJOU,INFORMATION,{{FRA,"NBROCCAJOU, nombre d'occurences ajoutées : "},
                          {ANG,"NBROCCAJOU, number of occurences added : "}}},
 {TRASRE,   INFORMATION,{{FRA,"TRASRE, traitement des soldes restrictifs.\n"},
                         {ANG,"TRASRE, restricted balance processing.\n"}}},
 {RECBNR,   INFORMATION,{{FRA,"RECBNR, recalcul des BNR.\n"},
                         {ANG,"RECNBR, recalc. of NAB.\n"}}},
 {NBROCCAJMO,INFORMATION,{{FRA,"NBROCCAJMO, nombre d'occurences ajoutées ou modifiées : "},
                          {ANG,"NBROCCAJMO, number of added or updated occurences : "}}},
 {CEDINC,    ATTENTION  ,{{FRA,"CEDINC, Cédule inconnue : "},
                          {ANG,"CEDINC, Unknown scedule : "}}},
 {COLECAINV, ATTENTION  ,{{FRA,"COLECAINV, Colonne écart invalide (pas de colonnes possibles pour le calcul).\n"},
                          {ANG,"COLECAINV, Invalid column ??? (no possible column for calcul.)\n"}}},
 {COLRATINV, ATTENTION  ,{{FRA,"COLRATINV, Colonne ratio invalide (pas de colonnes possibles pour le calcul).\n"},
                          {ANG,"COLRATINV, Invalid column ratio (no possible columns for calc.)\n"}}},
 {CPTINC,    ATTENTION  ,{{FRA,"CPTINC, Numéro de compte inconnu :"},
                          {ANG,"CPTINC, Unknown account number :"}}},
 {CREEFQ,    INFORMATION,{{FRA,"CREEFQ, Création du numéro séqentiel pour les EF.\n"},
                          {ANG,"CREEFQ, Creation of sequential number for the FS.\n"}}},
 {DETAILINV, ATTENTION  ,{{FRA,"DETAILINV, Ligne de détail invalide.\n"},
                          {ANG,"DETAILINV, Invalid detail line.\n"}}},
 {ECDINEX,   ERREUR     ,{{FRA,"ECDINEX, Détail de cédule inexistant : "},
                          {ANG,"ECDINEX, Scedule detail does not exist :"}}},
 {EFIINC,    ATTENTION  ,{{FRA,"EFIINC, Etat financier inconnu :"},
                          {ANG,"EFIINC, Unknown financial statement :"}}},
 {EFIINV,    ATTENTION  ,{{FRA,"EFIINV, Etat financier inconnu ou invalide :"},
                          {ANG,"EFIINV, Unknown or invalid financial statement :"}}},
 {EFITROPLAR,ATTENTION  ,{{FRA,"EFITROPLAR, Définition des colonnes trop large pour la largeur de page demandée.\n"},
                          {ANG,"EFITROPLAR, Column definition too wide for requested page width.\n"}}},
 {EXPINV,    ATTENTION  ,{{FRA,"EXPINV, Expression de calcul invalide :"},
                          {ANG,"EXPINV, Invalid calculation expression :"}}},
 {FORMINC,   ATTENTION  ,{{FRA,"FORMINC, Format inconnu :"},
                          {ANG,"FORMINC, Unknown format :"}}},
 {LIGREFBALINV,ATTENTION,{{FRA,"LIGREFBALINV, Ligne de référence de balance invalide :"},
                          {ANG,"LIGREFBALINV, Invalid reference balance line :"}}},
 {LIGREFINV,   ATTENTION,{{FRA,"LIGREFINV, Ligne de référence invalide :"},
                          {ANG,"LIGREFINV, Invalid reference line :"}}},
 {LONGBUFINS,  ERREUR   ,{{FRA,"LONGBUFINS, Longeur du buffer de travail insuffisante. CONTACTEZ LE SUPPORT TECHNIQUE PROSIG !.\n"},
                          {ANG,"LONGBUFINS, Insufficient working buffer. CONTACT PROSIG TECHNICAL SUPPORT !.\n"}}},
 {LONGMAXEXP,  ATTENTION,{{FRA,"LONGMAXEXP, Expression de calcul trop grande :"},
                          {ANG,"LONGMAXEXP, Calculation expression too big :"}}},
 {MEMINS,      ERREUR   ,{{FRA,"MEMINS, Mémoire insuffisante.\n"},
                          {ANG,"MEMINS, Insufficient memory.\n"}}},
 {PAGTROPCOURTE,ATTENTION,{{FRA,"PAGTROPCOURTE, Longueur de page trop courte pour imprimer cet état financier :"},
                           {ANG,"PAGTROPCOURTE, Page length too short to print this financial statement :"}}},
 {PASDETEFI,   ATTENTION,{{FRA,"PASDETEFI, Pas de détail dans l'état financier :"},
                          {ANG,"PASDETEFI, No detail in financial statement :"}}},
 {PECCLEINV,   ATTENTION,{{FRA,"PECCLEINV, Période comptable inconnue.\n"},
                          {ANG,"PECCLEINV, Unknown accounting period.\n"}}},
 {RLLBCK,      ATTENTION,{{FRA,"RLLBCK, Annulation de toutes les modifications. Rollback...\n"},
                          {ANG,"RLLBCK, All updates are cancelled. Rollback...\n"}}},
 {SELINV,      ATTENTION,{{FRA,"SELINV, Sélection invalide :"},
                          {ANG,"SELINV, Invalid selection."}}},
 {DIVZERR,     ATTENTION,{{FRA,"DIVZERR, Division par zéro dans le calcul. Résultat forcé à 0.\n"},
                          {ANG,"DIVZERR, Division by zero in calculation. Result forced to 0.\n"}}},
 {CPTBNRINT,   ERREUR   ,{{FRA,"CPTBNRINT, Compte de BNR introuvé.\n"},
                          {ANG,"CPTBNRINT, R.E. account not found.\n"}}},
 {ALLBUFIMP,   ERREUR   ,{{FRA,"ALLBUFIMP, Allocation impossible du buffer d'écriture du fichier d'impression.\n"},
                          {ANG,"ALLBUFIMP, Printing buffer allocation is not possible.\n"}}},
 {RATNONAUT,   ATTENTION,{{FRA,"RATNONAUT, Vous ne pouvez pas utiliser une colonne RATIO dans une expression de calcul : "},
                          {ANG,"RATNONAUT, You may not use a RATIO column in a CALC expression : "}}},
 {0,0,{{' ',""},{' ',""}}} /****** FIN DE LA TABLE ******/
};


/*
**------------------------------------------------------------------------------
** Programme principal
**------------------------------------------------------------------------------
*/

int mc950(nom_programme,langue_usager,numero_message)
char    *       nom_programme;
char            langue_usager;
int             numero_message;
{

 /*
  * Déclaration des variables locales.
  */

  int indice_langue;
  int indice_message;

 /*
  * Recherche du message dans la table
  */

  for ( indice_message = 0;
           table_message[indice_message].code_message != numero_message
        && table_message[indice_message].code_message != 0;
        indice_message++ );

  if (table_message[indice_message].code_message == 0)
   {
    fprintf(stderr,"MC950-A-MESSINC, Message numéro %d. inconnu!.",numero_message);
    return(ATTENTION);
   }

 /*
  * Recherche du code de sévérité associé à la langue
  */

  for ( indice_langue=0;
           indice_langue < NOMBRE_LANGUES
        && (   table_severite[table_message[indice_message].severite].element[indice_langue].lngcle
            != langue_usager );
        indice_langue++ );

  if (indice_langue == NOMBRE_LANGUES)
    indice_langue = 0;

 /*
  * Affichage du message trouvé
  */

  fprintf ( stderr,"%s-%c-%s"
                  ,nom_programme
                  ,table_severite[table_message[indice_message].severite].element[indice_langue].code
                  ,table_message[indice_message].mess_lang[indice_langue].txt_mess
          );

  return(table_message[indice_message].severite);
}
