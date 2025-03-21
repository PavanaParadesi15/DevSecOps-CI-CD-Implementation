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

# Run the project locally

## 1. Create a EC2 Instance

### Clone the repo

```
git clone https://github.com/yourusername/repo-name.git
cd repo-name
```

### Install Node.js:

```
sudo apt update
sudo apt install nodejs npm
node -v
nmp -v
```

### To install dependencies

- We use npm to manage the dependencies of the application. It downloads the dependencies from the file called "package.json"

```
npm install
```

### To Create a build

```
npm run build
```

### To run the application locally 

```
npm run dev
```

# Create Docker Image

- I am creating a multi-stage docker file

Steps involved
- 1. Download the dependencies
- 2. Build the code
- 3. Create Dist folder - Code artifact
- 4. Copy Dist folder onto Nginx (web server)


## Multistage Docker file

First  stage of Docker files includes
- Downloading dependencies
- Building application
- Creating Artifact - DIST

Second stage of Docker file
- Install Nginx
- Run the nginx server
- Put DIST artifact files to nginx html location from where it can serve static content.

Using multiple stages in the docker file, helps to reduce the docker image size drastically. In first stage there are lot of dependencies  related to npm, we can avoid them in the second stage by just copying the DIST file to nginx server


# Docker commands 

### To build a docker image
```
docker build -t <image-name:version> .
```

### To run the docker image
```
docker run -d -p 9090:80 <image-name:version>                       
```

-d : detached mode . run the container in the background





















