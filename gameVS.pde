import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

/** TODO
 *  Version 4:
 *    Damage Number Graphic
 *    Current Weapon Text
 *    Swap Weapon Menu
**/

/** Version 3 Changes:
 *    Added Shields
 *    Implemented Window Scaling with scaleFactor variable
 *    Added staff, a weapon for those without weapon proficiency
 *    Added Dual Wielding
 *    Removed mandatory wait between actions using rising edge detection
 *    Debugging
**/

/** Version 2 Changes:
 *    Keyboard Control added with keyboardInstead variable
 *    Added support for charge
 *      revolver, rapier, bow
 *    Added support for charge absorb
 *      dagger, ax
**/


boolean keyboardInstead = true;
float scaleFactor =  1.2;

void settings() {
  //System.setProperty("jogl.disable.openglcore", "false");
  //size(400, 400, P3D);
  size((int)(640 * scaleFactor), (int)(480 * scaleFactor));
  
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
  public int shieldCharge;
  public int fakeShieldCharge;
  public boolean isFeint;
  public boolean isPrimaryHand;
  public boolean isDualWield;
  public boolean isWithShield;
  public boolean attackNow;
  public int move;
  public int absorb;
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
    absorb = 0;
    shieldCharge = 0;
    fakeShieldCharge = 0;
    attackNow = false;
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
      move = -1;
      return null;
    }
    if(shieldCharge + currentAttack.shieldCharge < 0) { 
      move = -1;
      return null;
    }
    absorb = 0;
    this.isFeint = isFeint;
    duration = currentAttack.duration;
    if(isFeint) {
      fakeCharge = charge + currentAttack.charge;
      if(fakeCharge > 6) {
        fakeCharge = 6;
      }
      if(currentAttack.absorbCharge) {
        absorb = fakeCharge;
        fakeCharge = 0;
      }
    } else {
      charge = charge + currentAttack.charge;
      if(charge > 6) {
        charge = 6;
      }
      if(currentAttack.absorbCharge) {
        absorb = charge;
        charge = 0;
      }
      fakeCharge = charge;
      
    }
    if(isFeint) {
      fakeShieldCharge = shieldCharge + currentAttack.shieldCharge;
      if(fakeShieldCharge > 6) {
        fakeShieldCharge = 6;
      }
    } else {
      shieldCharge = shieldCharge + currentAttack.shieldCharge;
      if(shieldCharge > 6) {
        shieldCharge = 6;
      }
      fakeShieldCharge = shieldCharge;
      
    }
    return currentAttack;
  }
  public boolean doTick() {
    attackNow = false;
    if(duration == 0) {
      return false;
    }
    duration--;
    if(duration == 0) {
      move = -1;
      fakeCharge = charge;
      fakeShieldCharge = shieldCharge;
      attackNow = true;
      return true; 
    }
    return false;
  }
  public void addShield() {
    isWithShield = true;
    lightAttack.duration++;
    lightAttack.shieldCharge++;
    lightDefend.damage -= 2;
    lightDefend.shieldCharge -= 2;
  }
}



class Attack {
  public int damage;
  public int duration;
  public int charge;
  public boolean absorbCharge;
  public int shieldCharge;
  public Attack(int damage, int duration, int charge, boolean absorbCharge) {
    this.damage = damage;
    this.duration = duration;
    this.charge = charge;
    this.absorbCharge = absorbCharge;
    shieldCharge = 0;
  }
}


