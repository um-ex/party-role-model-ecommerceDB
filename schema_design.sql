create schema ecommerce;
use ecommerce;

-- creating table for party and party type

create table party_type(
	party_type_id int auto_increment primary key,
    type_name varchar(50) not null unique
);

create table party (
	party_id int auto_increment primary key,
    party_type_id int not null,
    Name varchar(100) not null,
    Email varchar(100),
    Phone varchar(20),
    address text,
    created_at timestamp default current_timestamp,
    constraint fk_party_type foreign key (party_type_id) references party_type (party_type_id)
);

-- creating tables for person and organizations (subtype of party)
create table person (
	party_id int primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    dob date,
    gender enum('male','female','other'),
    constraint fk_person_party foreign key (party_id) references party(party_id)
);

create table organization (
	party_id int primary key,
    company_name varchar(100) not null,
    registration_number varchar(100),
    PAN_no varchar(20),
    constraint fk_org_party foreign key (party_id) references party(party_id)
);

-- creating table for party role type and party role
create table role_type (
	role_type_id int auto_increment primary key,
    type_name varchar(50) not null unique
);
create table party_role(
	party_role_id int auto_increment primary key,
    role_type_id int not null,
    party_id int not null,
    created_at timestamp default current_timestamp,
    constraint fk_party_role_party_type foreign key (role_type_id) references role_type(role_type_id),
    constraint fk_party_role_party foreign key (party_id) references party(party_id)
);

-- creating table for party relationship and party relationship type

create table relationship_type(
	relationship_type_id int auto_increment primary key,
    relationship_name varchar(100) not null unique    
);	
create table Party_relationship (
	party_relationship_id int auto_increment primary key,
    From_party_id int not null,
    To_party_id int not null,
    relationship_type_id int not null,
    created_at timestamp default current_timestamp,
    constraint fk_relationship_from foreign key (From_party_id) references party(party_id),
    constraint fk_relationship_to foreign key (To_party_id) references party(party_id),
    constraint fk_relationship_type foreign key(relationship_type_id) references relationship_type(relationship_type_id)
);

-- creating tables for products and categories
create table product_category (
	category_id int auto_increment primary key,
    Name varchar(100) not null,
    Parent_category_id int,
    constraint fk_category_parent foreign key(parent_category_id) references product_category(category_id)
);

create table product (
	product_id int auto_increment primary key,
    Name varchar(200) not null,
    description text,
    price decimal(10,2) not null,
    stock_quantity int default 0,
    seller_role_id int not null,
    category_id int not null,
    created_at timestamp default current_timestamp,
    constraint fk_product_seller foreign key(seller_role_id) references party_role(party_role_id),
    constraint fk_product_category foreign key(category_id) references product_category(category_id)
);

-- creating tables for orders and items
create table `order` (
	order_id int auto_increment primary key,
    customer_role_id int not null,
    order_date timestamp default current_timestamp,
	status ENUM('pending', 'confirmed','shipped','delivered','cancelled') default 'pending',
    total_amount decimal(10,2) not null,
    constraint fk_order_customer foreign key(customer_role_id) references party_role(party_role_id)
);

create table order_item(
	order_item_id int auto_increment primary key,
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity > 0),
    unit_price decimal(10,2) not null,
    constraint fk_order_item_order foreign key (order_id) references `order`(order_id),
    constraint fk_order_item_product foreign key (product_id) references product(product_id)
);

-- creating tables for payments and shipments
create table payment(
	payment_id int auto_increment primary key,
    order_id int not null,
    payment_provider_role_id int not null,
    amount decimal(10,2) not null,
    payment_date timestamp default current_timestamp,
    payment_status enum('pending','completed','failed','refunded') default 'pending',
    constraint fk_payment_order foreign key (order_id) references `order`(order_id),
    constraint fk_payment_party_role foreign key(payment_provider_role_id) references party_role(party_role_id)
);

create table shipment (
	shipment_id int auto_increment primary key,
    order_id int not null,
    delivery_agent_id int not null,
    tracking_number varchar(100),
    shipment_status enum('pending','shipped', 'delivered','returned') default 'pending',
    shipped_date timestamp null,
    delivered_date timestamp null,
    constraint fk_shipment_order foreign key(order_id) references `order`(order_id),
    constraint fk_shipment_party_role foreign key(delivery_agent_id) references party_role(party_role_id)
);

-- create table for login auth
create table user_account(
	user_id int auto_increment primary key,
    party_id int not null,
    username varchar(100) not null unique,
    password varchar(255) not null,
    is_active boolean default true,
    last_login timestamp null,
    created_at timestamp default current_timestamp,
    constraint fk_useraccount_party foreign key(party_id) references party(party_id)
);
-- app role can be admin, user
create table app_role(
	app_role_id int auto_increment primary key,
    app_role_name varchar(100) not null unique,
    description text
);

create table permission (
	permission_id int auto_increment primary key,
    permission_name varchar(100) not null unique,
    description text
);

create table role_permission (
	app_role_id int not null,
    permission_id int not null,
    primary key(app_role_id, permission_id),
    constraint fk_role_permission_app_role foreign key (app_role_id) references app_role(app_role_id),
    constraint fk_role_permission_permission foreign key (permission_id) references permission(permission_id)
);

create table user_account_role (
	user_id int not null,
    app_role_id int not null,
    primary key(user_id, app_role_id),
    constraint fk_user_account_role_user_account foreign key (user_id) references user_account(user_id),
    constraint fk_user_account_role_app_role foreign key (app_role_id) references app_role(app_role_id)
);

