DROP DATABASE IF EXISTS ccms;
CREATE DATABASE ccms;
USE ccms;
CREATE TABLE ClubCategory (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);
CREATE TABLE Club (
    club_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    founding_date DATE,
    CONSTRAINT uq_club_name UNIQUE (name),
    CONSTRAINT fk_club_category FOREIGN KEY (category_id)
        REFERENCES ClubCategory(category_id)
);
CREATE TABLE Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_no VARCHAR(20) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    enrolment_year INT NOT NULL,
    CONSTRAINT uq_student_no UNIQUE (student_no),
    CONSTRAINT uq_student_email UNIQUE (email)
);
CREATE TABLE Membership (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    club_id INT NOT NULL,
    joined_date DATE NOT NULL,
    status ENUM('Active','Inactive') DEFAULT 'Active',
    CONSTRAINT uq_membership UNIQUE (student_id, club_id),
    CONSTRAINT fk_member_student FOREIGN KEY (student_id)
        REFERENCES Student(student_id),
    CONSTRAINT fk_member_club FOREIGN KEY (club_id)
        REFERENCES Club(club_id)
);

CREATE TABLE Event (
    event_id      INT AUTO_INCREMENT PRIMARY KEY,
    club_id       INT NOT NULL,
    title         VARCHAR(150) NOT NULL,
    description   VARCHAR(500),
    event_datetime DATETIME NOT NULL,
    venue         VARCHAR(150) NOT NULL,
    capacity      INT NOT NULL,
    is_restricted TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = open, 1 = restricted
    CONSTRAINT fk_event_club FOREIGN KEY (club_id)
        REFERENCES Club(club_id)
);

CREATE TABLE EventParticipation (
    participation_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id         INT NOT NULL,
    student_id       INT NOT NULL,
    registered_at    DATETIME NOT NULL,
    attended         TINYINT(1) NOT NULL DEFAULT 0, -- 0 = registered, 1 = attended
    CONSTRAINT uq_event_participation UNIQUE (event_id, student_id),
    CONSTRAINT fk_participation_event FOREIGN KEY (event_id)
        REFERENCES Event(event_id),
    CONSTRAINT fk_participation_student FOREIGN KEY (student_id)
        REFERENCES Student(student_id)
);

CREATE TABLE Announcement (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    club_id         INT NULL,               -- NULL = Union-wide announcement
    title           VARCHAR(150) NOT NULL,
    message         TEXT NOT NULL,
    sent_at         DATETIME NOT NULL,
    channel         ENUM('Email','Portal','SocialMedia') NOT NULL,
    created_by      VARCHAR(150) NOT NULL,  -- name or staff ID of creator
    CONSTRAINT fk_announcement_club FOREIGN KEY (club_id)
        REFERENCES Club(club_id)
);

CREATE TABLE AnnouncementRecipient (
    recipient_id     INT AUTO_INCREMENT PRIMARY KEY,
    announcement_id  INT NOT NULL,
    student_id       INT NOT NULL,
    sent_status      ENUM('Sent','Failed') NOT NULL DEFAULT 'Sent',
    delivered_at     DATETIME NULL,
    read_at          DATETIME NULL,
    CONSTRAINT uq_announcement_recipient UNIQUE (announcement_id, student_id),
    CONSTRAINT fk_ar_announcement FOREIGN KEY (announcement_id)
        REFERENCES Announcement(announcement_id),
    CONSTRAINT fk_ar_student FOREIGN KEY (student_id)
        REFERENCES Student(student_id)
);

CREATE TABLE MembershipAudit (
    audit_id        INT AUTO_INCREMENT PRIMARY KEY,
    membership_id   INT NULL,
    student_id      INT NULL,
    club_id         INT NULL,
    action_type     ENUM('INSERT','UPDATE','DELETE') NOT NULL,
    action_time     DATETIME NOT NULL,
    changed_by      VARCHAR(150) NULL,
    old_status      ENUM('Active','Inactive') NULL,
    new_status      ENUM('Active','Inactive') NULL
);

