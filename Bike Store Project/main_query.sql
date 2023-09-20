SELECT 
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name) AS 'cust_full_name',
	cus.city,
	cus.state,
	ord.order_date,
	SUM(itm.quantity) AS 'total_units',
	SUM(itm.quantity * itm.list_price) AS 'revenue',
	prd.product_name,
	cat.category_name,
	brn.brand_name,
	sto.store_name,
	CONCAT(stf.first_name,' ',stf.last_name) AS 'sales_rep_full_name'
FROM [BikeStores].sales.orders ord
JOIN [BikeStores].sales.customers cus
ON ord.customer_id = cus.customer_id
JOIN [BikeStores].sales.order_items itm
ON ord.order_id = itm.order_id
JOIN [BikeStores].production.products prd
ON itm.product_id = prd.product_id
JOIN [BikeStores].production.categories cat
ON prd.category_id = cat.category_id
JOIN [BikeStores].sales.stores sto
ON sto.store_id = ord.store_id
JOIN [BikeStores].sales.staffs stf
ON ord.staff_id = stf.staff_id
JOIN [BikeStores].production.brands brn
ON prd.brand_id = brn.brand_id
GROUP BY
	ord.order_id,
	CONCAT(cus.first_name,' ', cus.last_name),
	cus.city,
	cus.state,
	ord.order_date,
	prd.product_name,
	cat.category_name,
	brn.brand_name,
	sto.store_name,
	CONCAT(stf.first_name,' ',stf.last_name)
