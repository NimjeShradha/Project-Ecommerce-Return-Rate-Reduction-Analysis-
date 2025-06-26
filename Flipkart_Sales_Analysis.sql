CREATE TABLE Flipkart_Sales (
	Order_ID INT,
	Order_Date DATE,
	Order_Time TIME,
	Delivery_Date DATE,
	Delivery_Time TIME,
	Return_Date DATE,
	Return_Time TIME,
	Return_Reason VARCHAR(100),
	Product_Name VARCHAR(200),
	Category VARCHAR(100),
	Company	VARCHAR(200),
	Product_Price FLOAT,
	Quantity INT,
	Payment_Method VARCHAR(100),
	Customer_Age INT,
	Customer_Gender VARCHAR(50),
	City VARCHAR(100),
	State VARCHAR(100),
	Customer_Purchase_History INT,
	Customer_Return_History INT,
	Product_Rating FLOAT,
	Product_Warranty VARCHAR(50),
	Shipping_Mode VARCHAR(50),
	Discount_Applied FLOAT,
	Return_Risk	BOOLEAN
);

COPY Flipkart_Sales (Order_ID,Order_Date,Order_Time,Delivery_Date,Delivery_Time,Return_Date,Return_Time,Return_Reason,Product_Name,Category,Company,Product_Price,Quantity,Payment_Method,Customer_Age,Customer_Gender,City,State,Customer_Purchase_History,Customer_Return_History,Product_Rating,Product_Warranty,Shipping_Mode,Discount_Applied,Return_Risk)
FROM 'D:\Tasks By ElevateLabs\Flipkart_Product_Returns.csv'
DELIMITER ','
CSV HEADER;

COPY Flipkart_Sales 
FROM 'D:\Tasks By ElevateLabs\Flipkart_Product_Returns.csv' 
WITH (FORMAT csv, HEADER true);

DROP TABLE IF EXISTS flipkart_clean;

CREATE TABLE flipkart_clean AS
SELECT
  Order_ID,
  Order_Date,
  Order_Time,
  Delivery_Date,
  Delivery_Time,

  -- Return_Date cleanup (safe fallback if malformed dates were imported as NULL)
  CASE 
    WHEN Return_Date IS NOT NULL THEN Return_Date::TEXT 
    ELSE 'NA' 
  END AS Return_Date,

  CASE 
    WHEN Return_Time IS NOT NULL THEN Return_Time::TEXT 
    ELSE 'NA' 
  END AS Return_Time,

  COALESCE(NULLIF(TRIM(Return_Reason), ''), 'NA') AS Return_Reason,

  NULLIF(TRIM(Product_Name), '') AS Product_Name,
  INITCAP(NULLIF(Category, '')) AS Category,
  INITCAP(NULLIF(Company, '')) AS Company,

  CAST(Product_Price AS DECIMAL(10,2)) AS Product_Price,
  Quantity,
  INITCAP(Payment_Method) AS Payment_Method,
  Customer_Age,
  UPPER(Customer_Gender) AS Customer_Gender,
  INITCAP(City) AS City,
  INITCAP(State) AS State,

  Customer_Purchase_History,
  Customer_Return_History,
  CAST(Product_Rating AS DECIMAL(3,1)) AS Product_Rating,
  Product_Warranty,
  INITCAP(Shipping_Mode) AS Shipping_Mode,
  CAST(Discount_Applied AS DECIMAL(5,2)) AS Discount_Applied,

  Return_Risk
FROM Flipkart_Sales;

SELECT * FROM flipkart_clean;

SELECT Category,
       SUM(Product_Price * Quantity) AS Total_Sales,
       SUM((Product_Price * Quantity) - Discount_Applied) AS Estimated_Profit
FROM flipkart_clean
GROUP BY Category
ORDER BY Estimated_Profit ASC;

--Aggregate returns, discounts, profit margin
--Segment high-return risk by product/company
SELECT Product_Name,
       COUNT(*) AS Total_Orders,
       SUM(CASE WHEN Return_Risk = TRUE THEN 1 ELSE 0 END) AS High_Risk_Returns,
       ROUND(SUM(CASE WHEN Return_Risk = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Return_Rate_Percent
FROM flipkart_sales
GROUP BY Product_Name
ORDER BY Return_Rate_Percent DESC;

COPY flipkart_clean TO 'D:\Tasks By ElevateLabs\flipkart_clean.csv' WITH CSV HEADER;

  

