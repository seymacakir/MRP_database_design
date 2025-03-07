import pyodbc
import os

# Define project folder path
path = "your_project_folder_path"  # Change this to the actual path
os.chdir(path)

# Database connection details
server = 'mrpserver.database.windows.net'
database = 'mrp_database'
username = 'your_username'
password = 'your_password'
driver = '{ODBC Driver 17 for SQL Server}'

# Establish connection using a context manager
conn_str = (
    f'DRIVER={driver};'
    f'SERVER=tcp:{server},1433;'
    f'DATABASE={database};'
    f'UID={username};'
    f'PWD={password}'
)

# Update SQL file paths for local execution
sql_files = [
    "sql/0-initialize_data_base.sql",
    "sql/1-initialize_tables.sql",
    "sql/2-recursive_triggers_on.sql",
    "sql/3-trigger_for_scheduled_order.sql",
    "sql/4-trigger_Update_Stock_with_Customer_Order.sql",
    "sql/5-trigger_Update_Stock_with_Production.sql",
    "sql/6-trigger_Update_Stock_with_Production_Order.sql"
]

try:
    with pyodbc.connect(conn_str) as conn:
        with conn.cursor() as cursor:
            
            # Execute SQL files
            for sql_file in sql_files:
                with open(sql_file, 'r', encoding='utf-8') as file:
                    sql_script = file.read()
                    cursor.execute(sql_script)
                conn.commit()
            
            print("All SQL scripts executed successfully.")
            
            # TEST DATA INSERTION
            test_data = [
                ("INSERT INTO Scheduled_Production (ID, ITEM_ID, Receipt_Day, Prod_Amount, Release_Day) VALUES (?, ?, ?, ?, ?)", (1, 1, '2022-02-01', 20, '2022-01-31')),
                ("INSERT INTO Scheduled_Production (ID, ITEM_ID, Receipt_Day, Prod_Amount, Release_Day) VALUES (?, ?, ?, ?, ?)", (2, 2, '2022-02-01', 10, '2022-01-31')),
                ("INSERT INTO Sales_Order (sales_order_ID, Customer_ID, Order_Date, Due_Date, TotalPrice) VALUES (?, ?, ?, ?, ?)", (1, 1, '2022-02-01', '2022-02-03', 70)),
                ("INSERT INTO Sales_Order_Details (ID, sales_order_ID, ITEM_ID, Order_Amount) VALUES (?, ?, ?, ?)", (1, 1, 2, 10)),
                ("INSERT INTO Sales_Order_Details (ID, sales_order_ID, ITEM_ID, Order_Amount) VALUES (?, ?, ?, ?)", (2, 1, 1, 30))
            ]
            
            for query, values in test_data:
                cursor.execute(query, values)
            conn.commit()

            print("Test data inserted successfully.")

except pyodbc.Error as e:
    print("Error:", e)
