import pyodbc
import os

path = 'C:\\Users\\seyma\\Desktop\\442_Project'
os.chdir(path)

server = 'mrpserver.database.windows.net'
database = 'mrp_database'
username = 'seymacakir'
password = '{cnjx8ArG}'   
driver= '{ODBC Driver 17 for SQL Server}'

conn = pyodbc.connect('DRIVER='+driver+';SERVER=tcp:'+server+';PORT=1433;DATABASE='+database+';UID='+username+';PWD='+ password) 
cursor=  conn.cursor() 

# DATABASE SCHEMA CREATION 
# create item table 
cursor.execute(" CREATE TABLE ITEMS (ID INT, Name VARCHAR(25),Description NVARCHAR(168),LotSize INT,LeadTime INT,Unit VARCHAR(20), PRIMARY KEY (ID));")
conn.commit()

# create BOM_details Table 

cursor.execute("CREATE TABLE BOM_Details (ID INT,ITEM_ID INT,child_item_ID INT,Factor Float,Level INT,PRIMARY KEY (ID),CONSTRAINT FK_ITEM_ID FOREIGN KEY (ITEM_ID)REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()

# Create Customer Table 
cursor.execute(" CREATE TABLE Customers ( Customer_ID INT, Customer_Name VARCHAR(168), Contact_Number  VARCHAR(11), Adress NVARCHAR(168),Mail NVARCHAR(168), PRIMARY KEY (Customer_ID));")
conn.commit()

# Create Sales_Order Table 
cursor.execute("CREATE TABLE Sales_Order (sales_order_ID INT,Customer_ID INT,Order_Date Date,Due_Date Date,TotalPrice Float,PRIMARY KEY (sales_order_ID),CONSTRAINT FK_Customer_ID  FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID) ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()

# Create Scheduled Production Table 

cursor.execute("CREATE TABLE Scheduled_Production (ID INT,ITEM_ID INT,Receipt_Day Date,Prod_Amount Float,Release_Day Date,PRIMARY KEY (ID),CONSTRAINT FK_ITEM_ID_Sceduled_Production FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()


# Create Production Order
cursor.execute("CREATE TABLE Production_Order (Product_ID INT, ITEM_ID INT, Prod_Amount Float, Release_Date Date,Receipt_Date Date,PRIMARY KEY (Product_ID),CONSTRAINT FK_ITEM_ID_Production_Order FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()

# Create Sales Order Details 
cursor.execute("CREATE TABLE Sales_Order_Details (ID INT,sales_order_ID INT,ITEM_ID INT,Order_Amount Float,PRIMARY KEY (ID),CONSTRAINT FK_ITEM_ID_Sales_Order_Details FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ID) ON DELETE CASCADE ON UPDATE CASCADE,CONSTRAINT FK_Sales_Order_ID FOREIGN KEY (sales_order_ID) REFERENCES Sales_Order (sales_order_ID) ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()

# Create Available Stock 
cursor.execute("CREATE TABLE Available_Stock ( Stock_ID INT, ITEM_ID INT, Stock_Date  Date, Stock_On_Hand Float,PRIMARY KEY (Stock_ID),CONSTRAINT FK_ITEM_ID_Available_Stock FOREIGN KEY (ITEM_ID) REFERENCES ITEMS (ID)  ON DELETE CASCADE ON UPDATE CASCADE);")
conn.commit()

#  sql commands works in sql server AND triggers are in the file as sql script and I run the code on Azure Portal since they are complex to write as string

# Initliaze ITEMS,BOM DETAILS CUSTOMERS, AVAILABLE STOCK AND SCHEDULED ORDERS FOR TEST 

# TEST CASE

cursor.execute( " INSERT INTO  Scheduled_Production VALUES (1,1,'2022-02-01',20,'2022-01-31')")
conn.commit()

cursor.execute( " INSERT INTO  Scheduled_Production VALUES (2,2,'2022-02-01',10,'2022-01-31')")
conn.commit()

cursor.execute("INSERT INTO Sales_Order VALUES (1,1,'2022-02-01','2022-02-03',70)")
conn.commit()

cursor.execute("INSERT INTO Sales_Order_Details VALUES (1,1,2,10)")
conn.commit()

cursor.execute("INSERT INTO Sales_Order_Details VALUES (2,1,1,30)")
conn.commit()


