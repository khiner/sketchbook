/* A wrapper around the ControlP5.Button class.
 * Conveniently holds the three images for default, mouseOver, and mouseClicked
 * Contains activate() and deactivate() functions
 */
class MyButton {
  PImage image1, image2, image3;
  Button button;
  
  MyButton(String name, int x, int y, String image1, String image2, String image3) {
    button = controlP5.addButton(name, 0, x, y, 59, 59);
    this.image1 = loadImage(image1);
    this.image2 = loadImage(image2);
    this.image3 = loadImage(image3);
    deactivate(); // deactivating sets the images to the default, unselected image set
  }
  
  /* Called when the button is clicked.
   * Sets the image to a grayed default, and cleared the selected particles.
   */
  void activate() {
    if (activeButton != null)
      activeButton.deactivate();
    selected.clear();
    activeButton = this;
    button.setImages(image3, image2, image3);
  }
  
  /* Deactivate the button by returning its images to default */
  void deactivate() {
    button.setImages(image1, image2, image3);
  }
}
