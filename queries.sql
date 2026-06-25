-- =====================================================================
--  DEMONSTRATION QUERIES  (read-only - they do NOT change any data)
--  Run after hotel_db.sql.
-- =====================================================================
USE hotel_db;

-- 1. show all guests
SELECT * FROM guest;

-- ---------- joins ----------

-- 2. each booking with guest name, room number and room type
SELECT b.booking_id,
       g.first_name, g.last_name,
       r.room_number,
       rt.name AS room_type,
       b.check_in_date, b.check_out_date,
       b.status
FROM booking b
JOIN guest g      ON b.guest_id = g.guest_id
JOIN room r       ON b.room_id  = r.room_id
JOIN room_type rt ON r.room_type_id = rt.room_type_id
ORDER BY b.check_in_date;

-- 3. every booking and its payment (LEFT JOIN keeps bookings with no payment)
SELECT b.booking_id, b.status, p.amount, p.status AS payment_status
FROM booking b
LEFT JOIN payment p ON b.booking_id = p.booking_id
ORDER BY b.booking_id;

-- ---------- aggregation (totals and counts) ----------

-- 4. total money actually paid, per room type
SELECT rt.name AS room_type, SUM(p.amount) AS total_paid
FROM payment p
JOIN booking b    ON p.booking_id = b.booking_id
JOIN room r       ON b.room_id = r.room_id
JOIN room_type rt ON r.room_type_id = rt.room_type_id
WHERE p.status = 'paid'
GROUP BY rt.name
ORDER BY total_paid DESC;

-- 5. how many bookings each guest has made
SELECT g.first_name, g.last_name, COUNT(*) AS num_bookings
FROM guest g
JOIN booking b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.first_name, g.last_name
ORDER BY num_bookings DESC;

-- 6. guests with more than one booking (HAVING filters the groups)
SELECT g.first_name, g.last_name, COUNT(*) AS num_bookings
FROM guest g
JOIN booking b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.first_name, g.last_name
HAVING COUNT(*) > 1;

-- ---------- a slightly harder one ----------

-- 7. rooms that are free between 12 and 16 June 2026.
--    A room is free if its status is 'available' and it has no
--    *active* (not cancelled) booking overlapping those dates.
SELECT r.room_number, rt.name AS room_type, rt.base_price
FROM room r
JOIN room_type rt ON r.room_type_id = rt.room_type_id
WHERE r.status = 'available'
  AND r.room_id NOT IN (
        SELECT room_id FROM booking
        WHERE status <> 'cancelled'          -- cancelled bookings don't hold the room
          AND check_in_date  < '2026-06-16'
          AND check_out_date > '2026-06-12'
  )
ORDER BY rt.base_price;

-- 8. payments that are still pending
SELECT b.booking_id, g.first_name, g.last_name, p.amount
FROM payment p
JOIN booking b ON p.booking_id = b.booking_id
JOIN guest g   ON b.guest_id   = g.guest_id
WHERE p.status = 'pending';
