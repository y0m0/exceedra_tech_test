CREATE DATABASE exceedra;


-- Create the table
CREATE TABLE exceedra_products (
    id serial PRIMARY KEY,
    product varchar(40),
    customer varchar(40),
    measure varchar(40),
    value float,
    valid_from_day DATE,
    valid_to_day DATE
);


-- Populate the table
-- Postgresql doesn't accept 0000-00-00 / 9999-99-99 as dates so I used NULL instead
INSERT INTO exceedra_products (product, customer, measure, value, valid_from_day, valid_to_day)
VALUES ('Widgets', 'Tesco', 'Gross Sales Price', 1, '20130101', '20130401'),
       ('Widgets', 'Tesco', 'Gross Sales Price', 1.5, '20130301', '20131231'),
       ('Widgets', 'Tesco', 'Gross Sales Price', 2, '20130401', '20150101'),
       ('Widgets', 'Tesco', 'Distribution Cost', 5, '20130101', '20130401'),
       ('Widgets', 'Tesco', 'Distribution Cost', 6, '20130301', '20140401'),
       ('Widgets', 'Tesco', 'Distribution Cost', 7, '20131231', '20150101'),
       ('Widgets', 'Asda', 'Gross Sales Price', 100, NULL, NULL),
       ('Widgets', 'Asda', 'Gross Sales Price', 200, '20131231', '20150101'),
       ('Widgets', 'Asda', 'Distribution Cost', 2, '20130301', '20131231'),
       ('Widgets', 'Asda', 'Distribution Cost', 3, '20140401', '20150101');


-- Select the records with overlapping dates
-- The OR statement is used to deal with the NULL values because I was unable to reproduce the 9999-99-99 CASE
SELECT id, product, customer, measure, value, valid_from_day, valid_to_day
FROM ( SELECT *,
             LEAD(valid_from_day) OVER (ORDER BY id) AS next_record_valid_from_day,
             LEAD(product) OVER (ORDER BY id) AS next_record_product,
             LEAD(customer) OVER (ORDER BY id) AS next_record_customer,
             LEAD(measure) OVER (ORDER BY id) AS next_record_measure
      FROM exceedra_products
    ) AS temp
WHERE product = next_record_product
AND customer = next_record_customer
AND measure = next_record_measure
AND (valid_to_day >= next_record_valid_from_day OR valid_to_day IS NULL);


-- Update the rows with overlapping dates
UPDATE exceedra_products AS t1
SET valid_to_day = temp.next_record_valid_from_day - INTERVAL '1' DAY
FROM (
  SELECT id, next_record_valid_from_day
  FROM ( SELECT *,
               lead(valid_from_day) OVER (ORDER BY id) AS next_record_valid_from_day,
               LEAD(product) OVER (ORDER BY id) AS next_record_product,
               LEAD(customer) OVER (ORDER BY id) AS next_record_customer,
               LEAD(measure) OVER (ORDER BY id) AS next_record_measure
        FROM exceedra_products
      ) AS temp
  WHERE product = next_record_product
  AND customer = next_record_customer
  AND measure = next_record_measure
  AND (valid_to_day >= next_record_valid_from_day OR valid_to_day IS NULL)
) AS temp
WHERE t1.id = temp.id;


-- Return the updated table
SELECT * FROM exceedra_products
ORDER BY id ASC;
