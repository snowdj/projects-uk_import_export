#######################################################################
# 11 - UK IMPORT EXPORT - Load <mq10>: by classification of product
#######################################################################

# load packages
pkg <- c('data.table', 'RMySQL')
invisible(lapply(pkg, require, character = TRUE))

# retrieve data directly from ONS
dt <- fread(
        'https://www.ons.gov.uk/file?uri=/businessindustryandtrade/internationaltrade/datasets/uktradeingoodsbyclassificationofproductbyactivity/current/mq10.csv',
        skip = 1        
)

# delete all rows not quarters data
dt <- dt[grep('Q', CDID)]

# recode quarter as numeric yyyyq
dt[, CDID := as.numeric(gsub('[^0-9]', '', CDID)) ]

# convert to long type
dt <- melt.data.table(dt, 'CDID', variable.factor = FALSE, na.rm = TRUE)

# rename molten table
setnames(dt, c('datefield', 'cdid', 'value'))

# delete NA values 
dt <- dt[!is.na(value)]

# save table
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_import_export')
dbSendQuery(dbc, "TRUNCATE TABLE mq10")
dbWriteTable(dbc, 'mq10', dt[order(datefield, cdid)], append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# clean and exit
rm(list = ls())
gc()