INSERT INTO ClubCategory (category_id, name, description) VALUES
(1, 'Academic', 'Subject-focused clubs and study groups'),
(2, 'Sports', 'Sports teams and fitness clubs'),
(3, 'Cultural', 'Cultural and international societies'),
(4, 'Special Interest', 'Hobby, tech, and other interest groups');

INSERT INTO Club (club_id, name, category_id, founding_date) VALUES
(1, 'Computer Science Society', 1, '2015-10-01'),
(2, 'Debate & Public Speaking Club', 1, '2018-02-15'),
(3, 'University Football Club', 2, '2010-09-01'),
(4, 'International Students Association', 3, '2012-01-20'),
(5, 'Gaming & Esports Club', 4, '2019-11-05');


INSERT INTO Student (student_id, student_no, first_name, last_name, email, enrolment_year) VALUES
(1, 'S10001', 'John', 'Smith', 'john.smith@campus.ac.uk', 2022),
(2, 'S10002', 'Aisha', 'Khan', 'aisha.khan@campus.ac.uk', 2023),
(3, 'S10003', 'Michael', 'Brown', 'michael.brown@campus.ac.uk', 2021),
(4, 'S10004', 'Sofia', 'Gonzalez', 'sofia.gonzalez@campus.ac.uk', 2022),
(5, 'S10005', 'Emily', 'Clark', 'emily.clark@campus.ac.uk', 2024),
(6, 'S10006', 'David', 'Lee', 'david.lee@campus.ac.uk', 2023),
(7, 'S10007', 'Wei', 'Zhang', 'wei.zhang@campus.ac.uk', 2024);


INSERT INTO Membership (membership_id, student_id, club_id, joined_date, status) VALUES
(1, 1, 1, '2023-01-15', 'Active'),   -- John Smith → Computer Science Society
(2, 1, 5, '2023-02-10', 'Active'),   -- John Smith → Gaming Club
(3, 2, 2, '2023-03-20', 'Active'),   -- Aisha → Debate Club
(4, 3, 3, '2022-09-10', 'Active'),   -- Michael → Football Club
(5, 4, 4, '2023-10-05', 'Active'),   -- Sofia → International Students Association
(6, 5, 1, '2024-01-12', 'Active'),   -- Emily → Computer Science Society
(7, 6, 5, '2023-04-18', 'Active'),   -- David → Gaming Club
(8, 7, 3, '2024-02-02', 'Active');   -- Wei → Football Club

INSERT INTO Event (event_id, club_id, title, description, event_datetime, venue, capacity, is_restricted) VALUES
(1, 1, 'Intro to Python Workshop', 'Beginner-friendly coding session for new members.', '2024-03-12 15:00:00', 'IT Building Lab 2', 40, 0),
(2, 5, 'Esports Tournament Qualifiers', 'Campus-wide gaming competition qualifiers.', '2024-04-05 18:00:00', 'Student Union Hall', 100, 0),
(3, 3, 'Football Team Tryouts', 'Tryouts for new football players.', '2024-02-28 10:00:00', 'Main Sports Field', 60, 0),
(4, 4, 'Cultural Food Festival', 'Students showcase traditional foods.', '2024-05-10 12:00:00', 'Campus Courtyard', 200, 0),
(5, 2, 'Public Speaking Masterclass', 'Skill-building seminar led by guest speaker.', '2024-03-22 17:00:00', 'Lecture Hall A', 80, 1);


INSERT INTO EventParticipation (participation_id, event_id, student_id, registered_at, attended) VALUES
(1, 1, 1, '2024-03-01 09:12:00', 1),  -- John attended Python workshop
(2, 1, 5, '2024-03-02 10:15:00', 0),  -- Emily registered but did not attend yet
(3, 2, 6, '2024-04-01 14:20:00', 0),  -- David registered for Esports tournament
(4, 3, 3, '2024-02-20 11:32:00', 1),  -- Michael attended football tryouts
(5, 4, 4, '2024-05-01 13:45:00', 0),  -- Sofia registered for food festival
(6, 5, 2, '2024-03-18 16:00:00', 1),  -- Aisha attended masterclass
(7, 5, 7, '2024-03-19 10:25:00', 0);  -- Wei registered but didn’t attend yet

