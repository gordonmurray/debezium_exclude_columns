CREATE DATABASE IF NOT EXISTS mydatabase;

USE mydatabase;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    surname VARCHAR(50),
    email VARCHAR(100),
    date_of_birth DATE,
    signed_up DATETIME,
    user_type ENUM('user', 'admin')
);

INSERT INTO users (first_name, surname, email, date_of_birth, signed_up, user_type) VALUES
('John', 'Doe', 'john.doe@example.com', '1990-01-01', '2022-01-15 08:30:00', 'user'),
('Jane', 'Smith', 'jane.smith@example.com', '1985-05-20', '2022-02-10 09:45:00', 'admin'),
('Alice', 'Johnson', 'alice.johnson@example.com', '1992-07-11', '2022-03-05 10:00:00', 'user'),
('Bob', 'Brown', 'bob.brown@example.com', '1988-09-30', '2022-04-20 11:20:00', 'user'),
('Charlie', 'Davis', 'charlie.davis@example.com', '1995-11-15', '2022-05-25 13:45:00', 'admin');
