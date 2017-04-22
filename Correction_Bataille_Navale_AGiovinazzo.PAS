Program bataille_navale2;

uses crt,sysutils;

CONST
	NBBATEAU=1; //J'ai mis 1 pour tester plus facilement
	MAXCASE=5;
	MINL=1;
	MAXL=10;
	MINC=1;
	MAXC=10;
	NBFLOTTE=2;

TYPE Cellule = record
		ligne:integer;
		col:integer;
END;

TYPE Bateau = record
		nCell:array[1..MAXCASE] of Cellule;
END;

TYPE Flotte = record
		nBateau:array[1..NBBATEAU] of Bateau;

END;

TYPE Joueur=array[1..NBFLOTTE] of Flotte;

TYPE PositionBateau=(enLigne,enColonne,enDiag);

TYPE EtatBateau=(Touche,Coule);

TYPE EtatFlotte=(AFlot,ASombre);

TYPE EtatJoueur=(Gagne,Perd);

PROCEDURE CreationCellule(l,c:integer;VAR nCell:Cellule);

	BEGIN
		nCell.ligne:=l;
		nCell.col:=c;
	END;


FUNCTION CompCellule(n1Cell:Cellule;n2Cell:Cellule):boolean;

	BEGIN
		IF ((n1Cell.ligne=n2Cell.ligne) AND (n1Cell.col=n2Cell.col)) THEN
			CompCellule:=true
		ELSE
			CompCellule:=false;
	END;

FUNCTION CreationBateau(nCell:Cellule;taille:integer):Bateau;

	VAR
		res:Bateau;
		i,pos:integer;
		posBateau:PositionBateau; //Type énuméré

	BEGIN

		randomize;
		pos:=random(3)+1;
		posBateau:=PositionBateau(pos);
		
		FOR i:=1 TO MAXCASE DO//Nombre de case du bateau
			BEGIN
				IF (i<=taille) THEN//Taille est un random d'une taille de bateau
					BEGIN
						res.nCell[i].ligne:=nCell.ligne;
						res.nCell[i].col:=nCell.col;
					END
				ELSE
					BEGIN
						res.nCell[i].ligne:=0;
						res.nCell[i].col:=0;
					END;
				

				IF (posBateau=enLigne) THEN
					nCell.col:=nCell.col+1
				ELSE
					BEGIN
						IF (posBateau=enColonne) THEN
							nCell.ligne:=nCell.ligne+1
						ELSE
							BEGIN
								nCell.ligne:=nCell.ligne+1;
								nCell.col:=nCell.col+1;
							END;
					END;
			
			END;

		CreationBateau:=res;

	END;

FUNCTION CtrlCell(nBat:Bateau;nCell:Cellule):Boolean;

//Vérifie que la cellule saisie est identique à l'une des cellules d'un bateau.

	VAR
		i:integer;
		valTest:Boolean;

	BEGIN
		valTest:=false;

		FOR i:=1 TO MAXCASE DO
			BEGIN
				IF (CompCellule(nBat.nCell[i],nCell)) THEN
					valTest:=True;
			END;

		CtrlCell:=valTest;

	END;

FUNCTION CtrlFlotte(nFlotte:Joueur;nCell:Cellule;i:integer):Boolean;

// Vérifie que la cellule saisie est identique à l'une des cellules d'un bateau d'une flotte.
	VAR
		j:integer;
		valTest:boolean;

	BEGIN

		valTest:=false;

		FOR j:=1 TO NBBATEAU DO
			BEGIN
				IF (CtrlCell(nFlotte[i].nBateau[j],nCell)) THEN
					valTest:=true;
			END;

		CtrlFlotte:=valTest;

	END;

PROCEDURE ChoixLCT(VAR taille:integer;j:integer;i:integer;VAR nCell:Cellule); //Permet au joueur de choisir sa taile de bateau et la 1ère position de son bateau.

VAR
	l,c:integer;
BEGIN

	REPEAT

		writeln('Veuilez entrer la taille du bateau ',j,' (Maximum 5 cases)');
		readln(taille);

	UNTIL (taille<=5) AND (taille>=1);

	REPEAT

		writeln('Veuillez entrer la ligne de la 1ere cellule du bateau ',j,' de la flotte ',i);
		readln(l);
		writeln('Veuillez entrer la colonne de la 1ere cellule du bateau ',j,' de la flotte ',i);
		readln(c);

	UNTIL (l>=MINL) AND (l<=MAXL) AND (c>=MINC) AND (c<=MAXC);

	CreationCellule(l,c,nCell);

END;

PROCEDURE AffichageF(i:integer;FlotteJ:Joueur); // Affiche la flotte des joueurs

VAR j,k:integer;

BEGIN

				
					writeln('Joueur : ',i);
					FOR j:=1 TO NBBATEAU DO
						BEGIN
							writeln('Bateau : ',j);
							FOR k:=1 TO MAXCASE DO
								BEGIN
									writeln('Lignes / Colonnes du bateau ',j,' de la flotte ',i,' : ',FlotteJ[i].nBateau[j].nCell[k].ligne,' / ',FlotteJ[i].nBateau[j].nCell[k].col);

								END;
						END;


END;

PROCEDURE FLotteCoule(Var F1,F2:EtatFlotte;FlotteJ:Joueur); //Verifie si une flotte a coulée

