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

genpay_physinfo_p <- fread("CMS 2014/CMS 2014 General Payments Details.csv", 
                         colClasses = c("NULL", "character", "NULL", "character", rep("NULL", 6),
                                        rep("character", 8), rep("NULL", 25), "character", 
                                        rep("NULL", 19)))

# Remove the 40,000-odd rows that refer to payments made to teaching hospitals
genpay_physinfo_p <- genpay_physinfo_p[Teaching_Hospital_ID == "", ]
genpay_physinfo_p[, Teaching_Hospital_ID := NULL] # Drop the Teaching_Hospital_ID column

# Ad hoc function to write genpay_physinfo to a new .csv file, in chunks
write_genpay_physinfo <- function(d) {
  for(i in 1:107) {
    write.table(d[i:(i + 99999), ], 
                "CMS 2014 General Payments Details - Physician Info.csv", append = TRUE, sep = ",")
  }
  write.table(d[10700001:10768319, ], 
                "CMS 2014 General Payments Details - Physician Info.csv", append = TRUE, sep = ",")
}

write_genpay_physinfo(genpay_physinfo_p) # Write the physician info table to disk

# Read the following columns of the General Payments Details .csv file:
# Teaching_Hospital_ID, Teaching_Hospital_Name, Recipient_City, Recipient_State,
# Recipient_Zipcode, Record_ID

# Record_ID will serve as the primary key

# Variable details:

# Teaching_Hospital_ID: Unique ID for teaching hospital that received payment
# Teaching_Hospital_Name: Name of teaching hospital that received payment
# Recipient_City: City where physician primarily practices
# Recipient_State: State where physician primarily practices
# Recipient_Zip_Code: 9-digit zip code for location of physician's primary practice
# Record_ID: Unique ID for each financial transaction

genpay_physinfo_th <- fread("CMS 2014/CMS 2014 General Payments Details.csv",
                            colClasses = c("NULL", rep("character", 2), rep("NULL", 7), 
                                           rep("character", 3), rep("NULL", 30), "character", 
                                           rep("NULL", 19)))

genpay_physinfo_th <- genpay_physinfo_th[Teaching_Hospital_ID != "", ]

# Write the teaching hospital info table to disk
write.csv(genpay_physinfo_th, "CMS 2014 General Payments Details - Teaching Hospitals Info.csv")

