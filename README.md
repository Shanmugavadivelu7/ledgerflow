# LedgerFlow

A simple sales ledger application for small retail shops built with Flutter and Node.js.

## Features

- Dashboard
- Customer Management
- Daily Sales
- Reports
- Cloud Database
- REST API

## Tech Stack

### Mobile
- Flutter
- Dio
- Material 3

### Backend
- Node.js
- Express.js
- Prisma ORM

### Database
- PostgreSQL (Neon)

### Deployment
- Render
- Docker

## Project Structure

LedgerFlow/
├── apps/
│   ├── api/
│   └── mobile/
├── docker-compose.yml
└── README.md

## Running Locally

### Backend

```bash
cd apps/api
npm install
npm run dev
```

### Flutter

```bash
cd apps/mobile
flutter pub get
flutter run
```

## Environment Variables

Create `.env` inside `apps/api`

```env
DATABASE_URL=your_database_url
PORT=3000
NODE_ENV=development
```

## API

Base URL

```
https://ledgerflow-api-w3th.onrender.com
```

## Screenshots

- Dashboard
- Customers
- Add Sale
- Reports

## Deployment

Backend: Render

Database: Neon PostgreSQL

## Author

Shanmuga Vadivelu