INSERT INTO Announcement (announcement_id, club_id, title, message, sent_at, channel, created_by) VALUES
(1, NULL, 'Welcome to the New Academic Year',
 'General welcome from the Students'' Union to all students.',
 '2024-09-20 09:00:00', 'Email', 'SU President'),
(2, 1, 'CS Society First Meeting',
 'Introduction meeting for new and returning Computer Science Society members.',
 '2024-09-22 17:00:00', 'Portal', 'CS Society President'),
(3, 3, 'Football Trials Reminder',
 'Reminder: Football team trials will be held this weekend. Don''t forget your kit.',
 '2024-09-21 18:30:00', 'Email', 'Football Coach'),
(4, 4, 'International Food Festival Volunteers',
 'Call for volunteers to help run stalls at the cultural food festival.',
 '2024-10-01 14:00:00', 'SocialMedia', 'International Society Chair'),
(5, 5, 'Esports Tournament Rules Update',
 'Updated rules and schedule for the upcoming campus Esports tournament.',
 '2024-10-05 16:15:00', 'Portal', 'Gaming Club Coordinator');

INSERT INTO AnnouncementRecipient (recipient_id, announcement_id, student_id, sent_status, delivered_at, read_at) VALUES
(1, 1, 1, 'Sent', '2024-09-20 09:01:00', '2024-09-20 09:10:00'), -- John
(2, 1, 2, 'Sent', '2024-09-20 09:01:30', NULL),                  -- Aisha
(3, 2, 1, 'Sent', '2024-09-22 17:05:00', '2024-09-22 17:20:00'), -- John → CS meeting
(4, 2, 5, 'Sent', '2024-09-22 17:05:15', NULL),                  -- Emily
(5, 3, 3, 'Sent', '2024-09-21 18:31:00', '2024-09-21 18:45:00'), -- Michael → Football reminder
(6, 3, 7, 'Sent', '2024-09-21 18:31:30', NULL),                  -- Wei
(7, 5, 6, 'Sent', '2024-10-05 16:16:00', '2024-10-05 16:30:00'); -- David → Esports rules

DELIMITER $$

CREATE PROCEDURE sp_add_student (
    IN p_student_no    VARCHAR(20),
    IN p_first_name    VARCHAR(100),
    IN p_last_name     VARCHAR(100),
    IN p_email         VARCHAR(150),
    IN p_enrolment_year INT
)
BEGIN
    -- Handle any SQL error: rollback and exit
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO Student (student_no, first_name, last_name, email, enrolment_year)
    VALUES (p_student_no, p_first_name, p_last_name, p_email, p_enrolment_year);

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_register_membership (
    IN p_student_no  VARCHAR(20),
    IN p_club_id     INT,
    IN p_joined_date DATE
)
BEGIN
    DECLARE v_student_id INT;

    -- Rollback on any SQL error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 1) Look up student_id from student_no
    SELECT student_id
      INTO v_student_id
      FROM Student
     WHERE student_no = p_student_no;

    -- 2) If no student found, raise an error to trigger rollback
    IF v_student_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student not found';
    END IF;

    -- 3) Insert membership (unique (student_id, club_id) prevents duplicates)
    INSERT INTO Membership (student_id, club_id, joined_date, status)
    VALUES (v_student_id, p_club_id, p_joined_date, 'Active');

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_delete_event (
    IN p_event_id INT
)
BEGIN
    -- Rollback if *any* SQL error happens
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- First delete participations linked to the event
    DELETE FROM EventParticipation
    WHERE event_id = p_event_id;

    -- Then delete the event itself
    DELETE FROM Event
    WHERE event_id = p_event_id;

    COMMIT;
