-- =====================================================================
--  OPTIONAL: create / update / delete practice
--  These statements CHANGE the data. Run them only if you want to
--  practise modifying the database. The main build file does not
--  include them, so hotel_db.sql always rebuilds a clean copy.
-- =====================================================================
USE hotel_db;

-- add a new guest
INSERT INTO guest (first_name, last_name, email, phone, country)
VALUES ('Emma', 'Wagner', 'emma.wagner@example.com', '+49 172 1234567', 'Germany');

-- mark a booking as checked out
UPDATE booking SET status = 'checked_out' WHERE booking_id = 3;

-- delete a booking (its payments are removed automatically via ON DELETE CASCADE)
DELETE FROM booking WHERE booking_id = 9;
