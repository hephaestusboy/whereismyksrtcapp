-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create buses table
CREATE TABLE IF NOT EXISTS buses (
    id SERIAL PRIMARY KEY,
    bus_number VARCHAR(50) NOT NULL,
    departure_point VARCHAR(255) NOT NULL,
    arrival_point VARCHAR(255) NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create bus_locations table
CREATE TABLE IF NOT EXISTS bus_locations (
    id SERIAL PRIMARY KEY,
    bus_id INTEGER REFERENCES buses(id),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(bus_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_buses_departure ON buses(departure_point);
CREATE INDEX IF NOT EXISTS idx_buses_arrival ON buses(arrival_point);
CREATE INDEX IF NOT EXISTS idx_bus_locations_bus_id ON bus_locations(bus_id);

-- Insert some sample data
INSERT INTO buses (bus_number, departure_point, arrival_point, departure_time, arrival_time)
VALUES 
    ('KSRTC-001', 'Kochi', 'Thiruvananthapuram', '08:00:00', '12:00:00'),
    ('KSRTC-002', 'Bangalore', 'Mysore', '09:00:00', '13:00:00'),
    ('KSRTC-003', 'Kozhikode', 'Kannur', '10:00:00', '12:30:00'); 