test <- read.csv("PGYR14_P063015/OP_DTL_GNRL_PGYR2014_P06302015.csv", nrow = 100)

install.packages("RMySQL")

library(RMySQL)
conn_cms <- dbConnect(MySQL(), user = "data_hacker", 
                      host = "health-db-internet.c6clocfz5zxy.us-east-1.rds.amazonaws.com",
                      password = "hack_pw",
                      port = 3306)

teaching_hospitals <- dbGetQuery(conn_cms, "select *
                                 from CMS_open_payments_2014.general_payment_data cms2014
                                 where cms2014.Teaching_Hospital_ID IS NOT NULL;")

write.csv(teaching_hospitals, "CMS 2014 General Payments - Teaching Hospitals.csv")

dbDisconnect(conn_cms)
rm(conn_cms)
