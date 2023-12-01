-- IS NULL operatore
    WHERE s.user_id = uid
    AND m.to_id IS NULL   

UPDATE views SET 
    css_list = '{bundle}',  -- TEXT[]
    js_list = '{bundle}'    -- TEXT[]
    WHERE vname LIKE 'vname-%' 
        AND vname <> 'vname-0';

-- pgcrypto  https://www.postgresql.org/docs/9.6/pgcrypto.html
-- UUID v4
CREATE EXTENSION IF NOT EXISTS "pgcrypto";  -- preferably
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- very limited
crypt('pw-abc123', gen_salt('bf', 8))

SELECT encode(digest(now()::text, 'sha1'), 'hex');
-- 6c475593bc1ab97eee1b3bd0179ca14cd64586ee

-- etag @ JSON: 
encode(digest(string_agg(mm.msg_id::text, '')
    || string_agg((extract(epoch 
            FROM date_trunc('milliseconds', mm.date_update))*1000)::text, ''
        ), 'sha1'), 'hex') -- SHA1( concat(mm.msg_id) + concat(mm.date_update) )

-- function :: SQL
DROP FUNCTION IF EXISTS get_msgs_chn(UUID, TIMESTAMPTZ, INT);
CREATE OR REPLACE FUNCTION get_msgs_chn(cid UUID, t TIMESTAMPTZ, n INT)
    RETURNS SETOF vw_messages AS
$BODY$
    SELECT * FROM vw_messages
    WHERE chn_id = cid
    AND date_create <= t
    ORDER BY date_create DESC   -- if per Flat 
    -- ORDER BY date_create ASC -- if per Nest (thread)
    LIMIT n
$BODY$
LANGUAGE SQL STABLE;

-- function :: PL/pgSQL
DROP FUNCTION IF EXISTS get_msgs_chn_json(UUID, TIMESTAMPTZ, INT);
CREATE OR REPLACE FUNCTION get_msgs_chn_json(cid UUID, t TIMESTAMPTZ, n INT)
    RETURNS json AS 
$BODY$
    DECLARE -- components
        m json;
    BEGIN
        SELECT CASE WHEN COUNT(mm.*) = 0 THEN '[]' ELSE json_agg(mm.*) END INTO m 
        FROM ( --SELECT * FROM get_msgs_chn(cid) 
            SELECT * FROM messages
            WHERE chn_id = cid
            AND date_create <= t
            ORDER BY date_create DESC
            LIMIT n
        ) mm;

        -- Build JSON response:
        RETURN (SELECT json_strip_nulls(json_build_object(
            'messages', m
        )));
    END
$BODY$
LANGUAGE 'plpgsql' STABLE;

-- ====================================================================
DROP TABLE foo;
CREATE TABLE IF NOT EXISTS foo (
    idx         BIGINT GENERATED ALWAYS AS IDENTITY,  
    fname TEXT DEFAULT 'fname x',
    about TEXT
);

DROP FUNCTION IF EXISTS dox();
CREATE OR REPLACE FUNCTION dox() 
    RETURNS boolean AS 
$BODY$
    DECLARE 
        about_pub text := 'Add this txt';
        x boolean := true;
        
    BEGIN
        INSERT INTO foo (fname, about) VALUES 
            ('bar none',about_pub), 
            ('bar some', about_pub);
        RETURN x;
    END
$BODY$
LANGUAGE 'plpgsql';

SELECT * FROM foo;
SELECT dox();
SELECT * FROM foo;
-- ====================================================================



-- ----------------------------------------------------------------------------
--  ADMIN  
-- ----------------------------------------------------------------------------
-- drop (remove, delete) db
DROP DATABASE db_foo;
-- create a db
CREATE DATABASE db_foo;
-- create user
CREATE USER userof_foo WITH PASSWORD 'pass_of_userof_foo';
-- grant privileges
GRANT ALL PRIVILEGES ON DATABASE db_foo to userof_foo;
-- revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE company from james;

-- alter
ALTER USER james WITH SUPERUSER;
ALTER USER james WITH NOSUPERUSER;
-- remove
DROP USER james;

-- server version
SELECT version();

-- connect to db
\c db_foo
-- list dbs
\l 
-- see current user
SELECT current_user;
-- see current database
SELECT current_database();


-- ----------------------------------------------------------------------------
-- Mock transactions trigger on/before user delete 
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS uzrs;
CREATE TABLE IF NOT EXISTS uzrs (
    user_id     INT PRIMARY KEY,
    uname     TEXT
);

DROP TABLE IF EXISTS txns;
CREATE TABLE IF NOT EXISTS txns (
    idx     INT  PRIMARY KEY,
    payer_id     INT,
    payee_id     INT
);
DROP TABLE IF EXISTS xcfg_users_mv;
CREATE TABLE IF NOT EXISTS xcfg_users_mv (
    user_id     INT PRIMARY KEY,
    uname     TEXT
);

INSERT INTO uzrs (user_id,uname) VALUES (1,11),(2,22),(3,33),(4,44),(5,55);
INSERT INTO txns (idx,payer_id,payee_id) VALUES (1,33,55),(2,11,44),(3,44,11),(4,22,11);
INSERT INTO xcfg_users_mv (user_id, uname) VALUES (999,'bogus');

SELECT * FROM uzrs;
SELECT * FROM xcfg_users_mv;
SELECT * FROM txns;

\set old_uzr 11 

UPDATE txns 
    SET (payer_id, payee_id) = (
            (CASE 
                WHEN (payer_id = :old_uzr) THEN 
                    (SELECT user_id FROM xcfg_users_mv 
                        WHERE uname = 'bogus'
                    )
                ELSE payer_id
            END),
            (CASE
                WHEN (payee_id = :old_uzr) THEN 
                    (SELECT user_id FROM xcfg_users_mv 
                        WHERE uname = 'bogus'
                    )
                ELSE payee_id
            END)
        ) -- Affect only transactions of OLD (deleted) user:
        WHERE payer_id = :old_uzr 
            OR payee_id = :old_uzr;
