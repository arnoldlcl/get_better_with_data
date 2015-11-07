setwd("D:/GBWD")

library(data.table) # The fread() function in the data.table library is much faster than read.csv(),
                    # though it returns an object of class "data.table" rather than "data.frame"
                    # so the syntax for subsetting, etc. will be different

# Read the following columns of the General Payments Details .csv file:
# Teaching_Hospital_ID, Physician_Profile_ID, Recipient_City, Recipient_State,
# Recipient_Zip_Code, Recipient_Country, Recipient_Province, Recipient_Postal_Code,
# Physician_Primary_Type, Physician_Specialty, Record_ID

# Record_ID will serve as the primary key
# Teaching_Hospital_ID is only in the table so we can subset: it'll be deleted later on

# Variable details:

# Physician_Profile_ID: Unique ID for physician receiving payment
# Recipient_City: City where physician primarily practices
# Recipient_State: State where physician primarily practices
# Recipient_Zip_Code: 9-digit zip code for location of physician's primary practice
# Recipient_Country: Country where physician primarily practices
# Recipient_Province: If Recipient_Country is NOT "United States": Province of physician's practice
# Recipient_Postal_Code: If Recipient_Country is NOT "United States": Postal code for location of practice
# Physician_Primary_Type: Primary type of medicine practiced by physician
# Physician_Specialty: Specialty of physician. Not all physicians have a specialty
# Record_ID: Unique ID for each financial transaction

genpay_physinfo <- fread("CMS 2014/CMS 2014 General Payments Details.csv", 
                         colClasses = c("NULL", "character", "NULL", "character", rep("NULL", 6),
                                        rep("character", 8), rep("NULL", 25), "character", 
                                        rep("NULL", 19)))

# Remove the 40,000-odd rows that refer to payments made to teaching hospitals
genpay_physinfo <- genpay_physinfo[Teaching_Hospital_ID == "", ]
genpay_physinfo[, Teaching_Hospital_ID := NULL] # Drop the Teaching_Hospital_ID column

write_genpay_phys <- function(genpay_phys) {
  for(i in 1:107) {
    write.table(genpay_phys[i:(i + 99999), ], "CMS 2014 General Payments Details - Physician Info.csv", append = TRUE, sep = ",")
  }
}

genpay_phys_jan <- genpay_phys[grep("01/", genpay_phys$Date_of_Payment), ]
genpay_phys_feb <- genpay_phys[grep("02/", genpay_phys$Date_of_Payment), ]
genpay_phys_mar <- genpay_phys[grep("03/", genpay_phys$Date_of_Payment), ]
genpay_phys_apr <- genpay_phys[grep("04/", genpay_phys$Date_of_Payment), ]
genpay_phys_may <- genpay_phys[grep("05/", genpay_phys$Date_of_Payment), ]
genpay_phys_jun <- genpay_phys[grep("06/", genpay_phys$Date_of_Payment), ]
genpay_phys_jul <- genpay_phys[grep("07/", genpay_phys$Date_of_Payment), ]
genpay_phys_aug <- genpay_phys[grep("08/", genpay_phys$Date_of_Payment), ]
genpay_phys_sep <- genpay_phys[grep("09/", genpay_phys$Date_of_Payment), ]
genpay_phys_oct <- genpay_phys[grep("10/", genpay_phys$Date_of_Payment), ]
genpay_phys_nov <- genpay_phys[grep("11/", genpay_phys$Date_of_Payment), ]
genpay_phys_dec <- genpay_phys[grep("12/", genpay_phys$Date_of_Payment), ]

genpay_1000$Date_of_Payment <- as.Date(genpay_1000$Date_of_Payment, "%m/%d/%Y")


library(RMySQL)
conn_cms <- dbConnect(MySQL(), user = "data_hacker", 
                      host = "health-db-internet.c6clocfz5zxy.us-east-1.rds.amazonaws.com",
                      password = "hack_pw",
                      port = 3306)

# Select all rows where payment was made to physicians
phys_jan <- dbGetQuery(conn_cms, "select cms2014.Physician_Profile_ID, cms2014.Physician_First_Name,
                                         cms2014.Physician_Middle_Name, cms2014.Physician_Last_Name,
                                         cms2014.Physician_Name_Suffix, cms2014.Recipient_Zip_Code,
                                         cms2014.Physician_Primary_Type, cms2014.Physician_Specialty
                                  from CMS_open_payments_2014.general_payment_data cms2014
                                  where cms2014.Teaching_Hospital_ID IS NULL
                                  and cms2014.Date_of_Payment LIKE '01/%';")

write.csv(teaching_hospitals, "CMS 2014 General Payments - Teaching Hospitals.csv")

dbDisconnect(conn_cms)
rm(conn_cms)
