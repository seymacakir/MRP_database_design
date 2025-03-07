CREATE TRIGGER Update_Stock_with_Production_Order ON [dbo].[Production_Order]
AFTER INSERT 
AS
  BEGIN 
    DECLARE @tmptable TABLE (  ITEM_ID INT ,Receipt_Date DATE ,Prod_Amount FLOAT)
         INSERT INTO  @tmptable(ITEM_ID,Receipt_Date,Prod_Amount) (  SELECT  ITEM_ID,Receipt_Date,Prod_Amount   FROM inserted )
	 

    UPDATE [dbo].[Available_Stock]
        SET Stock_On_Hand =   Stock_On_Hand + ( SELECT Prod_Amount FROM  @tmptable)                           
                             WHERE Stock_Date >= (select Receipt_Date From @tmptable) and ITEM_ID = (select ITEM_ID From @tmptable)
	
	delete from @tmptable
  END;
