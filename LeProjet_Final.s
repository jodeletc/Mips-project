##################################################################################################
#                               Projet: TRAITEMENTS D'IMAGES en MIPS                             #                                    
#                                         réalisé par:                                           #        
#                                    Ahmed MOHAMED YONIS                                         #                   
#                                            et                                                  # 
#                                       Jodel ALCINDOR                                           #
##################################################################################################                                                                                       


.data
bienvenue: .asciiz "Bienvenue dans notre incroyable programme qui applique le filtre de sobel à une image ! \n"

bits : .asciiz "Malheureusement nous ne pouvons traiter uniquement les images codés sur 8bits...faute de temps nos programmeurs n'ont pu implémenter un programme capable de traiter n'importe quelle image .... (c'est ce qu'ils disent mais à vrai dire ils sont nuls xD ...)\n"

commencement: .asciiz "COMMENÇONS ! Nous ésperons que vous allez passer une incroyable expérience et que vous apprécierez le moment (et que vous nous donnerez une excellente note !!)\n"

debut: .asciiz "Tapez 1 pour débuter ou 0 pour quitter\n"

question: .asciiz "Bon choix ! \nÀ présent veuillez entrer le nom du document a ouvrir\n"                        
au_revoir: .asciiz "\nFin du programme ! À très bientôt !\n"

image_init:	.space 32                   	  #tableau pour stocker le nom du fichier entrant
image_result:	.space 39            	      	  #tableau pour stocker le nom du fichier résultant
extension: .asciiz "Contour"			  #L'extension Contour a ajouter a la fin du fichier sortant

masque1: .byte 1, 0, -1, 2, 0, -2, 1, 0, -1       #le masque fx
masque2:.byte 1, 2, 1, 0, 0, 0, -1, -2, -1        #le masque fy

sentinelle: .asciiz "\0"			  #la sentinelle "\0" codé en dur dans la variable sentielle 
point: .word 46					  # "." passé en code ascii
bm:             .space 2
identification: .space 4
taille:         .space 4
antislashn: .asciiz "\n"			  #l'anti-slash n codé en dur dans la variable antislashn		

draft : .space 1000
.text


main:
li $v0 4			
la $a0 bienvenue
syscall  

li $v0 4			
la $a0 bits	
syscall

li $v0 4			
la $a0 commencement	
syscall 

li $v0 4			
la $a0 debut	
syscall     

li $v0 5			
syscall 

beqz $v0 fin_du_programme

li $v0 4			
la $a0 question	
syscall       		 			#Appel systeme 4 pour afficher une chaine de caracteres 
	
la $a0 image_init				#sauvegarde du nom du fichier dans image_init(tableau statique)		
li $a1 31					#sauvegarde de la taille max de la chaine (+ 1 apres pour \0)
li $v0 8 					#appel système 8 pour afficher une chaine de caracteres
syscall 

move $a3 $a0 					#sauvegarde de l'adresse de la chaine(dans le tableau image_init) dans $a3
la $a2 antislashn 				#sauvegarde de &(antislahn) dans $a2
lb $t5 0($a2) 					
li $s1 0 					#compteur ici = 0;(Initialisation)
parcours:
beq $a1 $s1 fin 				#Si on a parcouru toute la chaine, on a fini
lb $t4 0($a3) 					#Sauvegarde de la lettre lue dans $t4
beq $t4 $t5 echange 				#Condition: lorsqu'on tombe sur \n on met \0 a sa place pour marquer la fin
addi $a3 $a3 1 					#On va a la case suivante pour lire le caractere suivant
addi $s1 $s1 1 					#compteur++
j parcours 
echange:
la $a2 sentinelle 				#chargement de &(sentinelle) pour le changement 
lb $t5 0($a2) 					
sb $t5 0($a3) 					
fin:	
la $a0 image_init
la $a1 image_result


