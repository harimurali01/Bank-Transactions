-- Convert following table in third normal form called:
--    ACCOUNT AND TRANSACTIONN and establish constraints

-- create account table
	
CREATE TABLE ACCOUNT (
AccountNo	VARCHAR(20)		PRIMARY KEY,
Name		VARCHAR(50),
City		VARCHAR(50),
SSN			VARCHAR(10),
State		CHAR(2),
Country		VARCHAR(20)
);

-- create transactionn table
-- Can't create tables with key words

CREATE TABLE TRANSACTIONN (
TransactionNo	INTEGER		PRIMARY KEY,
AccountNo		VARCHAR(20),
TransactionDate	DATETIME,
Debt			NUMERIC(16,2),
Credit			NUMERIC(16,2),
Balance			NUMERIC(16,2),
CONSTRAINT FK_AcctTran FOREIGN KEY (AccountNo) REFERENCES ACCOUNT(AccountNo)
);

--	Insert 5 records in ACCOUNT table

INSERT INTO ACCOUNT VALUES(101,'John','Toronto','4875FHBJFKD','Ontario','Canada');
INSERT INTO ACCOUNT VALUES(109,'Tony','Indianapolis','8686DKFGHGN','Indiana','United States');
INSERT INTO ACCOUNT VALUES(150,'William','Calgary','9867NGMFNKJ','Alberta','Canada');
INSERT INTO ACCOUNT VALUES(169,'Nancy','Montreal','23478NBVBBB','Quebec','Canada');
INSERT INTO ACCOUNT VALUES(126,'Rebecca','Miami','00945JBNKJG','Florida','United States');

-- Insert 10 transactions from Jan 1,2022 to Jan 10, 2022, two transactions for each account

INSERT INTO TRANSACTIONN VALUES(0101221,101,'2022-01-01 10:00:44',0.00,550.00,550.00);
INSERT INTO TRANSACTIONN VALUES(0110222,101,'2022-01-10 13:05:34',50.00,0.00,500.00);
INSERT INTO TRANSACTIONN VALUES(0102221,109,'2022-01-02 10:10:24',0.00,260.00,260.00);
INSERT INTO TRANSACTIONN VALUES(0109222,109,'2022-01-09 12:10:14',10.00,0.00,250.00);
INSERT INTO TRANSACTIONN VALUES(0103221,150,'2022-01-03 10:20:44',0.00,425.00,425.00);
INSERT INTO TRANSACTIONN VALUES(0108222,150,'2022-01-08 11:15:34',25.00,0.00,400.00);
INSERT INTO TRANSACTIONN VALUES(0104221,169,'2022-01-04 10:30:24',0.00,880.00,880.00);
INSERT INTO TRANSACTIONN VALUES(0107222,169,'2022-01-07 16:20:14',80.00,0.00,800.00);
INSERT INTO TRANSACTIONN VALUES(0105221,126,'2022-01-05 10:40:44',0.00,555.00,555.00);
INSERT INTO TRANSACTIONN VALUES(0106222,126,'2022-01-06 14:30:34',55.00,0.00,500.00);

-- Retrieve transactions from Jan 1,2022 to Jan 5,2022 starting from latest record
-- format: YYYY-MM-DD HH:MI:SS

SELECT * FROM TRANSACTIONN WHERE TransactionDate
BETWEEN '2022-01-01 00:00:00' AND '2022-01-05 23:59:00'
ORDER BY TransactionDate DESC;


-- Complete the following queries
-- Create a view based on last 5 transactions according to date and display:
-- Account No, Name, Transaction No, Transaction Date, Debt, Credit, Balance

CREATE VIEW vwAcctNTransaction
AS
SELECT  A.AccountNo, 
        A.Name, 
        T.TransactionNo,
        T.TransactionDate,
        T.Debt,
		T.Credit,
		T.Balance
FROM ACCOUNT	A
JOIN TRANSACTIONN	T
ON A.AccountNo = T.AccountNo;

-- Write a query to show latest transaction from each Account

SELECT * 
FROM vwAcctNTransaction V1
WHERE EXISTS (
	SELECT * FROM vwAcctNTransaction AS V2
	WHERE V2.AccountNo = V1.AccountNo
	AND V2.TransactionDate < V1.TransactionDate
);

-- Using subquery, display all transactions that are equal to the 
-- Minimum value of a transaction in DEBT

