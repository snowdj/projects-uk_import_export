##################################################################################################
# 31 - UK IMPORT EXPORT - Convert summary tables in fst format for quick access from Shiny apps
##################################################################################################

# load packages
pkg <- c('data.table', 'fst', 'RMySQL')
invisible(lapply(pkg, require, character = TRUE))

# retrieve initial tables from database
appname <- 'uk_import_export'
dbc <- dbConnect(MySQL(), group = 'dataOps', dbname = appname)
mr <- data.table( dbReadTable(dbc, 'mret'), key = 'datefield', stringsAsFactors = TRUE)
mq <- data.table( dbReadTable(dbc, 'mq10'), key = 'datefield')
dbDisconnect(dbc)

mr[, `:=`(datefield = factor(datefield, order = TRUE), cdid = factor(cdid))]
mq[, `:=`(datefield = factor(datefield, order = TRUE), cdid = factor(cdid))]

# add time variables


# recode data


# save  
fst.path <- '/usr/local/share/data/bin/shiny/'
write.fst(mr, paste0(fst.path, appname, '/mr.fst'), 100 )
write.fst(mq, paste0(fst.path, appname, '/mq.fst'), 100 )
