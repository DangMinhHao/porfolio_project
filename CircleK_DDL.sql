
-- Circle K database 
CREATE DATABASE CircleK;

-- Access CircleK database
USE CircleK 
GO;

-- TERMINAL table
CREATE TABLE Terminal (
	terminal_id VARCHAR(30) NOT NULL,
	terminal_name VARCHAR(30) NOT NULL,
CONSTRAINT PKterminal PRIMARY KEY (terminal_id)
);


-- TERRITORY table 
CREATE TABLE Territory (
	zip_code VARCHAR(20) NOT NULL,
	city VARCHAR(20) NOT NULL,
	description VARCHAR(50),
CONSTRAINT PKzipcode PRIMARY KEY (zip_code)
);


-- STORE table 
CREATE TABLE Store (
	store_id VARCHAR(30) NOT NULL,
	address VARCHAR(50) NOT NULL,
	zip_code VARCHAR(20) NOT NULL,
	total_width FLOAT,
	total_length FLOAT,
	total_area FLOAT,
CONSTRAINT FKzipcode FOREIGN KEY (zip_code) REFERENCES Territory
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT PKstore PRIMARY KEY (store_id)
);


-- PAYMENT TABLE
CREATE TABLE Payment (
	payment_id VARCHAR(20) NOT NULL,
	payment_name VARCHAR(20) NOT NULL,
	category VARCHAR(20) NOT NULL,
	description VARCHAR(50),
CONSTRAINT PKpayment PRIMARY KEY (payment_id)
);


-- EMPLOYEE TABLE 
CREATE TABLE Employee (
	employee_id VARCHAR(20) NOT NULL,
	working_date DATE NOT NULL,
	full_name VARCHAR(50),
	gender varchar(10) NOT NULL,
	birthday DATE,
	phone VARCHAR(15) NOT NULL,
	email VARCHAR(30) NOT NULL,
	certify_no VARCHAR(20) NOT NULL,
	full_current_address VARCHAR(30) NOT NULL,
	full_permanent_address VARCHAR(30) NOT NULL,
	zip_code VARCHAR(20) NOT NULL,
CONSTRAINT CKgender CHECK (gender IN ('Male', 'Female', 'Other')),
CONSTRAINT FKzip_code FOREIGN KEY (zip_code) REFERENCES Territory
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT PKemployee_id PRIMARY KEY (employee_id)
);


-- TITLE TABLE
CREATE TABLE Title (
	employee_id VARCHAR(20) NOT NULL,
	version_no VARCHAR(20) NOT NULL,
	begin_date DATE NOT NULL,
	end_date DATE NOT NULL,
	title VARCHAR(20) NOT NULL,
CONSTRAINT PKemp_version_id PRIMARY KEY (employee_id, version_no),
CONSTRAINT FKemp_id FOREIGN KEY (employee_id) REFERENCES Employee
	ON UPDATE CASCADE
	ON DELETE CASCADE
);


-- SUPPLIER TABLE
CREATE TABLE Supplier (
	supplier_id VARCHAR(20) NOT NULL,
	supplier_name VARCHAR(20) NOT NULL,
	supplier_origin VARCHAR(20),
CONSTRAINT PKsupplier_id PRIMARY KEY (supplier_id)
);


-- SUBCATEGORY TABLE
CREATE TABLE SubCategory (
	sub_category_id VARCHAR(20) NOT NULL,
	sub_category_name VARCHAR(20) NOT NULL,
	category VARCHAR(20),
CONSTRAINT PKsub_category_id PRIMARY KEY (sub_category_id)
);

-- PRODUCT TABLE
CREATE TABLE Product (
	product_id VARCHAR(20) NOT NULL,
	product_name VARCHAR(30) NOT NULL,
	unit_price FLOAT NOT NULL,
	description VARCHAR(50),
	sub_category_id VARCHAR(20) NOT NULL,
	supplier_id VARCHAR(20) NOT NULL,
CONSTRAINT PKproduct_id PRIMARY KEY (product_id),
CONSTRAINT FKsub_category_id FOREIGN KEY (sub_category_id) REFERENCES SubCategory
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKsupplier_id FOREIGN KEY (supplier_id) REFERENCES Supplier
	ON UPDATE CASCADE
	ON DELETE CASCADE
)


-- PROMOTION TABLE 
CREATE TABLE Promotion (
	promotion_id VARCHAR(20) NOT NULL,
	promotion_name VARCHAR(40) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL, 
	promotion_type VARCHAR(20) NOT NULL,
	discount VARCHAR(10) NOT NULL,
CONSTRAINT PKpromotion_id PRIMARY KEY (promotion_id),
CONSTRAINT CKpromotion_type CHECK (promotion_type IN ('discount', 'buy 1 get 1'))
)


-- MEMBERSHIP TABLE
CREATE TABLE Membership (
	rank_id VARCHAR(20) NOT NULL,
	rank_name VARCHAR(20) NOT NULL,
	total_spending FLOAT NOT NULL,
CONSTRAINT PKrank_id PRIMARY KEY (rank_id) 
)


