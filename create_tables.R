###############################################################
# 01- CREATE TABLES IN DATABASE <uk_import_export>
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
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)

# SITC ----------------------------------------------------------------------------------------------------------------
strSQL = "
    CREATE TABLE sitc (
    ) COLLATE='utf8_unicode_ci' ENGINE=MyISAM ROW_FORMAT=FIXED;
"
dbSendQuery(dbc, strSQL)


## Clean & Exit -------------------------------------------------------------------------------------------------------
dbDisconnect(dbc)
rm(list = ls())
gc()
