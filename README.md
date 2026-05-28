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
