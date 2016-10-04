bcp pubs.dbo."authors" in authors.txt  -c -S.\APOLLO -T  
bcp pubs.[dbo].sales   in sales.txt    -c -S.\APOLLO -T      
bcp pubs..stores       in stores.txt   -c -S.\APOLLO -T         
bcp Northwind..[Order Details] out OrderDetails.txt  -c -S.\APOLLO -T 
bcp "select * from pubs..jobs" queryout jobs.txt     -c -S.\APOLLO -T

