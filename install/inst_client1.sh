# Script pour exécution chez le client
#
# Il est à noter que :
#      Quand ce script est exécuter chez le client, les variables 
#      d'envirronnement PG_* sont corrects. On est déjà positionner dans le
#      répertoire PG_INSTALL.
# On reçoit en paramètre : 1er   Usager Oracle que l'on installe.
#                          2ième Mot de passe de cette Usager.
#                          3ième Host de cette usager.
#
#
# Sert car on repasse les triggers sur les tables, les éléments de ces tables
# tombe en read_only.
#
echo '
Update rdb$relation_fields Set rdb$update_flag = 1
Where ( rdb$relation_name ) In
      ( Select rdb$relation_name 
          From rdb$relations
         Where rdb$relation_name not like "RDB%" 
           And rdb$relation_name not like "QLI%" 
           And rdb$relation_name not In 
               ( Select distinct rdb$view_name 
                   From rdb$view_relations 
               )
      )
  And rdb$update_flag=0;
exit; ' | isql $PG_DATA/dict.gdb
