library(tidyverse)
library(magrittr)

library(RSQLite)
library(DBI)

contrib_all <- read.csv("Direct Contributions & JFC Dist-Table 1.csv",header=T,na.strings="NA")

contributors <- select(contrib_all, date, contrib, City, 
                       State, Zip, Fecoccemp, orgname)
contributors %<>% distinct()

families <- select(contrib_all, contrib, contribid, fam, lastname)
families %<>% distinct()

org <- select(contrib_all, orgname, ultorg)
org %<>% distinct()

cycles <- select(contrib_all,date,cycle)
cycles %<>% distinct()

contributions <- select(contrib_all, fectransid, recipid, contrib, date, amount)
contributions %<>% distinct()

recipient <- select(contrib_all, recipid, recipient, type, party, recipcode, cmteid)
recipient %<>% distinct()

parties <- select(contrib_all,party,recipcode)
parties %<>% distinct()

assignmentdb <- dbConnect(SQLite(), "tim-db.sqlite")
dbWriteTable(assignmentdb, "org", org)
dbWriteTable(assignmentdb, "contributors",contributors)
dbWriteTable(assignmentdb, "families",families)
dbWriteTable(assignmentdb, "cycles",cycles)
dbWriteTable(assignmentdb, "contributions", contributions)
dbWriteTable(assignmentdb,"recipient", recipient)
dbWriteTable(assignmentdb, "parties", parties)
dbDisconnect(assignmentdb)



