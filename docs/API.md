# API Integration Documentation

## Backend Requirements

The frontend expects the following REST API endpoints:

### Create Game
```http
POST /api/games
Content-Type: application/json

{
  "name": "string",
  "boardSize": number
}

Response: Game object
```

### Get All Games
```http
GET /api/games

Response: Array of Game objects
```

### Get Game by ID
```http
GET /api/games/{gameId}

Response: Game object
```

### Execute Action
```http
POST /api/games/{gameId}/action
Content-Type: application/json

{
  "action": "rotate|move|pickFlower|dropFlower|giveFlower|clean",
  "direction": "north|east|south|west"
}

Response: Updated Game object
```

### Auto Play
```http
POST /api/games/{gameId}/autoplay

Response: Updated Game object
```

### Get Replay
```http
GET /api/games/{gameId}/replay

Response: Array of GameBoard objects (step-by-step states)
```

## Data Models

### Game Object
```json
{
  "id": "string",
  "name": "string",
  "board": GameBoard,
  "status": "playing|won|gameOver",
  "actions": Array<GameAction>,
  "createdAt": "ISO8601 datetime",
  "updatedAt": "ISO8601 datetime"
}
```

### GameBoard Object
```json
{
  "width": number,
  "height": number,
  "cells": Array<Cell>,
  "robot": Robot,
  "princessPosition": Position,
  "totalFlowers": number,
  "flowersDelivered": number
}
```

### Robot Object
```json
{
  "position": Position,
  "orientation": "north|east|south|west",
  "flowersHeld": number
}
```

### Position Object
```json
{
  "x": number,
  "y": number
}
```

### Cell Object
```json
{
  "position": Position,
  "type": "empty|robot|princess|flower|obstacle"
}
```

### GameAction Object
```json
{
  "type": "rotate|move|pickFlower|dropFlower|giveFlower|clean",
  "direction": "north|east|south|west",
  "timestamp": "ISO8601 datetime",
  "success": boolean,
  "errorMessage": "string?"
}
```

## Error Handling

### Error Response Format
```json
{
  "message": "string",
  "statusCode": number,
  "error": "string"
}
```

### HTTP Status Codes
- `200 OK`: Successful request
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

## Configuration

Set the API base URL in `.env`:
```
API_BASE_URL=http://localhost:8000
```

Or via environment variable:
```bash
export API_BASE_URL=http://localhost:8000
flutter run
```
