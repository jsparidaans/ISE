create table Product
(
    ProductCode INT not null,
    ProductName varchar(40) not null,
    ProductPrice money not null,
    ProductsInStock smallint not null,
    constraint PK_PRODUCT primary key (ProductCode),
    constraint chk_product check ((ProductName = 'TELEVISION' and ProductPrice >= 200) or ProductName != 'TELEVISION')
)
