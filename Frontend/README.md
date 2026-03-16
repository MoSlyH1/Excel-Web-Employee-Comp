# Employee Hub

Employee Hub is a full-stack employee management system designed to store and manage employee information and documents.

The system consists of:

* **Frontend:** Flutter Web application
* **Backend:** Node.js (Express API)
* **Database:** PostgreSQL
* **Deployment:** Docker & Docker Compose

The entire system can be started with a single command using Docker.

---

# Running the Project

## Prerequisites

Make sure the following software is installed:

* Docker
* Docker Compose

---

## Start the Application

From the project root directory run:

docker compose up --build

Docker will automatically:

* Start the PostgreSQL database
* Build the Node.js backend
* Build the Flutter frontend
* Load the provided database backup

---

## Access the Application

After the containers start:

Frontend (Web Application):

http://localhost:8080

Backend API:

http://localhost:3000

---

# System Architecture

Browser
↓
Flutter Frontend (Port 8080)
↓
Node.js Backend API (Port 3000)
↓
PostgreSQL Database

---

# Technologies Used

Frontend:

* Flutter Web
* Custom Widgets
* API service layer

Backend:

* Node.js
* Express.js
* PostgreSQL client (pg)
* Multer for file uploads

Database:

* PostgreSQL

Deployment:

* Docker
* Docker Compose

---

# Project Structure

Excel-Web-Company-Employee

Backend

* server.js (main backend server and database connection)
* package.json
* Dockerfile

Frontend

* Flutter Web project
* Widgets for UI components
* API service file for backend communication
* HomeScreen for the main interface
* Employee model representing employee data

database

* employee_Hub_backup.sql (initial database structure and data)

docker-compose.yml
README.md

---

# Backend Overview

The backend is built with **Node.js and Express**.

The **server.js** file is responsible for:

* Creating the Express server
* Connecting to PostgreSQL
* Handling API routes
* Managing file uploads
* Providing employee and company endpoints

It acts as the central communication layer between the frontend and the database.

---

# Frontend Overview

The frontend is built using **Flutter Web**.

The application includes:

* **Widgets** representing UI components and buttons
* **API services file** to communicate with backend endpoints
* **HomeScreen** which acts as the main dashboard
* **Employee model** that defines the employee data structure

---

# Database

The PostgreSQL database is automatically initialized using the provided SQL backup:

database/employee_Hub_backup.sql

This file contains:

* Table structures
* Functions
* Initial data

Docker loads this file automatically when the database container starts for the first time.

---

# Stopping the Application

Press:

CTRL + C

Then run:

docker compose down

---

# Notes

The entire application environment is containerized, meaning the project can run on any machine with Docker installed without requiring manual setup of Node.js, PostgreSQL, or Flutter.