END$$

DELIMITER ;

DELIMITER $$

-- Audit INSERT on Membership
CREATE TRIGGER trg_membership_insert
AFTER INSERT ON Membership
FOR EACH ROW
BEGIN
    INSERT INTO MembershipAudit (
        membership_id,
        student_id,
        club_id,
        action_type,
        action_time,
        changed_by,
        old_status,
        new_status
    ) VALUES (
        NEW.membership_id,
        NEW.student_id,
        NEW.club_id,
        'INSERT',
        NOW(),
        USER(),
        NULL,
        NEW.status
    );
END$$

-- Audit UPDATE on Membership (track status changes)
CREATE TRIGGER trg_membership_update
AFTER UPDATE ON Membership
FOR EACH ROW
BEGIN
    INSERT INTO MembershipAudit (
        membership_id,
        student_id,
        club_id,
        action_type,
        action_time,
        changed_by,
        old_status,
        new_status
    ) VALUES (
        NEW.membership_id,
        NEW.student_id,
        NEW.club_id,
        'UPDATE',
        NOW(),
        USER(),
        OLD.status,
        NEW.status
    );
END$$

-- Audit DELETE on Membership
CREATE TRIGGER trg_membership_delete
AFTER DELETE ON Membership
FOR EACH ROW
BEGIN
    INSERT INTO MembershipAudit (
        membership_id,
        student_id,
        club_id,
        action_type,
        action_time,
        changed_by,
        old_status,
        new_status
    ) VALUES (
        OLD.membership_id,
        OLD.student_id,
        OLD.club_id,
        'DELETE',
        NOW(),
        USER(),
        OLD.status,
        NULL
    );
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_register_student_for_event (
    IN p_student_no VARCHAR(20),
    IN p_event_id   INT
)
BEGIN
    DECLARE v_student_id INT;
    DECLARE v_capacity   INT;
    DECLARE v_current    INT;

    -- On any SQL error, rollback the transaction
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    -- 1) Look up the student_id from student_no
    SELECT student_id
      INTO v_student_id
      FROM Student
     WHERE student_no = p_student_no;

    IF v_student_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student not found';
    END IF;

    -- 2) Check that the event exists and get its capacity
    SELECT capacity
      INTO v_capacity
      FROM Event
     WHERE event_id = p_event_id;

    IF v_capacity IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event not found';
    END IF;

    -- 3) Count current registrations for this event
    SELECT COUNT(*)
      INTO v_current
      FROM EventParticipation
     WHERE event_id = p_event_id;

    -- If event is full, rollback the whole transaction
    IF v_current >= v_capacity THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Event capacity reached. Registration not allowed.';
    END IF;

    -- 4) Insert the participation record
    INSERT INTO EventParticipation (event_id, student_id, registered_at, attended)
    VALUES (p_event_id, v_student_id, NOW(), 0);

    -- All good: commit the transaction
    COMMIT;
END$$

DELIMITER ;

CREATE INDEX idx_student_student_no
    ON Student(student_no);

-- Index to optimise queries filtering memberships by student
CREATE INDEX idx_membership_student
    ON Membership(student_id);

-- Index to optimise club-based membership queries
CREATE INDEX idx_membership_club
    ON Membership(club_id);

-- Index to speed up event queries by datetime (e.g., upcoming events)
CREATE INDEX idx_event_datetime
    ON Event(event_datetime);

-- Index to improve performance of participation queries by event
CREATE INDEX idx_event_participation_event
    ON EventParticipation(event_id);

-- Index to improve announcement recipient filtering by announcement
CREATE INDEX idx_announcement_recipient_announcement
    ON AnnouncementRecipient(announcement_id);

-- Index to speed up recipient lookups by student
CREATE INDEX idx_announcement_recipient_student
    ON AnnouncementRecipient(student_id);

