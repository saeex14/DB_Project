create table Users(
username VARCHAR(25) UNIQUE NOT NULL,
password VARCHAR(256) NOT NULL,
name VARCHAR(50),
lastname VARCHAR(50),
email VARCHAR(50),
phone_number VARCHAR(11),
salt UNIQUEIDENTIFIER,
PRIMARY KEY(username)
)