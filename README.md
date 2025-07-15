# SQL Bike Store Project

Author: Matthew Boodhoo

In this project, I will be performing various queries and cleaning some bike store data. I want to demonstrate and record my knowledge of SQL. The project includes, but is not limited to, the following operations: Select, where, order by, group by, case statements, common table expressions, window functions, stored procedures, and triggers.

Data Obtained from: \
	https://www.sqlservertutorial.net/getting-started/sql-server-sample-database/ \
  https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database?select=staffs.csv

The syntax used to create the database was specific to SQL Server. However, I am using MySQL. As such, I had to make minor adjustments to the database creation script to conform to MySQL syntax. For example, changing IDENTITY(1,1) to AUTO_INCREMENT. Also, the original create table statements included foreign keys linking various tables. I decided to remove these links to create my own links during the course of this project. Also, I downloaded the csv formatted data from the second link to make inserting data into the tables easier. I then used the Table Data Import Wizard to load the data into the respective tables. I recommend loading the data into the tables in the order the tables were created.

After the initial database and table setup, every query and action performed on this data is my own work.