class Player {
  public int health;
  public int THPdamage;
  public int tempHealth;
  public int fakeTempHealth;
  public int tempHealth1;
  public int fakeTempHealth1;
  public int tempHealth2;
  public int fakeTempHealth2;
  public int defence;
  public boolean shouldNullTHP1;
  public boolean shouldNullTHP2;
  public Weapon mainWeapon;
  public Weapon secondWeapon;
  public boolean isDualWielding;
  public Player(int defence, Weapon mainWeapon) {
    this.health = 3;
    this.tempHealth = 0;
    this.tempHealth1 = 0;
    this.tempHealth2 = 0;
    this.defence = defence;
    this.mainWeapon = mainWeapon;
    shouldNullTHP1 = false;
    shouldNullTHP2 = false;
    isDualWielding = false;
    THPdamage = 0;
  }
  public Attack doAttack(int attackNumber, boolean isFeint) {
    Attack returnAttack = mainWeapon.doAttack(attackNumber, isFeint);
    if(returnAttack == null) {
      return null;
    }
    fakeTempHealth1 = tempHealth1;
    if(returnAttack.damage < 0) {
      if(isFeint) {
        fakeTempHealth1 = - returnAttack.damage;
        fakeTempHealth1 += mainWeapon.absorb;
        //mainWeapon.absorb = 0;
      } else {
        tempHealth1 = -returnAttack.damage;
        tempHealth1 += mainWeapon.absorb;
        //mainWeapon.absorb = 0;
        fakeTempHealth1 = tempHealth1;
      }
    }
    return returnAttack;
  }
  public Attack doSecondAttack(int attackNumber, boolean isFeint) {
    if(!isDualWielding) return null;
    Attack returnAttack = secondWeapon.doAttack(attackNumber, isFeint);
    if(returnAttack == null) {
      return null;
    }
    fakeTempHealth2 = tempHealth2;
    if(returnAttack.damage < 0) {
      if(isFeint) {
        fakeTempHealth2 = - returnAttack.damage;
        fakeTempHealth2 += secondWeapon.absorb;
        //mainWeapon.absorb = 0;
      } else {
        tempHealth2 = -returnAttack.damage;
        tempHealth2 += secondWeapon.absorb;
        //mainWeapon.absorb = 0;
        fakeTempHealth2 = tempHealth2;
      }
    }
    return returnAttack;
  }
  public boolean doTick() {
    if(isDualWielding) {
      boolean retVal1 = mainWeapon.doTick();
      shouldNullTHP1 = retVal1;
      boolean retVal2 = secondWeapon.doTick();
      shouldNullTHP2 = retVal2;
      return retVal1 || retVal2;
    } else {
      boolean retVal = mainWeapon.doTick();
      shouldNullTHP1 = retVal;
      return retVal;
    }
  }
  public void earlyTick() {
    if(shouldNullTHP1) {
      THPdamage -= tempHealth1;
      tempHealth1 = 0;
      fakeTempHealth1 = 0;
    }
    if(shouldNullTHP2) {
      THPdamage -= tempHealth2;
      tempHealth2 = 0;
      fakeTempHealth2 = 0;
    }
    if(THPdamage < 0) THPdamage = 0;
    if(isDualWielding) {
      tempHealth = (2*tempHealth1 + 2*tempHealth2 + 2) / 3 - THPdamage;
      fakeTempHealth = (2*fakeTempHealth1 + 2*fakeTempHealth2 + 2) / 3 - THPdamage;
    } else {
      tempHealth = tempHealth1 - THPdamage;
      fakeTempHealth = fakeTempHealth1 - THPdamage;
    } 
  }
  public void handleDamage(int damage) {
    if(isDualWielding) {
      tempHealth = (2*tempHealth1 + 2*tempHealth2 + 2) / 3 - THPdamage;
      fakeTempHealth = (2*fakeTempHealth1 + 2*fakeTempHealth2 + 2) / 3 - THPdamage;
    } else {
      tempHealth = tempHealth1 - THPdamage;
      fakeTempHealth = fakeTempHealth1 - THPdamage;
    } 
    int blockDamage = damage - tempHealth;
    int armorDamage = damage - defence;
    if(armorDamage < 0) {
      armorDamage = 0;
    }
    if(blockDamage <= armorDamage) {
      if(blockDamage > 0) {
        health -= blockDamage;
        tempHealth = 0;
        tempHealth1 = 0;
        fakeTempHealth = 0;
        fakeTempHealth1 = 0;
        if(isDualWielding) {
          tempHealth2 = 0;
          fakeTempHealth2 = 0;
        }
        THPdamage = 0;
      } else {
        THPdamage += damage;
      }
    } else {
      health -= armorDamage;
      tempHealth = 0;
      tempHealth1 = 0;
      fakeTempHealth = 0;
      fakeTempHealth1 = 0;
      if(isDualWielding) {
        tempHealth2 = 0;
        fakeTempHealth2 = 0;
      }
      THPdamage = 0;
    }
  }
  public int getDamage() {
    if(isDualWielding) {
      int damage1 = 0, damage2 = 0;
      if(mainWeapon.attackNow && mainWeapon.currentAttack.damage > 0 && !(mainWeapon.isFeint) ) {
        damage1 = mainWeapon.currentAttack.damage + mainWeapon.absorb;
      }
      if(secondWeapon.attackNow && secondWeapon.currentAttack.damage > 0 && !(secondWeapon.isFeint)) {
        damage2 = secondWeapon.currentAttack.damage + secondWeapon.absorb;
      }
      return (2*damage1 + 2*damage2 + 2) / 3;
    } else {
      if(mainWeapon.currentAttack.damage > 0 && !(mainWeapon.isFeint) ) {
        return mainWeapon.currentAttack.damage + mainWeapon.absorb;
      }
    }
    return 0;
  }
  public void addShield() {
    mainWeapon.addShield();
  }
  public void addSecondary(Weapon newWeapon) {
    isDualWielding = true;
    secondWeapon = newWeapon;
    secondWeapon.lightAttack.duration++;
    secondWeapon.heavyAttack.duration++;
    secondWeapon.lightDefend.duration++;
    secondWeapon.heavyDefend.duration++;
    mainWeapon.isDualWield = true;
    secondWeapon.isDualWield = true;
  }
}
class Controller {
  ControlDevice device;
  