la $a2 point 					#chargement de &(point)
lb $t5 0($a2)
boucle_init:
lb $t0 0($a0) 					#On va lire caractere par caractere
beq $t0 $t5 completer 				#aller a completer lorsqu'on trouve le point
sb $t0 0($a1) 					#On range tous les autres caracteres dans $a1(nom du fichier resultant)
addi $a0 $a0 1 				
addi $a1 $a1 1					#Incrementons les adresses(case suivante)
j boucle_init 
completer:
move $s0 $a0 					#sauvegarde de t[i] = .
la $a3 extension 				#chargement de &(extension)
li $t1 0 					#i 
li $t2 7 					#la taille de l'extension (ici :contour)
boucle_suiv:
beq $t1 $t2 fin_reecriture			
lb $t0 0($a3) 					#sauvegardons dans $t0 caractere par caractere(A chaque tour de boucle)
sb $t0 0($a1) 					#On recopie dans $a1(Adresse de la chaine du fich. res.) chaque carac.
addi $t1 $t1 1 					#i++;
addi $a1 $a1 1 					
addi $a3 $a3 1 
j boucle_suiv
fin_reecriture:					#A la fin il nous reste a ajouter .bmp dans $a1(caractere par caractere)
lb $t0 0($a0) 					#Ajoutons l'extension finale .bmp au fichier
sb $t0 0($a1) 					
lb $t0 1($a0) 					#Sauvegarde de "b" dans $t0 et ainsi de suite
sb $t0 1($a1) 					#On écrit l'élement de $t0 dans $a1 et ainsi de suite
lb $t0 2($a0) 					
sb $t0 2($a1) 					
lb $t0 3($a0) 					
sb $t0 3($a1) 					
la $a2 sentinelle 				
lb $t5 0($a2) 					
sb $t5 4($a1) 					#Marquons la fin de la chaine	                

############################################### OUVRONS LE DOCUMENT PASSE EN PARAMETRES ################################################

ouvrir_doc:
li $v0 13				#Appel systeme pour ouvrir un document en mémoire
la $a0 image_init
li $a1 0				
li $a2 0				#On lit le mode
syscall

move $s0 $v0				#sauvegarde dans $s0 le descripteur du document stocké initialement dans $v0
	
li $v0 13
la $a0 image_result
li $a1 1
li $a2 0
syscall
move $s1 $v0				
	
######################################################### REECRIVONS L'ENTETE ##########################################################
subu $sp $sp 4
li $v0 9
li $a0 1078				#Allouons de la mémoire 
syscall
sw $v0 0($sp)			

li $v0 14			
move $a0 $s0				
lw $a1 ($sp)
li $a2 1078
syscall
	
li $v0 15			
move $a0 $s1
lw $a1 0($sp)
li $a2 1078
syscall
	
	
######################################################### FERMONS LE DOCUMENT  ##########################################################
fermonsdoc:
li $v0 16			#Appel systeme pour fermer un document en mips
move $a0 $s0			#Sans oublier de recopier le descripteur du fichier dans $a0
syscall



###################################### OUVRONS LE DOCUMENT A NOUVEAU POUR PRENDRE DES INFORMATIONS #####################################

li $v0 13
la $a0 image_init
li $a1 0
li $a2 0
syscall
move $s0 $v0
			
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0			#Ensuite on charge dans $a0 le descripteur du fichier
la $a1 bm			#On charge l'adresse pour prendre les données 
li $a2 2			#On lit 2 octets
syscall

#POUR LA LONGUEUR
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
move $a1 $sp
li $a2 4			#On lit 4 octets
syscall
lw $s2 ($sp)           		#sauvegarde du resultat dans $s2

li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
la $a1 identification		#On charge l'adresse pour prendre les données
li $a2 4			#On lit 4 octets
syscall

#L'OFFSET	
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
move $a1 $sp
li $a2 4			#On lit 4 octets
syscall
lw $s3 0($sp)			#sauvegarde du resultat dans $s3
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
la $a1 taille
li $a2 4			#On lit 4 octets 
syscall

#LA LARGEUR
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
move $a1 $sp
li $a2 4			#On lit 4 octets 
syscall
lw $s4 ($sp)
    			
#LA HAUTEUR			#Appel systeme pour lire le fichier
li $v0 14
move $a1 $sp
li $a2 4			#On lit 4 octets
syscall	
lw $s5 ($sp)
addu $sp $sp 4	


##############################################################  FERMETURE DU FICHIER ###################################################
li 	$v0 16
move 	$a0 $s0
syscall

######################################################################################################################################
# Si on suit  ce qui a été dit dans  le sujet  jusque la l'image s'étale sur 1078 octets:
# 14(entete du fichier) + 40(entete de l'image) + la palette de couleur(4 * 256 nombres de couleur) = 1078

li $v0 13
la $a0 image_init
li $a1 0
li $a2 0
syscall
move $s0 $v0
	
