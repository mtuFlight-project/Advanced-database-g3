-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 7: Section 9 (AES-256 Encryption) + Section 10 (Password Hashing)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 9: ENCRYPTION (AES-256)
-- ============================================================

-- 9.1 Insert passenger with encrypted phone number
INSERT INTO passengers (full_name, email, phone, city, passport_number, password_hash)
VALUES (
    'Abebe Girma',
    'abebe@gmail.com',
    AES_ENCRYPT('0912345678', 'flight_platform_secret_key_256bit'),
    'Addis Ababa',
    'EP1234567',
    SHA2(CONCAT('mysalt_2026', 'MySecurePassword!'), 256)
);

-- 9.2 Decrypt phone (admin use only)
SELECT passenger_id, full_name, email,
       CAST(AES_DECRYPT(phone, 'flight_platform_secret_key_256bit') AS CHAR) AS phone,
       city
FROM passengers
WHERE passenger_id = 1;

-- 9.3 Store encrypted Telebirr payment reference
INSERT INTO payments (booking_id, method, amount, currency, txn_ref, status)
VALUES (
    1,
    'Telebirr',
    15000.00,
    'ETB',
    AES_ENCRYPT('TELE-09-1234-5678-REF', 'flight_platform_secret_key_256bit'),
    'Completed'
);

-- 9.4 Decrypt transaction reference (admins only)
SELECT payment_id, booking_id, method,
       AES_DECRYPT(txn_ref, 'flight_platform_secret_key_256bit') AS txn_reference,
       amount, status
FROM payments
WHERE payment_id = 1;


-- ============================================================
-- SECTION 10: PASSWORD HASHING
-- ============================================================

-- Register passenger with hashed password
INSERT INTO passengers (full_name, email, password_hash, city)
VALUES (
    'Sara Ahmed',
    'sara@email.com',
    SHA2(CONCAT('unique_salt_2026_sara', 'MyPassword123!'), 256),
    'Dire Dawa'
);

-- Verify password on login
SELECT passenger_id
FROM passengers
WHERE email         = 'sara@email.com'
  AND password_hash = SHA2(CONCAT('unique_salt_2026_sara', 'MyPassword123!'), 256);
