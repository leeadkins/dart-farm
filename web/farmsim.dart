library farmsim;

import 'dart:html';

part 'engine.dart';

int WIDTH = 768;
int HEIGHT = 432;
int ROWS = 27;
int COLS = 48;
int CELL_SIZE = 16;

int TOOL_NONE = 0;
int TOOL_HOE = 1;
int TOOL_SEED = 2;
int TOOL_SCYTHE = 3;

int CURRENT_TOOL = 0;

class ScoreBoard extends Label {
  int score = 0;
  int multiplier = 100;

  ScoreBoard() : super(20, 20, "Score: 0");

  void incrementScore() {
    score++;
    this.text = "Score: ${score * multiplier}";
  }
}
ScoreBoard sboard = new ScoreBoard();

class FieldTile extends Sprite {
  static int STATE_DORMANT = 1;
  static int STATE_TILLED = 2;
  static int STATE_GROWING = 3;
  static int STATE_COMPLETE = 4;

  bool active = false;
  bool mouseEventsEnabled = true;
  int state = FieldTile.STATE_DORMANT;
  double startedState = 0;

  FieldTile(int x, int y) : super('tiles.png', x, y, CELL_SIZE, CELL_SIZE, 0, 0);

  BOOL onClick(MouseEvent e) {
    if(state == STATE_DORMANT && CURRENT_TOOL ==  TOOL_HOE) {
      switchToState(STATE_TILLED);
    } else if(state == STATE_TILLED && CURRENT_TOOL ==  TOOL_SEED) {
      switchToState(STATE_GROWING);
    } else if(state == STATE_COMPLETE && CURRENT_TOOL ==  TOOL_SCYTHE) {
      sboard.incrementScore();
      switchToState(STATE_DORMANT);
    }
    return true;
  }

  void switchToState(int state) {
    this.state = state;
    this.startedState = 0;
    if(state == STATE_DORMANT) {
      this.u = 0 * CELL_SIZE;
      this.v = 0 * CELL_SIZE;
    } else if(state == STATE_TILLED) {
      this.u = 1 * CELL_SIZE;
      this.v = 0 * CELL_SIZE;
    } else if(state == STATE_GROWING) {
      this.u = 2 * CELL_SIZE;
      this.v = 0 * CELL_SIZE;
    } else if(state == STATE_COMPLETE) {
      this.u = 3 * CELL_SIZE;
      this.v = 0 * CELL_SIZE;
    }
  }

  void update(double time) {
     // this is likely the most hacky thing ever...
    if(state == STATE_GROWING) {
      if(startedState == 0) {
         startedState = time;
      } else if(time - startedState >= 5000){
        switchToState(STATE_COMPLETE);
      }
    }
  }
}

class Field extends GameObjectContainer {
  Field(): super() {
    for(int x = 0; x < COLS; x++) {
      for(int y = 0; y < ROWS; y++) {
        addObject(new FieldTile(x * CELL_SIZE, y*CELL_SIZE));
      }
    }
  }
}

class ControlPanelButton extends Button {

  bool active = false;

  ControlPanelButton(int x, int y, int u, int v) : super('tiles.png', x, y, 30, 30, u * CELL_SIZE, v * CELL_SIZE, CELL_SIZE, CELL_SIZE);

  void render(CanvasRenderingContext2D ctx) {
    super.render(ctx);
    if(active) {
      ctx.strokeStyle = "#ebdf23";
      ctx.strokeRect(this.getAbsoluteX(), this.getAbsoluteY(), this.width, this.height);
    }
  }
}


class ControlPanel extends Panel {
  ControlPanel() : super(WIDTH/2 - 78, HEIGHT - 50, 145, 40) {
    this.fillColor= "#777";
    this.strokeColor = "#333";

    ControlPanelButton tillButton = new ControlPanelButton(5, 5, 0, 1);
    ControlPanelButton plantButton = new ControlPanelButton(40, 5, 1, 1);
    ControlPanelButton harvestButton = new ControlPanelButton(75, 5, 2, 1);
    ControlPanelButton cancelButton = new ControlPanelButton(110, 5, 3, 1);
    tillButton.whenClicked((){
      CURRENT_TOOL = TOOL_HOE;
      tillButton.active = true;
      plantButton.active = false;
      harvestButton.active = false;
      cancelButton.active = false;
    });
    plantButton.whenClicked((){
      CURRENT_TOOL = TOOL_SEED;
      tillButton.active = false;
      plantButton.active = true;
      harvestButton.active = false;
      cancelButton.active = false;
    });
    harvestButton.whenClicked((){
      CURRENT_TOOL = TOOL_SCYTHE;
      tillButton.active = false;
      plantButton.active = false;
      harvestButton.active = true;
      cancelButton.active = false;
    });
    cancelButton.whenClicked((){
      CURRENT_TOOL = TOOL_NONE;
      tillButton.active = false;
      plantButton.active = false;
      harvestButton.active = false;
      cancelButton.active = true;
    });


    addObject(tillButton);
    addObject(plantButton);
    addObject(harvestButton);
    addObject(cancelButton);
  }
}

void main() {
  // First, setup a canvas.
  Game game = new Game("#game_window", WIDTH, HEIGHT);

  // Preload any image assets you're going to use.
  game.loadFile('tiles.png');

  // Once those are loaded, build your game.
  game.onReady((){
    Field field = new Field();
    ControlPanel controlPanel = new ControlPanel();
    game.addObject(field);
    game.addObject(controlPanel);

    game.addObject(sboard);
    // Start the game.
    game.start();
  });
}