test <- read.csv("PGYR14_P063015/OP_DTL_GNRL_PGYR2014_P06302015.csv", nrow = 100)

install.packages("RMySQL")

library(RMySQL)
conn_cms <- dbConnect(MySQL(), user = "data_hacker", 
                      host = "health-db-internet.c6clocfz5zxy.us-east-1.rds.amazonaws.com",
                      password = "hack_pw",
                      port = 3306)

result <- dbGetQuery(conn_cms, "select distinct(cms2013.Recipient_State), avg(cms2013.Total_Amount_of_Payment_USDollars)
                                from CMS_open_payments_2013.general_payment_data cms2013
                                where cms2013.Physician_Specialty like '%Allopathic%'
                                group by cms2013.Physician_Specialty, cms2013.Recipient_State;")

result2 <- dbGetQuery(conn_cms, "select *
                                 from CMS_open_payments_2013.general_payment_data cms2013
                                 where cms2013.Teaching_Hospital_ID IS NOT NULL;")

dbDisconnect(conn_cms)
rm(conn_cms)
