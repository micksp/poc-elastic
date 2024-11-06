CREATE TABLE city (
    id INT PRIMARY KEY,
    name VARCHAR(255)
);

CREATE TABLE person (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES city(id)
);
