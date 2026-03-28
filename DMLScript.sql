create temp table TmpCategories as
select distinct
    product_category as categoryName,
    pet_category as petCategory
from raw_data;

create temp table TmpGeography as
select distinct
    country,
    city,
    state,
    postalCode
from
(
    select customer_country as country, null::varchar as city, null::varchar as state, customer_postal_code as postalCode from raw_data
    union
    select seller_country, null, null, seller_postal_code from raw_data
    union
    select store_country, store_city, store_state, null from raw_data
    union
    select supplier_country, supplier_city, null, null from raw_data
) as all_geo
where country is not null;

insert into DimProductCategories (categoryName, petCategory)
select categoryName, petCategory
from TmpCategories
on conflict do nothing;

insert into DimGeography (country, city, state, postalCode)
select country, city, state, postalCode
from TmpGeography
on conflict do nothing;


insert into DimCustomers (firstName, lastName, age, email, geoId, petType, petName, petBreed)
select distinct on (customer_email) 
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    geo.geoId,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
from raw_data raw
join DimGeography geo
    on raw.customer_country = geo.country
    and raw.customer_postal_code = geo.postalCode
where customer_email is not null;

insert into DimSellers (firstName, lastName, email, geoId)
select distinct on (seller_email) 
    seller_first_name,
    seller_last_name,
    seller_email,
    geo.geoId
from raw_data raw
join DimGeography geo
    on raw.seller_country = geo.country
    and raw.seller_postal_code = geo.postalCode
where seller_email is not null;

insert into DimSuppliers (name, contactName, email, phone, geoId)
select distinct on (supplier_name, supplier_email) 
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    geo.geoId
from raw_data raw
join DimGeography geo
    on raw.supplier_country = geo.country
    and raw.supplier_city = geo.city
where supplier_name is not null and supplier_email is not null;

insert into DimStores (name, locationAddress, phone, email, geoId)
select distinct on (store_name) 
    store_name,
    store_location,
    store_phone,
    store_email,
    geo.geoId
from raw_data raw
join DimGeography geo
    on raw.store_country = geo.country
    and raw.store_city = geo.city
    and raw.store_state = geo.state
where store_name is not null;

insert into DimProducts (name, categoryId, brand, price, weight, color, size, material, description, rating, releaseDate, expiryDate)
select distinct on (product_name, product_brand) 
    product_name,
    cat.categoryId,
    product_brand,
    product_price,
    product_weight,
    product_color,
    product_size,
    product_material,
    product_description,
    product_rating,
    product_release_date,
    product_expiry_date
from raw_data raw
join DimProductCategories cat
    on raw.product_category = cat.categoryName
    and raw.pet_category = cat.petCategory
where product_name is not null and product_brand is not null;

insert into FactSales
(
    saleDate,
    customerId,
    sellerId,
    productId,
    storeId,
    supplierId,
    quantity,
    totalPrice
)
select 
    raw.sale_date,
    customer.customerId,
    seller.sellerId,
    product.productId,
    store.storeId,
    supplier.supplierId,
    raw.sale_quantity,
    raw.sale_total_price
from raw_data raw
join DimCustomers customer on raw.customer_email = customer.email
join DimSellers seller on raw.seller_email = seller.email
join DimProducts product 
    on raw.product_name = product.name 
    and raw.product_brand = product.brand
join DimStores store on raw.store_name = store.name
join DimSuppliers supplier 
    on raw.supplier_name = supplier.name 
    and raw.supplier_email = supplier.email;
