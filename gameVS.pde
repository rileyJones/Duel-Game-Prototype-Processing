import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

void settings() {
  //System.setProperty("jogl.disable.openglcore", "false");
  //size(400, 400, P3D);
  size(640, 480);
  
}

class Weapon {
  public Attack lightAttack;
  public Attack heavyAttack;
  public Attack lightDefend;
  public Attack heavyDefend;
  public Attack currentAttack;
  public int duration;
  public int charge;
  public int fakeCharge;
  public boolean isFeint;
  public boolean isPrimaryHand;
  public boolean isDualWield;
  public boolean isWithShield;
  public int move;
  public Weapon(Attack lightAttack, Attack heavyAttack, Attack lightDefend, Attack heavyDefend) {
    this.lightAttack = lightAttack;
    this.heavyAttack = heavyAttack;
    this.lightDefend = lightDefend;
    this.heavyDefend = heavyDefend;
    currentAttack = null;
    duration = 0;
    charge = 0;
    isFeint = false;
    isPrimaryHand = true;
    isDualWield = false;
    isWithShield = false;
    move = -1;
  }
  public Attack doAttack(int attackNumber, boolean isFeint) {
    if(duration != 0 && !this.isFeint) {
      return null;
    }
    fakeCharge = charge;
    move = attackNumber;
    switch(attackNumber) {
      case 0:
        currentAttack = lightAttack;
        break;
      case 1:
        currentAttack = heavyAttack;
        break;
      case 2:
        currentAttack = lightDefend;
        break;
      case 3:
        currentAttack = heavyDefend;
        break;
      default:
        return null;
    }
    if(charge + currentAttack.charge < 0) {
      currentAttack = null;
      return null;
    }
    this.isFeint = isFeint;
    duration = currentAttack.duration;
    if(isFeint) {
      fakeCharge = charge + currentAttack.charge;
      if(fakeCharge > 6) {
        fakeCharge = 6;
      }
    } else {
      charge = charge + currentAttack.charge;
      if(charge > 6) {
        charge = 6;
      }
      fakeCharge = charge;
    }
    return currentAttack;
  }
  public boolean doTick() {
    if(duration == 0) {
      return false;
    }
    duration--;
    if(duration == 0) {
      move = -1;
      return true; 
    }
    return false;
  }
}



class Attack {
  public int damage;
  public int duration;
  public int charge;
  public boolean absorbCharge;
  public Attack(int damage, int duration, int charge, boolean absorbCharge) {
    this.damage = damage;
    this.duration = duration;
    this.charge = charge;
    this.absorbCharge = absorbCharge;
  }
}


class Player {
  public int health;
  public int tempHealth;
  public int fakeTempHealth;
  public int defence;
  public boolean shouldNullTHP;
  public Weapon mainWeapon;
  public Player(int defence, Weapon mainWeapon) {
    this.health = 3;
    this.tempHealth = 0;
    this.defence = defence;
    this.mainWeapon = mainWeapon;
    shouldNullTHP = false;
  }
  public Attack doAttack(int attackNumber, boolean isFeint) {
    Attack returnAttack = mainWeapon.doAttack(attackNumber, isFeint);
    if(returnAttack == null) {
      return null;
    }
    fakeTempHealth = tempHealth;
    if(returnAttack.damage < 0) {
      if(isFeint) {
         fakeTempHealth = - returnAttack.damage;
      } else {
        tempHealth = -returnAttack.damage;
        fakeTempHealth = tempHealth;
      }
    }
    return returnAttack;
  }
  public boolean doTick() {
    boolean retVal = mainWeapon.doTick();
    shouldNullTHP = retVal;
    return retVal;
  }
  public void earlyTick() {
    if(shouldNullTHP) {
      tempHealth = 0;
      fakeTempHealth = 0;
    }
  }
  public void handleDamage(int damage) {
    int blockDamage = damage - tempHealth;
    int armorDamage = damage - defence;
    if(armorDamage < 0) {
      armorDamage = 0;
    }
    if(blockDamage <= armorDamage) {
      if(blockDamage > 0) {
        health -= blockDamage;
        tempHealth = 0;
        fakeTempHealth = 0;
      } else {
        fakeTempHealth = fakeTempHealth - tempHealth - blockDamage;
        tempHealth = -blockDamage;
      }
    } else {
      health -= armorDamage;
      tempHealth = 0;
      fakeTempHealth = 0;
    }
  }
  public int getDamage() {
    if(mainWeapon.currentAttack.damage > 0 && !(mainWeapon.isFeint) ) {
      return mainWeapon.currentAttack.damage;
    }
    return 0;
  }
}
class Controller {
  ControlDevice device;
  