VAR i,j,k:integer;

BEGIN
	F1:=ASombre;
	F2:=ASombre;
	FOR i:=1 TO NBFLOTTE DO
		BEGIN
			FOR j:=1 TO NBBATEAU DO
				BEGIN
					FOR k:=1 TO MAXCASE DO
						BEGIN
							IF (FlotteJ[i].nBateau[j].nCell[k].ligne<>0) AND (FlotteJ[i].nBateau[j].nCell[k].col<>0) THEN
								BEGIN
									IF i=1 THEN
										F1:=AFlot
									ELSE
										F2:=AFlot;
								END;
						END;
				END;
		END;
END;

//PROGRAMME PRINCIPAL

VAR
	l,c:integer;
	taille:integer;
	i,j,k:integer;
	FlotteJ:Joueur;
	Cell:Cellule;
	BatExist:boolean;
	coordtir:string;
	flottevisee:integer;
	Toucher:boolean;
	F1,F2:EtatFlotte;



BEGIN
	clrscr;

		//Creation des flottes de chaque joueur : Chaque joueur créer sa flotte, la création de bateau est demandée au joueur pour la taille et la 1ère position.
		//Si le bateau existe déjà dans la flotte du joueur alors on réitère la demande.
		//Sinon le bateau est créé.
		FOR i:=1 TO NBFLOTTE DO
			BEGIN
				writeln('Le joueur ',i,' cree sa flotte : ');
				FOR j:=1 TO NBBATEAU DO
					BEGIN
						REPEAT
							BEGIN

								ChoixLCT(taille,j,i,Cell);

								BatExist:=CtrlFlotte(FlotteJ,Cell,i);

								FlotteJ[i].nBateau[j]:=CreationBateau(Cell,taille);	

								IF (BatExist=TRUE) THEN
									writeln(UTF8TOANSI('Le bateau saisi existe déjà dans votre flotte'));
							END;
							
						UNTIL (BatExist=FALSE);

					END;

			END;

	//Affichage : Affiche la flotte de chaque joueur avant de commencer la partie.
	writeln('Voici les flottes des 2 joueurs');
	FOR i:=1 TO NBFLOTTE DO
		BEGIN		
			AffichageF(i,FlotteJ);
		END;	

	writeln('Appuyez sur une touche pour continuer');
	readln;

	//Phase de jeu des joueurs : 

	clrscr;
	Toucher:=FALSE;
	BatExist:=FALSE;
	F1:=AFlot;
	F2:=AFlot;
	writeln('La partie commence ! ');

	REPEAT 
		BEGIN
			FOR i:=1 TO NBFLOTTE DO
				BEGIN
					clrscr;
					IF i=1 THEN
						BEGIN
							flottevisee:=2
						END
					ELSE
						BEGIN
							flottevisee:=1;
						END;

					AffichageF(i,FlotteJ);

					IF (F1=AFlot) AND (F2=AFlot) THEN
						BEGIN	
							REPEAT 
								BEGIN

									REPEAT //Tant que la position de tir est supérieur à 10/10 alors on redemande au joueur de saisir une position
										BEGIN
											writeln('Choisissez vos coordonnees de tir : lignes/colonne ');
											writeln('Ligne');
											readln(l);
											writeln('Colonne');
											readln(c);
											CreationCellule(l,c,Cell);
										END;
									UNTIL (l>=MINL) AND (l<=MAXL) AND (c>=MINC) AND (c<=MAXC);

									BatExist:=CtrlFlotte(FlotteJ,Cell,flottevisee); //Si le bateau existe alors
									Toucher:=BatExist; // Touche prend la valeur vraie

									IF (Toucher=TRUE) THEN // Si le joueur touche, on met à 0 la valeur de la cellule.
										BEGIN
											writeln(UTF8ToAnsi('Vous avez touche en cellule '),coordtir);
											FOR j:=1 TO NBBATEAU DO
												BEGIN
													FOR k:=1 TO MAXCASE DO
														BEGIN
															IF (FlotteJ[flottevisee].nBateau[j].nCell[k].ligne=l) AND (FlotteJ[flottevisee].nBateau[j].nCell[k].col=c) THEN
																BEGIN
																	FlotteJ[flottevisee].nBateau[j].nCell[k].ligne:=0;
																	FlotteJ[flottevisee].nBateau[j].nCell[k].col:=0;
																END;
														END;
												END;
										END
									ELSE
										BEGIN
											writeln(UTF8TOANSI('Raté'));
										END;

									FLotteCoule(F1,F2,FlotteJ); //Appel de la procédure pour savoir si la flotte a coulé d'un des 2 joueurs.

									writeln('Appuyez sur une touche pour continuer');
									readln;

								END;

							UNTIL (Toucher=FALSE) OR (F1=ASombre) OR (F2=ASombre); // Le tour se termine si le joueur rate ou si les valeurs de toutes les cellules d'un joueur sont à 0

						END;
				END;
		END;

	UNTIL (F1=ASombre) OR (F2=ASombre); // La partie se termine et annonce le gagnant si un joueur n'a plus de flotte

	IF (F1=ASombre) THEN
		writeln(UTF8TOANSI('Le joueur 2 a gagné'))
	ELSE
		writeln(UTF8TOANSI('Le joueur 1 a gagné'));

	readln;

END.