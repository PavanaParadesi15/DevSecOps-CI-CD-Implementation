# DevSecOps-CI-CD-Implementation

## DevSecOps

- DevSecOps is same as the Devops with security implementation in the Devops implementations, not only implementing  security in CI/CD pipelines. 
- In this project I am implementing DevSecOps in CI/CD pipelines as it is one of the part in devsecops approach.
- We can find outdated packages, packages with critical vulnerabilities in the code, Hard coding of secrets, attacks from the external users through DevSecOps implementation. 

# Application

This is the simple gaming application - TicTacToe, implementing it using DevSecOps approach using Github Actions as CI CD pipeline tool

![image](https://github.com/user-attachments/assets/8fc18e14-ad5c-4857-afc3-ac1de9279162)

![image](https://github.com/user-attachments/assets/8a0447c5-d0ac-4860-9b97-4af79caf8abd)


## Technologies Used

- React 18 for Frontend
- TypeScript (.tsx)
- Tailwind CSS
- Lucide React for icons


## Project Structure

```
src/
├── components/
│   ├── Board.tsx       # Game board component
│   ├── Square.tsx      # Individual square component
│   ├── ScoreBoard.tsx  # Score tracking component
│   └── GameHistory.tsx # Game history component
├── utils/
│   └── gameLogic.ts    # Game logic utilities
├── App.tsx             # Main application component
└── main.tsx           # Entry point
```

## Game Logic

The game implements the following rules:

- goes first, followed by O
- The first player to get 3 of their marks in a row (horizontally, vertically, or diagonally) wins
- If all 9 squares are filled and no player has 3 marks in a row, the game is a draw
- Winning combinations are highlighted
- Game statistics are tracked and displayed

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn










