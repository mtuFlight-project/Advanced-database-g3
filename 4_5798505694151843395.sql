-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 5: Section 6 (Transactions) + Section 7 (Isolation Levels)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 6: TRANSACTIONS & CONCURRENCY CONTROL
-- ============================================================

-- Transaction A: ACID-Compliant Seat Booking (Successful COMMIT)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;

  -- Step 1: Lock the seat row exclusively
  SELECT seat_id, status
  FROM seats
  WHERE instance_id = 101 AND seat_number = '12A'
  FOR UPDATE;

  -- Step 2: (Application checks: if status != 'Available', ROLLBACK)

  -- Step 3: Mark seat as booked
  UPDATE seats
  SET status = 'Booked'
  WHERE seat_id = 5001;

  -- Step 4: Create booking record
  INSERT INTO bookings (passenger_id, instance_id, seat_id, status, total_fare)
  VALUES (1, 101, 5001, 'Confirmed', 15000.00);

  -- Step 5: Create payment record
  INSERT INTO payments (booking_id, method, amount, currency, status, txn_ref)
  VALUES (
    LAST_INSERT_ID(),
    'Telebirr',
    15000.00,
    'ETB',
    'Completed',
    AES_ENCRYPT('TELE-2026-00123456', 'flight_platform_secret_key_256bit')
  );

  -- Step 6: Log the action
  INSERT INTO audit_log (table_name, record_id, action, performed_by, details)
  VALUES (
    'bookings',
    LAST_INSERT_ID(),
    'INSERT',
    'abebe@gmail.com',
    '{"seat":"12A","flight":"ET101","fare":15000}'
  );

COMMIT;


-- Transaction B: Failed Booking — ROLLBACK (seat already taken)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;

  SELECT seat_id, status
  FROM seats
  WHERE instance_id = 101 AND seat_number = '12A'
  FOR UPDATE;
  -- Sara's transaction is BLOCKED until Abebe's lock releases.
  -- Once unblocked: seat status = 'Booked' -> Application triggers ROLLBACK.

ROLLBACK;


-- ============================================================
-- SECTION 7: ISOLATION LEVEL EXAMPLES
-- ============================================================

-- READ COMMITTED — for flight browsing (non-critical reads)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN;
  SELECT f.flight_number, f.scheduled_departure, al.airline_name,
         COUNT(s.seat_id) AS available_seats
  FROM flight_instances fi
  JOIN flights   f  ON fi.flight_id   = f.flight_id
  JOIN airlines  al ON f.airline_id   = al.airline_id
  JOIN seats     s  ON fi.instance_id = s.instance_id
  WHERE f.departure_airport = 'ADD'
    AND fi.departure_date   = '2026-06-15'
    AND s.status            = 'Available'
  GROUP BY fi.instance_id;
COMMIT;

-- SERIALIZABLE — for seat booking and payment
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
  SELECT seat_id, status
  FROM seats
  WHERE instance_id = 101 AND seat_number = '12A'
  FOR UPDATE;
  -- ... proceed with booking ...
COMMIT;