subu $sp $sp 8		

li $v0 14			
move $a0 $s0
la $a1 draft
li $a2 1078
syscall	
			
	
#COMMENCONS A RECOPIER LA MATRICE 
    	
subu $s2 $s2 1078		
li $v0 9			#Appel systeme pour allouer de la mémoire.		
move $a0 $s2			
syscall
sw $v0 0($sp)
	
li $v0 14			#Appel systeme pour lire le fichier 
move $a0 $s0
lw $a1 0($sp)			#On copie la matrice correspondant à l'image
move $a2 $s2
syscall

#RÉSERVONS UNE PLACE POUR LA FUTURE IMAGE

li $v0 9			#Appel systeme pour allouer de la mémoire
move $a0 $s2			
syscall
sw $v0 4($sp)			#Place pour stocker temporairement l'image résultante
#######################################################################################################################################

#CALCUL DE LA CONVULUTION
#Chaque masque fx, fy sera multiplié par la matrice de l'image

lw $a1 4($sp)			#Image résultante
lw $a2 ($sp)			#Image initiale
jal produit_convolution


#APRES CALCUL, ECRIVIONS LA SUITE DANS L'IMAGE RESULTANTE

li $v0 15		      #Appel systeme pour ecrire dans un fichier
move $a0 $s1
lw $a1 4($sp)
move $a2 $s2
syscall


li $v0 16
move $a0 $s0		     #Fermons le premier fichier définitivement
syscall
	
li $v0 16		     #Fermons l'autre
move $a0 $s1
syscall

fin_du_programme:
li $v0 4			
la $a0 au_revoir
syscall 
li $v0 10		     #Appel systeme pour fermer le fichier
syscall

#################################################### FONCTIONS AUXILIAIRES DEFINIES ####################################################

seuiltest:
#prologue
subu $sp $sp 4
sw $ra ($sp)
	
ble $a0 $a1 etape2	    #Si $a1>= a0, sauter a l'etape2. $a0 etant l'entier a seuiller.
li $a0 255		    #Sinon, ramener $a0 a 255
etape2:
bge $a0 $a2 fin_seuil_test  #Si $a0 >= $a2. sauter a la fin
li $a0 0		    #Sinon ramener #$a0 a 0
#epilogue	
fin_seuil_test:
move $v0 $a0
lw $ra ($sp)
addu $sp $sp 4
jr $ra

########################################################################################################################################
		
pointM:
#prologue    
subu $sp $sp 20
sw $s0 16($sp)
sw $a0 12($sp)
sw $a1 8($sp)
sw $a2 4($sp)
sw $ra 0($sp)
#code
mulu $s0 $a0 $s4			#s0 = a0 * s4 (i * largeur)
addu $s0 $s0 $a1			#s0 = s0 + a1 (i * largeur + j)
addu $a2 $a2 $s0   			#a2 = a2 + s0 ($a2 + decalage)
lb $v0 ($a2) 				#Sauvegarde du resultat dans V0
li $a2 256
divu $v0 $a2
mfhi $v0         			
#épilogue
lw $s0 16($sp)
lw $a0 12($sp)
lw $a1 8($sp)
lw $a2 4($sp)
lw $ra 0($sp)
addu $sp $sp 20
jr $ra

########################################################################################################################################
	
pointF:
#prologue
subu $sp $sp 20
sw $s0 16($sp)
sw $a0 12($sp)
sw $a1 8($sp)
sw $a2 4($sp)
sw $ra 0($sp)
#code
mulu $s0 $a0 3				# $s0 = $a0 * 3   (i * 3)
addu $s0 $a1 $s0			# $s0 = $s0 + $a1 (i * 3 + j)
addu $a2 $a2 $s0			# $a2 = $a2 + $s0 (decalage)
lb $v0 ($a2)     			# on load l'octet qui est à la place (i,j) ($a2)
#épilogue 
lw $s0 16($sp)
lw $a0 12($sp)
lw $a1 8($sp)
lw $a2 4($sp)
lw $ra 0($sp)
addu $sp $sp 20
jr $ra

