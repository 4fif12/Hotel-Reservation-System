-- =====================================================================
--  HOTEL MANAGEMENT DATABASE  (complete, self-contained build)
--  Tested on MySQL 8 / MariaDB 10.11.
--  Run this single file to create the whole working database.
-- =====================================================================

DROP DATABASE IF EXISTS hotel_db;
CREATE DATABASE hotel_db;
USE hotel_db;

-- ---------------------------------------------------------------------
--  TABLES
-- ---------------------------------------------------------------------

-- types of room (Single, Double, etc.) and their nightly price
CREATE TABLE room_type (
    room_type_id INT AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(50)  NOT NULL,
    base_price   DECIMAL(8,2) NOT NULL,
    max_capacity INT          NOT NULL,
    CHECK (base_price >= 0),
    CHECK (max_capacity > 0)
);

-- the actual rooms in the hotel
-- status is an ENUM so a typo like 'availabel' is rejected instead of stored
CREATE TABLE room (
    room_id      INT AUTO_INCREMENT PRIMARY KEY,
    room_number  VARCHAR(10) NOT NULL UNIQUE,
    `floor`      INT NOT NULL,                       -- backticked: FLOOR is also a function name
    status       ENUM('available','occupied','maintenance','cleaning')
                 NOT NULL DEFAULT 'available',
    room_type_id INT NOT NULL,
    FOREIGN KEY (room_type_id) REFERENCES room_type(room_type_id)
);

-- customers
CREATE TABLE guest (
    guest_id   INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(120) NOT NULL UNIQUE,
    phone      VARCHAR(30),
    country    VARCHAR(60)
);

-- a guest booking a room for some dates
CREATE TABLE booking (
    booking_id     INT AUTO_INCREMENT PRIMARY KEY,
    guest_id       INT  NOT NULL,
    room_id        INT  NOT NULL,
    check_in_date  DATE NOT NULL,
    check_out_date DATE NOT NULL,
    num_guests     INT  NOT NULL DEFAULT 1,
    status         ENUM('confirmed','checked_in','checked_out','cancelled')
                   NOT NULL DEFAULT 'confirmed',
    FOREIGN KEY (guest_id) REFERENCES guest(guest_id),
    FOREIGN KEY (room_id)  REFERENCES room(room_id),
    CHECK (check_out_date > check_in_date),
    CHECK (num_guests > 0)
);

-- payments for a booking
-- ON DELETE CASCADE: if a booking is removed, its payments go with it
CREATE TABLE payment (
    payment_id   INT AUTO_INCREMENT PRIMARY KEY,
    booking_id   INT NOT NULL,
    amount       DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    method       ENUM('card','cash','bank_transfer') NOT NULL,
    status       ENUM('paid','pending','refunded') NOT NULL DEFAULT 'paid',
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id) ON DELETE CASCADE,
    CHECK (amount >= 0)
);

-- ---------------------------------------------------------------------
--  SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO room_type (name, base_price, max_capacity) VALUES
('Single', 60,  1),
('Double', 90,  2),
('Twin',   95,  2),
('Family', 140, 4),
('Suite',  220, 3);

INSERT INTO room (room_number, `floor`, status, room_type_id) VALUES
('101', 1, 'available',   1),
('102', 1, 'available',   1),
('103', 1, 'maintenance', 2),
('201', 2, 'available',   2),
('202', 2, 'available',   3),
('203', 2, 'available',   2),
('301', 3, 'available',   4),
('302', 3, 'available',   4),
('401', 4, 'available',   5),
('402', 4, 'available',   5);

INSERT INTO guest (first_name, last_name, email, phone, country) VALUES
('Anna',  'Schmidt', 'anna.schmidt@example.com', '+49 170 1112221', 'Germany'),
('Liam',  'OBrien',  'liam.obrien@example.com',  '+353 86 2223331', 'Ireland'),
('Sofia', 'Rossi',   'sofia.rossi@example.com',  '+39 333 4445551', 'Italy'),
('Kenji', 'Tanaka',  'kenji.tanaka@example.com', '+81 90 5556661',  'Japan'),
('Maria', 'Garcia',  'maria.garcia@example.com', '+34 600 6667771', 'Spain'),
('Tom',   'Becker',  'tom.becker@example.com',   '+49 171 7778881', 'Germany'),
('Priya', 'Nair',    'priya.nair@example.com',   '+91 98 8889991',  'India'),
('Lukas', 'Novak',   'lukas.novak@example.com',  '+420 60 9990001', 'Czechia');

-- bookings (the cancelled one is KEPT as a record, not deleted)
INSERT INTO booking (guest_id, room_id, check_in_date, check_out_date, num_guests, status) VALUES
(1, 1, '2026-06-01', '2026-06-04', 1, 'checked_out'),
(2, 4, '2026-06-02', '2026-06-06', 2, 'checked_out'),
(3, 7, '2026-06-05', '2026-06-09', 3, 'checked_in'),
(4, 9, '2026-06-10', '2026-06-14', 2, 'confirmed'),
(5, 2, '2026-06-11', '2026-06-13', 1, 'confirmed'),
(6, 4, '2026-06-15', '2026-06-18', 2, 'confirmed'),
(7, 8, '2026-06-20', '2026-06-25', 4, 'confirmed'),
(1, 9, '2026-07-01', '2026-07-03', 2, 'confirmed'),
(8, 5, '2026-06-03', '2026-06-05', 2, 'cancelled'),
(3, 1, '2026-07-05', '2026-07-08', 1, 'confirmed');

-- payments: amount = nights * nightly base price, so totals are meaningful
--   b1 Single  3n*60 =180   b2 Double 4n*90 =360   b3 Family 4n*140=560
--   b4 Suite   4n*220=880   b5 Single 2n*60 =120   b6 Double 3n*90 =270
--   b7 Family  5n*140=700
INSERT INTO payment (booking_id, amount, payment_date, method, status) VALUES
(1, 180, '2026-06-01', 'card',          'paid'),
(2, 360, '2026-06-02', 'card',          'paid'),
(3, 560, '2026-06-05', 'bank_transfer', 'paid'),
(4, 880, '2026-06-08', 'card',          'pending'),
(5, 120, '2026-06-11', 'cash',          'paid'),
(6, 270, '2026-06-14', 'card',          'pending'),
(7, 700, '2026-06-18', 'bank_transfer', 'pending');
