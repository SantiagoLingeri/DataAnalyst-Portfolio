				/*		 			SQL - DESING & BUILD BUSINESS DATABASE		 			*/		
                
/*									(Creating a Comprehensive Business Database with SQL)							
                                                    
*	This project involves the design and implementation of a comprehensive Business Database(DB) using SQL. 

*	The main goal was to efficiently manage various aspects of a Business's operations by modeling a DB schema that can efficiently store and organize business-related data, such as sales transactions, customer information, item details, and company records. 

*	In addition, the project aims to ensure DB's integrity and long-term functionality by minimizing data duplication, while optimizing data handling.

*	The DB schema ensures the relationships between different entities are maintained, allowing for easy retrieval and analysis of Business information.

*	The key steps of the project included:

		1. Creating DB and 4 tables (sales, customers, items, and companies)
		2. Assigning Primary and Foreign Keys: Primary keys ensure the uniqueness of each record in the tables. Foreign keys establish essential relationships between tables, enabling efficient data retrieval.
		3. Setting Constraints: To enforce data integrity and prevent validation errors. These constraints included unique keys, default values, and cascading delete actions to maintain data consistency.
		4. Data Validation: Handling Data types accurately for every feature to avoid future errors.
		5. Data Pre-processing: The database was prepared to handle potential data discrepancies, and improve data quality.

* SQL skills used: Data Definition Language(DDL), Create, Primary Key, Foreing Key, Constraints, Data Types, Relational Database, 
																																																							*/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Create Database (DB)		*/

CREATE DATABASE IF NOT EXISTS Business_Ops;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Select DB to assing all tables 	*/

USE Business_Ops;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Create table sales		*/
										/*			COLUMNS 
														+ purchase_number (ID for each Sale), 
														+ Date, 
														+ Customer ID (linked to customers table)
														+ Item code	(linked to customers table)			*/

CREATE TABLE sales
(
	purchase_number 	INT NOT NULL AUTO_INCREMENT,
    date_of_purchase 	DATETIME,
    customer_id 		INT,
    item_code 			VARCHAR(10) NOT NULL,
    
PRIMARY KEY (purchase_number),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
FOREIGN KEY (item_code) REFERENCES items(item_code) ON DELETE CASCADE
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Create table customers		*/
										/*			COLUMNS 
														+ customer_id (unique, linked to sales)
														+ fisrt_name
														+ last_name
														+ email_address (unique)
														+ number_of_complaints			*/

CREATE TABLE customers
(
	customer_id 			INT NOT NULL AUTO_INCREMENT,
    fisrt_name 				VARCHAR(20) NOT NULL,
    last_name 				VARCHAR (20) NOT NULL,
    email_address 			VARCHAR(30) UNIQUE KEY,
    number_of_complaints 	TINYINT NOT NULL,
    
PRIMARY KEY (customer_id)
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Create table items		*/
										/*			COLUMNS 
														+ item_code (unique, linked to sales)
														+ unit_price
														+ company_id (linked to companies)			*/				

CREATE TABLE items
(
	item_code 		VARCHAR(10) NOT NULL,
    unit_price 		DECIMAL(10,2) NOT NULL,
    company_id 		INT NOT NULL,
    
PRIMARY KEY (item_code),
FOREIGN KEY (company_id) REFERENCES companies(company_id) ON DELETE CASCADE
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

											/*		Create table items		*/
											/*			COLUMNS 
														+ company_id (unique, linked to sales and items)
														+ company_name
														+ representatives_phone_number (unique)
														+ company_email_address (unique)			*/

CREATE TABLE suppliers
(
	company_id 						INT NOT NULL AUTO_INCREMENT,
    company_name 					VARCHAR(20) NOT NULL,
    representatives_phone_number 	INT UNIQUE KEY,
    company_email_address 			VARCHAR(30) UNIQUE KEY,
    
PRIMARY KEY (company_id)
);


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		Data pre-processing. (No complaints from a customer means 0, for future calculations)		*/

ALTER TABLE customers
CHANGE COLUMN number_of_complaints number_of_complaints INT DEFAULT 0;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

										/*		 Data validation. (Preventing errors with +20 caracters Company names)		*/
                                                        
ALTER TABLE companies
MODIFY company_name VARCHAR(50) NOT NULL;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------