########################################################################################################################################
convolution:
#prologue
subu $sp $sp 36
sw $a0 ($sp)
sw $a1 4($sp)
sw $a2 8($sp)
sw $s0 12($sp)
sw $s1 16($sp)
sw $s2 20($sp)
sw $s3 24($sp)
sw $s5 28($sp)
sw $ra 32($sp)
#code
#On teste si on se trouve aux extrémités de l'image si oui on retourne 0
move $t0 $s4                  	# $t0 = largeur
move $t1 $s5			# $t1 = longueur
beqz $a0 end0
beqz $a1 end0
subi $t0 $t0 1
subi $t1 $t1 1
beq $a0 $t0 end0
beq $a1 $t0 end0

#Sinon on commence la convolution au point ($a0, $a1)
move $t0 $a0    
move $t1 $a1    
li $s0 -1  			#k
li $s1 0   			#l
li $t7 3  			#taile des masques
li $s5 0  			#somme


loopk:
addu $s0 $s0 1
bge $s0 $t7 end_conv
li $s1 0
loopl:
bge $s1 $t7 loopk
move $a0 $s0
move $a1 $s1
lw $a2 8($sp)
jal pointF				# on prend le point F($a0,$a1)
move $s2 $v0
subi $t2 $t0 1				# $t2 = $t0 - 1
addu $t2 $t2 $s0			# $t2 += k
subu $t3 $t1 1				# $t3 = $t1 - 1
addu $t3 $t3 $s1			# $t3 += l
move $a0 $t2				
move $a1 $t3
move $a2 $a3
jal pointM				# on prend le point A($t2, $t3)
move $s3 $v0
mulu $s2 $s2 $s3			# faisons la somme de ces deux points
addu $s5 $s5 $s2			# on les ajoute à $s5
addu $s1 $s1 1
j loopl
	
	
end0:
li $v0 0
j end_conv	
end_conv:
#épilogue
move $v0 $s5
lw $a0 ($sp)
lw $a1 4($sp)
lw $a2 8($sp)
lw $s0 12($sp)
lw $s1 16($sp)
lw $s2 20($sp)
lw $s3 24($sp)
lw $s5 28($sp)
lw $ra 32($sp)
addu $sp $sp 36
jr $ra

#########################################################################################################################################
#CALCULONS GX ET GX EN UTILISANT LE MASQUE FX OU FY 
# EN DEUXIEME LIEU NOUS ALLONS SEUILLER LES RESULTATS OBTENUS
# => PRENDRE LES VALEURS ABSOLUES DES ELEMENTS DE GX ET DE GY

produit_convolution:
#prologue
subu $sp $sp 32
sw $a1 0($sp)
sw $a2 4($sp)
sw $s0 8($sp)
sw $s1 12($sp)
sw $s2 16($sp)
sw $ra 20($sp)
sw $s3 24($sp)
sw $s5 28($sp)
#code
li $s0 -1				#On met le décompte des lignes a -1	
li $s1 0				#on met le décompte des colonnes a 0
loopi:
addi $s0 $s0 1
bgt $s0 $s4 end_produit
li $s1 0			
	
loopj:	
bgt $s1 $s5 loopi
move $a0 $s0
move $a1 $s1
la $a2 masque1				#chargement de l'adresse du masque 1
lw $a3 4($sp)
jal convolution				#convolution avec fx 

abs $s2 $v0                     	#On prends la valeur absolue du résultat retourné
	
move $a0 $s0
move $a1 $s1
la $a2 masque2				#chargement de l'adresse du masque 2
lw $a3 4($sp)
jal convolution				#convolution avec fy 
	
abs $s6 $v0				#On prend la valeur absolue du résultat retourné
	
addu $s2 $s6 $s2
	
move $a0 $s2
li $a1 255
li $a2 230
jal seuiltest				#Aplliquons le seuillage	
	
abs $s6 $v0
lw $a1 0($sp)       
	
	
mul $s3 $s0 $s4				# s3 = s0 * s4
add $s3 $s3 $s1	        		# s3 = s3 + s1
add $a1 $a1 $s3 		
sb $s6 0($a1)				#On sauvegarde chaque résultat(pixel) apres chaque calcul


addi $s1 $s1 1				#On incrémente notre compteur
j loopj

#épilogue
end_produit:
lw $a1 0($sp)
lw $a2 4($sp)
lw $s0 8($sp)
lw $s1 12($sp)
lw $s2 16($sp)
lw $ra 20($sp)
lw $s3 24($sp)     
lw $s5 28($sp)     
addu $sp $sp 32
jr $ra	
