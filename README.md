# Snake Game in RISC-V Assembly

This is a for-fun project - I am not an expert in RISC-V assembly. This is a simple Snake game implementation in RISC-V assembly language, created as a learning exercise.

## How to Run

1. Launch RARS (RISC-V Assembler and Runtime Simulator)
2. Open the following tools in RARS:
   - Bitmap Display (preferably set the width to 4px)
   - Keyboard and Display MMIO Simulator
   - Timer
3. Connect all tools to the program
4. Compile and run the program
5. Use the bottom window of the IO tool as the input for controlling the snake

## Controls

- Use the arrow keys to control the snake's direction
- The snake will continuously move in the current direction
- Try to eat the food (orange squares) to grow longer
- Avoid hitting the walls or yourself
