-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 2: Section 2 (Passengers & Bookings Tables)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 2: DDL — TABLE DEFINITIONS (Zone 2: Passengers & Bookings)
-- ============================================================

-- 2.1 Passengers
CREATE TABLE passengers (
    passenger_id    BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(120)  NOT NULL,
    email           VARCHAR(150)  NOT NULL,
    phone           VARBINARY(255),          -- AES-encrypted phone number
    city            VARCHAR(80),
    passport_number VARCHAR(50),
    password_hash   CHAR(64)      NOT NULL COMMENT 'SHA-256 salted hash',
    failed_attempts INT           NOT NULL DEFAULT 0,
    locked_until    DATETIME      DEFAULT NULL,
    last_login      DATETIME      DEFAULT NULL,
    created_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_email    UNIQUE (email),
    CONSTRAINT uq_passport UNIQUE (passport_number)
);

-- 2.2 Bookings
CREATE TABLE bookings (
    booking_id   BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
    passenger_id BIGINT        NOT NULL,
    instance_id  BIGINT        NOT NULL,
    seat_id      BIGINT        NOT NULL,
    status       ENUM('Reserved','Confirmed','Cancelled','Completed')
                 NOT NULL DEFAULT 'Reserved',
    booked_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    total_fare   DECIMAL(10,2) NOT NULL,
    CONSTRAINT uq_seat_booking UNIQUE (seat_id),        -- Prevents double-booking
    CONSTRAINT fk_bk_passenger FOREIGN KEY (passenger_id)
        REFERENCES passengers(passenger_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bk_instance  FOREIGN KEY (instance_id)
        REFERENCES flight_instances(instance_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bk_seat      FOREIGN KEY (seat_id)
        REFERENCES seats(seat_id) ON DELETE RESTRICT
);
