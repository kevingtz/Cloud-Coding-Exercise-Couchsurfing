-- Create database if it doesn't exist
CREATE DATABASE IF NOT EXISTS greetings_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Use the database
USE greetings_db;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
INSERT INTO users (name) VALUES 
('Kevin Loyola'),
('Eduardo Mendoza'),
('Fernando Lopez');