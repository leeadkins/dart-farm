/**
* RSEngine
* A collection of really simple objects to help make
* games. You could call it an engine if you want,
* but it's way too barebones for that.
*
* Things I'm not a big fan of yet:
*  - Mouse event handling. Bleh. Like really.
*/

part of farmsim;

class ResourceCache {
  static final ResourceCache _resourceCache = new ResourceCache._internal();

  Map<String, ImageElement> resources = new Map<String, ImageElement>();
  List<Function> readyCallbacks = [];

  factory ResourceCache() {
    return _resourceCache;
  }

  void loadFile(String fileName) {

    if(resources[fileName]) {
      return resources[fileName];
    } else {
      ImageElement img = new ImageElement();
      img.onLoad.listen((e){
        resources[fileName] = img;

        if(isReady()) {
          readyCallbacks.forEach((func){
            func();
          });
        }
      });
      resources[fileName] = false;
      img.src = fileName;
    }
  }

  bool isReady() {
    var ready = true;

    resources.forEach((String key, ImageElement value) {
      if(value == false) {
        ready = false;
      }
    });

    return ready;
  }

  void onReady(Function func) {
    readyCallbacks.add(func);
  }

  void loadFiles(List listOfFiles) {
    listOfFiles.forEach((String image) {
      loadFile(image);
    });
  }

  ImageElement getFile(String fileName) {
    return resources[fileName];
  }

  ResourceCache._internal();
}

abstract class GameObject {
  int x = 0;
  int y = 0;
  bool mouseEventsEnabled = false;
  String tag;

  GameObject parent;

  GameObject();

  void update(double time);
  void render(CanvasRenderingContext2D ctx);

  int getAbsoluteX() {
    if(this.parent != null) {
      return this.x + this.parent.getAbsoluteX();
    }
    return this.x;
  }

  int getAbsoluteY() {
    if(this.parent != null) {
      return this.y + this.parent.getAbsoluteY();
    }
    return this.y;
  }

  void enableMouseEvents() {
    mouseEventsEnabled = true;
  }

  void disableMouseEvents() {
    mouseEventsEnabled = false;
  }

  bool shouldHandleMouseEvent(MouseEvent event) {
    return mouseEventsEnabled == true;
  }

  bool onClick(MouseEvent event) {
    return false;
  }

  void setTag(String tag) {
    this.tag = tag;
  }

}

class GameObjectContainer extends GameObject{
  List<GameObject> gameObjects = new List();
  bool mouseEventsEnabled = true;

  void update(double time) {
    gameObjects.forEach((GameObject object) {
      object.update(time);
    });
  }

  void render(CanvasRenderingContext2D ctx) {
    gameObjects.forEach((GameObject object) {
      object.render(ctx);
    });
  }

  void addObject(GameObject object) {
    object.parent = this;
    gameObjects.add(object);
  }

  void removeObject(GameObject object) {
    object.parent = null;
    gameObjects.remove(object);
  }

  bool onClick(MouseEvent event) {
    bool handled = false;
    if(shouldHandleMouseEvent(event)) {
      for(int i = 0; i < gameObjects.length; i++ ){
        GameObject obj = gameObjects.reversed.elementAt(i);
        if(obj.shouldHandleMouseEvent(event) && obj.onClick(event)) {
          handled = true;
          break;
        }
      }
    }
    return handled;
  }

}

class Panel extends GameObjectContainer {
  int width;
  int height;
  int x;
  int y;
  String fillColor = '#fff';
  String strokeColor = '#f00';

  Panel(this.x, this.y, this.width, this.height, {tag: 'Tag'}) {
    this.tag = tag;
  }

  void update(double time) {}

  void render(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = fillColor;
    ctx.strokeStyle = strokeColor;
    ctx.fillRect(this.getAbsoluteX(),this.getAbsoluteY(),width,height);
    ctx.strokeRect(this.getAbsoluteX(),this.getAbsoluteY(),width,height);
    super.render(ctx);
  }

  void setFillColor(String color) {
    this.fillColor = color;
  }

  void setStrokeColor(String color) {
    this.strokeColor = color;
  }

  bool shouldHandleMouseEvent(MouseEvent event) {
    int xo = event.offsetX;
    int yo = event.offsetY;
    return super.shouldHandleMouseEvent(event) && xo >= this.getAbsoluteX() && xo <= this.getAbsoluteX() + this.width && yo >= this.getAbsoluteY() && yo <= this.getAbsoluteY() + this.height;
  }