-- CUSTOMER TABLE
CREATE TABLE Customer (
	customer_id VARCHAR(20) NOT NULL,
	created_date DATE NOT NULL,
	full_name VARCHAR(20) NOT NULL,
	gender VARCHAR(10) NOT NULL, 
	birthday DATE,
	phone VARCHAR(15) NOT NULL,
	email VARCHAR(30) NOT NULL,
	certify_no VARCHAR(20) NOT NULL,
	zip_code VARCHAR(20) NOT NULL,
	current_rank VARCHAR(20) NOT NULL,
CONSTRAINT PKcustomer_id PRIMARY KEY (customer_id),
CONSTRAINT CKgender_cus CHECK (gender IN ('Male', 'Female', 'Other')),
CONSTRAINT FKzip_code_cus FOREIGN KEY (zip_code) REFERENCES Territory
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKcurrent_rank FOREIGN KEY (current_rank) REFERENCES Membership
	ON UPDATE CASCADE
	ON DELETE CASCADE,
)
-- POINT BALANCE TABLE
CREATE TABLE [Point balance] (
	customer_id VARCHAR(20) NOT NULL,
	update_date DATETIME NOT NULL,
	total_spending FLOAT NOT NULL,
	next_rank VARCHAR(20),
CONSTRAINT PKcust_update_date PRIMARY KEY (customer_id, update_date),
CONSTRAINT FKcustomer_id FOREIGN KEY (customer_id) REFERENCES Customer
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKnext_rank FOREIGN KEY (next_rank) REFERENCES Membership
)


-- TRANSACTION TABLE 
CREATE TABLE [Transaction] (
	transaction_id VARCHAR(20) NOT NULL,
	transaction_date DATETIME NOT NULL,
	store_id VARCHAR(30) NOT NULL,
	employee_id VARCHAR(20) NOT NULL,
	terminal_id VARCHAR(30) NOT NULL,
	customer_id VARCHAR(20), -- customer_id can be NULL because there are Customers do not register membership
	total_quantity INT NOT NULL,
	total_amount FLOAT NOT NULL,
	VAT FLOAT,
	net_amount FLOAT NOT NULL,
	payment_id VARCHAR(20) NOT NULL,
	cash_received FLOAT NOT NULL,
	change_due FLOAT NOT NULL,
CONSTRAINT PKtransaction_id PRIMARY KEY (transaction_id),
CONSTRAINT FKstore_id_trans FOREIGN KEY (store_id) REFERENCES Store
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKemployee_id_trans FOREIGN KEY (employee_id) REFERENCES Employee,
CONSTRAINT FKterminal_id_trans FOREIGN KEY (terminal_id) REFERENCES Terminal
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKcustomer_id_trans FOREIGN KEY (customer_id) REFERENCES Customer,
CONSTRAINT FKpayment_id_trans FOREIGN KEY (payment_id) REFERENCES Payment
	ON UPDATE CASCADE
	ON DELETE CASCADE
)


--TRANSACTION DETAIL TABLE
CREATE TABLE [Transaction detail] (
	transaction_id VARCHAR(20) NOT NULL,
	ordinal_number VARCHAR(20) NOT NULL,
	product_id VARCHAR(20) NOT NULL,
	quantity INT NOT NULL,
	original_total_amount FLOAT NOT NULL,
	promotion_1 VARCHAR(20),
	promotion_2 VARCHAR(20),
	total_amount FLOAT NOT NULL
CONSTRAINT PKtransaction_ordnum PRIMARY KEY (transaction_id, ordinal_number),
CONSTRAINT FKproduct_id FOREIGN KEY (product_id) REFERENCES Product
	ON UPDATE CASCADE
	ON DELETE CASCADE,
CONSTRAINT FKpromoption_1 FOREIGN KEY (promotion_1) REFERENCES Promotion
	ON UPDATE NO ACTION
	ON DELETE NO ACTION,
CONSTRAINT FKpromoption_2 FOREIGN KEY (promotion_2) REFERENCES Promotion
	ON UPDATE NO ACTION
	ON DELETE NO ACTION
);



USE CircleK
GO

-- TRIGGER THAT GENERATE DATA FOR POINT BALANCE
CREATE TRIGGER trg_ManagePointBalance
	ON [Transaction]
	AFTER INSERT
AS BEGIN

	DECLARE @customer_id VARCHAR(20)
	DECLARE @current_rank VARCHAR(20)
	DECLARE @rank_name VARCHAR(20)
	DECLARE @total_spending FLOAT
	DECLARE @next_rank_spending FLOAT
	DECLARE @next_rank VARCHAR(20)
	DECLARE @next_rank_after_update VARCHAR(20)
	DECLARE @update_date DATETIME

	DECLARE fetch_data CURSOR FOR SELECT transaction_date, customer_id FROM inserted;
	OPEN fetch_data;
	FETCH NEXT FROM fetch_data INTO @update_date, @customer_id;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SELECT 
			@current_rank = current_rank 
		FROM Customer 
		WHERE @customer_id = customer_id;

		SELECT 
			@rank_name = rank_name 
		FROM Membership 
		WHERE @current_rank = rank_id;

		SELECT @total_spending = SUM(net_amount)
		FROM [Transaction]
		WHERE customer_id = @customer_id;

		IF @rank_name != 'Diamond' 
			BEGIN 
				SET @next_rank = CAST(@current_rank AS INT) + 1
				SELECT @next_rank_spending = total_spending FROM Membership WHERE @next_rank = rank_id
				IF @total_spending >= @next_rank_spending
					BEGIN
						UPDATE Customer
						SET current_rank = @next_rank
						WHERE customer_id = @customer_id;
						SET @next_rank_after_update = CAST(@next_rank AS INT) + 1
						INSERT INTO [Point balance] VALUES(@customer_id, @update_date, @total_spending, @next_rank_after_update);
					END
				ELSE 
					BEGIN 
						INSERT INTO [Point balance] VALUES(@customer_id, @update_date, @total_spending, @next_rank);
					END
			END 
		ELSE IF @rank_name = 'Diamond' 
			BEGIN
				INSERT INTO [Point balance] VALUES(@customer_id, @update_date, @total_spending, NULL);
			END;

		FETCH NEXT FROM fetch_data INTO @update_date, @customer_id;
	END
	CLOSE fetch_data;
	DEALLOCATE fetch_data;
END






