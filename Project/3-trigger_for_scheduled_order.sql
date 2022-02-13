CREATE TRIGGER Update_Stock_with_Scheduled_Orders ON [dbo].[Scheduled_Production]
AFTER INSERT 
AS
  BEGIN 
    DECLARE @tmptable TABLE (  ITEM_ID INT ,Receipt_Day DATE ,Prod_Amount FLOAT)

         INSERT INTO  @tmptable(ITEM_ID,Receipt_Day,Prod_Amount) (  SELECT  ITEM_ID,Receipt_Day,Prod_Amount   FROM inserted )

    UPDATE [dbo].[Available_Stock]
        SET Stock_On_Hand =   Stock_On_Hand + ( SELECT Prod_Amount FROM  @tmptable)                           
                             WHERE Stock_Date >= (select Receipt_Day From @tmptable) and ITEM_ID = (select ITEM_ID From @tmptable)

  END;

