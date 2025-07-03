# Trek Mobile App

A Flutter mobile application for trekking and travel bookings with a Node.js backend.

## Project Structure

```
trek mobile/
├── trek/                    # Flutter mobile app (Frontend)
└── trek_web_backend/        # Node.js API server (Backend)
```

## Prerequisites

- Flutter SDK (3.32.2 or higher)
- Node.js (v16 or higher)
- MongoDB (running locally or cloud instance)
- Android Studio / VS Code

## Setup Instructions

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd trek_web_backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables:
   - Copy `config/config.env.example` to `config/config.env` (if it exists)
   - Update the MongoDB connection string in `config/config.env`
   - Set your JWT secret and other configurations

4. Start the backend server:
   ```bash
   npm start
   ```
   
   The server will run on `http://localhost:3000`

### Frontend Setup

1. Navigate to the Flutter app directory:
   ```bash
   cd trek
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Generate code files:
   ```bash
   flutter packages pub run build_runner build
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## API Configuration

The Flutter app is configured to connect to the backend at:
- **Android Emulator**: `http://10.0.2.2:3000/api/v1`
- **iOS Simulator**: `http://localhost:3000/api/v1`
- **Physical Device**: Update the IP address in `lib/core/network/api_endpoints.dart`

## Features

### Backend API Endpoints
- **Authentication**: `/api/v1/auth`
  - POST `/register` - User registration
  - POST `/login` - User login
  - GET `/getCustomer/:id` - Get user profile
  - PUT `/updateCustomer/:id` - Update user profile

- **Packages/Trips**: `/api/v1/package`
  - GET `/` - Get all packages
  - GET `/:id` - Get package by ID
  - POST `/` - Create new package
  - PUT `/:id` - Update package
  - DELETE `/:id` - Delete package

- **Bookings**: `/api/v1/bookings`
  - GET `/` - Get user bookings
  - POST `/` - Create new booking

- **Wishlist**: `/api/v1/wishlist`
  - GET `/` - Get user wishlist
  - POST `/` - Add to wishlist
  - DELETE `/:id` - Remove from wishlist

### Frontend Features
- User authentication (login/register)
- Trip browsing and details
- Booking management
- User profile management
- Offline support with local storage

## Architecture

The app follows Clean Architecture principles:

- **Domain Layer**: Entities, repositories interfaces, use cases
- **Data Layer**: Repository implementations, data sources, models
- **Presentation Layer**: BLoC pattern, UI components

## Dependencies

### Backend
- Express.js
- MongoDB with Mongoose
- JWT for authentication
- Multer for file uploads
- CORS enabled

### Frontend
- Flutter 3.32.2
- Dio for HTTP requests
- BLoC for state management
- Hive for local storage
- GetIt for dependency injection

## Troubleshooting

### Common Issues

1. **NDK Version Mismatch**: Update Android NDK version in `android/app/build.gradle.kts`
2. **Connection Issues**: Ensure backend is running and check API endpoints configuration
3. **Build Errors**: Run `flutter clean` and `flutter pub get` before building

### Development Tips

- Use `flutter packages pub run build_runner watch` for automatic code generation
- Check the network logs in the Flutter app for API debugging
- Use Postman or similar tools to test backend endpoints

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. 