-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 6: Section 8 (Role-Based Access Control / RBAC)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 8: ROLE-BASED ACCESS CONTROL (RBAC)
-- ============================================================

-- Step 1: Create roles
CREATE ROLE admin;
CREATE ROLE airline_staff;
CREATE ROLE passenger;

-- Step 2: Grant Admin full privileges
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

-- Step 3: Grant Airline Staff flight and seat management
GRANT ALL PRIVILEGES ON airlines         TO airline_staff;
GRANT ALL PRIVILEGES ON flights          TO airline_staff;
GRANT ALL PRIVILEGES ON flight_instances TO airline_staff;
GRANT ALL PRIVILEGES ON seats            TO airline_staff;
GRANT SELECT         ON bookings         TO airline_staff;
GRANT SELECT         ON passengers       TO airline_staff;

-- Step 4: Grant Passenger limited access
GRANT SELECT          ON flights          TO passenger;
GRANT SELECT          ON airlines         TO passenger;
GRANT SELECT          ON airports         TO passenger;
GRANT SELECT          ON flight_instances TO passenger;
GRANT SELECT          ON seats            TO passenger;
GRANT SELECT, INSERT  ON bookings         TO passenger;
GRANT SELECT, INSERT  ON payments         TO passenger;
GRANT SELECT          ON loyalty_miles    TO passenger;

-- Step 5: Assign roles to database users
GRANT admin         TO db_admin_user;
GRANT airline_staff TO staff_user;
GRANT passenger     TO passenger_user;
