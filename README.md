# Duel-Game-Prototype-Processing
A simple Dueling game built in processing.

## Dependencies
This uses the library 'Game Control Plus 1.2.2', which comes with Processing 3.5.4.
Keyboard controls, and the program as a whole, will work without this library, if you remove all the lines of code that require it.


## Gameplay
This game is a 2 Player turn based competitive game where both players choose their moves simultaniously.
### Goal
The goal of the game is to reduce the other player to 1 Health or less. If both players are reduced to 1 Health on the same turn, it is a draw.
### Mechanics
In order to reduce the enemy's health, you must use attacks. Make sure to pay attention to the amount of damage each one does in the
grid below your player.

Damage: The damage your move does is shown in the info grid. Defense is subtractive, and so is blocking. But only the greater number applies.

Duration: Almost all moves take multiple turns to come out. Using the wrong move can leave you open and unable to react, so keep turn count in mind.
The effect of the attack comes out after the last turn of its duration. Defend's effect is continuous throughout its use.

Charge: Some moves will increase or decrease charge. This charge is permanent until used by another move. If you do not have enough charge,
you cannot do the move and will instead skip your turn.

Shield Charge: This only comes into play if you are using a shield. It is separate to regular charge.

Absorb: Some moves will use all of your charge and add it to either your attack or your defense. These moves are indicated with a "-N" in the charge column

### Shields
Shields make your light attack have 1 more duration, but increases shield charge by 1 each use.

Shields make your light defend reduce damage by 2 more than usual, but consumes 2 shield charge each use.

### Dual Wielding
Any weapon can be used with any other weapon. The second weapon, however, will have +1 duration to all moves.

Additionally, all moves with either weapon will have 2/3 effect (damage or defense). If you can time the moves to be at the same time, you will do more damage or defense (x4/3) than would occur with a single weapon.

Dual Wield damage rounds up.

### Moves
There are 5 basic moves:

Pass: Skip this turn

Light Attack: Deal little damage, often increases charge.

Heavy Attack: Deal lots of damage, often decreases charge.

Light Defend: Block little damage, mostly does not use charge.

Heavy Defend: Block lots of damage, mostly does not use charge.

In addition, all moves have a 'feint' varient. When doing this, you can cancel the move at any time, but it will not do or block any damage.

## Controls 
### Keyboard
#### Player 1
V (hold): Feint Move

F: Light Attack / Move menu cursor down

D: Heavy Attack / Accept menu choice

S: Light Defend / Go to previous menu / Open menu between match

A: Heavy Attack / Move menu cursor up

G: Pass Turn / Start next match

#### Player 2
M (hold): Feint Move

J: Light Attack / Move menu cursor down

K: Heavy Attack / Accept menu choice

L: Light Defend / Go to previous menu / Open menu between match

';': Heavy Attack / Move menu cursor up

H: Pass Turn / Start next match


### Controller 
#### (May need tweaking to work) (Buttons are named in Nintendo style)
#### Player 1
LB (hold): Feint Move

B: Light Attack / Move menu cursor down

A: Heavy Attack / Accept menu choice

Y: Light Defend / Go to previous menu / Open menu between match

X: Heavy Attack / Move menu cursor up

RB: Pass Turn / Start next match

#### Player 2
LB (hold): Feint Move

B: Light Attack / Move menu cursor down

A: Heavy Attack / Accept menu choice

Y: Light Defend / Go to previous menu / Open menu between match

X: Heavy Attack / Move menu cursor up

RB: Pass Turn / Start next match

## Fixing Controllers if They Don't Work
All* controller code takes place in the controller class (line 379).

Buttons are assigned in the class (line 414 - 419).
This may be different for different controllers.

Which controller number to use is determined by 'id' passed into the contructor.
These values are passed in the setup method (line 577) at (line 579 - 580).

In order to figure out the id and button names of your controllers, run the example program Gcp_ShowDevices included with 'Game Control Plus'
Which controller is which id may change between connections.

## Editable Constants
keyboardInstead:  Uses the keyboard as input instead of two controllers

scaleFactor:      Scales the window

damageDecayTime:  How long it takes damage numbers to fade away in frames (60 FPS)

fastWeaponSwap:   If true, opens the weapon swap menu instead of going into the game on boot
