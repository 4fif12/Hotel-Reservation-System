# Hotel Reservation System

A relational database for managing the daily records of a small hotel — its rooms, guests, bookings and payments — built in SQL and tested on MySQL / MariaDB.

## Purpose

This project models the core data a hotel needs to operate: the types of room it offers, the physical rooms, the guests who stay, the bookings that connect a guest to a room for a set of dates, and the payments taken against those bookings. The schema is normalised so that every fact is stored only once, which prevents the data from contradicting itself, and it uses keys and constraints to keep the data valid.

## Database structure

The database contains five tables, all linked by one-to-many relationships:

- **room_type** — the categories of room (Single, Double, Twin, Family, Suite) with their nightly price and capacity
- **room** — the physical rooms, each belonging to one room type
- **guest** — the customers
- **booking** — a guest's stay in a room for a set of dates (the bridge between guests and rooms)
- **payment** — money taken against a booking

An entity-relationship diagram is included in the repository (`er_diagram.png`).

## Files

| File | Description |
|------|-------------|
| `hotel_db.sql` | Creates the database, all five tables (with keys and constraints) and the sample data. Run this first. |
| `queries.sql` | A set of read-only demonstration queries (joins, aggregation, HAVING, an availability search). |
| `crud_examples.sql` | Optional examples that add, update and delete data. Run only if you want to practise modifying the database. |
| `er_diagram.png` | The entity-relationship diagram of the schema. |

## Installation and execution

You will need MySQL or MariaDB installed.

1. Open the MySQL client (for example MySQL Workbench, or `mysql` from the command line).
2. Run the schema and sample data:
   ```
   source path/to/hotel_db.sql;
   ```
   This drops any existing copy, creates the `hotel_db` database, builds the tables and loads the sample data. Re-running it resets everything to a clean state.
3. Run the demonstration queries:
   ```
   source path/to/queries.sql;
   ```
4. (Optional) Try the data-changing examples:
   ```
   source path/to/crud_examples.sql;
   ```

## Example usage

After running `hotel_db.sql`, you can run queries such as finding which rooms are free for a given date range:

```sql
SELECT r.room_number, rt.name AS room_type, rt.base_price
FROM room r
JOIN room_type rt ON r.room_type_id = rt.room_type_id
WHERE r.status = 'available'
  AND r.room_id NOT IN (
        SELECT room_id FROM booking
        WHERE status <> 'cancelled'
          AND check_in_date < '2026-06-16'
          AND check_out_date > '2026-06-12'
  )
ORDER BY rt.base_price;
```

This returns only the rooms that are available and have no active booking overlapping those dates.

## Key features

- Five normalised tables (3NF) so each fact is stored once
- Primary and foreign keys to enforce relationships between tables
- `CHECK` constraints (e.g. a booking's check-out date must be after its check-in date)
- `UNIQUE` constraints on guest email and room number
- `ENUM` columns to restrict status and method fields to valid values
- `ON DELETE CASCADE` so a booking's payments are removed if the booking is deleted
- Demonstration queries covering joins, aggregation, grouping and an availability search
