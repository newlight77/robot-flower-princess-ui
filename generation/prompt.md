I’ll need to create only the frontend part with user interface to be interactive so the player can play and visualize the game in real time.

## Goal
The robot delivers all flowers to the princess. The player has to guide the robot to navigate to pick flowers, then give them to princess.

### Use case :
* 🎲 Create game with configurable dimensions (3x3 to 50x50)
* 📋 Manage all games created with their status
* 🎮 Intuitive Controls with buttons to control actions (move, pick flower, drop flower or give flower)
* 🎨 Visual Game Board using icons and distinct colors
* 🏆 Game de statuts : Playing, Won, Game Over

## Game

Board : 2D grid configurable from 3x3 to 50x50

Board Cases :
* 🤖 Robot (R) : Controlled by the player
* 👑 Princesse (P) : Destination of flowers delivery
* 🌸 Fleur (F) : To be picked, random position, multiple but maximum 10% on the game board
* 🗑️ Obstacles (O) : Obstacles, cleanable, around 30% on the game board
* ⬜ Empty (E) : Empty cases

### Rules
Actions: There are 5 types of actions the robot can do :

↩️ Rotate : the player can command the the robot to turn on itself to be oriented toward a specified direction (EAST, SOUTH, WEST, NORTH).
🚶‍♂️ Moving : the player can command the the robot to move, one case at a time, in a direction (EAST, SOUTH, WEST, NORTH) toward an adjacent case. It can move while holding flowers. If the action is invalid, the game is over.
⛏️🌸 Picking flower : the player can command the robot to pick a flower in a direction toward an adjacent case. It can pick multiple flowers, up to 12.  If the action is invalid, the game is over.
🫳🌸 Drop flower: the player can command the robot to drop a flower in a direction toward an adjacent case. If the action is invalid, the game is over.
🫴🏼🌸 Give Flower: the player can command the robot to give flowers in its hands as a bouquet in a direction toward an adjacent case. If the action is invalid, the game is over.
🗑️ Cleaning : the player can command the robot to clean an obstacle in a direction toward an adjacent case. If the action is invalid, the game is over.
Victory : the game is considered victory only when all flowers are delivered to the princess.
Game Over : A game over occurs when the robot execute an invalid action, against any rule above

### Additional functionality
* For any of the actions above, the command is executed by the backed through API call. If the action is invalid, there would be an error code and message in the response.
* The player can activate an auto-play that sends a command to the backend to resolve the game automatically and try to win.
* The player can also do a replay any the game played with a simulation functionality, by animating the full sequence of board states step-by-step provided by the backend.

First, can you create a frontend project using flutter with best practices with below guidelines:
* responsive for desktop and mobile, but mobile first, so the target platform is web+mobile
* palette of color and theme inspired by The Wild Robot
* codebase structured with the hexagonal architecture as show on this repository (https://github.com/newlight77/dailymotion-next-app)
* code covered properly by tests
* use docker to build and run
* include ci workflow with github action
* project name is Robot-Flower-Princess-Front

At last, I would like to be able to download the full project packaged as a zip. You'll probably need to split the complete artefacts into 5 sub parts, one generator script par part:
1. project structure & core
2. Domain layer with ports, entities, value objects and use cases
3. Data & presentation layer
4. Game page & main App
5. Project package and setup scripts