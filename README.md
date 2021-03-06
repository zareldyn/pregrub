# PreGRUB
A boot loader that finds GRUB on another disk and runs it (old project).

Sorry for non-French speakers, perhaps one day I'll translate explanations and code comments into English.

## C'est quoi ? À quoi ça sert ?

C'est le code ASM de la routine d'amorçage à mettre dans le premier secteur (MBR) du disque dur (celui sélectionné pour le BOOT), qui va aller chercher et exécuter [GRUB](https://www.gnu.org/software/grub/) si celui-ci est installé dans les premiers secteurs d'un autre disque dur.

Aujourd'hui, je pense que ça ne sert plus. Mais avant… (laissez moi vous conter une expérience personnelle)

Remontons vers le milieu des années 2000. La sainte époque de l'AGP 4X, du PCI, de la DDR1, des Athlon XP, des northbridges/southbridges et des contrôleurs PATA.  
Une carte mère de légende, la [Abit KR7A-RAID](https://techreport.com/review/3357/abit-kr7a-raid-motherboard), fait le bonheur de son propriétaire (moi).  
Hélas, le contrôleur PATA HPT372 qu'elle embarque fait des bêtises : pour désigner l'un des HDDs branchés sur lui comme étant le HDD de BOOT, ça trouve rien de mieux que d'écrire 5 petits octets en plein milieu du secteur 9 (LBA) du disque en question. Ce ne serait pas dérangeant s'il n'y avait pas déjà des données à cet endroit, en l'occurence le code de GRUB. Je précise au passage que l'autre contrôleur PATA de la carte avait déjà 4 lecteurs à gérer, et que donc j'avais choisi de mettre mes HDDs système sur le HPT372 (ne serait-ce que pour profiter du RAID-0).

Pour pas que cette « boot mark » et GRUB ne s'écrasent mutuellement, voici une solution (il y en a sûrement d'autres) :  
Surtout ne pas installer le code de GRUB sur le disque marqué BOOT par le BIOS du HPT372, mais le mettre sur un autre disque. Il faut alors que la routine d'amorçage du HDD marqué BOOT aille charger et exécuter le code d'amorçage de GRUB (1er secteur) situé sur l'autre disque. C'est ce que fait PreGRUB.

## Comment ça marche et limitations

Une fois traduit par [NASM](https://www.nasm.us/), PreGRUB est un fichier binaire de 512 octets dont le contenu est à copier sur le 1er secteur du disque marqué BOOT. Je ne sais plus quel outil j'utilisais à l'époque pour le mettre là, toujours est-il qu'il faut faire attention à ne pas écraser la table de partitions située sur ce 1er secteur : du PreGRUB binaire (MBR sans table de partitions), seuls le code au début ainsi que le nombre magique 0xAA55 à la fin nous intéressent.

Au démarrage, PreGRUB commence par se déplacer lui-même en mémoire, car c'est à la place qu'il occupait avant que seront copiés les octets du 1er secteur de chaque HDD trouvé. Ça fait ainsi une boucle sur les disques jusqu'à ce qu'un 1er secteur contiennent la signature « GRUB ». Comme les données de ce secteur sont déjà à la bonne place en mémoire (07C00h), il n'y a plus qu'à le lancer, GRUB prend le relai.

Le petit hic dans tout ça, c'est qu'en l'état actuel PreGRUB ne fait pas de 2ème boucle pour chercher la signature « GRUB » à l'intérieur du secteur à analyser. À la place, il s'attend à la trouver exactement à un offset déterminé :
```assembly
  mov ax,[es:0x0188]
  cmp ax,0x5247                ;"GR"
  jnz rech
  mov ax,[es:0x018a]
  cmp ax,0x4255                ;"UB"
  jnz rech
```
L'offset est ici 0x0188 (et 0x018a), mais ça peut éventuellement changer lors d'une MAJ de GRUB. Il faut donc manuellement, si le cas se présente, chercher le bon offset en étudiant le 1er secteur occupé par GRUB, puis réécrire notre MBR PreGRUB avec la bonne valeur.
