###############################################################
# 01 - UK IMPORT EXPORT - Create Tables in Database
###############################################################
library(RMySQL)
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_import_export')

## mq10: BY CLASSIFICATION OF PRODUCT AND ACTIVITY ---------------------------------------------------------------------
strSQL = "
    CREATE TABLE mq10 (
    	datefield SMALLINT(5) UNSIGNED NOT NULL,
    	CDID CHAR(5) NOT NULL COMMENT 'see *CDID* field in *cdid_nace* table' COLLATE 'utf8_unicode_ci',
    	value MEDIUMINT(8) UNSIGNED NOT NULL,
    	PRIMARY KEY (datefield, CDID),
    	INDEX (datefield),
    	INDEX (CDID)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# CDID_NACE -----------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE cdid_nace (
    	CDID CHAR(4) NOT NULL COMMENT 'See *CDID* field in *mq10* table' COLLATE 'utf8_unicode_ci',
    	DP TINYINT(1) UNSIGNED NOT NULL COMMENT '1-WorldWide, 2-Europe, 3-Rest Of The World',
    	IE TINYINT(1) UNSIGNED NOT NULL COMMENT '1-Import, 2-Export',
    	PV TINYINT(1) UNSIGNED NOT NULL COMMENT '1-Current Price, 2-Current Volume',
    	SA TINYINT(1) UNSIGNED NOT NULL COMMENT '0-Not Seasonally Adjusted, 1-Seasonally Adjusted',
    	NACE CHAR(5) NOT NULL COMMENT 'See *NACE* field in *nace* table' COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (CDID),
    	INDEX (NACE),
    	INDEX (DP),
    	INDEX (IE),
    	INDEX (PV),
    	INDEX (SA)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# NACE ----------------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE nace (
    	NACE CHAR(5) NOT NULL COMMENT 'See *NACE* field in *CDID_NACE* table' COLLATE 'utf8_unicode_ci',
    	description CHAR(60) NOT NULL COLLATE 'utf8_unicode_ci',
    	parent CHAR(5) NOT NULL COLLATE 'utf8_unicode_ci',
    	ordering SMALLINT(5) UNSIGNED NOT NULL,
    	level TINYINT(1) UNSIGNED NOT NULL COMMENT '1-Section (C:Manufactured products), 2-Division (11:Beverages), 3-Group (11.0:Beverages), 4-Class (11.01:Distilled alcoholic beverages), 5-Category (11.01.1:Distilled alcoholic beverages)',
    	PRIMARY KEY (NACE),
    	INDEX (parent),
    	INDEX (ordering),
    	INDEX (level)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)


## mret: BY AREA AND COMMODITY -----------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE mret (
    	datefield MEDIUMINT(6) UNSIGNED NOT NULL,
    	CDID CHAR(5) NOT NULL COMMENT 'see *CDID* field in *cdid_sitc* table' COLLATE 'utf8_unicode_ci',
    	value DECIMAL(10, 4) NOT NULL,
    	PRIMARY KEY (datefield, cdid),
    	INDEX (datefield),
    	INDEX (CDID)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# CDID_SITC -----------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE cdid_sitc (
    	CDID CHAR(4) NOT NULL COLLATE 'utf8_unicode_ci',
    	MTC SMALLINT(5) UNSIGNED NOT NULL,
    	CTA TINYINT(3) UNSIGNED NOT NULL,
    	IE TINYINT(3) UNSIGNED NOT NULL,
    	SITC CHAR(30) NOT NULL COMMENT 'See *SITC* field in *SITCs* table' COLLATE 'utf8_unicode_ci',
    	UNIT CHAR(10) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (CDID),
    	INDEX (SITC),
    	INDEX (CTA),
    	INDEX (IE),
    	INDEX (MTC),
    	INDEX (UNIT)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# SITC ----------------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE sitc (
    	SITC CHAR(30) NOT NULL COLLATE 'utf8_unicode_ci',
    	description CHAR(60) NOT NULL COLLATE 'utf8_unicode_ci',
    	parent CHAR(30) NULL DEFAULT NULL COLLATE 'utf8_unicode_ci',
    	ordering SMALLINT(5) UNSIGNED NOT NULL,
    	level TINYINT(1) UNSIGNED NOT NULL,
    	PRIMARY KEY (SITC),
    	INDEX (parent),
    	INDEX (ordering),
    	INDEX (level)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# LOOKUPS ----------------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE lookups (
    	domain_id CHAR(3) NOT NULL COLLATE 'utf8_unicode_ci',
    	lookup_id CHAR(3) NOT NULL COLLATE 'utf8_unicode_ci',
    	description CHAR(30) NOT NULL COLLATE 'utf8_unicode_ci',
    	PRIMARY KEY (domain_id, lookup_id),
    	INDEX (domain_id),
    	INDEX (lookup_id)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# CALENDAR ----------------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE calendar (
    	dm_id SMALLINT(3) UNSIGNED NOT NULL COMMENT 'id for the month',
    	dmn MEDIUMINT(6) UNSIGNED NOT NULL COMMENT 'month in numeric format YYYYMM',
    	dmc CHAR(8) NOT NULL COMMENT 'month in text format MMM YYYY' COLLATE 'utf8_unicode_ci',
    	dq_id TINYINT(3) UNSIGNED NOT NULL COMMENT 'id for the quarter',
    	dqn SMALLINT(5) UNSIGNED NOT NULL COMMENT 'quarter in numeric format YYYYQ',
    	dqc CHAR(6) NOT NULL COMMENT 'quarter in text format YYYYQ' COLLATE 'utf8_unicode_ci',
    	dy SMALLINT(4) UNSIGNED NOT NULL,
    	INDEX (dm_id),
    	INDEX (dq_id),
    	INDEX (dy)
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)


## Clean & Exit -------------------------------------------------------------------------------------------------------
dbDisconnect(dbc)
rm(list = ls())
gc()
