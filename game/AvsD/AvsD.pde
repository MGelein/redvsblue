//Java util is necessary for sorting of arraylists
import java.util.*;
import processing.sound.*;

//Self ref, used in the sound stuff
PApplet app;

//The global game variable. This contains the game-manager
final Game game = new Game();
final Virus virus = new Virus();
final Salt salt = new Salt();
final GUI gui = new GUI();
final Network network = new Network();
final Ship ship = new Ship();
final SoundManager soundManager = new SoundManager();

//Add the keycode for the spacebar
final int SPACE = 32;

//Handles the initialization of the game
void setup() {
  //Set the current window size. For testing, otherwise fullscreen
  fullScreen(P2D);
  //size(960, 540, P2D);
  hint(DISABLE_TEXTURE_MIPMAPS);
  app = this;
  ((PGraphicsOpenGL)g).textureSampling(2);
  //Initialize the game, start loading assets, etc
  game.init();
  //Don't do any smoothing to textures
  noSmooth();
}

//Renders and updates the game in the main loop
void draw() {
  //Update your state
  game.update();
  //Render to your own canvas
  game.render();
  //Render the game canvas and stretch it to the correct size
  image(game.g, game.offset.x, game.offset.y, width, height);
  //Draw the game-fps to the screen
  fill(virus.COL_VR, 100);
  text(((int) frameRate) + " fps", 5, 15);
}

//Handles keyPressed events and forwards to the Key manager
void keyPressed() {
  //If we press ANY KEY, then start the game
  if (game.state == GameState.READY) game.restart();
  else if (game.state == GameState.LOST) {
    if (keyCode == ENTER) {
      game.submitScore();
    } else if ((key + "").length() > 0) {
      game.typeKey(key + "", keyCode);
    }
  } else Key.setState(keyCode, true);
}

//Handles keyReleased events and forwards to the Key manager
void keyReleased() {
  Key.setState(keyCode, false);
}


//Interface that says you can update
interface IUpdate {
  void update();
}

//Interface that says you can be rendered using a supplied canvas
abstract class RenderObj {
  int depth = 0;
  abstract void render(PGraphics g);
}

void postProgress() {
  postProgress(virus.percentage);
}

//Posts the progress
void postProgress(float percentage) {
  if(network.postingProgress) return;
  network.postingProgress = true;
  loadStrings(network.progressURL + percentage);
  network.postingProgress = false;
}

//Updates the people
void getPeople() {
  if(network.retrievingPeople) return;
  network.retrievingPeople = true;
  ArrayList<PVector> places = new ArrayList<PVector>();
  String[] lines = loadStrings(network.peopleURL);
  for (String line : lines) {
    if (line.trim().length() < 1) continue;
    String[] parts = line.split(",");
    if (parts.length < 5) continue;
    float x = parseFloat(parts[1]);
    float y = parseFloat(parts[2]);
    places.add(new PVector(x, (y *-1 + 1)));
  }
  salt.addPeople(places);
  network.retrievingPeople = false;
}
