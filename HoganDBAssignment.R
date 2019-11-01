library(tidyverse)
library(magrittr)

library(RSQLite)
library(DBI)

contrib_all <- read.csv("Direct Contributions & JFC Dist-Table 1.csv",header=T,na.strings="NA")

JFC <- read.csv("JFC Contributions (DO NOT SUM W-Table 1.csv",header=T,na.strings="NA")

contrib_all <- apply(contrib_all,2,toupper)
contrib_all <- as.data.frame(contrib_all)

# Thank you Harry for this idea!
contrib_all$contrib <- gsub(", ", "/", contrib_all$contrib)
contrib_all$contrib <- sub(" .+","",contrib_all$contrib)
contrib_all$contrib <- sub(",.+","",contrib_all$contrib)
contrib_all$contrib <- sub("/",", ",contrib_all$contrib)
contrib_all$contrib <- sub("/","",contrib_all$contrib)

families <- select(contrib_all, contribid, fam, contrib, lastname)
families <- families[grep(",",families$contrib),]
families %<>% group_by(contribid,fam) %>% slice(which.min(nchar(as.character(contrib)))) %>% distinct()
test <- families %>% select(contribid,fam) %>% distinct()

contributions <- select(contrib_all, fectransid, recipid, contribid, fam, date, amount)
contributions %<>% distinct()

contributors <- select(contrib_all, contribid, fam, City, 
                       State, Zip, Fecoccemp, orgname)
contributors %<>% distinct()

org <- select(contrib_all, Fecoccemp, orgname, ultorg)
org %<>% distinct()

cycles <- select(contrib_all,date,cycle)
cycles %<>% distinct()

recipient <- select(contrib_all, recipid, recipient, type, party, recipcode, cmteid)
recipient %<>% distinct()

assignmentdb <- dbConnect(SQLite(), "tim-db.sqlite",ov)
dbWriteTable(assignmentdb, "contributions", contributions)
dbWriteTable(assignmentdb, "contributors",contributors)
dbWriteTable(assignmentdb, "org", org)
dbWriteTable(assignmentdb, "families",families)
dbWriteTable(assignmentdb, "cycles",cycles)
dbWriteTable(assignmentdb,"recipient", recipient)
dbDisconnect(assignmentdb)


#length(unique(JFC$ultorg))

#common <- intersect(contrib_all$orgname,JFC$orgname)
#length(common)
#length(common) - length(unique(JFC$orgname))

#common2 <- intersect(contrib_all$Fecoccemp,JFC$Fecoccemp)
#length(common2)
#length(common2) - length(unique(JFC$Fecoccemp))

#common3 <- intersect(contrib_all$ultorg,JFC$ultorg)
#length(common3)
#length(common3) - length(unique(JFC$ultorg))