  Button Up;
  Button Down;
  Button Left;
  Button Right;
  
  Button LB;
  Button RB;
  public Controller(int id) {
    if(keyboardInstead) {
      device = null;
      switch(id) {
        case 0:
          Down = new Button('f');
          Right = new Button('d');
          Left = new Button('s');
          Up = new Button('a');
          
          LB = new Button('v');
          RB = new Button('g');
          break;
        case 1:
          Down = new Button('j');
          Right = new Button('k');
          Left = new Button('l');
          Up = new Button(';');
          
          LB = new Button('m');
          RB = new Button('h');
          break;
      }
    } else {
      device = control.getDevice(id);
      Down = new Button(device.getButton("A"));
      Right = new Button(device.getButton("B"));
      Left = new Button(device.getButton("C"));
      Up = new Button(device.getButton("X"));
      LB = new Button(device.getButton("Y"));
      RB = new Button(device.getButton("Z"));
    }
  }
  public void doTick() {
    Up.doTick();
    Down.doTick();
    Left.doTick();
    Right.doTick();
    
    LB.doTick();
    RB.doTick();
  }
}

class Button {
  ControlButton Cbutton;
  char Kbutton;
  boolean prevVal;
  boolean prevVal2;
  public Button(char readChar) {
    Kbutton = readChar;
  }
  public Button(ControlButton readButton) {
    Cbutton = readButton;
    prevVal = false;
    prevVal2 = false;
  }
  
  public boolean pressed() {
    if(!prevVal2) {
      if(keyboardInstead) {
        return keysHeld[Kbutton];
      } else {
        return Cbutton.pressed();
      }
    }
    return false;
  }
  public boolean held() {
    if(keyboardInstead) {
      return keysHeld[Kbutton];
    } else {
      return Cbutton.pressed();
    }
  }
  public void doTick() {
    if(keyboardInstead) {
      prevVal2 = prevVal;
      prevVal =  keysHeld[Kbutton];
    } else {
      prevVal = Cbutton.pressed();
    }
  }
  
}

boolean[] keysHeld = new boolean[255];


Player P1;
Player P2;

int P1Move;
int P1Move2;
int P2Move;
int P2Move2;

boolean checkSecondMove;

int waitVal;




