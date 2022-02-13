CREATE TRIGGER Update_Stock_with_Customer_Order ON [dbo].[Sales_Order_Details]
AFTER INSERT 
AS
  BEGIN 

  	declare @mrp_initial TABLE(
                        ITEM_ID INT NOT NULL,                                   
                        LotSize INT,
                        LeadTime INT,
                        Due_Date date not null,
                        ORDER_AMOUNT float NOT NULL,
                        Available_Stock float
                                          )
   
 	Insert into @mrp_initial 
    	select  t1.ITEM_ID,  LotSize,LeadTime, Due_Date,ORDER_AMOUNT, COALESCE(Stock_On_Hand,0) AS Stock_On_Hand
    	FROM inserted as t1 
    	INNER JOIN [dbo].[Sales_Order] AS t2 
    	ON t1.sales_order_ID = t2.sales_order_ID
    	INNER JOIN ITEMS as t3 ON t1.ITEM_ID = t3.ID
    	LEFT JOIN Available_Stock as t4 ON t1.ITEM_ID = t4.ITEM_ID AND  t2.Due_Date = t4.Stock_Date 
	select * from @mrp_initial
	Declare @ORDER_AMOUNT FLOAT
		SET @ORDER_AMOUNT = (select ORDER_AMOUNT from @mrp_initial)
	DECLARE @AVAILABLE_STOCK FLOAT 
		SET @AVAILABLE_STOCK = ( select Available_Stock from @mrp_initial ) 
	SELECT @ORDER_AMOUNT,@AVAILABLE_STOCK

    	IF (@ORDER_AMOUNT <= @AVAILABLE_STOCK) 
			BEGIN
     		UPDATE Available_Stock 
        		SET Stock_On_Hand = Stock_On_Hand - @ORDER_AMOUNT
         			where ITEM_ID = (SELECT ITEM_ID from @mrp_initial)
			END
		
		ELSE 
			BEGIN 
    		DECLARE @ITEM_ID INT 
        		SET @ITEM_ID = (select ITEM_ID  from @mrp_initial)
    		DECLARE @LotSize Float
        		SET @LotSize = (select CEILING((ORDER_AMOUNT - Available_Stock )/LotSize)*LotSize  from @mrp_initial)
    		DECLARE @Release_Date Date
       		 	SET @Release_Date = (select DATEADD(day,-LeadTime,Due_Date)  from @mrp_initial)
   		 	DECLARE @Receipt_Date   Date
       		 	SET @Receipt_Date = (SELECT Due_Date from @mrp_initial)
    		DECLARE @ID INT 
        		SET @ID =  COALESCE( (select MAX(Product_ID) +1 from [dbo].[Production_Order]),1)
			INSERT INTO [dbo].[Production_Order] VALUES (@ID, @ITEM_ID,@Lotsize,@Release_Date,@Receipt_Date)
			 UPDATE Available_Stock 
        		SET Stock_On_Hand = Stock_On_Hand - @ORDER_AMOUNT
         			where ITEM_ID = (SELECT ITEM_ID from @mrp_initial) and Stock_Date >= @Receipt_Date
			UPDATE [dbo].[Available_Stock]
				SET Stock_On_Hand = 0
         			where ITEM_ID = (SELECT ITEM_ID from @mrp_initial) and Stock_Date < @Receipt_Date
        	END
		DELETE FROM @mrp_initial

	END;

