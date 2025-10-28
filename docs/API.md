# API Integration Documentation

## Backend Requirements

The frontend expects the following REST API endpoints:

### Create Game
```http
POST /api/games
Content-Type: application/json

{
  "name": "string",
  "cols": number,
  "rows": number
}

Response: Game object
```

### Get All Games
```http
GET /api/games?limit=10

Query Parameters:
- limit (optional): Maximum number of games to return (default: 10)

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
  "direction": "NORTH|EAST|SOUTH|WEST"
}

Response: Updated Game object
```

### Auto Play
```http
POST /api/games/{gameId}/autoplay
POST /api/games/{gameId}/autoplay?strategy=optimal
POST /api/games/{gameId}/autoplay?strategy=ml

Query Parameters:
- strategy (optional): AI strategy - 'greedy' (default), 'optimal', or 'ml'

Strategies:
- greedy (default): Safe & reliable. 75% success rate. Checks safety before picking flowers.
- optimal: Fast & efficient. 62% success rate, but 25% fewer actions. Uses A* pathfinding and multi-step planning.
- ml: Hybrid ML/heuristic approach. Uses ML Player service for predictions. Learns from game patterns.

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
  "orientation": "NORTH|EAST|SOUTH|WEST",
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
  "direction": "NORTH|EAST|SOUTH|WEST",
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

## Related Documentation

- [Architecture](ARCHITECTURE.md) - System design and layers
- [Testing Strategy](TESTING_STRATEGY.md) - Testing API integration
- [CI/CD Pipeline](CI_CD.md) - Automated testing
- [Deployment Guide](DEPLOYMENT.md) - Environment configuration

---

**Last Updated**: October 24, 2025
**Version**: 1.1