  bool onClick(MouseEvent event) {
    // If you expect something to potentially handle this for you, you
    // need to call super.
    bool handled = super.onClick(event);

    // If it hasn't already been handled, feel free to handle it yourself
    if(!handled) {
      window.console.log(this.tag);
    }

    // You need to return something here to let other things know if you've handled the click.
    // This will stop things from bubbling on up.
    return true;
  }

}


class Sprite extends GameObject {

  String imageName;
  ImageElement image = false; // The asset to use
  int x = 0;  // Where to draw it
  int y = 0;
  int width = 0; // Obvs.
  int height = 0;
  int u = 0; // The x/y offset of the sprite within the sprite sheet provided.
  int v = 0;
  int uWidth = 0;
  int uHeight = 0;

  Sprite(this.imageName, this.x, this.y, this.width, this.height, this.u, this.v, {int sourceWidth, int sourceHeight}) {

    if(sourceWidth != null) {
      this.uWidth = sourceWidth;
    } else {
      this.uWidth = this.width;
    }

    if(sourceHeight != null) {
      this.uHeight = sourceHeight;
    } else {
      this.uHeight = this.height;
    }

    image = ResourceCache._resourceCache.getFile(imageName);
  }

  void update(double time) {}

  bool shouldHandleMouseEvent(MouseEvent event) {
    int xo = event.offsetX;
    int yo = event.offsetY;
    return super.shouldHandleMouseEvent(event) && xo >= this.getAbsoluteX() && xo <= this.getAbsoluteX() + this.width && yo >= this.getAbsoluteY() && yo <= this.getAbsoluteY() + this.height;
  }

  bool onClick(MouseEvent event) {
    return false;
  }

  void render(CanvasRenderingContext2D ctx) {
    if(this.image != false) {
      ctx.drawImageScaledFromSource(this.image, this.u, this.v, this.uWidth, this.uHeight, this.getAbsoluteX(), this.getAbsoluteY(), this.width, this.height);
    }
  }
}

class Button extends Sprite {
  bool mouseEventsEnabled = true;

  List<Function> clickHandlers = new List<Function>();

  Button(String imageName, int x, int y, int width, int height, int u, int v, int sourceWidth, int sourceHeight) : super(imageName, x, y, width, height, u, v, sourceWidth:sourceWidth, sourceHeight:sourceHeight);

  bool onClick(MouseEvent event) {
    clickHandlers.forEach((Function f){
      f();
    });
    return true;
  }

  void whenClicked(Function function) {
    clickHandlers.add(function);
  }
}

class Tile extends GameObject {
  int x;
  int y;

  Tile(this.x, this.y);
  void update(double time) {

  }
  void render(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = "#0f0";
    ctx.fillRect(this.x, this.y, 16, 16);
  }
}

class Label extends GameObject {

  int x;
  int y;
  String text;

  Label(this.x, this.y, this.text);

  void update(double time) {}

  void render(CanvasRenderingContext2D ctx) {
    ctx.strokeStyle = "#000";
    ctx.strokeText(text, x, y);
  }
}


class Game extends GameObjectContainer {
  bool running;
  CanvasElement element;
  CanvasRenderingContext2D ctx;

  Game(String eleSelector, int width, int height) {
    this.running = false;
    element = querySelector(eleSelector);
    element.width = width;
    element.height = height;
    ctx = element.getContext("2d");

    element.onClick.listen(onClick);
  }

  void render(CanvasRenderingContext2D ctx) {
    ctx.fillStyle = "#000";
    ctx.fillRect(0,0,element.width, element.height);
    super.render(ctx);
  }

  void onAnimationFrame(double time) {

    update(time);
    render(ctx);

    if(this.running == true) {
      window.requestAnimationFrame(onAnimationFrame);
    }
  }

  void start() {
    this.running = true;
    onAnimationFrame(-1.0);
  }

  void stop() {
    this.running = false;
  }

  void loadFile(String file) {
    ResourceCache c = new ResourceCache();
    c.loadFile(file);
  }

  void loadFiles(List listOfFiles) {
    ResourceCache c = new ResourceCache();
    c.loadFiles(listOfFiles);
  }

  void onReady(func) {
    ResourceCache c = new ResourceCache();
    c.onReady(func);
  }

}