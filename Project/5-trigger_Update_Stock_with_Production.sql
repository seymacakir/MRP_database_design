CREATE TRIGGER Update_Stock_with_Production ON [dbo].[Production_Order]
AFTER INSERT 
AS
  BEGIN 

 	declare @mrp_initial TABLE(
                        ITEM_ID INT NOT NULL,                               
                        Prod_Amount Float,
                        Release_Date date not null,
                        Receipt_Date  DATE NOT NULL                        
                                          )

 		Insert into @mrp_initial 
    		select  ITEM_ID, Prod_Amount,Release_Date,Receipt_Date    FROM inserted as t1 
	declare @number_of_childs INT
 	  		SET @number_of_childs = (select  count(*) from [dbo].[BOM_Details] where ITEM_ID = (select ITEM_ID from @mrp_initial))
	declare @PARENT_ID INT
 	  		SET @PARENT_ID = (select ITEM_ID from @mrp_initial)
	DECLARE @DEMAND FLOAT 
			SET @DEMAND = (select Prod_Amount from @mrp_initial)
	DECLARE @RECEIPT_DATE DATE 
			SET @RECEIPT_DATE = (select Release_Date from @mrp_initial)
		
	

	 DECLARE @BOM TABLE ( ID INT,ITEM_ID INT, Factor Float,RECEIPT_DATE DATE)
	 	insert into @BOM 
		  SELECT *
			FROM (
  			SELECT ROW_NUMBER() OVER (ORDER BY child_item_ID) AS row_num, child_item_ID, Factor, @RECEIPT_DATE AS RECEIPT_DATE
             from [dbo].[BOM_Details] where ITEM_ID = @PARENT_ID) AS sub 

	SELECT * FROM inserted	
	WHILE (@number_of_childs >=1 )
		BEGIN

			DECLARE @tmp TABLE ( ITEM_ID INT, FACTOR FLOAT, DEMAND FLOAT, STOCK_ON_HAND FLOAT, RECEIPT_DATE DATE, RELEASE_DATE DATE, LOTSIZE INT)
    		INSERT INTO @tmp
			select t1.ITEM_ID AS ITEM_ID,Factor, Factor*@DEMAND AS DEMAND, Stock_On_Hand, RECEIPT_DATE, DATEADD(day,-LeadTime,@RECEIPT_DATE) AS RELEASE_DATE, LotSize
			FROM @BOM as t1
			INNER JOIN [dbo].[Available_Stock] as t2 ON t1.ITEM_ID = t2.ITEM_ID AND t1.RECEIPT_DATE = t2.Stock_Date
			INNER JOIN ITEMS as t3 ON t1.ITEM_ID = t3.ID 
		  	WHERE t1.ID = @number_of_childs

			IF (select STOCK_ON_HAND FROM @tmp) >= (select DEMAND FROM @tmp)
				BEGIN
				UPDATE Available_Stock 
        		SET Stock_On_Hand = Stock_On_Hand  - (SELECT DEMAND from @tmp)
         		where ITEM_ID = (SELECT ITEM_ID from @tmp)
				END 
			ELSE 
				BEGIN 
				DECLARE @ITEM_ID INT 
        		SET @ITEM_ID = (select ITEM_ID  from @tmp)
    			DECLARE @Amount Float
       			SET @Amount = (select CEILING((DEMAND - Stock_On_Hand)/LOTSIZE)*LOTSIZE  from @tmp)
    			DECLARE @Release_Date Date
        		SET @Release_Date = (select RELEASE_DATE from @tmp)
   				DECLARE @ID INT 
        		SET @ID =  COALESCE( (select MAX(Product_ID) +1 from [dbo].[Production_Order]),1)
				INSERT INTO [dbo].[Production_Order] VALUES (@ID, @ITEM_ID,@Amount,@Release_Date,@Receipt_Date)
        		UPDATE [dbo].[Available_Stock] 
         			SET Stock_On_Hand = Stock_On_Hand  - (SELECT DEMAND from @tmp)
            		where Stock_Date >= @RECEIPT_DATE and ITEM_ID = (SELECT ITEM_ID from @tmp)
				UPDATE [dbo].[Available_Stock] 
					SET Stock_On_Hand = 0
            		where Stock_Date < @RECEIPT_DATE and ITEM_ID = (SELECT ITEM_ID from @tmp)
				END 

	


    	SET @number_of_childs = (@number_of_childs - 1)
		DELETE FROM @tmp;
		END 
    END;