SELECT * 
FROM vwAcctNTransaction
WHERE Debt = (SELECT MIN(Debt) FROM vwAcctNTransaction);


-- Insert 10 more transactions in transaction table for each account for the same existing date of
-- transactions

INSERT INTO TRANSACTIONN VALUES(0101223,101,'2022-01-01 10:00:44',0.00,550.00,550.00);
INSERT INTO TRANSACTIONN VALUES(0110224,101,'2022-01-10 13:05:34',50.00,0.00,500.00);
INSERT INTO TRANSACTIONN VALUES(0102223,109,'2022-01-02 10:10:24',0.00,260.00,260.00);
INSERT INTO TRANSACTIONN VALUES(0109224,109,'2022-01-09 12:10:14',10.00,0.00,250.00);
INSERT INTO TRANSACTIONN VALUES(0103223,150,'2022-01-03 10:20:44',0.00,425.00,425.00);
INSERT INTO TRANSACTIONN VALUES(0108224,150,'2022-01-08 11:15:34',25.00,0.00,400.00);
INSERT INTO TRANSACTIONN VALUES(0104223,169,'2022-01-04 10:30:24',0.00,880.00,880.00);
INSERT INTO TRANSACTIONN VALUES(0107224,169,'2022-01-07 16:20:14',80.00,0.00,800.00);
INSERT INTO TRANSACTIONN VALUES(0105223,126,'2022-01-05 10:40:44',0.00,555.00,555.00);
INSERT INTO TRANSACTIONN VALUES(0106224,126,'2022-01-06 14:30:34',55.00,0.00,500.00);

-- Write a query to display Total Debt, Total Credit and Total balance for each account

SELECT
AccountNo, 
SUM(Debt) AS TotalDebt,
SUM(Credit) AS TotalCredit,
SUM(Balance) AS TotalBalance
FROM TRANSACTIONN
GROUP BY AccountNo;

-- Create an index INDEX_TRANS_DT based on the Transaction date
-- SP_HELPINDEX 'TRANSACTIONN'
-- SHOW KEYS FROM TRANSACTIONN
-- SHOW INDEXES FROM TRANSACTIONN

CREATE INDEX INDEX_TRANS_DT on TRANSACTIONN(TransactionDate);

-- Write a query to create table while SELECTING all records from Transactions table sort by
-- Transaction date without using CREATE command. Table name: ONLY_TRANSACT

SELECT * INTO ONLY_TRANSACT FROM TRANSACTIONN;

-- Create replica table of Transaction Table called Transaction_2 with constraints

CREATE TABLE Transaction_2 LIKE TRANSACTIONN;
INSERT INTO Transaction_2 SELECT * FROM TRANSACTIONN;

-- Display records which are common in transaction table 1 and 2 in one query.
-- Without using JOINING condition

SELECT * FROM TRANSACTIONN
UNION
SELECT * FROM Transaction_2;

-- Display all records from Transaction table 1 and Transaction table 2 using without using
-- JOIN condition

SELECT * FROM TRANSACTIONN
UNION ALL
SELECT * FROM Transaction_2;

-- Create Common table Expression called CTE_1 with the 
-- same data points as in Q2 (i)

WITH CTE_1 (AccountNo, Name, Debt, Credit, Balance) AS (
    SELECT    
        AccountNo, Name, Debt, Credit, Balance
    FROM    
        vwAcctNTransaction
)

SELECT
    distinct(AccountNo),
    Name
FROM 
    CTE_1
WHERE
    Balance >= 750;


-- Create a physical table CTE_TRANS5 while retrieving data through CTE_1

WITH CTE_1 (AccountNo, Name, Debt, Credit, Balance) AS(
SELECT    
        AccountNo, Name, Debt, Credit, Balance
    FROM    
        vwAcctNTransaction
)
SELECT AccountNo, Name, Debt, Credit, Balance
INTO CTE_TRANS5 FROM CTE_1;
                          

-- Modify table ACCOUNT and TRANSACTIONN
-- Add CREATEDT column in ACCOUNT and TRANSACTION table

ALTER TABLE ACCOUNT ADD CREATEDT DATE;

ALTER TABLE TRANSACTIONN ADD CREATEDT DATE;

-- Insert Todays’ date in each row for both the tables in CREATDT column
-- GETDATE()

UPDATE ACCOUNT SET CREATEDT = SYSDATE;

UPDATE TRANSACTIONN SET CREATEDT = SYSDATE;