void keyPressed() {
  if(key > 255 || key < 0) return;
  keysHeld[key] = true;
}
void keyReleased() {
  if(key > 255 || key < 0) return;
  keysHeld[key] = false;
}
ControlIO control;

Controller P1Controller;
Controller P2Controller;

public Weapon sword() {    // 1 Handed Medium Weapons
  Attack lightAttack = new Attack(2,2,0,false);
  Attack heavyAttack = new Attack(3,3,0,false);
  Attack lightDefend = new Attack(-2,2,0,false);
  Attack heavyDefend = new Attack(-3,3,0,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon revolver() {    // 1 Handed Ranged Weapons
  Attack lightAttack = new Attack(0,1,1,false);
  Attack heavyAttack = new Attack(2,1,-1,false);
  Attack lightDefend = new Attack(-1,1,0,false);
  Attack heavyDefend = new Attack(-2,1,-1,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon rapier() {    // 1 Handed Light Weapons
  Attack lightAttack = new Attack(1,2,1,false);
  Attack heavyAttack = new Attack(3,2,-1,false);
  Attack lightDefend = new Attack(-1,2,1,false);
  Attack heavyDefend = new Attack(-3,2,-1,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon dagger() {    // 1 Handed Small Weapons
  Attack lightAttack = new Attack(1,1,1,false);
  Attack heavyAttack = new Attack(1,2,0,true);
  Attack lightDefend = new Attack(-1,1,0,false);
  Attack heavyDefend = new Attack(-2,2,0,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon ax() {    // 2 Handed Weapons
  Attack lightAttack = new Attack(3,3,1,false);
  Attack heavyAttack = new Attack(2,3,0,true);
  Attack lightDefend = new Attack(-3,3,0,false);
  Attack heavyDefend = new Attack(-3,3,0,true);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon bow() {    // 2 Handed Ranged Weapons
  Attack lightAttack = new Attack(0,2,1,false);
  Attack heavyAttack = new Attack(4,3,-1,false);
  Attack lightDefend = new Attack(-2,1,0,false);
  Attack heavyDefend = new Attack(-4,3,-1,false);
  return new Weapon(lightAttack,heavyAttack,lightDefend,heavyDefend);
}
public Weapon staff() {    // Low-Skill Weapons / Proficient->Unarmed  //Note: auto-proficient at Low-Skill weapons
  Attack lightAttack = new Attack(1,2,2,false);
  Attack heavyAttack = new Attack(2,2,1,false);
  Attack lightDefend = new Attack(-2,3,0,false);
  Attack heavyDefend = new Attack(-2,2,-2,false);
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
  P1 = new Player(1, dagger());
  P2 = new Player(1, dagger());
  P1.addSecondary(dagger());
  P2.addSecondary(dagger());
  //P2.addShield();
  P1Move = 0;
  P2Move = 0;
  P1Move2 = 0;
  P2Move2 = 0;
  checkSecondMove = false;
}

void draw() {
  //float scaleFactor = min(1.0*width/640, 1.0*height/480);
  scale(scaleFactor);
  background(#5ae6f2);
  P1Controller.doTick();
  P2Controller.doTick();
//  waitVal--;
//  if(waitVal < 0) {
//    waitVal = 0;
//  }  
  drawGround();
  drawUI();
  drawControls();
  //drawCharacters();
  if(winCheck()) {
    if((P1Controller.RB.pressed() || P2Controller.RB.pressed())) {
      rebuildGame();
    }
  } else {
    inputHandler();
  }
  
}

void inputHandler() {

//  if(waitVal == 0) {
    int temp = -1;
    temp = Cinput(P1Controller);
    if(checkSecondMove) {
      if(temp != 0) P1Move2 = temp;
    } else {
      if(temp != 0) P1Move = temp;
    }
    temp = Cinput(P2Controller);
    if(checkSecondMove) {
      if(temp != 0) P2Move2 = temp;
    } else {
      if(temp != 0) P2Move = temp;
    }
//  }
  if(P1Move != 0 && P2Move != 0) {
    textSize(20);
    if(!checkSecondMove) {
//      waitVal = 60;
    } else {
      text("Second Move", 250, 200);
    }
    checkSecondMove = true;
    if(!P1.isDualWielding) P1Move2 = 9;
    if(!P2.isDualWielding) P2Move2 = 9;
  }
  if(P1Move2 != 0 && P2Move2 != 0) {
    boolean P1Feint = false;
    boolean P2Feint = false;
    boolean P1Feint2 = false;
    boolean P2Feint2 = false;
    if(P1Move >= 5 && P1Move <= 8) {
      P1Feint = true;
      P1Move -= 4;
    }
    if(P2Move >= 5 && P2Move <= 8) {
      P2Feint = true;
      P2Move -= 4;
    }
    if(P1Move2 >= 5 && P1Move2 <= 8) {
      P1Feint2 = true;
      P1Move2 -= 4;
    }
    if(P2Move2 >= 5 && P2Move2 <= 8) {
      P2Feint2 = true;
      P2Move2 -= 4;
    }
    if(P1Move != 9) {
      P1.doAttack(P1Move-1, P1Feint);
    }
    if(P2Move != 9) {
      P2.doAttack(P2Move-1, P2Feint);
    }
    if(P1Move2 != 9) {
      P1.doSecondAttack(P1Move2-1, P1Feint2);
    }
    if(P2Move2 != 9) {
      P2.doSecondAttack(P2Move2-1, P2Feint2);
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
//    waitVal = 60;
    P1Move = 0;
    P2Move = 0;
    P1Move2 = 0;
    P2Move2 = 0;
    checkSecondMove = false;
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
  if(thisController.LB.held()) {
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
  text("Charge 1:", 20, 80);
  text(""+P1.mainWeapon.fakeCharge, 20+101, 80);
  text("Charge 2:", 170, 80);
  if(P1.mainWeapon.isWithShield) {
    text(""+P1.mainWeapon.fakeShieldCharge, 170+101, 80);
  }
  if(P1.isDualWielding) {
    text(""+P1.secondWeapon.fakeCharge, 170+101, 80);
  }
  text("Charge 1:", 320 + 20, 80);
  text(""+P2.mainWeapon.fakeCharge, 320+20+101, 80);
  text("Charge 2:", 320 + 170, 80);
  if(P2.mainWeapon.isWithShield) {
    text(""+P2.mainWeapon.fakeShieldCharge, 320+170+101, 80);
  }
  if(P2.isDualWielding) {
    text(""+P2.secondWeapon.fakeCharge, 320+170+101, 80);
  }
  drawCharge(P1.mainWeapon,       10, 100);
  if(P1.isDualWielding) {
    drawCharge(P1.secondWeapon,       10+160, 100);
  }
  drawCharge(P2.mainWeapon, 320 + 10, 100);
  if(P2.isDualWielding) {
    drawCharge(P2.secondWeapon, 320 + 10+160, 100);
  }
  drawMoveText(P1.mainWeapon, 20, 140);
  if(P1.isDualWielding) {
    drawMoveText(P1.secondWeapon, 20+160, 140);
  }
  drawMoveText(P2.mainWeapon, 320 + 20, 140);
  if(P2.isDualWielding) {
    drawMoveText(P2.secondWeapon, 320 + 20+160, 140);
  }
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
      if(thisWeapon.isDualWield) {
        text("" + (2+2*(thisWeapon.currentAttack.damage+thisWeapon.absorb))/3, xOff+69, yOff+25);
      } else {
        text("" + (thisWeapon.currentAttack.damage+thisWeapon.absorb), xOff+69, yOff+25);
      }
      
    }
    if(thisWeapon.currentAttack.damage < 0) {
      text("DEF:", xOff+10, yOff+25);
      if(thisWeapon.isDualWield) {
        text("" + (2+2*(-thisWeapon.currentAttack.damage+thisWeapon.absorb))/3, xOff+59, yOff+25);
      } else {
        text("" + (-thisWeapon.currentAttack.damage+thisWeapon.absorb), xOff+59, yOff+25);
      }
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
  
  
