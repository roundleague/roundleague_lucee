-- Round League — Database Schema
-- Generated from production INFORMATION_SCHEMA. Safe to re-run (CREATE TABLE IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS app_events (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  player_id  INT DEFAULT NULL,
  event      VARCHAR(50) NOT NULL,
  metadata   JSON DEFAULT NULL,
  created_at DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS game_plays (
  playID                  INT AUTO_INCREMENT PRIMARY KEY,
  scheduleID              INT NOT NULL,
  isPlayoff               TINYINT(1) NOT NULL DEFAULT 0,
  playerID                INT NOT NULL,
  teamID                  INT NOT NULL,
  stat_type               VARCHAR(20) NOT NULL,
  points_scored           TINYINT DEFAULT 0,
  home_score              SMALLINT DEFAULT 0,
  away_score              SMALLINT DEFAULT 0,
  period                  TINYINT DEFAULT 1,
  clock_remaining_seconds INT DEFAULT NULL,
  local_play_id           VARCHAR(60) NOT NULL,
  is_removed              TINYINT(1) DEFAULT 0,
  created_at              TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_local_play (scheduleID, isPlayoff, local_play_id),
  INDEX idx_schedule      (scheduleID, isPlayoff),
  INDEX idx_scoring       (scheduleID, isPlayoff, points_scored, is_removed)
);

CREATE TABLE IF NOT EXISTS awards (
  AwardID       INT AUTO_INCREMENT PRIMARY KEY,
  AwardName     VARCHAR(200) DEFAULT NULL,
  PlayerID      INT DEFAULT NULL,
  Week          INT DEFAULT NULL,
  IsSeasonAward BIT(1) DEFAULT NULL,
  DateAwarded   DATE DEFAULT NULL,
  SeasonID      INT DEFAULT NULL,
  DivisionID    INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS boxscores (
  BoxScoreID    INT AUTO_INCREMENT PRIMARY KEY,
  HomeTeamID    INT DEFAULT NULL,
  HomeTeamScore INT DEFAULT NULL,
  HomeTeamWin   BIT(1) DEFAULT NULL,
  AwayTeamID    INT DEFAULT NULL,
  AwayTeamScore INT DEFAULT NULL,
  AwayTeamWin   BIT(1) DEFAULT NULL,
  SeasonID      INT DEFAULT NULL,
  DatePlayed    DATE DEFAULT NULL,
  ScheduleID    INT DEFAULT NULL,
  DivisionID    INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS champions (
  championsID         INT AUTO_INCREMENT PRIMARY KEY,
  teamID              INT DEFAULT NULL,
  seasonID            INT DEFAULT NULL,
  playoffs_bracketID  INT DEFAULT NULL,
  backup_bracket_name VARCHAR(100) DEFAULT ''
);

CREATE TABLE IF NOT EXISTS divisions (
  DivisionID   INT AUTO_INCREMENT PRIMARY KEY,
  SeasonID     INT DEFAULT NULL,
  DivisionName VARCHAR(50) DEFAULT NULL,
  IsWomens     BIT(1) DEFAULT NULL,
  leagueID     INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS game_notifications (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  scheduleID INT NOT NULL,
  userID     INT NOT NULL,
  type       ENUM('24h','2h') NOT NULL,
  sentAt     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS game_subs (
  subID       INT AUTO_INCREMENT PRIMARY KEY,
  scheduleID  INT NOT NULL,
  teamID      INT NOT NULL,
  playerOutID INT NOT NULL,
  playerInID  INT NOT NULL,
  homeScore   INT NOT NULL,
  awayScore   INT NOT NULL,
  seq         INT NOT NULL
);

CREATE TABLE IF NOT EXISTS leagues (
  leagueID   INT AUTO_INCREMENT PRIMARY KEY,
  leagueName VARCHAR(50) NOT NULL DEFAULT '',
  seasonID   INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS merge_audit_log (
  auditID        INT AUTO_INCREMENT PRIMARY KEY,
  keptPlayerID   INT NOT NULL,
  mergedPlayerID INT NOT NULL,
  mergedByUser   VARCHAR(100) NOT NULL,
  mergeDate      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  userID    INT NOT NULL,
  token     VARCHAR(64) NOT NULL,
  expiresAt DATETIME NOT NULL,
  usedAt    DATETIME DEFAULT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pending_signups (
  pending_signupsID INT AUTO_INCREMENT PRIMARY KEY,
  userID            INT DEFAULT NULL,
  confirmationCode  VARCHAR(200) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS pending_teams (
  pending_teamsID     INT AUTO_INCREMENT PRIMARY KEY,
  teamName            VARCHAR(200) NOT NULL,
  selectedDivision    VARCHAR(50) NOT NULL DEFAULT '0',
  status              VARCHAR(25) NOT NULL DEFAULT '0',
  captainFirstName    VARCHAR(100) NOT NULL,
  captainLastName     VARCHAR(100) NOT NULL,
  allPlayersOver18    VARCHAR(3) NOT NULL DEFAULT '',
  email               VARCHAR(100) NOT NULL DEFAULT '0',
  phoneNumber         VARCHAR(100) NOT NULL DEFAULT '0',
  highestLevel        VARCHAR(100) NOT NULL DEFAULT '0',
  playerCountEstimate VARCHAR(100) NOT NULL DEFAULT '0',
  dayPreference       VARCHAR(100) NOT NULL DEFAULT '',
  referralSource      VARCHAR(50) NOT NULL DEFAULT '',
  referralOther       VARCHAR(255) NOT NULL DEFAULT '',
  dateAdded           DATE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS player_payment_contributions (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  player_id         INT NOT NULL,
  team_id           INT NOT NULL,
  amount            DECIMAL(10,2) NOT NULL,
  season            VARCHAR(50) NOT NULL,
  stripe_session_id VARCHAR(255) DEFAULT NULL,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS playergamelog (
  PlayerGameLogID INT AUTO_INCREMENT PRIMARY KEY,
  PlayerID        INT DEFAULT NULL,
  FGM             INT DEFAULT NULL,
  FGA             INT DEFAULT NULL,
  `3FGM`          INT DEFAULT NULL,
  `3FGA`          INT DEFAULT NULL,
  FTM             INT DEFAULT NULL,
  FTA             INT DEFAULT NULL,
  Points          INT DEFAULT NULL,
  Rebounds        INT DEFAULT NULL,
  Assists         INT DEFAULT NULL,
  Steals          INT DEFAULT NULL,
  Blocks          INT DEFAULT NULL,
  Turnovers       INT DEFAULT NULL,
  BoxScoreID      INT DEFAULT NULL,
  SeasonID        INT DEFAULT NULL,
  DivisionID      INT DEFAULT NULL,
  TeamID          INT DEFAULT NULL,
  ScheduleID      INT DEFAULT NULL,
  Fouls           INT DEFAULT NULL,
  plusMinus       INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS players (
  PlayerID              INT AUTO_INCREMENT PRIMARY KEY,
  RegisterDate          DATE NOT NULL,
  Email                 VARCHAR(200) NOT NULL DEFAULT '',
  firstName             VARCHAR(200) NOT NULL DEFAULT '',
  lastName              VARCHAR(200) NOT NULL DEFAULT '',
  BirthDate             DATE NOT NULL,
  Phone                 VARCHAR(200) NOT NULL DEFAULT '',
  HighestLevel          VARCHAR(200) DEFAULT NULL,
  FullyVaccinated       VARCHAR(100) NOT NULL DEFAULT '',
  FreeAgent             VARCHAR(50) DEFAULT NULL,
  position              VARCHAR(200) NOT NULL DEFAULT '',
  height                VARCHAR(200) NOT NULL DEFAULT '',
  weight                VARCHAR(200) NOT NULL DEFAULT '',
  hometown              VARCHAR(200) NOT NULL DEFAULT '',
  School                VARCHAR(200) NOT NULL DEFAULT '',
  PermissionToShare     VARCHAR(20) DEFAULT NULL,
  Status                VARCHAR(200) NOT NULL DEFAULT '',
  PhotoURL              VARCHAR(200) NOT NULL DEFAULT '',
  Instagram             VARCHAR(200) NOT NULL DEFAULT '',
  DivisionID            INT NOT NULL DEFAULT 0,
  Team                  VARCHAR(200) DEFAULT NULL,
  Gender                VARCHAR(50) DEFAULT NULL,
  MastersLeague         VARCHAR(50) DEFAULT NULL,
  ZipCode               INT DEFAULT NULL,
  ShoeSize              VARCHAR(50) DEFAULT NULL,
  ShoeType              VARCHAR(250) DEFAULT NULL,
  AdidasConflict        VARCHAR(50) DEFAULT NULL,
  AdidasInterestTesting VARCHAR(50) DEFAULT NULL,
  ModifiedDate          DATE DEFAULT NULL,
  mergedIntoPlayerID    INT DEFAULT NULL,
  is_youth              TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS playerstats (
  PlayerStatsID INT AUTO_INCREMENT PRIMARY KEY,
  PlayerID      INT DEFAULT NULL,
  Points        FLOAT DEFAULT NULL,
  Rebounds      FLOAT DEFAULT NULL,
  Assists       FLOAT DEFAULT NULL,
  FGM           FLOAT DEFAULT NULL,
  FGA           FLOAT DEFAULT NULL,
  `3FGM`        FLOAT DEFAULT NULL,
  `3FGA`        FLOAT DEFAULT NULL,
  FTM           FLOAT DEFAULT NULL,
  FTA           FLOAT DEFAULT NULL,
  Steals        FLOAT DEFAULT NULL,
  Blocks        FLOAT DEFAULT NULL,
  Turnovers     FLOAT DEFAULT NULL,
  GamesPlayed   INT DEFAULT NULL,
  SeasonID      INT DEFAULT NULL,
  DivisionID    INT DEFAULT NULL,
  TeamID        INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS playoffs_bracket (
  Playoffs_bracketID INT AUTO_INCREMENT PRIMARY KEY,
  Name               VARCHAR(50) NOT NULL DEFAULT '',
  SeasonID           INT DEFAULT NULL,
  SortOrder          INT DEFAULT NULL,
  MaxTeamSize        INT DEFAULT NULL,
  BracketFormat      VARCHAR(20) NOT NULL DEFAULT 'single'
);

CREATE TABLE IF NOT EXISTS playoffs_playergamelog (
  Playoffs_PlayerGameLogID INT AUTO_INCREMENT PRIMARY KEY,
  PlayerID                 INT DEFAULT NULL,
  FGM                      INT DEFAULT NULL,
  FGA                      INT DEFAULT NULL,
  `3FGM`                   INT DEFAULT NULL,
  `3FGA`                   INT DEFAULT NULL,
  FTM                      INT DEFAULT NULL,
  FTA                      INT DEFAULT NULL,
  Points                   INT DEFAULT NULL,
  Rebounds                 INT DEFAULT NULL,
  Assists                  INT DEFAULT NULL,
  Steals                   INT DEFAULT NULL,
  Blocks                   INT DEFAULT NULL,
  Turnovers                INT DEFAULT NULL,
  BoxScoreID               INT DEFAULT NULL,
  SeasonID                 INT DEFAULT NULL,
  DivisionID               INT DEFAULT NULL,
  TeamID                   INT DEFAULT NULL,
  Playoffs_ScheduleID      INT DEFAULT NULL,
  Fouls                    INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS playoffs_schedule (
  Playoffs_ScheduleID INT AUTO_INCREMENT PRIMARY KEY,
  HomeTeamID          INT DEFAULT NULL,
  AwayTeamID          INT DEFAULT NULL,
  Week                INT DEFAULT NULL,
  StartTime           TIME DEFAULT NULL,
  Date                DATE DEFAULT NULL,
  Playoffs_BracketID  INT DEFAULT NULL,
  SeasonID            INT DEFAULT NULL,
  HomeScore           INT DEFAULT NULL,
  AwayScore           INT DEFAULT NULL,
  BracketGameID       INT DEFAULT NULL,
  BracketRoundID      INT DEFAULT NULL,
  HomeSeed            INT DEFAULT NULL,
  AwaySeed            INT DEFAULT NULL,
  Location            VARCHAR(250) DEFAULT NULL,
  WinnerAdvancesTo    INT DEFAULT NULL,
  LoserAdvancesTo     INT DEFAULT NULL,
  GameLabel           VARCHAR(60) DEFAULT NULL,
  status                  ENUM('scheduled','live','final') NOT NULL DEFAULT 'scheduled',
  clock_status            ENUM('stopped','running','paused') NOT NULL DEFAULT 'stopped',
  clock_remaining_seconds INT NOT NULL DEFAULT 1500,
  clock_updated_at        DATETIME DEFAULT NULL,
  clock_period            TINYINT NOT NULL DEFAULT 1,
  shot_clock_remaining    TINYINT NOT NULL DEFAULT 30,
  shot_clock_status       ENUM('stopped','running') NOT NULL DEFAULT 'stopped',
  shot_clock_updated_at   DATETIME DEFAULT NULL,
  home_fouls_h1           INT NOT NULL DEFAULT 0,
  home_fouls_h2           INT NOT NULL DEFAULT 0,
  away_fouls_h1           INT NOT NULL DEFAULT 0,
  away_fouls_h2           INT NOT NULL DEFAULT 0,
  home_timeouts_h1        INT NOT NULL DEFAULT 2,
  home_timeouts_h2        INT NOT NULL DEFAULT 2,
  away_timeouts_h1        INT NOT NULL DEFAULT 2,
  away_timeouts_h2        INT NOT NULL DEFAULT 2
);

CREATE TABLE IF NOT EXISTS push_tokens (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  userID    INT NOT NULL,
  token     VARCHAR(255) NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS recaps (
  recapsID   INT AUTO_INCREMENT PRIMARY KEY,
  scheduleID INT NOT NULL,
  recapText  TEXT NOT NULL,
  isPlayoff  TINYINT(1) NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS roster (
  RosterID     INT AUTO_INCREMENT PRIMARY KEY,
  PlayerID     INT NOT NULL,
  TeamID       INT DEFAULT NULL,
  SeasonID     INT NOT NULL,
  DivisionID   INT DEFAULT NULL,
  Jersey       INT DEFAULT NULL,
  Starter      INT DEFAULT NULL,
  DateModified DATE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS schedule (
  ScheduleID              INT AUTO_INCREMENT PRIMARY KEY,
  HomeTeamID              INT DEFAULT NULL,
  AwayTeamID              INT DEFAULT NULL,
  Week                    INT DEFAULT NULL,
  StartTime               TIME DEFAULT NULL,
  Date                    DATE DEFAULT NULL,
  DivisionID              INT DEFAULT NULL,
  SeasonID                INT DEFAULT NULL,
  HomeBoxScoreLink        VARCHAR(1000) DEFAULT NULL,
  AwayBoxScoreLink        VARCHAR(1000) DEFAULT NULL,
  HomeScore               INT DEFAULT NULL,
  AwayScore               INT DEFAULT NULL,
  status                  ENUM('scheduled','live','final') NOT NULL DEFAULT 'scheduled',
  clock_status            ENUM('stopped','running','paused') NOT NULL DEFAULT 'stopped',
  clock_remaining_seconds INT NOT NULL DEFAULT 1500,
  clock_updated_at        DATETIME DEFAULT NULL,
  clock_period            TINYINT NOT NULL DEFAULT 1,
  shot_clock_remaining    TINYINT NOT NULL DEFAULT 30,
  shot_clock_status       ENUM('stopped','running') NOT NULL DEFAULT 'stopped',
  shot_clock_updated_at   DATETIME DEFAULT NULL,
  home_fouls_h1           INT NOT NULL DEFAULT 0,
  home_fouls_h2           INT NOT NULL DEFAULT 0,
  away_fouls_h1           INT NOT NULL DEFAULT 0,
  away_fouls_h2           INT NOT NULL DEFAULT 0,
  home_timeouts_h1        INT NOT NULL DEFAULT 2,
  home_timeouts_h2        INT NOT NULL DEFAULT 2,
  away_timeouts_h1        INT NOT NULL DEFAULT 2,
  away_timeouts_h2        INT NOT NULL DEFAULT 2
);

CREATE TABLE IF NOT EXISTS seasons (
  SeasonID         INT AUTO_INCREMENT PRIMARY KEY,
  SeasonName       VARCHAR(100) DEFAULT NULL,
  Status           VARCHAR(50) DEFAULT NULL,
  StartDate        DATE DEFAULT NULL,
  EndDate          DATE DEFAULT NULL,
  PreviousSeasonID INT DEFAULT NULL,
  team_fee         DECIMAL(10,2) DEFAULT 1000.00
);

CREATE TABLE IF NOT EXISTS standings (
  StandingsID       INT AUTO_INCREMENT PRIMARY KEY,
  TeamID            INT DEFAULT NULL,
  Wins              INT DEFAULT NULL,
  Losses            INT DEFAULT NULL,
  SeasonID          INT DEFAULT NULL,
  DivisionID        INT DEFAULT NULL,
  PointDifferential INT DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS team_payments (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  team_id           INT NOT NULL,
  season            VARCHAR(50) NOT NULL,
  amount_paid       DECIMAL(10,2) NOT NULL,
  payment_method    VARCHAR(20) DEFAULT NULL,
  paid_by_player_id INT DEFAULT NULL,
  stripe_session_id VARCHAR(255) DEFAULT NULL,
  created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS team_photos (
  photoID    INT AUTO_INCREMENT PRIMARY KEY,
  teamID     INT NOT NULL,
  seasonID   INT NOT NULL,
  s3Key      VARCHAR(500) NOT NULL,
  photoURL   VARCHAR(500) NOT NULL,
  filename   VARCHAR(255) DEFAULT NULL,
  uploadedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS team_preferences (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  teamID         INT NOT NULL,
  timePreference VARCHAR(50) DEFAULT 'No Preference',
  skillLevel     INT DEFAULT 2,
  dayPreference  VARCHAR(20) DEFAULT 'No Preference',
  blackouts      TEXT DEFAULT NULL,
  seasonID       INT DEFAULT NULL,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS teams (
  teamId          INT AUTO_INCREMENT PRIMARY KEY,
  Status          VARCHAR(50) NOT NULL DEFAULT '0',
  teamName        VARCHAR(50) NOT NULL DEFAULT '',
  CaptainPlayerID INT NOT NULL DEFAULT 0,
  RegisterDate    DATE NOT NULL,
  DivisionID      INT DEFAULT 0,
  SeasonID        INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS transactions (
  TransactionsID    INT AUTO_INCREMENT PRIMARY KEY,
  PlayerID          INT DEFAULT NULL,
  FromTeamID        INT DEFAULT NULL,
  ToTeamID          INT DEFAULT NULL,
  SeasonID          INT DEFAULT NULL,
  CaptainModifiedBy INT DEFAULT NULL,
  DateModified      DATE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS users (
  userID       INT AUTO_INCREMENT PRIMARY KEY,
  userName     VARCHAR(100) DEFAULT NULL,
  password     VARCHAR(100) DEFAULT NULL,
  dateModified DATE DEFAULT NULL,
  playerID     INT DEFAULT NULL,
  status       VARCHAR(50) DEFAULT NULL,
  role         VARCHAR(50) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS site_content (
  pageKey     VARCHAR(100) NOT NULL PRIMARY KEY,
  contentHTML MEDIUMTEXT   NOT NULL,
  updatedAt   DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS contact_messages (
  messageID        INT AUTO_INCREMENT PRIMARY KEY,
  senderEmail      VARCHAR(200) NOT NULL,
  senderPhone      VARCHAR(50) DEFAULT NULL,
  subject          VARCHAR(200) NOT NULL DEFAULT '',
  messageBody      TEXT NOT NULL,
  consentToContact TINYINT NOT NULL DEFAULT 0,
  isRead           TINYINT NOT NULL DEFAULT 0,
  isSpam           TINYINT NOT NULL DEFAULT 0,
  isAnomalous      TINYINT NOT NULL DEFAULT 0,
  spamReason       VARCHAR(50) DEFAULT NULL,
  createdAt        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  jiraKey          VARCHAR(50) DEFAULT NULL,
  jiraURL          VARCHAR(500) DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS bug_reports (
  bugID           INT AUTO_INCREMENT PRIMARY KEY,
  fingerprintHash CHAR(32)      NOT NULL,
  errorType       VARCHAR(200)  NOT NULL DEFAULT '',
  errorFile       VARCHAR(500)  NOT NULL DEFAULT '',
  errorLine       INT           NOT NULL DEFAULT 0,
  errorMessage    TEXT          NOT NULL,
  pageURL         VARCHAR(500)  NOT NULL DEFAULT '',
  occurrenceCount INT           NOT NULL DEFAULT 1,
  firstSeenAt     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  lastSeenAt      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved        TINYINT       NOT NULL DEFAULT 0,
  jiraKey         VARCHAR(50)   DEFAULT NULL,
  jiraURL         VARCHAR(500)  DEFAULT NULL,
  UNIQUE KEY uq_fingerprint (fingerprintHash),
  INDEX idx_resolved  (resolved),
  INDEX idx_lastSeen  (lastSeenAt)
);

CREATE TABLE IF NOT EXISTS bug_occurrences (
  occurrenceID  INT AUTO_INCREMENT PRIMARY KEY,
  bugID         INT           NOT NULL,
  occurredAt    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  userName      VARCHAR(100)  DEFAULT NULL,
  deployVersion VARCHAR(100)  DEFAULT NULL,
  pageURL       VARCHAR(500)  NOT NULL DEFAULT '',
  INDEX idx_bugID_occurredAt (bugID, occurredAt)
);

CREATE TABLE IF NOT EXISTS security_events (
  eventID     INT AUTO_INCREMENT PRIMARY KEY,
  eventType   VARCHAR(50)   NOT NULL,
  clientIP    VARCHAR(45)   NOT NULL DEFAULT '',
  subject     VARCHAR(255)  NOT NULL DEFAULT '',
  reason      VARCHAR(255)  NOT NULL DEFAULT '',
  anomalous   TINYINT       NOT NULL DEFAULT 0,
  occurredAt  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_occurredAt (occurredAt),
  INDEX idx_eventType  (eventType),
  INDEX idx_anomalous  (anomalous)
);
