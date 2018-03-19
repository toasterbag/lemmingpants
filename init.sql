-- Initialization ------------------------------------------------------------
--
-- The role lemmingpants and the database lemmingpants must exist!

DROP SCHEMA IF EXISTS api CASCADE;
CREATE SCHEMA api AUTHORIZATION lemmingpants;
GRANT ALL PRIVILEGES ON SCHEMA api TO lemmingpants;
SET SCHEMA 'api';

-- Tables -------------------------------------------------------------------

CREATE TABLE attendee (
    id      INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cid     TEXT NOT NULL,
    name    TEXT NOT NULL,
    nick    TEXT NULL,
    created TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE agenda_item (
    id      INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    title   TEXT NOT NULL,
    content TEXT NOT NULL,
    order_  INTEGER GENERATED BY DEFAULT AS IDENTITY,
    active  BOOLEAN DEFAULT FALSE NOT NULL
);
-- Only one agenda item may be active at the time.
CREATE UNIQUE INDEX ON agenda_item (active) WHERE active;

CREATE TABLE speaker_queue (
    id             INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    agenda_item_id INTEGER REFERENCES agenda_item NOT NULL
);

CREATE TABLE speaker (
    id               INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    speaker_queue_id INTEGER REFERENCES speaker_queue NOT NULL,
    attendee_id      INTEGER REFERENCES attendee NOT NULL,
    speaking         BOOLEAN DEFAULT FALSE NOT NULL,
    created          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
-- At most one speaker per queue may be active at the time.
CREATE UNIQUE INDEX ON speaker (speaker_queue_id, speaking) where speaking;

-- Roles --------------------------------------------------------------------

GRANT ALL PRIVILEGES ON SCHEMA api TO lemmingpants;

DROP ROLE IF EXISTS web_anon;
CREATE ROLE web_anon NOLOGIN;
GRANT web_anon TO lemmingpants;

GRANT USAGE ON SCHEMA api TO web_anon;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA api TO web_anon;
GRANT SELECT ON ALL TABLES IN SCHEMA api TO web_anon;


DROP ROLE IF EXISTS write_access_user;
CREATE ROLE write_access_user NOLOGIN;
GRANT write_access_user TO lemmingpants;

GRANT USAGE ON SCHEMA api TO write_access_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA api TO write_access_user;
GRANT ALL ON ALL TABLES IN SCHEMA api TO write_access_user;

-- Example data  -------------------------------------------------------------

INSERT INTO attendee(cid, name) VALUES('ekeroot', 'A. Ekeroot');
INSERT INTO attendee(cid, name) VALUES('snelob', 'Snel Bob');
INSERT INTO attendee(cid, name) VALUES('bobbobson', 'Bob Bobsson');
INSERT INTO attendee(cid, name) VALUES('testson', 'Test Testson');
INSERT INTO attendee(cid, name) VALUES('doedsbengt', 'Döds Bengt');

INSERT INTO agenda_item(title, content, order_)
    VALUES('Mötets öppnande', 'Mötet bör öpnas med trumpetstötar och godis.', 1);
INSERT INTO agenda_item(title, content, order_)
    VALUES('Val av mötesordförande', 'Förslag: sittande.', 2);
INSERT INTO agenda_item(title, content, order_)
    VALUES('Val av reservmötesordförande ifall den första går sönder', 'Förslag: stående.', 3);
INSERT INTO agenda_item(title, content, order_)
    VALUES('Mer glass=?', 'JA! MER GLASS!!!', 4);
INSERT INTO agenda_item(title, content, order_)
    VALUES('Mer bäsk?', 'Mmmmmbäsk...', 5);
INSERT INTO agenda_item(title, content, order_)
    VALUES('Mötets stängande', 'Vi tänkte gå hem nu.', 6);
