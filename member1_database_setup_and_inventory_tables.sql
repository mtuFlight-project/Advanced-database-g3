-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 1: Database Setup + Section 1 (Inventory & Flights Tables)
-- ============================================================

-- ============================================================
-- SECTION 0: DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS flight_booking_system
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE flight_booking_system;


-- ============================================================
-- SECTION 1: DDL — TABLE DEFINITIONS (Zone 1: Inventory & Flights)
-- ============================================================

-- 1.1 Airlines
CREATE TABLE airlines (
    airline_id   INT AUTO_INCREMENT PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL,
    iata_code    CHAR(2)      NOT NULL,
    country      VARCHAR(80)  NOT NULL,
    CONSTRAINT uq_airline_name UNIQUE (airline_name),
    CONSTRAINT uq_iata         UNIQUE (iata_code)
);

-- 1.2 Airports
CREATE TABLE airports (
    airport_code CHAR(3)      PRIMARY KEY,
    airport_name VARCHAR(100) NOT NULL,
    city         VARCHAR(80)  NOT NULL,
    country      VARCHAR(80)  NOT NULL,
    timezone     VARCHAR(50)  NOT NULL
);

-- 1.3 Flights (route definitions, not individual calendar flights)
CREATE TABLE flights (
    flight_id           INT AUTO_INCREMENT PRIMARY KEY,
    flight_number       VARCHAR(10)  NOT NULL,
    airline_id          INT          NOT NULL,
    departure_airport   CHAR(3)      NOT NULL,
    arrival_airport     CHAR(3)      NOT NULL,
    scheduled_departure TIME         NOT NULL,
    scheduled_arrival   TIME         NOT NULL,
    distance_km         INT,
    CONSTRAINT uq_flight_number UNIQUE (flight_number),
    CONSTRAINT fk_fl_airline    FOREIGN KEY (airline_id)
        REFERENCES airlines(airline_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fl_dep        FOREIGN KEY (departure_airport)
        REFERENCES airports(airport_code) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_fl_arr        FOREIGN KEY (arrival_airport)
        REFERENCES airports(airport_code) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.4 Flight Instances (actual calendar-day flights)
CREATE TABLE flight_instances (
    instance_id    BIGINT  NOT NULL AUTO_INCREMENT PRIMARY KEY,
    flight_id      INT     NOT NULL,
    departure_date DATE    NOT NULL,
    region_code    TINYINT NOT NULL COMMENT '1=East Africa, 2=West Africa, 3=International',
    status         ENUM('Scheduled','Delayed','Departed','Arrived','Cancelled')
                   DEFAULT 'Scheduled',
    CONSTRAINT uq_flight_date UNIQUE (flight_id, departure_date),
    CONSTRAINT fk_fi_flight   FOREIGN KEY (flight_id)
        REFERENCES flights(flight_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 1.5 Seats (per-flight seat inventory)
CREATE TABLE seats (
    seat_id      BIGINT     NOT NULL AUTO_INCREMENT PRIMARY KEY,
    instance_id  BIGINT     NOT NULL,
    seat_number  VARCHAR(4) NOT NULL,
    cabin_class  ENUM('Economy','Business','First') NOT NULL DEFAULT 'Economy',
    status       ENUM('Available','Reserved','Booked') NOT NULL DEFAULT 'Available',
    CONSTRAINT uq_seat      UNIQUE (instance_id, seat_number),
    CONSTRAINT fk_seat_inst FOREIGN KEY (instance_id)
        REFERENCES flight_instances(instance_id) ON DELETE CASCADE ON UPDATE CASCADE
);