  ControlButton Up;
  ControlButton Down;
  ControlButton Left;
  ControlButton Right;
  
  ControlButton LB;
  ControlButton RB;
  public Controller(int id) {
    device = control.getDevice(id);
    Down = device.getButton("A");
    Right = device.getButton("B");
    Left = device.getButton("C");
    Up = device.getButton("X");
    LB = device.getButton("Y");
    RB = device.getButton("Z");
  }
}

Player P1;
Player P2;

int P1Move;
int P2Move;

int waitVal;



ControlIO control;

Controller P1Controller;
Controller P2Controller;

public Weapon sword() {
  Attack lightAttack = new Attack(2,2,0,false);
  Attack heavyAttack = new Attack(3,3,0,false);
  Attack lightDefend = new Attack(-2,2,0,false);
  Attack heavyDefend = new Attack(-3,3,0,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}


void setup() {
  control = ControlIO.getInstance(this);
  P1Controller = new Controller(0);
  P2Controller = new Controller(1);
  surface.setTitle("Game VS");
  surface.setResizable(false);
  frameRate(60);
  rebuildGame();
}

void rebuildGame() {
  waitVal = 60;
  P1 = new Player(1, sword());
  P2 = new Player(1, sword());
  P1Move = 0;
  P2Move = 0;
}

void draw() {
  background(#5ae6f2);
  waitVal--;
  if(waitVal < 0) {
    waitVal = 0;
  }  
  drawGround();
  drawUI();
  drawControls();
  //drawCharacters();
  if(winCheck()) {
    if((P1Controller.RB.pressed() || P2Controller.RB.pressed()) && waitVal == 0) {
      rebuildGame();
    }
  } else {
    inputHandler();
  }
  
}

void inputHandler() {

  if(waitVal == 0) {
    int temp = Cinput(P1Controller);
    if(temp != 0) P1Move = temp;
    temp = Cinput(P2Controller);
    if(temp != 0) P2Move = temp;
  }
  if(P1Move != 0 && P2Move != 0) {
    boolean P1Feint = false;
    boolean P2Feint = false;
    if(P1Move >= 5 && P1Move <= 8) {
      P1Feint = true;
      P1Move -= 4;
    }
    if(P2Move >= 5 && P2Move <= 8) {
      P2Feint = true;
      P2Move -= 4;
    }
    if(P1Move != 9) {
      P1.doAttack(P1Move-1, P1Feint);
    }
    if(P2Move != 9) {
      P2.doAttack(P2Move-1, P2Feint);
    }
    boolean P1Attack = P1.doTick();
    boolean P2Attack = P2.doTick();
    if(P1Attack) {
      P2.handleDamage(P1.getDamage());
    }
    if(P2Attack) {
      P1.handleDamage(P2.getDamage());
    }
    P1.earlyTick();
    P2.earlyTick();
    waitVal = 60;
    P1Move = 0;
    P2Move = 0;
    
  }
}
boolean winCheck() {
  fill(0);
  textSize(75);
  if(P1.health <= 1) {
    if(P2.health <= 1) {
      text("Draw", 230, 200);
      return true;
    } else {
      text("Player 2 Wins", 80, 200);
      return true;
    }
  } else if(P2.health <=1) {
    text("Player 1 Wins", 80, 200);
    return true;
  }
  return false;
}



int Cinput(Controller thisController) {
  if(thisController.RB.pressed()) {
    return 9;
  }
  if(thisController.LB.pressed()) {
    if(thisController.Right.pressed()) {
      return 6;
    }
    if(thisController.Down.pressed()) {
      return 5;
    }
    if(thisController.Up.pressed()) {
      return 8;
    }
    if(thisController.Left.pressed()) {
      return 7;
    }
  } else {
    if(thisController.Right.pressed()) {
      return 2;
    }
    if(thisController.Down.pressed()) {
      return 1;
    }
    if(thisController.Up.pressed()) {
      return 4;
    }
    if(thisController.Left.pressed()) {
      return 3;
    }
  }
  return 0;
}

void drawGround() {
  noStroke();
  fill(#edc49a);
  rect(0,300,640,180);
  fill(#c29569);
  rect(0,300,640,170);
  fill(#9c744e);
  rect(0,300,640,90);
  fill(#7a5a3b);
  rect(0,300,640,45);
  fill(#5c4127);
  rect(0,300,640,23);
  fill(#402b16);
  rect(0,300,640,11);
  fill(#1f1307);
  rect(0,300,640,6);
}

void drawUI() {
  fill(#2d91fc);
  stroke(0);
  rect(0,0,320,100);
  fill(#e8681e);
  rect(320,0,320,100);
  line(0,25,640,25);
  fill(0);
  textSize(20);
  text("Player 1", 10, 20);
  text("Player 2", 320 + 10, 20);
  text("Health: ", 20, 50);
  text("Health: ", 320 + 20, 50);
  text(""+P1.health, 94, 50); 
  text(""+P2.health, 320 + 94, 50);
  text("Defense:   +", 140, 50);
  text("Defense:   +", 320 + 140, 50);
  text(""+P1.defence, 140 + 89, 50);
  text(""+P2.defence, 320 + 140 + 89, 50);
  text(""+P1.fakeTempHealth, 140 + 126, 50);
  text(""+P2.fakeTempHealth, 320 + 140 + 126, 50);
  text("Charge 1: 0", 20, 80);
  text("Charge 2: 0", 170, 80);
  text("Charge 1: 0", 320 + 20, 80);
  text("Charge 2: 0", 320 + 170, 80);
  drawCharge(P1.mainWeapon,       10, 100);
  drawCharge(P2.mainWeapon, 320 + 10, 100);
  drawMoveText(P1.mainWeapon, 20, 140);
  drawMoveText(P2.mainWeapon, 320 + 20, 140);
}
void drawMoveText(Weapon thisWeapon, int xOff, int yOff) {
  stroke(0);
  fill(0);
  int move = thisWeapon.move;
  switch(move) {
    case 0:
      text("Light Attack", xOff, yOff);
      break;
   case 1:
     text("Heavy Attack", xOff, yOff);
     break;
   case 2:
     text("Light Defend", xOff, yOff);
     break;
   case 3:
     text("Heavy Defend", xOff, yOff);
     break;
  }
  if(move != -1) {
    if(thisWeapon.currentAttack.damage > 0) {
      text("DMG:", xOff+10, yOff+25);
      text("" + thisWeapon.currentAttack.damage, xOff+69, yOff+25);
    }
    if(thisWeapon.currentAttack.damage < 0) {
      text("DEF:", xOff+10, yOff+25);
      text("" + -thisWeapon.currentAttack.damage, xOff+59, yOff+25);
    }
    
  }
}

void drawCharge(Weapon thisWeapon, int xOff, int yOff) {
  if(thisWeapon.currentAttack == null) {
    return;
  }
  int numSquares = thisWeapon.currentAttack.duration;
  int emptySquares = thisWeapon.duration;
  if(emptySquares != 0) {
    fill(166);
    for(int i = 0; i < numSquares; i++) {
      rect(xOff + 20 * i, yOff, 20, 20);
    }
    for(int i = numSquares - 1; i > emptySquares - 2; i--) {
      switch(i) {
        case 3:
          fill(#80ff00);
          break;
        case 2:
          fill(#eeff00);
          break;
        case 1:
          fill(#ffbf00);
          break;
        case 0:
          fill(#ff4400);
          break;
        default:
          fill(#001eff);
          break;
      }
      rect(xOff - 20*i + 20 * (numSquares-1), yOff, 20, 20);
    }
  }
}

void drawControls() {
  float scale = 0.5;
  drawCross(320-(int)(105*scale), 475-(int)(200*scale), scale);
}

void drawCross(int xOff, int yOff, float scale) {
  
  fill(#0080ff,200);
  noStroke();
  arc(xOff+105*scale, yOff+75*scale, 290*scale, 250*scale, QUARTER_PI+HALF_PI, TWO_PI-QUARTER_PI);
  fill(#fa3200,200);
  arc(xOff+105*scale, yOff+75*scale, 290*scale, 250*scale, -QUARTER_PI, PI-QUARTER_PI);
  
  fill(240,240,255);
  stroke(0);
  circle(xOff+105*scale, yOff+15*scale, 30*scale);
  circle(xOff+105*scale, yOff+135*scale, 30*scale);
  circle(xOff+45*scale, yOff+75*scale, 30*scale);
  circle(xOff+165*scale, yOff+75*scale, 30*scale);
  rect(xOff, yOff, 65*scale, 30*scale, 10*scale, 4*scale, 2*scale, 2*scale);
  rect(xOff+145*scale, yOff, 65*scale, 30*scale, 4*scale, 10*scale, 2*scale, 2*scale);
  
  fill(0);
  textSize(20*scale);
  text("Feint", xOff+10*scale, yOff+22*scale);
  text("Pass", xOff+157*scale, yOff+22*scale);
  text("Heavy", xOff+75*scale, yOff-7*scale);
  text("Light", xOff+80*scale, yOff+169*scale);
  text("Light", xOff-26*scale, yOff+82*scale);
  text("Heavy", xOff+186*scale, yOff+82*scale);
}
  
  
