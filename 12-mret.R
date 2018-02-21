##################################################################
# 12 - UK IMPORT EXPORT - Load <mret>: by area and commodity
##################################################################

# load packages
pkg <- c('data.table', 'RMySQL')
invisible(lapply(pkg, require, character = TRUE))

# retrieve data directly from ONS
dts <- fread(
        'https://www.ons.gov.uk/file?uri=/economy/nationalaccounts/balanceofpayments/datasets/tradeingoodsmretsallbopeu2013timeseriesspreadsheet/current/mret.csv',
        skip = 1
)

# delete all rows not monthly or without data
dts <- dts[nchar(CDID) == 8][substr(CDID, 1, 4) >= 1998]

# recode "date" as numeric yyyymm  
dts[, m := substr(CDID, 6, 8)][.(m = unique(m), to = 1:12), on = 'm', m := i.to][, CDID := paste0(substr(CDID, 1, 4), ifelse(nchar(m) == 1, '0', ''), m) ][, m := NULL]

# convert to long type
dts <- melt.data.table(dts, 'CDID', variable.factor = FALSE, na.rm = TRUE)

# rename molten table
setnames(dts, c('datefield', 'cdid', 'value'))

# delete NA values 
dts <- dts[!is.na(value)]

# save table
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = 'uk_import_export')
dbSendQuery(dbc, "TRUNCATE TABLE mret")
dbWriteTable(dbc, 'mret', dts[order(datefield, cdid)], append = TRUE, row.names = FALSE)
dbDisconnect(dbc)

# clean and exit
rm(list = ls())
gc()

