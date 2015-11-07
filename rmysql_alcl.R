# The following code takes the CMS 2014 General Payments Details file, 5.5 GB,
# and splits it into smaller tables related by a primary key.

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

# This table provides information on the physician involved with each financial transaction

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

genpay_phys <- fread("CMS 2014/CMS 2014 General Payments Details.csv", 
                     colClasses = c("NULL", "character", "NULL", "character", rep("NULL", 6),
                                    rep("character", 8), rep("NULL", 25), "character", 
                                    rep("NULL", 19)))

# Remove the 40,000-odd rows that refer to payments made to teaching hospitals
genpay_phys <- genpay_phys[Teaching_Hospital_ID == "", ]
genpay_phys[, Teaching_Hospital_ID := NULL] # Drop the Teaching_Hospital_ID column

# Ad hoc function to write genpay_phys to a new .csv file, in chunks
write_genpay <- function(d) {
  for(i in 0:106) {
    write.table(d[((i * 100000) + 1):((i + 1) * 100000)], 
                "CMS 2014 General Payments Details - Physician Info.csv", append = TRUE, sep = ",", row.names = FALSE)
  }
  write.table(d[10700001:10768319, ], 
              "CMS 2014 General Payments Details - Physician Info.csv", append = TRUE, sep = ",", row.names = FALSE)
}

write_genpay(genpay_phys) # Write the physician info table to disk
rm(genpay_phys)

# This table provides information on the teaching hospital involved with each financial transaction

# Variable details:

# Teaching_Hospital_ID: Unique ID for teaching hospital that received payment
# Teaching_Hospital_Name: Name of teaching hospital that received payment
# Recipient_City: City where physician primarily practices
# Recipient_State: State where physician primarily practices
# Recipient_Zip_Code: 9-digit zip code for location of physician's primary practice
# Record_ID: Unique ID for each financial transaction

genpay_th <- fread("CMS 2014/CMS 2014 General Payments Details.csv",
                    colClasses = c("NULL", rep("character", 2), rep("NULL", 7), 
                                    rep("character", 3), rep("NULL", 30), "character", 
                                    rep("NULL", 19)))

genpay_th <- genpay_th[Teaching_Hospital_ID != "", ]

# Write the teaching hospital info table to disk
write.csv(genpay_th, "CMS 2014 General Payments Details - Teaching Hospitals Info.csv", row.names = FALSE)
rm(genpay_th)

# This table provides information about the financial transactions themselves

# Teaching_Hospital_ID: Unique ID for teaching hospital that received payment
# Physician_Profile_ID: Unique ID for physician receiving payment
# Total_Amount_of_Payment_USDollars: Payment amount in USD; if in foreign currency, converted to USD
# Date_of_Payment: Date of payment (if many payments, date of first payment)
# Number_of_Payments_Included_in_Total_Amount: Number of discrete payments
# Form_of_Payment_or_Transfer_of_Value: Method of payment (e.g. cash? in-kind?)
# Nature_of_Payment_or_Transfer_of_Value: Nature of payment (e.g. consulting fee?)
# Record_ID: Unique ID for each financial transaction

genpay_trans <- fread("CMS 2014/CMS 2014 General Payments Details.csv",
                      colClasses = c("NULL", "character", "NULL", "character", 
                                     rep("NULL", 24), rep("character", 5), rep("NULL", 10), 
                                     "character", rep("NULL", 19)))

# Ad hoc function to write genpay_trans and genpay_manuGPO to a new .csv file, in chunks

write_genpay2 <- function(d) {
  for(i in 0:107) {
    write.table(d[((i * 100000) + 1):((i + 1) * 100000)], 
                "CMS 2014 General Payments Details - Transaction Info.csv", append = TRUE, sep = ",", row.names = FALSE)
  }
  write.table(d[10800001:10818054, ], 
              "CMS 2014 General Payments Details - Transaction Info.csv", append = TRUE, sep = ",", row.names = FALSE)
}

write_genpay2(genpay_trans)

# This table provides information about manufacturers and Group Purchasing Organizations (GPOs) per
# transaction

# Submitting_Applicable_Manufacturer_or_Applicable_GPO_Name: Manufacturer/GPO who submitted payment
# Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_ID: ID of Manufacturer/GPO who made payment
# Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Name
# Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_State
# Applicable_Manufacturer_or_Applicable_GPO_Making_Payment_Country

genpay_manuGPO <- fread("CMS 2014/CMS 2014 General Payments Details.csv", 
                        colClasses = c(rep("NULL", 23), rep("character", 5), 
                                       rep("NULL", 15), "character", rep("NULL", 19)))

write_genpay3 <- function(d) {
  for(i in 0:107) {
    write.table(d[((i * 100000) + 1):((i + 1) * 100000)], 
                "CMS 2014 General Payments Details - Manufacturer and GPO Info.csv", append = TRUE, sep = ",", row.names = FALSE)
  }
  write.table(d[10800001:10818054, ], 
              "CMS 2014 General Payments Details - Manufacturer and GPO Info.csv", append = TRUE, sep = ",", row.names = FALSE)
}

write_genpay3(genpay_manuGPO)

# Table of physicians and state licenses

genpay_license <- fread("CMS 2014/CMS 2014 General Payments Details.csv", 
                        colClasses = c(rep("NULL", 3), "character", rep("NULL", 14), 
                                       rep("character", 5), rep("NULL", 40)))

genpay_license <- unique(genpay_license)

write.csv(genpay_license, "CMS 2014 General Payments Details - License Info.csv", row.names = FALSE)

# Table of product information associated with each financial transaction

genpay_prod <- fread("CMS 2014/CMS 2014 General Payments Details.csv",
                     colClasses = c(rep("NULL", 43), "character", "NULL", rep("character", 16), 
                                    rep("NULL", 2)))

write_genpay4 <- function(d) {
  for(i in 0:107) {
    write.table(d[((i * 100000) + 1):((i + 1) * 100000)], 
                "CMS 2014 General Payments Details - Product Info.csv", append = TRUE, sep = ",", row.names = FALSE)
  }
  write.table(d[10800001:10818054, ], 
              "CMS 2014 General Payments Details - Product Info.csv", append = TRUE, sep = ",", row.names = FALSE)
}

write_genpay4(genpay_prod)
