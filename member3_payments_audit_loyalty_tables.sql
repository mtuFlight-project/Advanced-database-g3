-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 3: Section 3 (Payments, Audit Log & Loyalty Miles Tables)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 3: DDL — TABLE DEFINITIONS (Zone 3: Payments & Audit)
-- ============================================================

-- 3.1 Payments
CREATE TABLE payments (
    payment_id  BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    booking_id  BIGINT        NOT NULL,
    method      ENUM('Telebirr','Card','Bank_Transfer','Miles') NOT NULL,
    amount      DECIMAL(10,2) NOT NULL,
    currency    CHAR(3)       NOT NULL DEFAULT 'ETB',
    status      ENUM('Pending','Completed','Failed','Refunded') DEFAULT 'Pending',
    paid_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    txn_ref     VARBINARY(255),            -- AES-encrypted transaction reference
    CONSTRAINT uq_txn_ref     UNIQUE (txn_ref),
    CONSTRAINT fk_pay_booking FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id) ON DELETE RESTRICT
);

-- 3.2 Audit Log (write-only — no UPDATE or DELETE privileges granted)
CREATE TABLE audit_log (
    log_id       BIGINT     NOT NULL AUTO_INCREMENT PRIMARY KEY,
    table_name   VARCHAR(50),
    record_id    BIGINT,
    action       ENUM('INSERT','UPDATE','DELETE','LOGIN','FAILED_LOGIN') NOT NULL,
    performed_by VARCHAR(80),
    details      TEXT,
    logged_at    TIMESTAMP  DEFAULT CURRENT_TIMESTAMP
);

-- 3.3 Loyalty Miles
CREATE TABLE loyalty_miles (
    miles_id       BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    passenger_id   BIGINT NOT NULL,
    booking_id     BIGINT NOT NULL,
    miles_earned   INT    DEFAULT 0,
    miles_redeemed INT    DEFAULT 0,
    balance        INT    DEFAULT 0,
    CONSTRAINT fk_lm_passenger FOREIGN KEY (passenger_id)
        REFERENCES passengers(passenger_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lm_booking   FOREIGN KEY (booking_id)
        REFERENCES bookings(booking_id) ON DELETE RESTRICT
);
