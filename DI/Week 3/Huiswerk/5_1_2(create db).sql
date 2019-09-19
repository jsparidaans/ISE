begin tran
create database db5_1
go
use db5_1
go

create table Product(
    ProductCode INT primary key identity,
    ProductName varchar(40) not null,
    ProductPrice money not null,
    ProductsInStock smallint not null
)

create table Customer(
    CustomerID int primary key not null,
    CustomerName varchar(40) not null
)

create table Orders(
    OrderNr int primary key identity,
    CustomerID int not null,
    OrderDate datetime not null,
    OrderStatus varchar(12) not null

    constraint FK_Customer_Orders_CustomerID foreign key (CustomerID) 
    references Customer(CustomerID)
    on update cascade 
)

create table OrderDetail(
    OrderNr int not null,
    ProductCode int not null,
    DetailQuantity smallint not null 

    constraint PK_OrderDetail_OrderNr_ProductCode primary key (OrderNr, ProductCode)
    constraint FK_OrderDetail_Product_ProductCode foreign key (ProductCode)
    references Product(ProductCode),
    constraint FK_OrderDetail_Orders_OrderNr foreign key (OrderNr)
    references Orders(OrderNr)
        on update cascade 


)




rollback tran