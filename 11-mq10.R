#######################################################################
# 11 - UK IMPORT EXPORT - Load <mq10>: by classification of product
#######################################################################

# load packages
pkg <- c('data.table', 'RMySQL')
invisible(lapply(pkg, require, character = TRUE))

# retrieve data directly from ONS
dts <- fread(
        'https://www.ons.gov.uk/file?uri=/businessindustryandtrade/internationaltrade/datasets/uktradeingoodsbyclassificationofproductbyactivity/current/mq10.csv',
        skip = 1        
)

# delete all rows not quarters data
dts <- dts[grep('Q', CDID)]

# recode quarter as numeric yyyyq
dts[, CDID := as.numeric(gsub('[^0-9]', '', CDID)) ]

# convert to long type
dts <- melt.data.table(dts, 'CDID', variable.factor = FALSE, na.rm = TRUE)

# rename molten table
setnames(dts, c('datefield', 'cdid', 'value'))

# delete NA values 
dts <- dts[!is.na(value)]

# save table
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_import_export')
dbSendQuery(dbc, "TRUNCATE TABLE mq10")
dbWriteTable(dbc, 'mq10', dts[order(datefield, cdid)], append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# clean and exit
rm(list = ls())
gc()
