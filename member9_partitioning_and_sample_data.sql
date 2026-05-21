-- ============================================================
--  FLIGHT BOOKING SYSTEM — Full MySQL Workbench Script
--  Mizan Tepi University | ITec 2072 | Group 3
-- ============================================================
-- MEMBER 9: Section 13 (Distributed Partitioning) + Section 14 (Sample Data)
-- ============================================================

USE flight_booking_system;

-- ============================================================
-- SECTION 13: DISTRIBUTED DATABASE — PARTITIONING BY REGION
-- ============================================================
-- Horizontal partitioning of flight_instances by region_code:
--   region_code = 1 → East Africa  (Addis Ababa hub)
--   region_code = 2 → West Africa  (Lagos edge node)
--   region_code = 3 → International (Dubai gateway node)

-- Note: In MySQL 8, partitioning is defined at table creation.
-- Below is the partitioned version of flight_instances.
-- (Drop the earlier flight_instances and re-create with partitioning.)

CREATE TABLE flight_instances_partitioned (
    instance_id    BIGINT  NOT NULL AUTO_INCREMENT,
    flight_id      INT     NOT NULL,
    departure_date DATE    NOT NULL,
    region_code    TINYINT NOT NULL COMMENT '1=East Africa, 2=West Africa, 3=International',
    status         ENUM('Scheduled','Delayed','Departed','Arrived','Cancelled')
                   DEFAULT 'Scheduled',
    PRIMARY KEY (instance_id, region_code),
    UNIQUE KEY uq_flight_date (flight_id, departure_date),
    CONSTRAINT fk_fip_flight FOREIGN KEY (flight_id)
        REFERENCES flights(flight_id) ON DELETE RESTRICT ON UPDATE CASCADE
)
PARTITION BY LIST (region_code) (
    PARTITION p_east_africa   VALUES IN (1),   -- Addis Ababa hub
    PARTITION p_west_africa   VALUES IN (2),   -- Lagos edge node
    PARTITION p_international VALUES IN (3)    -- Dubai gateway node
);


-- ============================================================
-- SECTION 14: SAMPLE DATA (for testing)
-- ============================================================

-- Airlines
INSERT INTO airlines (airline_name, iata_code, country) VALUES
  ('Ethiopian Airlines', 'ET', 'Ethiopia'),
  ('Kenya Airways',      'KQ', 'Kenya'),
  ('RwandAir',           'WB', 'Rwanda');

-- Airports
INSERT INTO airports (airport_code, airport_name, city, country, timezone) VALUES
  ('ADD', 'Bole International Airport',   'Addis Ababa', 'Ethiopia', 'Africa/Addis_Ababa'),
  ('NBO', 'Jomo Kenyatta International', 'Nairobi',      'Kenya',    'Africa/Nairobi'),
  ('DXB', 'Dubai International Airport', 'Dubai',        'UAE',      'Asia/Dubai'),
  ('LOS', 'Murtala Muhammed Airport',    'Lagos',        'Nigeria',  'Africa/Lagos');

-- Flights
INSERT INTO flights (flight_number, airline_id, departure_airport, arrival_airport,
                     scheduled_departure, scheduled_arrival, distance_km)
VALUES
  ('ET101', 1, 'ADD', 'NBO', '08:00:00', '10:30:00', 1170),
  ('ET202', 1, 'ADD', 'DXB', '23:00:00', '04:30:00', 3310);

-- Flight Instances
INSERT INTO flight_instances (flight_id, departure_date, region_code, status) VALUES
  (1, '2026-06-15', 1, 'Scheduled'),
  (2, '2026-06-15', 3, 'Scheduled');

-- Seats (sample for instance 1)
INSERT INTO seats (instance_id, seat_number, cabin_class, status) VALUES
  (1, '12A', 'Economy',  'Available'),
  (1, '12B', 'Economy',  'Available'),
  (1, '1A',  'Business', 'Available');

-- ============================================================
-- END OF SCRIPT
-- ============================================================
