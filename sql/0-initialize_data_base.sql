CREATE TABLE ITEMS (
    ID INT PRIMARY KEY,
    Name VARCHAR(25),
    Description NVARCHAR(168),
    LotSize INT,
    LeadTime INT,
    Unit VARCHAR(20)
);

CREATE TABLE BOM_Details (
    ID INT PRIMARY KEY,
    ITEM_ID INT,
    child_item_ID INT,
    Factor FLOAT,
    Level INT,
    CONSTRAINT FK_ITEM_ID FOREIGN KEY (ITEM_ID) 
        REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(168),
    Contact_Number VARCHAR(11),
    Address NVARCHAR(168),
    Mail NVARCHAR(168)
);

CREATE TABLE Sales_Order (
    sales_order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE,
    Due_Date DATE,
    TotalPrice FLOAT,
    CONSTRAINT FK_Customer_ID FOREIGN KEY (Customer_ID) 
        REFERENCES Customers(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Scheduled_Production (
    ID INT PRIMARY KEY,
    ITEM_ID INT,
    Receipt_Day DATE,
    Prod_Amount FLOAT,
    Release_Day DATE,
    CONSTRAINT FK_ITEM_ID_Scheduled_Production FOREIGN KEY (ITEM_ID) 
        REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Production_Order (
    Product_ID INT PRIMARY KEY,
    ITEM_ID INT,
    Prod_Amount FLOAT,
    Release_Date DATE,
    Receipt_Date DATE,
    CONSTRAINT FK_ITEM_ID_Production_Order FOREIGN KEY (ITEM_ID) 
        REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Sales_Order_Details (
    ID INT PRIMARY KEY,
    sales_order_ID INT,
    ITEM_ID INT,
    Order_Amount FLOAT,
    CONSTRAINT FK_ITEM_ID_Sales_Order_Details FOREIGN KEY (ITEM_ID) 
        REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Sales_Order_ID FOREIGN KEY (sales_order_ID) 
        REFERENCES Sales_Order (sales_order_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Available_Stock (
    Stock_ID INT PRIMARY KEY,
    ITEM_ID INT,
    Stock_Date DATE,
    Stock_On_Hand FLOAT,
    CONSTRAINT FK_ITEM_ID_Available_Stock FOREIGN KEY (ITEM_ID) 
        REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE
);