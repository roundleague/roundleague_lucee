-- Round League — Sample seed data
-- Matches production schema exactly.
-- All player passwords are SHA-1("password123") = CBFDAC6008F9CAB4083784CBD1874F76618D2A97

SET FOREIGN_KEY_CHECKS = 0;

-- ── Seasons ──────────────────────────────────────────────────────────────────
INSERT INTO seasons (SeasonID, SeasonName, Status, StartDate, EndDate, PreviousSeasonID, team_fee) VALUES
(1, 'Spring 2025', 'Active', '2025-01-05', '2025-03-30', NULL, 1000.00);

-- ── Leagues ──────────────────────────────────────────────────────────────────
INSERT INTO leagues (leagueID, leagueName, seasonID) VALUES
(1, 'Round League', 1);

-- ── Divisions ────────────────────────────────────────────────────────────────
INSERT INTO divisions (DivisionID, SeasonID, DivisionName, IsWomens, leagueID) VALUES
(1, 1, 'North Division', 0, 1),
(2, 1, 'South Division', 0, 1);

-- ── Teams (4 per division) ───────────────────────────────────────────────────
INSERT INTO teams (teamId, Status, teamName, CaptainPlayerID, RegisterDate, DivisionID, SeasonID) VALUES
(1, 'Active', 'The Ballers',   1,  '2025-01-01', 1, 1),
(2, 'Active', 'Slam Dunkers',  6,  '2025-01-01', 1, 1),
(3, 'Active', 'Net Rippers',   11, '2025-01-01', 1, 1),
(4, 'Active', 'Hoop Dreams',   16, '2025-01-01', 1, 1),
(5, 'Active', 'Fast Break',    21, '2025-01-01', 2, 1),
(6, 'Active', 'Court Kings',   26, '2025-01-01', 2, 1),
(7, 'Active', 'Rim Rockers',   31, '2025-01-01', 2, 1),
(8, 'Active', 'Triple Threat', 36, '2025-01-01', 2, 1);

