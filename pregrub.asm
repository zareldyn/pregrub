;PreGRUB syntaxe NASM


[BITS 16]                      ;mode réel
[ORG 0x0]


;=== tout ce programme sera d'abord logé à 07C00h, mais on va le déplacer =====;

  mov ax,0x07c0                ;initialisation segments de données
  mov ds,ax
  mov ax,0x0060                ;par convention, l'adresse pour déplacer ce code est 00600h
  mov es,ax
  mov ax,0x5000                ;initialisation segment de pile (choix d'emplacement et taille arbitraires)
  mov ss,ax
  mov sp,0xf000

  cld
  mov cx,200                   ;on va copier 200 octets de code
  mov si,34                    ;la copie doit commencer par le 35ème octet (eh oui avant c'est le code de copie ;-))
  xor di,di
  rep movsb                    ;et c'est parti, on reloge la suite
  jmp 0x0060:00                ;"far jump" à [es:0]


;=== code qui sera exécuté depuis 00600h ======================================;

  mov ax,0x0060                ;initialisation segments de données (échange ds<->es)
  mov ds,ax
  mov ax,0x07c0
  mov es,ax
  mov dl,0x7f                  ;dl contiendra le numéro du disque dur testé

  mov si,MESS_DEB-34
  call AFFICHER
  mov si,DAP-34

rech:                          ;boucle de recherche d'un secteur d'amorçage contenant le début de GRUB
  inc dl
  cmp dl,0x88
  jz  erreur                   ;on teste tout de même jusqu'à un éventuel 8ème disque dur...
  mov ah,0x42
  int 0x13                     ;on écrase joyeusement le contenu de 07C00h avec un secteur à tester
  jc  rech
  mov ax,[es:0x0188]
  cmp ax,0x5247                ;"GR"
  jnz rech
  mov ax,[es:0x018a]
  cmp ax,0x4255                ;"UB"
  jnz rech

ok:                            ;signature "GRUB" trouvée
  mov si,MESS_GOK-34
  call AFFICHER
  jmp 0x07c0:00                ;"far jump" à [es:0] pour exécuter le secteur d'amorçage de GRUB

erreur:
  mov si,MESS_ERR-34
  call AFFICHER
err:
  jmp err

AFFICHER:
  xor bx,bx
  mov ah,0x0e
debAFFICH:
  lodsb
  or al,al
  jz  finAFFICH
  int 0x10
  jmp debAFFICH
finAFFICH:
  ret


;=== données nécessaires à l'exécution de PreGRUB =============================;

DAP   db 16,0,1,0              ;sera lu par l'int 13h (mode LBA)
  OFS dw 0
      dw 0x07C0
  SEC dd 0,0

MESS_DEB db "PreGRUB -> GRUB ",0
MESS_GOK db "OK",13,10,0
MESS_ERR db "absent, CTRL-ALT-SUPPR pour redemarrer",13,10,0


;=== données en plus pour faire de PreGRUB un secteur de 512 octets ===========;

times 510-($-$$) db 0          ;à compléter éventuellement avec une table de partitions
dw 0xAA55                      ;signature pour le BIOS
