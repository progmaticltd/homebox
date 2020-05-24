--- SOgo database initialisation script for postgresql

CREATE TABLE sogo_users (
    c_uid VARCHAR(128) NOT NULL PRIMARY KEY,
    c_name VARCHAR(128) NOT NULL,
    c_password VARCHAR(128) NOT NULL,
    c_cn VARCHAR(128) NULL,
    mail VARCHAR(128) NOT NULL,
    CONSTRAINT mail_unique UNIQUE (mail)
    );