-- ── Players (5 per team = 40 total) ──────────────────────────────────────────
-- Columns: PlayerID, RegisterDate, Email, firstName, lastName, BirthDate, Phone,
--          HighestLevel, FullyVaccinated, FreeAgent, position, height, weight,
--          hometown, School, PermissionToShare, Status, PhotoURL, Instagram,
--          DivisionID, Gender, MastersLeague, ZipCode, is_youth
INSERT INTO players (PlayerID, RegisterDate, Email, firstName, lastName, BirthDate, Phone, HighestLevel, FullyVaccinated, FreeAgent, position, height, weight, hometown, School, PermissionToShare, Status, PhotoURL, Instagram, DivisionID, Gender, MastersLeague, ZipCode, is_youth) VALUES
-- Team 1: The Ballers (DivisionID=1)
(1,  '2025-01-01', 'john.smith@example.com',      'John',    'Smith',      '1995-03-15', '503-555-0101', 'College',     'Yes', 'No', 'PG', '6-1',  '185', 'Portland',    'PSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97201, 0),
(2,  '2025-01-01', 'marcus.johnson@example.com',   'Marcus',  'Johnson',    '1997-07-22', '503-555-0102', 'High School', 'Yes', 'No', 'SG', '6-3',  '195', 'Beaverton',   'Beaverton HS',   'Yes', 'Active', '', '', 1, 'Male', 'No', 97005, 0),
(3,  '2025-01-01', 'derek.williams@example.com',   'Derek',   'Williams',   '1993-11-08', '503-555-0103', 'College',     'Yes', 'No', 'SF', '6-5',  '210', 'Portland',    'UP',             'Yes', 'Active', '', '', 1, 'Male', 'No', 97203, 0),
(4,  '2025-01-01', 'tony.brown@example.com',       'Tony',    'Brown',      '1990-05-30', '503-555-0104', 'Pro',         'Yes', 'No', 'PF', '6-7',  '225', 'Gresham',     'PSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97030, 0),
(5,  '2025-01-01', 'james.davis@example.com',      'James',   'Davis',      '1996-09-12', '503-555-0105', 'College',     'Yes', 'No', 'C',  '6-9',  '240', 'Hillsboro',   'PCC',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97124, 0),
-- Team 2: Slam Dunkers (DivisionID=1)
(6,  '2025-01-01', 'kevin.wilson@example.com',     'Kevin',   'Wilson',     '1994-02-18', '503-555-0106', 'College',     'Yes', 'No', 'PG', '5-11', '175', 'Portland',    'Reed',           'Yes', 'Active', '', '', 1, 'Male', 'No', 97202, 0),
(7,  '2025-01-01', 'chris.martinez@example.com',   'Chris',   'Martinez',   '1998-04-25', '503-555-0107', 'High School', 'Yes', 'No', 'SG', '6-2',  '190', 'Tigard',      'Tigard HS',      'Yes', 'Active', '', '', 1, 'Male', 'No', 97223, 0),
(8,  '2025-01-01', 'brian.anderson@example.com',   'Brian',   'Anderson',   '1992-08-14', '503-555-0108', 'College',     'Yes', 'No', 'SF', '6-4',  '205', 'Lake Oswego', 'Lewis and Clark', 'Yes', 'Active', '', '', 1, 'Male', 'No', 97034, 0),
(9,  '2025-01-01', 'robert.taylor@example.com',    'Robert',  'Taylor',     '1991-12-03', '503-555-0109', 'Pro',         'Yes', 'No', 'PF', '6-6',  '220', 'Vancouver',   'WSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 98661, 0),
(10, '2025-01-01', 'michael.thomas@example.com',   'Michael', 'Thomas',     '1999-06-20', '503-555-0110', 'High School', 'Yes', 'No', 'C',  '6-8',  '230', 'Portland',    'Grant HS',       'Yes', 'Active', '', '', 1, 'Male', 'No', 97212, 0),
-- Team 3: Net Rippers (DivisionID=1)
(11, '2025-01-01', 'alex.garcia@example.com',      'Alex',    'Garcia',     '1995-01-28', '503-555-0111', 'College',     'Yes', 'No', 'PG', '6-0',  '180', 'Portland',    'UP',             'Yes', 'Active', '', '', 1, 'Male', 'No', 97203, 0),
(12, '2025-01-01', 'eric.jackson@example.com',     'Eric',    'Jackson',    '1997-09-15', '503-555-0112', 'High School', 'Yes', 'No', 'SG', '6-2',  '195', 'Clackamas',   'Clackamas HS',   'Yes', 'Active', '', '', 1, 'Male', 'No', 97015, 0),
(13, '2025-01-01', 'daniel.white@example.com',     'Daniel',  'White',      '1994-04-07', '503-555-0113', 'College',     'Yes', 'No', 'SF', '6-4',  '210', 'Milwaukie',   'Linfield',       'Yes', 'Active', '', '', 1, 'Male', 'No', 97222, 0),
(14, '2025-01-01', 'paul.harris@example.com',      'Paul',    'Harris',     '1989-10-22', '503-555-0114', 'Pro',         'Yes', 'No', 'PF', '6-7',  '235', 'Portland',    'PSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97207, 0),
(15, '2025-01-01', 'ryan.martin@example.com',      'Ryan',    'Martin',     '1996-02-14', '503-555-0115', 'College',     'Yes', 'No', 'C',  '6-10', '250', 'Beaverton',   'OSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97006, 0),
-- Team 4: Hoop Dreams (DivisionID=1)
(16, '2025-01-01', 'jason.thompson@example.com',   'Jason',   'Thompson',   '1993-07-19', '503-555-0116', 'College',     'Yes', 'No', 'PG', '6-1',  '185', 'Portland',    'UO',             'Yes', 'Active', '', '', 1, 'Male', 'No', 97211, 0),
(17, '2025-01-01', 'kyle.garcia@example.com',      'Kyle',    'Garcia',     '1998-03-08', '503-555-0117', 'High School', 'Yes', 'No', 'SG', '6-3',  '195', 'Gresham',     'Centennial HS',  'Yes', 'Active', '', '', 1, 'Male', 'No', 97233, 0),
(18, '2025-01-01', 'nathan.moore@example.com',     'Nathan',  'Moore',      '1995-11-25', '503-555-0118', 'College',     'Yes', 'No', 'SF', '6-5',  '215', 'Hillsboro',   'PCC',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97123, 0),
(19, '2025-01-01', 'trevor.hill@example.com',      'Trevor',  'Hill',       '1991-05-04', '503-555-0119', 'Pro',         'Yes', 'No', 'PF', '6-8',  '230', 'Lake Oswego', 'OSU',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97035, 0),
(20, '2025-01-01', 'bryan.scott@example.com',      'Bryan',   'Scott',      '1997-08-30', '503-555-0120', 'College',     'Yes', 'No', 'C',  '6-9',  '245', 'Tigard',      'PCC',            'Yes', 'Active', '', '', 1, 'Male', 'No', 97224, 0),
-- Team 5: Fast Break (DivisionID=2)
(21, '2025-01-01', 'darius.young@example.com',     'Darius',  'Young',      '1994-06-12', '503-555-0121', 'College',     'Yes', 'No', 'PG', '6-0',  '178', 'Portland',    'PCC',            'Yes', 'Active', '', '', 2, 'Male', 'No', 97217, 0),
(22, '2025-01-01', 'isaac.king@example.com',       'Isaac',   'King',       '1996-10-18', '503-555-0122', 'High School', 'Yes', 'No', 'SG', '6-3',  '200', 'Beaverton',   'Sunset HS',      'Yes', 'Active', '', '', 2, 'Male', 'No', 97007, 0),
(23, '2025-01-01', 'brandon.lewis@example.com',    'Brandon', 'Lewis',      '1993-01-05', '503-555-0123', 'College',     'Yes', 'No', 'SF', '6-5',  '215', 'Portland',    'Reed',           'Yes', 'Active', '', '', 2, 'Male', 'No', 97202, 0),
(24, '2025-01-01', 'cameron.lee@example.com',      'Cameron', 'Lee',        '1990-07-28', '503-555-0124', 'Pro',         'Yes', 'No', 'PF', '6-7',  '225', 'Vancouver',   'Clark',          'Yes', 'Active', '', '', 2, 'Male', 'No', 98663, 0),
(25, '2025-01-01', 'jordan.hall@example.com',      'Jordan',  'Hall',       '1997-04-15', '503-555-0125', 'College',     'Yes', 'No', 'C',  '6-10', '248', 'Hillsboro',   'Pacific',        'Yes', 'Active', '', '', 2, 'Male', 'No', 97125, 0),
-- Team 6: Court Kings (DivisionID=2)
(26, '2025-01-01', 'marcus.allen@example.com',     'Marcus',  'Allen',      '1995-09-22', '503-555-0126', 'College',     'Yes', 'No', 'PG', '5-10', '172', 'Portland',    'Concordia',      'Yes', 'Active', '', '', 2, 'Male', 'No', 97213, 0),
(27, '2025-01-01', 'terrence.wright@example.com',  'Terrence','Wright',     '1998-01-30', '503-555-0127', 'High School', 'Yes', 'No', 'SG', '6-2',  '192', 'Milwaukie',   'Rex Putnam HS',  'Yes', 'Active', '', '', 2, 'Male', 'No', 97222, 0),
(28, '2025-01-01', 'jamal.turner@example.com',     'Jamal',   'Turner',     '1994-05-16', '503-555-0128', 'College',     'Yes', 'No', 'SF', '6-4',  '208', 'Gresham',     'Mt Hood CC',     'Yes', 'Active', '', '', 2, 'Male', 'No', 97030, 0),
(29, '2025-01-01', 'corey.adams@example.com',      'Corey',   'Adams',      '1991-11-07', '503-555-0129', 'Pro',         'Yes', 'No', 'PF', '6-6',  '222', 'Portland',    'PSU',            'Yes', 'Active', '', '', 2, 'Male', 'No', 97201, 0),
(30, '2025-01-01', 'vernon.parker@example.com',    'Vernon',  'Parker',     '1999-03-14', '503-555-0130', 'High School', 'Yes', 'No', 'C',  '6-8',  '235', 'Tigard',      'Tualatin HS',    'Yes', 'Active', '', '', 2, 'Male', 'No', 97062, 0),
-- Team 7: Rim Rockers (DivisionID=2)
(31, '2025-01-01', 'malik.robinson@example.com',   'Malik',   'Robinson',   '1993-08-04', '503-555-0131', 'College',     'Yes', 'No', 'PG', '6-1',  '182', 'Portland',    'Warner Pacific', 'Yes', 'Active', '', '', 2, 'Male', 'No', 97220, 0),
(32, '2025-01-01', 'dante.carter@example.com',     'Dante',   'Carter',     '1996-12-19', '503-555-0132', 'High School', 'Yes', 'No', 'SG', '6-3',  '198', 'Lake Oswego', 'Lakeridge HS',   'Yes', 'Active', '', '', 2, 'Male', 'No', 97034, 0),
(33, '2025-01-01', 'reggie.mitchell@example.com',  'Reggie',  'Mitchell',   '1992-04-25', '503-555-0133', 'College',     'Yes', 'No', 'SF', '6-5',  '212', 'Beaverton',   'Pacific',        'Yes', 'Active', '', '', 2, 'Male', 'No', 97008, 0),
(34, '2025-01-01', 'andre.phillips@example.com',   'Andre',   'Phillips',   '1989-09-11', '503-555-0134', 'Pro',         'Yes', 'No', 'PF', '6-8',  '230', 'Portland',    'UO',             'Yes', 'Active', '', '', 2, 'Male', 'No', 97204, 0),
(35, '2025-01-01', 'deshawn.evans@example.com',    'DeShawn', 'Evans',      '1997-01-28', '503-555-0135', 'College',     'Yes', 'No', 'C',  '6-11', '255', 'Clackamas',   'Clackamas CC',   'Yes', 'Active', '', '', 2, 'Male', 'No', 97015, 0),
-- Team 8: Triple Threat (DivisionID=2)
(36, '2025-01-01', 'tyrone.washington@example.com','Tyrone',  'Washington', '1994-05-08', '503-555-0136', 'College',     'Yes', 'No', 'PG', '6-0',  '180', 'Portland',    'PSU',            'Yes', 'Active', '', '', 2, 'Male', 'No', 97218, 0),
(37, '2025-01-01', 'jerome.coleman@example.com',   'Jerome',  'Coleman',    '1997-10-22', '503-555-0137', 'High School', 'Yes', 'No', 'SG', '6-2',  '193', 'Vancouver',   'Skyview HS',     'Yes', 'Active', '', '', 2, 'Male', 'No', 98685, 0),
(38, '2025-01-01', 'lamont.baker@example.com',     'Lamont',  'Baker',      '1993-02-17', '503-555-0138', 'College',     'Yes', 'No', 'SF', '6-4',  '207', 'Hillsboro',   'Linfield',       'Yes', 'Active', '', '', 2, 'Male', 'No', 97123, 0),
(39, '2025-01-01', 'curtis.howard@example.com',    'Curtis',  'Howard',     '1990-06-30', '503-555-0139', 'Pro',         'Yes', 'No', 'PF', '6-7',  '228', 'Portland',    'OSU',            'Yes', 'Active', '', '', 2, 'Male', 'No', 97206, 0),
(40, '2025-01-01', 'raymond.ward@example.com',     'Raymond', 'Ward',       '1996-11-05', '503-555-0140', 'College',     'Yes', 'No', 'C',  '6-10', '252', 'Gresham',     'Mt Hood CC',     'Yes', 'Active', '', '', 2, 'Male', 'No', 97030, 0);

-- ── Users (password = "password123") ─────────────────────────────────────────
INSERT INTO users (userName, password, dateModified, playerID, status, role) VALUES
('john.smith@example.com',      'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 1,  'Active', 'Captain'),
('marcus.johnson@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 2,  'Active', 'Player'),
('derek.williams@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 3,  'Active', 'Player'),
('tony.brown@example.com',      'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 4,  'Active', 'Player'),
('james.davis@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 5,  'Active', 'Player'),
('kevin.wilson@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 6,  'Active', 'Captain'),
('chris.martinez@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 7,  'Active', 'Player'),
('brian.anderson@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 8,  'Active', 'Player'),
('robert.taylor@example.com',   'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 9,  'Active', 'Player'),
('michael.thomas@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 10, 'Active', 'Player'),
('alex.garcia@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 11, 'Active', 'Captain'),
('eric.jackson@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 12, 'Active', 'Player'),
('daniel.white@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 13, 'Active', 'Player'),
('paul.harris@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 14, 'Active', 'Player'),
('ryan.martin@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 15, 'Active', 'Player'),
('jason.thompson@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 16, 'Active', 'Captain'),
('kyle.garcia@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 17, 'Active', 'Player'),
('nathan.moore@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 18, 'Active', 'Player'),
('trevor.hill@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 19, 'Active', 'Player'),
('bryan.scott@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 20, 'Active', 'Player'),
('darius.young@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 21, 'Active', 'Captain'),
('isaac.king@example.com',      'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 22, 'Active', 'Player'),
('brandon.lewis@example.com',   'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 23, 'Active', 'Player'),
('cameron.lee@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 24, 'Active', 'Player'),
('jordan.hall@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 25, 'Active', 'Player'),
('marcus.allen@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 26, 'Active', 'Captain'),
('terrence.wright@example.com', 'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 27, 'Active', 'Player'),
('jamal.turner@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 28, 'Active', 'Player'),
('corey.adams@example.com',     'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 29, 'Active', 'Player'),
('vernon.parker@example.com',   'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 30, 'Active', 'Player'),
('malik.robinson@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 31, 'Active', 'Captain'),
('dante.carter@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 32, 'Active', 'Player'),
('reggie.mitchell@example.com', 'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 33, 'Active', 'Player'),
('andre.phillips@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 34, 'Active', 'Player'),
('deshawn.evans@example.com',   'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 35, 'Active', 'Player'),
('tyrone.washington@example.com','CBFDAC6008F9CAB4083784CBD1874F76618D2A97','2025-01-01', 36, 'Active', 'Captain'),
('jerome.coleman@example.com',  'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 37, 'Active', 'Player'),
('lamont.baker@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 38, 'Active', 'Player'),
('curtis.howard@example.com',   'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 39, 'Active', 'Player'),
('raymond.ward@example.com',    'CBFDAC6008F9CAB4083784CBD1874F76618D2A97', '2025-01-01', 40, 'Active', 'Player');

-- ── Roster ───────────────────────────────────────────────────────────────────
INSERT INTO roster (PlayerID, TeamID, SeasonID, DivisionID, Jersey) VALUES
(1,1,1,1,10),(2,1,1,1,23),(3,1,1,1,5),(4,1,1,1,34),(5,1,1,1,42),
(6,2,1,1,1),(7,2,1,1,15),(8,2,1,1,7),(9,2,1,1,21),(10,2,1,1,33),
(11,3,1,1,4),(12,3,1,1,11),(13,3,1,1,22),(14,3,1,1,31),(15,3,1,1,50),
(16,4,1,1,3),(17,4,1,1,14),(18,4,1,1,24),(19,4,1,1,44),(20,4,1,1,55),
(21,5,1,2,6),(22,5,1,2,13),(23,5,1,2,20),(24,5,1,2,35),(25,5,1,2,41),
(26,6,1,2,2),(27,6,1,2,16),(28,6,1,2,25),(29,6,1,2,30),(30,6,1,2,45),
(31,7,1,2,8),(32,7,1,2,17),(33,7,1,2,26),(34,7,1,2,40),(35,7,1,2,52),
(36,8,1,2,9),(37,8,1,2,18),(38,8,1,2,27),(39,8,1,2,37),(40,8,1,2,48);

-- ── Schedule ─────────────────────────────────────────────────────────────────
-- status enum: 'scheduled' | 'live' | 'final'  (NOT NULL, default 'scheduled')
-- North Division (DivisionID=1) — Weeks 1-3
-- South Division (DivisionID=2) — Weeks 1-3
-- Weeks 1-2 finalized; Week 3 upcoming

INSERT INTO schedule (ScheduleID, HomeTeamID, AwayTeamID, Week, StartTime, Date, DivisionID, SeasonID, HomeScore, AwayScore, status) VALUES
-- North — Week 1 (final)
(1,  1, 2, 1, '12:00:00', '2025-01-05', 1, 1, 78, 65, 'final'),
(2,  3, 4, 1, '13:00:00', '2025-01-05', 1, 1, 55, 62, 'final'),
-- North — Week 2 (final)
(3,  1, 3, 2, '12:00:00', '2025-01-12', 1, 1, 71, 68, 'final'),
(4,  2, 4, 2, '13:00:00', '2025-01-12', 1, 1, 80, 75, 'final'),
-- North — Week 3 (upcoming)
(5,  1, 4, 3, '12:00:00', '2025-01-19', 1, 1, NULL, NULL, 'scheduled'),
(6,  2, 3, 3, '13:00:00', '2025-01-19', 1, 1, NULL, NULL, 'scheduled'),
-- South — Week 1 (final)
(7,  5, 6, 1, '12:00:00', '2025-01-05', 2, 1, 88, 72, 'final'),
(8,  7, 8, 1, '13:00:00', '2025-01-05', 2, 1, 61, 77, 'final'),
-- South — Week 2 (final)
(9,  5, 7, 2, '12:00:00', '2025-01-12', 2, 1, 65, 70, 'final'),
(10, 6, 8, 2, '13:00:00', '2025-01-12', 2, 1, 73, 81, 'final'),
-- South — Week 3 (upcoming)
(11, 5, 8, 3, '12:00:00', '2025-01-19', 2, 1, NULL, NULL, 'scheduled'),
(12, 6, 7, 3, '13:00:00', '2025-01-19', 2, 1, NULL, NULL, 'scheduled');

-- ── Standings ────────────────────────────────────────────────────────────────
INSERT INTO standings (TeamID, Wins, Losses, SeasonID, DivisionID, PointDifferential) VALUES
(1, 2, 0, 1, 1,  16),
(2, 1, 1, 1, 1,  -8),
(3, 0, 2, 1, 1, -10),
(4, 1, 1, 1, 1,   2),
(5, 1, 1, 1, 2,  11),
(6, 0, 2, 1, 2, -24),
(7, 1, 1, 1, 2, -11),
(8, 2, 0, 1, 2,  24);

-- ── PlayerGameLog ─────────────────────────────────────────────────────────────
-- Columns: PlayerID, FGM, FGA, 3FGM, 3FGA, FTM, FTA, Points, Rebounds, Assists,
--          Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus

-- Game 1: The Ballers 78 vs Slam Dunkers 65 — ScheduleID=1, DivisionID=1
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(1,  9,15,2,5,4,5,22, 5,4,2,0,3,NULL,1,1,1,1,2, 13),
(2,  6,11,0,2,4,5,16, 8,2,1,1,1,NULL,1,1,1,1,3, 13),
(3,  5,10,1,3,2,3,13, 4,6,0,0,2,NULL,1,1,1,1,2, 13),
(4,  5, 9,1,3,0,0,11, 3,1,1,2,0,NULL,1,1,1,1,1, 13),
(5,  6,10,0,2,4,4,16, 6,3,2,0,1,NULL,1,1,1,1,2, 13),
(6,  7,14,2,5,2,2,18, 4,5,1,0,2,NULL,1,1,2,1,2,-13),
(7,  5,11,1,3,2,3,13, 7,2,2,1,1,NULL,1,1,2,1,3,-13),
(8,  5, 9,0,2,2,2,12, 3,4,0,0,2,NULL,1,1,2,1,1,-13),
(9,  4, 8,0,2,2,2,10, 5,1,1,2,0,NULL,1,1,2,1,2,-13),
(10, 4, 8,0,2,4,4,12, 2,3,1,0,3,NULL,1,1,2,1,2,-13);

-- Game 2: Net Rippers 55 vs Hoop Dreams 62 — ScheduleID=2, DivisionID=1
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(11, 5,11,1,3,2,3,13, 4,3,2,0,2,NULL,1,1,3,2,3,-7),
(12, 4, 9,1,3,0,0, 9, 6,2,1,0,1,NULL,1,1,3,2,2,-7),
(13, 4, 8,0,2,2,2,10, 4,4,0,0,2,NULL,1,1,3,2,2,-7),
(14, 5,10,1,3,0,0,11, 3,1,1,1,0,NULL,1,1,3,2,1,-7),
(15, 5,10,0,2,2,2,12, 5,2,2,1,1,NULL,1,1,3,2,2,-7),
(16, 6,12,2,4,4,5,18, 5,4,1,0,2,NULL,1,1,4,2,2, 7),
(17, 5,10,1,3,2,3,13, 6,3,0,1,1,NULL,1,1,4,2,3, 7),
(18, 4, 8,0,2,2,2,10, 4,2,2,0,2,NULL,1,1,4,2,2, 7),
(19, 3, 7,1,3,0,0, 7, 3,2,1,0,1,NULL,1,1,4,2,1, 7),
(20, 5,10,2,4,2,2,14, 4,2,0,2,0,NULL,1,1,4,2,2, 7);

-- Game 3: The Ballers 71 vs Net Rippers 68 — ScheduleID=3, DivisionID=1
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(1,  7,14,1,4,4,5,19, 4,5,1,0,2,NULL,1,1,1,3,2, 3),
(2,  5,10,0,2,4,5,14, 7,2,0,2,1,NULL,1,1,1,3,3, 3),
(3,  6,11,2,4,0,0,14, 3,4,1,0,2,NULL,1,1,1,3,1, 3),
(4,  3, 7,1,3,2,2, 9, 3,1,1,1,1,NULL,1,1,1,3,2, 3),
(5,  5, 9,3,5,2,2,15, 5,3,2,0,1,NULL,1,1,1,3,2, 3),
(11, 7,13,2,4,4,5,20, 5,3,1,0,2,NULL,1,1,3,3,3,-3),
(12, 5,10,1,3,4,4,15, 6,2,0,0,1,NULL,1,1,3,3,2,-3),
(13, 4, 9,0,2,2,3,10, 3,4,1,0,2,NULL,1,1,3,3,2,-3),
(14, 5,10,1,3,0,0,11, 4,2,0,1,0,NULL,1,1,3,3,1,-3),
(15, 5,10,0,2,2,2,12, 4,1,2,1,1,NULL,1,1,3,3,2,-3);

-- Game 4: Slam Dunkers 80 vs Hoop Dreams 75 — ScheduleID=4, DivisionID=1
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(6,  9,16,2,5,4,4,24, 5,6,1,0,3,NULL,1,1,2,4,3, 5),
(7,  6,12,1,3,4,5,17, 8,2,2,1,1,NULL,1,1,2,4,2, 5),
(8,  5,10,1,3,2,2,13, 3,5,0,0,2,NULL,1,1,2,4,2, 5),
(9,  5, 9,0,2,0,0,10, 6,1,1,2,0,NULL,1,1,2,4,1, 5),
(10, 5,10,2,4,4,4,16, 2,4,1,0,2,NULL,1,1,2,4,2, 5),
(16, 8,15,2,5,4,5,22, 5,5,1,0,3,NULL,1,1,4,4,3,-5),
(17, 6,11,1,3,2,2,15, 6,3,0,1,1,NULL,1,1,4,4,2,-5),
(18, 5,10,1,3,0,0,11, 4,2,2,0,2,NULL,1,1,4,4,2,-5),
(19, 4, 8,0,2,4,4,12, 3,2,1,0,1,NULL,1,1,4,4,1,-5),
(20, 4, 9,3,4,4,4,15, 4,2,0,2,0,NULL,1,1,4,4,2,-5);

-- Game 7: Fast Break 88 vs Court Kings 72 — ScheduleID=7, DivisionID=2
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(21, 9,15,3,6,4,5,25, 5,5,2,0,2,NULL,1,2,5,7,2, 16),
(22, 7,13,1,4,4,5,19, 6,3,1,0,1,NULL,1,2,5,7,2, 16),
(23, 6,11,2,4,2,2,16, 4,4,0,1,2,NULL,1,2,5,7,3, 16),
(24, 4, 9,0,2,4,5,12, 7,2,1,2,1,NULL,1,2,5,7,2, 16),
(25, 5, 9,2,4,4,5,16, 5,2,2,0,2,NULL,1,2,5,7,2, 16),
(26, 7,14,2,5,4,4,20, 4,5,1,0,2,NULL,1,2,6,7,2,-16),
(27, 5,11,1,4,4,4,15, 6,3,0,0,1,NULL,1,2,6,7,3,-16),
(28, 5,10,0,3,2,2,12, 4,4,1,0,2,NULL,1,2,6,7,2,-16),
(29, 4, 9,1,3,0,0, 9, 5,2,1,0,1,NULL,1,2,6,7,1,-16),
(30, 5,11,2,4,4,5,16, 3,2,0,1,3,NULL,1,2,6,7,3,-16);

-- Game 8: Rim Rockers 61 vs Triple Threat 77 — ScheduleID=8, DivisionID=2
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(31, 6,13,1,4,4,5,17, 5,4,1,0,3,NULL,1,2,7,8,3,-16),
(32, 5,10,0,3,2,2,12, 6,2,1,0,1,NULL,1,2,7,8,2,-16),
(33, 4, 9,1,3,0,0, 9, 4,3,0,0,2,NULL,1,2,7,8,2,-16),
(34, 4, 8,0,2,2,3,10, 7,1,0,2,0,NULL,1,2,7,8,2,-16),
(35, 5, 9,0,2,3,4,13, 5,1,2,1,0,NULL,1,2,7,8,2,-16),
(36, 8,14,3,6,4,4,23, 4,5,2,0,2,NULL,1,2,8,8,2, 16),
(37, 6,12,2,4,4,5,18, 6,3,1,0,1,NULL,1,2,8,8,2, 16),
(38, 5,10,0,2,1,2,11, 4,4,0,1,2,NULL,1,2,8,8,3, 16),
(39, 4, 8,0,2,2,3,10, 7,1,1,2,1,NULL,1,2,8,8,2, 16),
(40, 4, 9,3,5,4,4,15, 5,1,0,0,0,NULL,1,2,8,8,2, 16);

-- Game 9: Fast Break 65 vs Rim Rockers 70 — ScheduleID=9, DivisionID=2
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(21, 7,13,1,4,4,5,19, 4,5,1,0,2,NULL,1,2,5,9,2,-5),
(22, 5,11,1,3,2,3,13, 5,3,0,0,1,NULL,1,2,5,9,2,-5),
(23, 4, 9,0,2,2,2,10, 3,4,1,1,2,NULL,1,2,5,9,3,-5),
(24, 3, 8,0,2,2,3, 8, 6,2,0,1,1,NULL,1,2,5,9,2,-5),
(25, 5, 9,3,5,2,3,15, 5,2,2,0,2,NULL,1,2,5,9,2,-5),
(31, 7,13,2,5,4,5,20, 5,4,2,0,2,NULL,1,2,7,9,2, 5),
(32, 5,11,1,3,2,2,13, 7,2,0,0,1,NULL,1,2,7,9,2, 5),
(33, 5, 9,0,2,0,0,10, 4,3,1,0,1,NULL,1,2,7,9,2, 5),
(34, 5, 9,1,3,0,0,11, 6,1,0,2,0,NULL,1,2,7,9,1, 5),
(35, 6,10,0,2,4,5,16, 6,1,2,1,1,NULL,1,2,7,9,2, 5);

-- Game 10: Court Kings 73 vs Triple Threat 81 — ScheduleID=10, DivisionID=2
INSERT INTO playergamelog (PlayerID, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Points, Rebounds, Assists, Steals, Blocks, Turnovers, BoxScoreID, SeasonID, DivisionID, TeamID, ScheduleID, Fouls, plusMinus) VALUES
(26, 8,15,2,5,4,5,22, 4,5,1,0,2,NULL,1,2,6,10,2,-8),
(27, 6,12,0,3,4,5,16, 5,3,1,0,1,NULL,1,2,6,10,2,-8),
(28, 5,10,1,3,0,0,11, 4,4,0,0,2,NULL,1,2,6,10,3,-8),
(29, 3, 8,0,2,2,3, 8, 5,2,1,0,1,NULL,1,2,6,10,1,-8),
(30, 5,11,2,4,4,4,16, 3,2,0,1,3,NULL,1,2,6,10,3,-8),
(36, 8,14,3,6,6,7,25, 5,5,2,0,2,NULL,1,2,8,10,2, 8),
(37, 7,13,2,5,2,3,18, 6,3,1,0,1,NULL,1,2,8,10,2, 8),
(38, 5,10,0,2,4,5,14, 4,4,0,1,2,NULL,1,2,8,10,3, 8),
(39, 4, 8,1,3,2,2,11, 7,1,1,2,1,NULL,1,2,8,10,2, 8),
(40, 4, 9,1,4,4,5,13, 4,1,0,0,0,NULL,1,2,8,10,2, 8);

-- ── PlayerStats (season averages) ────────────────────────────────────────────
-- Columns: PlayerID, Points, Rebounds, Assists, FGM, FGA, 3FGM, 3FGA, FTM, FTA,
--          Steals, Blocks, Turnovers, GamesPlayed, SeasonID, DivisionID, TeamID

INSERT INTO playerstats (PlayerID, Points, Rebounds, Assists, FGM, FGA, `3FGM`, `3FGA`, FTM, FTA, Steals, Blocks, Turnovers, GamesPlayed, SeasonID, DivisionID, TeamID) VALUES
-- Team 1 — The Ballers (2 games)
(1,  20.5, 4.5, 4.5,  8.0,14.5,1.5,4.5,4.0,5.0,1.5,0.0,2.5, 2,1,1,1),
(2,  15.0, 7.5, 2.0,  5.5,10.5,0.0,2.0,4.0,5.0,0.5,1.5,1.0, 2,1,1,1),
(3,  13.5, 3.5, 5.0,  5.5,10.5,1.5,3.5,1.0,1.5,0.5,0.0,2.0, 2,1,1,1),
(4,  10.0, 3.0, 1.0,  4.0, 8.0,1.0,3.0,1.0,1.0,1.0,1.5,0.5, 2,1,1,1),
(5,  15.5, 5.5, 3.0,  5.5, 9.5,1.5,3.5,3.0,3.0,2.0,0.0,1.0, 2,1,1,1),
-- Team 2 — Slam Dunkers (2 games)
(6,  21.0, 4.5, 5.5,  9.0,15.0,2.0,5.0,3.0,3.0,1.0,0.0,2.5, 2,1,1,2),
(7,  15.0, 7.5, 2.0,  5.5,11.5,1.0,3.0,3.0,4.0,2.0,1.0,1.0, 2,1,1,2),
(8,  12.5, 3.0, 4.5,  5.0, 9.5,0.5,2.5,2.0,2.0,0.0,0.0,2.0, 2,1,1,2),
(9,  10.0, 5.5, 1.0,  4.5, 8.5,0.0,2.0,1.0,1.0,1.0,2.0,0.0, 2,1,1,2),
(10, 14.0, 2.0, 3.5,  4.5, 9.0,1.0,3.0,4.0,4.0,1.0,0.0,2.5, 2,1,1,2),
-- Team 3 — Net Rippers (2 games)
(11, 16.5, 4.5, 3.0,  6.0,12.0,1.5,3.5,3.0,4.0,1.5,0.0,2.0, 2,1,1,3),
(12, 12.0, 6.0, 2.0,  4.5, 9.5,1.0,3.0,2.0,2.0,0.5,0.0,1.0, 2,1,1,3),
(13, 10.0, 3.5, 4.0,  4.0, 8.5,0.0,2.0,2.0,2.5,0.5,0.0,2.0, 2,1,1,3),
(14, 11.0, 3.5, 1.5,  5.0,10.0,1.0,3.0,0.0,0.0,0.5,1.0,0.0, 2,1,1,3),
(15, 12.0, 4.5, 1.5,  5.0,10.0,0.0,2.0,2.0,2.0,2.0,1.0,1.0, 2,1,1,3),
-- Team 4 — Hoop Dreams (2 games)
(16, 20.0, 5.0, 4.5,  7.0,13.5,2.0,4.5,4.0,5.0,1.0,0.0,2.5, 2,1,1,4),
(17, 14.0, 6.0, 3.0,  5.5,10.5,1.0,3.0,2.0,2.5,0.0,1.0,1.0, 2,1,1,4),
(18, 10.5, 4.0, 2.0,  4.5, 9.0,0.5,2.5,1.0,1.0,2.0,0.0,2.0, 2,1,1,4),
(19,  9.5, 3.0, 2.0,  3.5, 7.5,0.5,2.5,2.0,2.0,1.0,0.0,1.0, 2,1,1,4),
(20, 14.5, 4.0, 2.0,  4.5, 9.5,2.5,4.0,3.0,3.0,0.0,2.0,0.0, 2,1,1,4),
-- Team 5 — Fast Break (2 games)
(21, 22.0, 4.5, 5.0,  8.0,14.0,2.0,5.0,4.0,5.0,1.5,0.0,2.0, 2,1,2,5),
(22, 16.0, 5.5, 3.0,  6.0,12.0,1.0,3.5,3.0,4.0,0.5,0.0,1.0, 2,1,2,5),
(23, 13.0, 3.5, 4.0,  5.0,10.0,1.0,3.0,2.0,2.0,0.5,1.0,2.0, 2,1,2,5),
(24, 10.0, 6.5, 2.0,  3.5, 8.5,0.0,2.0,3.0,4.0,0.5,1.5,1.0, 2,1,2,5),
(25, 15.5, 5.0, 2.0,  5.0, 9.0,2.5,4.5,3.0,4.0,2.0,0.0,2.0, 2,1,2,5),
-- Team 6 — Court Kings (2 games)
(26, 21.0, 4.0, 5.0,  7.5,14.5,2.0,5.0,4.0,4.5,1.0,0.0,2.0, 2,1,2,6),
(27, 15.5, 5.5, 3.0,  5.5,11.5,0.5,3.5,4.0,4.5,0.5,0.0,1.0, 2,1,2,6),
(28, 11.5, 4.0, 4.0,  5.0,10.0,0.5,3.0,1.0,1.0,0.5,0.0,2.0, 2,1,2,6),
(29,  8.5, 5.0, 2.0,  3.5, 8.5,0.5,2.5,1.0,1.5,1.0,0.0,1.0, 2,1,2,6),
(30, 16.0, 3.0, 2.0,  5.0,11.0,2.0,4.0,4.0,4.5,0.0,1.0,3.0, 2,1,2,6),
-- Team 7 — Rim Rockers (2 games)
(31, 18.5, 5.0, 4.0,  6.5,13.0,1.5,4.5,4.0,5.0,1.5,0.0,2.5, 2,1,2,7),
(32, 12.5, 6.5, 2.0,  5.0,10.5,0.5,3.0,2.0,2.0,0.5,0.0,1.0, 2,1,2,7),
(33,  9.5, 4.0, 3.0,  4.5, 9.0,0.5,2.5,0.0,0.0,0.5,0.0,1.5, 2,1,2,7),
(34, 10.5, 6.5, 1.0,  4.5, 8.5,0.5,2.5,1.0,1.5,0.0,2.0,0.0, 2,1,2,7),
(35, 14.5, 5.5, 1.0,  5.5, 9.5,0.0,2.0,3.5,4.5,2.0,1.0,0.5, 2,1,2,7),
-- Team 8 — Triple Threat (2 games)
(36, 24.0, 4.5, 5.0,  8.0,14.0,3.0,6.0,5.0,5.5,2.0,0.0,2.0, 2,1,2,8),
(37, 18.0, 6.0, 3.0,  6.5,12.5,2.0,4.5,3.0,4.0,1.0,0.0,1.0, 2,1,2,8),
(38, 12.5, 4.0, 4.0,  5.0,10.0,0.0,2.0,2.5,3.5,0.0,1.0,2.0, 2,1,2,8),
(39, 10.5, 7.0, 1.0,  4.0, 8.0,0.5,2.5,2.0,2.5,1.0,2.0,1.0, 2,1,2,8),
(40, 14.0, 4.5, 1.0,  4.0, 9.0,2.0,4.5,4.0,4.5,0.0,0.0,0.0, 2,1,2,8);

-- ── Sample game recaps ────────────────────────────────────────────────────────
INSERT INTO recaps (scheduleID, recapText) VALUES
(1, 'The Ballers dominated from start to finish, riding John Smith''s 22-point performance to a convincing 78-65 victory over the Slam Dunkers. Smith shot efficiently from beyond the arc while James Davis controlled the paint with 16 points and 6 rebounds. Kevin Wilson led a valiant Slam Dunkers effort with 18 points, but turnovers in the fourth quarter proved costly as Portland''s depth advantage made the difference in this North Division showdown.'),
(7, 'Darius Young put on a clinic with 25 points and 5 assists as Fast Break rolled past Court Kings 88-72 in a South Division opener. Young hit three triples in the first half to establish the tone, and Fast Break''s defense forced 11 turnovers. Court Kings'' Marcus Allen kept his team in the fight with 20 points, but Fast Break''s balanced attack — all five starters scored in double figures — proved too much to overcome.');

SET FOREIGN_KEY_CHECKS = 1;
