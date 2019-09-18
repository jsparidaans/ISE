begin tran 
use DB5_1
go
create procedure spReadyOrders
as 
BEGIN
    select c.customerID, c.CustomerName, o.OrderNr, o.OrderStatus
    from Customer c inner join Orders o 
    on c.CustomerID = o.CustomerID
end

rollback tran