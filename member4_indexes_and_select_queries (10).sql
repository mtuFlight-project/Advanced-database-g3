-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 4: Section 4 (Indexes) + Section 5 (Optimized SELECT Queries)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 4: INDEXES FOR QUERY OPTIMIZATION
-- ============================================================

-- Fast flight searches by route and date
CREATE INDEX idx_fi_flight_date
    ON flight_instances (flight_id, departure_date);

-- Seat availability lookups
CREATE INDEX idx_seats_instance_status
    ON seats (instance_id, status);

-- Booking lookups by passenger
CREATE INDEX idx_bookings_passenger
    ON bookings (passenger_id, status);

-- Audit log queries by action and time
CREATE INDEX idx_auditlog_action_time
    ON audit_log (action, logged_at);


-- ============================================================
-- SECTION 5: OPTIMIZED SELECT QUERIES
-- ============================================================

-- Query 1: Search Available Flights with Seat Count
-- (replace date and airport codes as needed)
SELECT
    f.flight_number,
    al.airline_name,
    f.scheduled_departure,
    f.scheduled_arrival,
    fi.departure_date,
    fi.status,
    COUNT(s.seat_id) AS available_seats
FROM flight_instances fi
JOIN flights   f  ON fi.flight_id   = f.flight_id
JOIN airlines  al ON f.airline_id   = al.airline_id
JOIN seats     s  ON fi.instance_id = s.instance_id
WHERE f.departure_airport = 'ADD'
  AND f.arrival_airport   = 'NBO'
  AND fi.departure_date   = '2026-06-15'
  AND s.status            = 'Available'
  AND s.cabin_class       = 'Economy'
  AND fi.status           IN ('Scheduled', 'Delayed')
GROUP BY fi.instance_id
HAVING available_seats > 0
ORDER BY f.scheduled_departure;


-- Query 2: Passenger Booking History with Payment Status
SELECT
    b.booking_id,
    fi.departure_date,
    f.flight_number,
    dep.city  AS departure_city,
    arr.city  AS arrival_city,
    s.seat_number,
    s.cabin_class,
    b.total_fare,
    b.status  AS booking_status,
    p.method  AS payment_method,
    p.status  AS payment_status
FROM bookings b
JOIN passengers      ps  ON b.passenger_id       = ps.passenger_id
JOIN flight_instances fi ON b.instance_id        = fi.instance_id
JOIN flights          f  ON fi.flight_id          = f.flight_id
JOIN airports        dep ON f.departure_airport   = dep.airport_code
JOIN airports        arr ON f.arrival_airport     = arr.airport_code
JOIN seats            s  ON b.seat_id             = s.seat_id
LEFT JOIN payments    p  ON b.booking_id          = p.booking_id
WHERE ps.email = 'abebe@gmail.com'
ORDER BY fi.departure_date DESC;


-- Query 3: Revenue Report by Route and Cabin Class
SELECT
    dep.city      AS departure_city,
    arr.city      AS arrival_city,
    s.cabin_class,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_fare)   AS gross_revenue,
    AVG(b.total_fare)   AS avg_fare
FROM bookings b
JOIN flight_instances fi  ON b.instance_id        = fi.instance_id
JOIN flights          f   ON fi.flight_id          = f.flight_id
JOIN airports        dep  ON f.departure_airport   = dep.airport_code
JOIN airports        arr  ON f.arrival_airport     = arr.airport_code
JOIN seats            s   ON b.seat_id             = s.seat_id
WHERE b.status         = 'Completed'
  AND fi.departure_date BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY dep.city, arr.city, s.cabin_class
ORDER BY gross_revenue DESC;
