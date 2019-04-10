CREATE TABLE bill_details (
    bill_no            NUMBER NOT NULL,
    payment_type       CHAR(10),
    delivery_mode_id   NUMBER NOT NULL
);

CREATE UNIQUE INDEX bill_details__idx ON
    bill_details (
        delivery_mode_id
    ASC );

ALTER TABLE bill_details ADD CONSTRAINT bill_details_pk PRIMARY KEY ( bill_no );

CREATE TABLE customer_profile (
    cust_id      NUMBER(5) NOT NULL,
    ssn          NUMBER(10),
    first_name   VARCHAR2(10),
    last_name    VARCHAR2(10),
    "D.O.B"      DATE,
    phone        NUMBER(10),
    gender       CHAR(6),
    zip_code     NUMBER(7),
    street       VARCHAR2(10),
    city         CHAR(15)
);

ALTER TABLE customer_profile ADD CONSTRAINT customer_profile_pk PRIMARY KEY ( cust_id );

CREATE TABLE delivery_mode (
    delivery_mode_id   NUMBER NOT NULL,
    delivery_type      CHAR(10),
    delivery_status    CHAR(5),
    order_number       NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX delivery_mode__idx ON
    delivery_mode (
        order_number
    ASC );

ALTER TABLE delivery_mode ADD CONSTRAINT delivery_mode_pk PRIMARY KEY ( delivery_mode_id );

CREATE TABLE dependent (
    dependent_id         NUMBER(5) NOT NULL,
    dependent_fname      VARCHAR2(10),
    dependent_lname      VARCHAR2(10),
    dependent_relation   VARCHAR2(10),
    employees_emp_id     NUMBER(5) NOT NULL,
    subway_branch_id     NUMBER(5) NOT NULL
);

ALTER TABLE dependent
    ADD CONSTRAINT dependent_pk PRIMARY KEY ( dependent_id,
                                              employees_emp_id,
                                              subway_branch_id );

CREATE TABLE employees (
    emp_id                    NUMBER(5) NOT NULL,
    employeename              CHAR(10),
    emp_job_desc              VARCHAR2(10),
    emp_join_date             DATE,
    subway_branch_subway_id   NUMBER(5) NOT NULL
);

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY ( emp_id,
                                                                subway_branch_subway_id );

CREATE TABLE menu (
    item_no                   NUMBER(5) NOT NULL,
    item_name                 CHAR(10),
    item_description          VARCHAR2(40 CHAR),
    item_cost                 NUMBER(5),
    subway_branch_subway_id   NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX menu__idx ON
    menu (
        subway_branch_subway_id
    ASC );

ALTER TABLE menu ADD CONSTRAINT menu_pk PRIMARY KEY ( item_no );

CREATE TABLE product_order (
    order_number   NUMBER(5) NOT NULL,
    order_date     DATE,
    price          FLOAT(3),
    to_street      VARCHAR2(10),
    to_zip         NUMBER(10),
    to_city        VARCHAR2(10),
    item_no        NUMBER(10),
    menu_item_no   NUMBER(5) NOT NULL,
    subway_id      NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX product_order__idx ON
    product_order (
        menu_item_no
    ASC );

ALTER TABLE product_order ADD CONSTRAINT product_order_pk PRIMARY KEY ( order_number );

CREATE TABLE reviews (
    review_number              NUMBER(5) NOT NULL,
    feedback                   VARCHAR2(50),
    ratings_stars              NUMBER(1),
    search_count               NUMBER(5),
    customer_profile_cust_id   NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX reviews__idx ON
    reviews (
        customer_profile_cust_id
    ASC );

ALTER TABLE reviews ADD CONSTRAINT reviews_pk PRIMARY KEY ( review_number );

CREATE TABLE salary (
    salary_id          NUMBER(10) NOT NULL,
    salary_amount      NUMBER(10),
    date_salary        DATE,
    employees_emp_id   NUMBER(5) NOT NULL,
    subway_branch_id   NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX salary__idx ON
    salary (
        employees_emp_id
    ASC,
        subway_branch_id
    ASC );

ALTER TABLE salary ADD CONSTRAINT salary_pk PRIMARY KEY ( salary_id );

CREATE TABLE subway_branch (
    subway_id                  NUMBER(5) NOT NULL,
    subway_pro_name            VARCHAR2(15),
    subway_street              VARCHAR2(20),
    subway_city                VARCHAR2(10),
    subway_zip                 NUMBER(5),
    customer_profile_cust_id   NUMBER(5) NOT NULL
);

CREATE UNIQUE INDEX subway_branch__idx ON
    subway_branch (
        customer_profile_cust_id
    ASC );

ALTER TABLE subway_branch ADD CONSTRAINT subway_branch_pk PRIMARY KEY ( subway_id );

ALTER TABLE bill_details
    ADD CONSTRAINT bill_details_delivery_mode_fk FOREIGN KEY ( delivery_mode_id )
        REFERENCES delivery_mode ( delivery_mode_id );

ALTER TABLE delivery_mode
    ADD CONSTRAINT delivery_mode_product_order_fk FOREIGN KEY ( order_number )
        REFERENCES product_order ( order_number );

ALTER TABLE dependent
    ADD CONSTRAINT dependent_employees_fk FOREIGN KEY ( employees_emp_id,
                                                        subway_branch_id )
        REFERENCES employees ( emp_id,
                               subway_branch_subway_id );

ALTER TABLE employees
    ADD CONSTRAINT employees_subway_branch_fk FOREIGN KEY ( subway_branch_subway_id )
        REFERENCES subway_branch ( subway_id );

ALTER TABLE menu
    ADD CONSTRAINT menu_subway_branch_fk FOREIGN KEY ( subway_branch_subway_id )
        REFERENCES subway_branch ( subway_id );

ALTER TABLE product_order
    ADD CONSTRAINT product_order_menu_fk FOREIGN KEY ( menu_item_no )
        REFERENCES menu ( item_no );

ALTER TABLE reviews
    ADD CONSTRAINT reviews_customer_profile_fk FOREIGN KEY ( customer_profile_cust_id )
        REFERENCES customer_profile ( cust_id );

ALTER TABLE salary
    ADD CONSTRAINT salary_employees_fk FOREIGN KEY ( employees_emp_id,
                                                     subway_branch_id )
        REFERENCES employees ( emp_id,
                               subway_branch_subway_id );

--  ERROR: FK name length exceeds maximum allowed length(30) 
ALTER TABLE subway_branch
    ADD CONSTRAINT customer_profile_fk FOREIGN KEY ( customer_profile_cust_id )
        REFERENCES customer_profile ( cust_id );

CREATE OR REPLACE TRIGGER fkntm_menu BEFORE
    UPDATE OF subway_branch_subway_id ON menu
BEGIN
    raise_application_error(-20225,'Non Transferable FK constraint  on table Menu is violated');
END;
/

CREATE SEQUENCE delivery_mode_delivery_mode_id START WITH 1 NOCACHE ORDER;

CREATE OR REPLACE TRIGGER delivery_mode_delivery_mode_id BEFORE
    INSERT ON delivery_mode
    FOR EACH ROW
    WHEN ( new.delivery_mode_id IS NULL )
BEGIN
    :new.delivery_mode_id := delivery_mode_delivery_mode_id.nextval;
END;
/