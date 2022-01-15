# Duel-Game-Prototype-Processing
A simple Dueling game built in processing.

## Dependencies
This uses the library 'Game Control Plus 1.2.2', which comes with Processing 3.5.4.
Keyboard controls, and the program as a whole, will work without this library, if you remove all the lines of code that require it.


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
