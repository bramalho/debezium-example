CREATE DATABASE todo;
ALTER USER 'user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'user'@'%';
FLUSH PRIVILEGES;

USE todo;

CREATE TABLE todos (
    id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(512),
    status enum('TODO', 'IN_PROGRESS', 'DONE') NOT NULL
);

INSERT INTO todos VALUES
    (default, "Test 1", "This is my test 1", "TODO"),
    (default, "Test 2", "This is my test 2", "IN_PROGRESS"),
    (default, "Test 3", "This is my test 3", "DONE"),
    (default, "Test 4", "This is my test 4", "IN_PROGRESS"),
    (default, "Test 5", "This is my test 5", "TODO");
