// Programme d'exemple de la librairie javacvPro
// par X. HINAULT - novembre 2011
// Tous droits réservés - Licence GPLv3

// Montre exemple utilisation de la fonction 

import monclubelec.javacvPro.*; // importe la librairie javacvPro

OpenCV opencv; // déclare un objet OpenCV principal

int widthCapture=320;
int heightCapture=200;

void setup(){ // fonction d'initialisation exécutée 1 fois au démarrage

        size(widthCapture*2,heightCapture); 

	opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
        opencv.allocate(widthCapture,heightCapture); // crée le buffer image de la taille voulue


        noLoop(); // stop programme         
}


void  draw() { // fonction exécutée en boucle

}


