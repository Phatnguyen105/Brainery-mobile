# Brainery Mobile

Brainery Mobile is a mobile e-learning application inspired by platforms like Udemy.  
The app allows students to discover online courses, watch video lessons, track learning progress, complete quizzes, manage wishlists, receive notifications, and continue learning across devices.

## Overview

This repository contains the mobile frontend of the Brainery e-learning platform.  
The mobile app communicates with the Backend API to fetch courses, authenticate users, save learning progress, manage enrollments, and synchronize user data.

The mobile app does not connect directly to the database.  
All data access is handled securely through the Backend API.

## Main Features

- User registration and login
- Course browsing and searching
- Course detail screen
- Course enrollment
- Video lesson playback
- Lesson progress tracking
- Continue learning from last watched position
- Quiz and assignment support
- Course reviews and comments
- Wishlist management
- Push notifications
- Offline lesson download support
- User profile management

## Local Login Accounts

These accounts are seeded by the backend migration
`Brainery-backend/Brainery/src/main/resources/db/migration/V14__seed_demo_login_accounts.sql`.

| Role | Email | Password |
| --- | --- | --- |
| User / Student | `student@brainery.local` | `Admin@123` |
| Instructor | `instructor@brainery.local` | `Admin@123` |
| Admin | `admin@brainery.local` | `Admin@123` |

If the emulator still shows `Invalid credentials`, restart the Spring Boot backend so Flyway can run the new migration, then run the mobile app again.

Instructor accounts open the `Instructor` workspace after login. From there you can create courses, add sections, add lessons, and create quizzes for lessons.

## Suggested Tech Stack

Depending on the implementation direction, this project can be built with:

- React Native with TypeScript
- Expo or React Native CLI
- React Navigation
- Axios or Fetch API
- Zustand / Redux Toolkit / Context API
- AsyncStorage or SecureStore
- Firebase Cloud Messaging for push notifications

## Project Structure

```text
Brainery-mobile/
├── src/
│   ├── assets/
│   ├── components/
│   ├── constants/
│   ├── hooks/
│   ├── navigation/
│   ├── screens/
│   ├── services/
│   ├── store/
│   ├── types/
│   └── utils/
├── App.tsx
├── package.json
└── README.md
