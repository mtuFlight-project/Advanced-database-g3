-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 8: Section 11 (Account Lockout Trigger) + Section 12 (Audit Logging)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 11: ACCOUNT LOCKOUT POLICY (TRIGGER)
-- ============================================================

DELIMITER $$
CREATE TRIGGER after_failed_login
AFTER UPDATE ON passengers
FOR EACH ROW
BEGIN
  IF NEW.failed_attempts >= 5 THEN
    UPDATE passengers
    SET locked_until = DATE_ADD(NOW(), INTERVAL 30 MINUTE)
    WHERE passenger_id = NEW.passenger_id;
  END IF;
END$$
DELIMITER ;

-- Check account lock status
SELECT passenger_id, email,
  CASE
    WHEN locked_until > NOW() THEN 'LOCKED'
    ELSE 'ACTIVE'
  END AS account_status
FROM passengers
WHERE email = 'abebe@gmail.com';


-- ============================================================
-- SECTION 12: AUDIT LOGGING (STORED PROCEDURE)
-- ============================================================

DELIMITER $$
CREATE PROCEDURE log_login_attempt(
  IN p_email   VARCHAR(150),
  IN p_success BOOLEAN
)
BEGIN
  DECLARE v_passenger_id BIGINT DEFAULT NULL;
  DECLARE v_action       VARCHAR(20);

  SELECT passenger_id INTO v_passenger_id
  FROM passengers
  WHERE email = p_email;

  SET v_action = IF(p_success, 'LOGIN', 'FAILED_LOGIN');

  INSERT INTO audit_log (table_name, record_id, action, performed_by, details)
  VALUES (
    'passengers',
    v_passenger_id,
    v_action,
    p_email,
    JSON_OBJECT('timestamp', NOW(), 'success', p_success)
  );

  IF NOT p_success THEN
    UPDATE passengers
    SET failed_attempts = failed_attempts + 1
    WHERE email = p_email;
  ELSE
    UPDATE passengers
    SET failed_attempts = 0, last_login = NOW()
    WHERE email = p_email;
  END IF;
END$$
DELIMITER ;

-- Detect brute-force login attacks
SELECT performed_by, COUNT(*) AS failed_count
FROM audit_log
WHERE action    = 'FAILED_LOGIN'
  AND logged_at >= NOW() - INTERVAL 1 HOUR
GROUP BY performed_by
HAVING COUNT(*) > 3
ORDER BY failed_count DESC;

-- Detect unusual booking activity (possible bot)
SELECT al.performed_by, COUNT(*) AS booking_count
FROM audit_log al
WHERE al.action     = 'INSERT'
  AND al.table_name = 'bookings'
  AND al.logged_at  >= NOW() - INTERVAL 1 HOUR
GROUP BY al.performed_by
HAVING COUNT(*) > 5
ORDER BY booking_count DESC;
