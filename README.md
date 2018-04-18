# PreGRUB
A boot loader that finds GRUB on another disk and runs it (old project)

Sorry for non-French speakers, perhaps one day I'll translate explanations and code comments into English.

## C'est quoi ? À quoi ça sert ?

C'est le code à mettre dans le premier secteur du disque dur (celui sélectionné pour le BOOT) qui va aller chercher et exécuter [GRUB](https://www.gnu.org/software/grub/) si celui-ci est installé dans les premiers secteurs d'un autre disque dur.

Aujourd'hui, je pense que ça ne sert plus. Mais avant… (laissez moi vous conter une expérience personnelle)

Remontons vers le milieu des années 2000. La sainte époque de l'AGP 4X, du PCI, de la DDR1, des Athlon XP, des northbridges/southbridges et des contrôleurs PATA.  
Une carte mère de légende, la [Abit KR7A-RAID](https://techreport.com/review/3357/abit-kr7a-raid-motherboard), fait le bonheur de son propriétaire (moi).  
Hélas, le contrôleur PATA HPT372 qu'elle embarque fait des bêtises : pour désigner l'un des HDDs branchés sur lui comme étant le HDD de BOOT, ça trouve rien de mieux que d'écrire 5 petits octets en plein milieu du secteur 9 (LBA) du disque en question. Ce ne serait pas dérangeant s'il n'y avait pas déjà des données en cet endroit, en l'occurence le code de GRUB. Je précise au passage que l'autre contrôleur PATA de la carte avait déjà 4 lecteurs à gérer, et que donc j'avais choisi de mettre mes HDDs système sur le HPT372 (ne serait-ce que pour profiter du RAID-0).

Pour pas que cette « boot mark » et GRUB ne s'écrasent mutuellement, la seule solution est alors :  
Surtout ne pas installer le code de GRUB sur le disque marqué BOOT par le BIOS du HPT372, mais le mettre sur un autre disque. Il faut alors que le code d'amorçage du HDD marqué BOOT aille charger et exécuter le code d'amorçage de GRUB (1er secteur) situé sur l'autre disque. C'est ce que fait PreGRUB.

## Comment ça marche et limitations

TODO
