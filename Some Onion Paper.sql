CREATE DATABASE IF NOT EXISTS DentistWebsite;
USE DentistWebsite;

CREATE TABLE clients ( 
    PatientID INT AUTO_INCREMENT PRIMARY KEY, 
    FirstName VARCHAR(50), 
    LastName VARCHAR(50), 
    Email VARCHAR(100), 
    PhoneNumber VARCHAR(15), 
    Address TEXT,  
    DateOfBirth DATE,  
    RegistrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
);

CREATE TABLE staff ( 
    DentistID INT AUTO_INCREMENT PRIMARY KEY, 
    FirstName VARCHAR(50), 
    LastName VARCHAR(50), 
    Specialty VARCHAR(100),  
    Email VARCHAR(100), 
    PhoneNumber VARCHAR(15), 
    HireDate DATE 
);

CREATE TABLE appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    PatientID INT NOT NULL,
    DentistID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    ReasonForVisit TEXT,
    Status ENUM('Booked', 'Completed', 'Cancelled') DEFAULT 'Booked',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES clients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DentistID) REFERENCES staff(DentistID) ON DELETE CASCADE
);

CREATE TABLE future_appointments ( 
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY, 
    PatientID INT NOT NULL, 
    DentistID INT NOT NULL,
    AppointmentDate DATETIME NOT NULL, 
    AppointmentReason TEXT, 
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (PatientID) REFERENCES clients(PatientID) ON DELETE CASCADE, 
    FOREIGN KEY (DentistID) REFERENCES staff(DentistID) ON DELETE CASCADE 
); 

CREATE TABLE past_appointments ( 
    AppointmentID INT PRIMARY KEY, 
    PatientID INT NOT NULL, 
    DentistID INT NOT NULL, 
    AppointmentDate DATETIME NOT NULL, 
    CompletionDate DATETIME, 
    AppointmentReason TEXT, 
    Status ENUM('Completed', 'Cancelled') NOT NULL, 
    Notes TEXT,
    FOREIGN KEY (PatientID) REFERENCES clients(PatientID) ON DELETE CASCADE, 
    FOREIGN KEY (DentistID) REFERENCES staff(DentistID) ON DELETE CASCADE 
); 

DELIMITER //

CREATE TRIGGER MoveToPastAppointments
AFTER UPDATE ON future_appointments
FOR EACH ROW
BEGIN
    IF NEW.AppointmentDate < NOW() THEN
        INSERT INTO past_appointments (
            AppointmentID, PatientID, DentistID, AppointmentDate, CompletionDate, AppointmentReason, Status, Notes
        )
        VALUES (
            NEW.AppointmentID, NEW.PatientID, NEW.DentistID, NEW.AppointmentDate, NOW(), 
            NEW.AppointmentReason, 
            'Completed', CONCAT('Auto-moved to past appointments on ', NOW())
        );
        DELETE FROM future_appointments WHERE AppointmentID = NEW.AppointmentID;
    END IF;
END //
DELIMITER ;