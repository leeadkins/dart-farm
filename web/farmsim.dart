library farmsim;

import 'dart:html';

part 'engine.dart';


int WIDTH = 768;
int HEIGHT = 432;
int ROWS = 27;
int COLS = 48;
int CELL_SIZE = 16;

class GrassTile extends Sprite {
  GrassTile(int x, int y) : super('tiles.png', x, y, CELL_SIZE, CELL_SIZE, 0, 0);
}

void main() {
  Game game = new Game("#game_window", WIDTH, HEIGHT);

  game.loadFile('tiles.png');


  game.onReady((){


    // Build the game in here...

    // Building the main panel on the bottom.
    Panel controlPanel = new Panel(WIDTH / 2 - 105, HEIGHT - 60, 210, 50);
    Panel button1 = new Panel(10, 10, 30, 30, tag: 'Button 1');
    Panel button2 = new Panel(50, 10, 30, 30, tag: 'Button 2');
    Panel button3 = new Panel(90, 10, 30, 30, tag: 'Button 3');
    Panel button4 = new Panel(130, 10, 30, 30, tag: 'Button 4');
    Panel button5 = new Panel(170, 10, 30, 30, tag: 'Button 5');

    controlPanel.addObject(button1);
    controlPanel.addObject(button2);
    controlPanel.addObject(button3);
    controlPanel.addObject(button4);
    controlPanel.addObject(button5);

    GameObjectContainer container = new GameObjectContainer();
    for(int x = 0; x < COLS; x++) {
      for(int y = 0; y < ROWS; y++) {
        container.addObject(new GrassTile(x * CELL_SIZE, y*CELL_SIZE));
      }
    }
    game.addObject(container);
    game.addObject(controlPanel);
    game.start();
  });
}