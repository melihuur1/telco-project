ALTER SESSION SET CONTAINER = XEPDB1;
ALTER SESSION SET CURRENT_SCHEMA = telco_user;

CREATE TABLE Tariffs (
    TARIFF_ID NUMBER PRIMARY KEY,         
    NAME VARCHAR2(100) NOT NULL,          
    MONTHLY_FEE NUMBER(10,2) NOT NULL,    
    DATA_LIMIT NUMBER(10,2), 
    MINUTE_LIMIT NUMBER(8,0), 
    SMS_LIMIT NUMBER(8,0)     
);

CREATE TABLE Customers (
    CUSTOMER_ID NUMBER PRIMARY KEY,       
    NAME VARCHAR2(150) NOT NULL,         
    CITY VARCHAR2(50),                    
    SIGNUP_DATE DATE,                    
    TARIFF_ID NUMBER,                     
    CONSTRAINT fk_customer_tariff_id FOREIGN KEY (TARIFF_ID) REFERENCES Tariffs(TARIFF_ID)
);

CREATE INDEX idx_customer_city ON Customers(CITY);

CREATE TABLE Monthly_Stats (
    ID NUMBER PRIMARY KEY,               
    CUSTOMER_ID NUMBER NOT NULL,          
    DATA_USAGE NUMBER(10,2),              
    MINUTE_USAGE NUMBER(8,0),             
    SMS_USAGE NUMBER(8,0),                
    PAYMENT_STATUS VARCHAR2(20),         
    CONSTRAINT fk_statistics_customer_id FOREIGN KEY (CUSTOMER_ID) REFERENCES Customers(CUSTOMER_ID),
    CONSTRAINT chk_payment_status CHECK (PAYMENT_STATUS IN ('PAID','LATE','UNPAID')),
    CONSTRAINT uq_stats_customer_id UNIQUE (CUSTOMER_ID) 
);


CREATE INDEX idx_payment_status ON Monthly_Stats(PAYMENT_STATUS);