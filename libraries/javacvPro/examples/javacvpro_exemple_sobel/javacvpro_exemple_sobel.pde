
// Programme d'exemple de la librairie javacvPro
// par X. HINAULT - octobre 2011
// Tous droits réservés - Licence GPLv3

// Exemple fonction sobel()

import codeanticode.gsvideo.*;
import monclubelec.javacvPro.*; // importe la librairie javacvPro

GSCapture video;

String url="http://www.mon-club-elec.fr/mes_images/online/lena.jpg"; // String contenant l'adresse internet de l'image à utiliser

OpenCV opencv; // déclare un objet OpenCV principal
int widthCapture=320;
int heightCapture=240;

void setup() { // fonction d'initialisation exécutée 1 fois au démarrage

  video = new GSCapture(this, widthCapture, heightCapture);
  video.start();
  //--- initialise OpenCV ---
  opencv = new OpenCV(this); // initialise objet OpenCV à partir du parent This
  opencv.allocate(widthCapture, heightCapture); // initialise les buffers OpenCv à la taille de l'image

    //--- initialise fenêtre Processing 
  size (widthCapture, heightCapture); // crée une fenêtre Processing de la 2xtaille du buffer principal OpenCV
}


void  draw() { // fonction exécutée en boucle
  if (video.available()) {
    video.read();
    opencv.copy(video.get()); // charge le PImage dans le buffer OpenCV
    opencv.sobel(0, 2); //applique le filtre de sobel sur le buffer OpenCV désigné avec paramètres
    opencv.gray(); // passage en niveau de gris
    opencv.invert(); // pour dessin au trait noir sur blanc
    image(opencv.image(), 0, 0); // affiche le buffer principal OpenCV dans la fenêtre Processing
  }
}

