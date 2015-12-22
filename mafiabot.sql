-- ======
-- Pragma
-- ======

PRAGMA foreign_keys = ON;
PRAGMA encoding = "UTF-8"; 

-- ======
-- Tables
-- ======

CREATE TABLE players (
	id INTEGER PRIMARY KEY ASC,
	name TEXT NOT NULL UNIQUE ON CONFLICT IGNORE
);

CREATE TABLE stages (
	id INTEGER PRIMARY KEY ASC,
	stage TEXT NOT NULL UNIQUE ON CONFLICT IGNORE
);

CREATE TABLE statuses (
	id INTEGER PRIMARY KEY ASC,
	status TEXT NOT NULL UNIQUE ON CONFLICT IGNORE
);

CREATE TABLE games (
	id INTEGER PRIMARY KEY ASC, -- Currently the same as the thread number.
	status INTEGER NOT NULL REFERENCES statuses(id),
	current_day INTEGER NOT NULL DEFAULT 0,
	current_stage INTEGER NOT NULL REFERENCES stages(id),
	name TEXT -- Friendly name for humans querying db.
);

CREATE TABLE gamesplayers (
	id INTEGER PRIMARY KEY ASC,
	game INTEGER NOT NULL REFERENCES games(id),
	player INTEGER NOT NULL REFERENCES players(id),
	player_status INTEGER NOT NULL REFERENCES statuses(id),
	UNIQUE(game, player) ON CONFLICT IGNORE
);

CREATE TABLE votes (
	id INTEGER PRIMARY KEY ASC,
	game INTEGER NOT NULL REFERENCES games(id),
	day INTEGER NOT NULL,
	post INTEGER NOT NULL, -- Currently the post number in the game thread.
	voter INTEGER NOT NULL REFERENCES players(id),
	target INTEGER NOT NULL REFERENCES players(id),
	UNIQUE(game, post)
);

-- =======
-- Indexes
-- =======

-- Index player names by lowercase version.
CREATE INDEX players_lc ON players(lower(name));

-- =======
-- Queries
-- =======

-- Inserts
-- -------

-- Insert a player
INSERT INTO players (name) VALUES (param);

-- Insert a stage
INSERT INTO stages (stage) VALUES (param);

-- Insert a status
-- Needs to be split into playerstatus and
-- gamestatus
INSERT INTO statuses (status) VALUES (param);

-- Insert a game
INSERT OR IGNORE INTO games (id, status, current_day, current_stage, name)
VALUES (param_thread, param_status, param_day, param_stage, param_name);

-- Insert a player into a game
INSERT INTO gamesplayers (game, player, player_status)
VALUE (param_thread, param_player, param_player_status);

-- Insert a vote
INSERT INTO votes (game, day, post, voter, target)
VALUES (param_thread, param_day, param_post, param_voter, param_target);

-- Selects
-- -------

-- Check player is in game
SELECT id FROM players WHERE
	games.id = param_thread AND
	lower(players.name) = param_player;

-- =====
-- Other
-- =====

-- May not be used:
CREATE TABLE days (
	id INTEGER PRIMARY KEY ASC,
	game INTEGER NOT NULL REFERENCES games(id),
	day INTEGER NOT NULL,
	stage INTEGER NOT NULL REFERENCES stages(id),
	UNIQUE(game, day)
);