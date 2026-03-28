create table DimGeography
(
    geoId serial primary key,
    country varchar(255),
    city varchar(255),
    state varchar(255),
    postalCode varchar(50),
    unique(country, city, state, postalCode)
);

create table DimCustomers
(
    customerId serial primary key,
    firstName varchar(255) ,
    lastName varchar(255),
    age int,
    email varchar(255),
    geoId int references DimGeography(geoId),
    petType varchar(100),
    petName varchar(100),
    petBreed varchar(100)

);

create table DimSellers
(
    sellerId serial primary key,
    
    firstName varchar(255),
    lastName varchar(255),
    email varchar(255),
    geoId int references DimGeography(geoId)
);

create table DimSuppliers
(
    supplierId serial primary key,
    name varchar(255),
    contactName varchar(255),
    email varchar(255),
    phone varchar(50),
    geoId int references DimGeography(geoId)
);

create table DimStores 
(
    storeId serial primary key,
    name varchar(255),
    locationAddress varchar(255),
    phone varchar(50),
    email varchar(255) ,
    geoId int references DimGeography(geoId)
);

create table DimProductCategories
(
    categoryId serial primary key,
    categoryName varchar(255),
    petCategory varchar(100),
    unique(categoryName, petCategory)
);

create table DimProducts
(
    productId serial primary key,
    name varchar(255),
    categoryId int references DimProductCategories(categoryId),
    brand varchar(255),
    price numeric(10,2),
    weight varchar(50),
    color varchar(50),
    size varchar(50),
    material varchar(255),
    description text,
    rating numeric(3,2),
    releaseDate date,
    expiryDate date

);

create table FactSales
(
    saleId serial primary key,
    saleDate date,

    customerId int references DimCustomers(customerId),
    sellerId int references DimSellers(sellerId),
    productId int references DimProducts(productId),
    storeId int references DimStores(storeId),
    supplierId int references DimSuppliers(supplierId),
    quantity int,
    totalPrice numeric(15,2)
);
