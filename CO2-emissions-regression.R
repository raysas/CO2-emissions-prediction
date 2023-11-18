## -----------------------------------------------------------------------------
library(tidyverse) #ggplot and dyplr are loaded with tidyverse


## -----------------------------------------------------------------------------
  df <- read.csv("MY2023 Fuel Consumption Ratings.csv", header = TRUE)
  #head(df, n = 3) #viewing the first 3 rows


## -----------------------------------------------------------------------------
print(paste("number of columns:", ncol(df) ,"; number of rows:", nrow(df)))


## -----------------------------------------------------------------------------
#head(is.na(df),n=2) # checks if our dataset contains missing values, hid cz output is too large
#summary(df) # checks how many NA we do have
#the output is hidden becuase it's huge


## -----------------------------------------------------------------------------
df <- subset(df, select = !apply(is.na(df), 2, any)) 
print(paste("number of columns after:", ncol(df))) #removes all the columns containing missing values


## -----------------------------------------------------------------------------
head(df, n=2)


## -----------------------------------------------------------------------------
print(df[832:836,])


## -----------------------------------------------------------------------------
df <- df[2:834,]
print(paste("number of rows after:", nrow(df)))


## -----------------------------------------------------------------------------
# Check for duplicate rows
has_duplicates <- any(duplicated(df) | duplicated(df, fromLast = TRUE))
if (has_duplicates) {
  print("The dataset contains at least two rows with the same information.")
} else {
  print("The dataset does not contain two rows with the same information. The dataset has no duplicate rows")
}


## -----------------------------------------------------------------------------
colnames(df)


## -----------------------------------------------------------------------------
new_names <- c("model_year", "car_make", "model_name", "vehicle_class", "engine_size", "transmission", "fuel_type", "city_consumption", "hwy_consumption", "mix_consumption", "mix_consumption_2", "CO2_emission", "CO2_rate", "smog_rate" ) 

colnames(df) <- new_names
colnames(df)


## -----------------------------------------------------------------------------
glimpse(df) #checks what type of data each feature is 


## -----------------------------------------------------------------------------
df <- transform(df, 
                      engine_size=as.numeric(engine_size),
                      city_consumption=as.numeric(city_consumption),
                      hwy_consumption=as.numeric(hwy_consumption),
                      mix_consumption=as.numeric(mix_consumption),
                      mix_consumption_2=as.numeric(mix_consumption_2),
                      CO2_emission=as.numeric(CO2_emission),
                      CO2_rate=as.factor(CO2_rate),
                      smog_rate=as.factor(smog_rate)
                    )
glimpse(df) #checks the data type after conversion


## -----------------------------------------------------------------------------
unique(df$model_year)


## -----------------------------------------------------------------------------
df <- subset(df, select = - model_year)


## -----------------------------------------------------------------------------
df <- subset(df, select = - mix_consumption_2)


## -----------------------------------------------------------------------------
unique(df$vehicle_class)


## -----------------------------------------------------------------------------
unique(df$transmission)


## -----------------------------------------------------------------------------
df <- mutate(df, vehicle_size_category = case_when(
  vehicle_class == "Full-size" ~ "Large",
  vehicle_class == "SUV: Standard" ~ "Medium",
  vehicle_class == "Mid-size" ~ "Medium",
  vehicle_class == "Minicompact"~ "Small",
  vehicle_class == "SUV: Small"~"Small",
  vehicle_class == "Compact"~"Small",
  vehicle_class == "Two-seater"~"Special",
  vehicle_class == "Subcompact"~"Small",
  vehicle_class == "Station wagon: Small"~"Small",
  vehicle_class == "Station wagon: Mid-size"~"Medium",
  vehicle_class == "Pickup truck: Small"~"Small",
  vehicle_class == "Pickup truck: Standard"~"Medium",
  vehicle_class == "Special purpose vehicle"~"Special",
  vehicle_class == "Minivan"~"Small"
))


df <- mutate(df, transmission_type_category = case_when(
  grepl("^A", df$transmission) ~ "Automatic",
  grepl("^M", df$transmission) ~ "Manual",
))

colnames(df)


## -----------------------------------------------------------------------------
df <- subset(df, select = - CO2_rate)
df <- subset(df, select = - smog_rate)


## -----------------------------------------------------------------------------
colnames(df)


## -----------------------------------------------------------------------------
outliers <- vector()
q1 <- quantile(df$CO2_emission, 0.25)
q3 <- quantile(df$CO2_emission, 0.75)

for (i in 1:nrow(df)) {
  lower_bound <- q1 - 3 * IQR(df$CO2_emission) #extreme outliers because why not :p
  upper_bound <- q3 + 3 * IQR(df$CO2_emission)

  if (df$CO2_emission[i] < lower_bound | df$CO2_emission[i] > upper_bound) {
    outliers <- append(outliers, i) #app if its lower or upper than the limits
    print(df[i,])
  }
}




## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_boxplot(mapping = aes(x=vehicle_size_category, y=CO2_emission, fill=vehicle_size_category))+
  theme(axis.text.x = element_blank())


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_boxplot(mapping = aes(x=transmission_type_category, y=CO2_emission, fill=transmission_type_category))+
  theme(axis.text.x = element_blank())


## -----------------------------------------------------------------------------
ggplot(data =df) + geom_density(mapping = aes(x = CO2_emission, fill =transmission_type_category, alpha = 0.25))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_boxplot(mapping = aes(x=transmission, y=CO2_emission, fill=transmission))+
  theme(axis.text.x = element_blank())


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_boxplot(mapping = aes(x=fuel_type, y=CO2_emission, fill=fuel_type))


## -----------------------------------------------------------------------------
ggplot(data =df) + geom_density(mapping = aes(x = CO2_emission, fill =fuel_type, alpha = 0.25))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_point(mapping= aes(x=engine_size, y=CO2_emission, fill=engine_size))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_point(mapping= aes(x=engine_size, y=CO2_emission, color=fuel_type))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_point(mapping= aes(x=engine_size, y=CO2_emission, color=transmission_type_category))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_point(mapping= aes(x=engine_size, y=CO2_emission, color=vehicle_size_category))


## -----------------------------------------------------------------------------
ggplot(data=df) +
  geom_point(mapping = aes(x=mix_consumption, y=CO2_emission, color=fuel_type)) +
  facet_wrap(~ fuel_type, nrow=2)


## -----------------------------------------------------------------------------
pairs(~engine_size+city_consumption+hwy_consumption+mix_consumption+CO2_emission, df, col = "#009ACD")

corr_matrix <- cor(df[, c("engine_size","city_consumption", "hwy_consumption", "mix_consumption", "CO2_emission")])
pal <- colorRampPalette(c("#b3cde0", "#6497b1" ,"#011f4b"))(100)
heatmap(cor(corr_matrix), col=pal)




## -----------------------------------------------------------------------------
slr_engine_model <- lm(CO2_emission ~ engine_size, data=df)
summary(slr_engine_model)


## -----------------------------------------------------------------------------
plot(df$engine_size, df$CO2_emission, xlab = "engine_size", ylab= "CO2 emitted", col= "#6aaa96", pch=20)
abline(slr_engine_model, col="#de425b", lwd=3, lty=1)


## -----------------------------------------------------------------------------
slr_vehicle_model <- lm(CO2_emission ~ vehicle_class, data=df)
summary(slr_vehicle_model)


## -----------------------------------------------------------------------------
#plot(df$vehicle_class, df$CO2_emission, xlab = "vehicle type", ylab= "CO2 emitted", col= "#6aaa96", pch=20)
#abline(slr_vehicle_model, col="#de425b", lwd=3, lty=1)


## -----------------------------------------------------------------------------
full_model <- lm(CO2_emission ~ ., data = df)
final <- step(full_model, direction = "backward")


## -----------------------------------------------------------------------------
summary(final)


## -----------------------------------------------------------------------------
int_engine_fuel_model <- lm(CO2_emission ~ engine_size*fuel_type, data = df)
summary(int_engine_fuel_model)


## -----------------------------------------------------------------------------
int_mix_fuel_model <- lm(CO2_emission ~ mix_consumption*fuel_type, data = df)
summary(int_mix_fuel_model)


## -----------------------------------------------------------------------------
multi_model <- lm(CO2_emission ~ engine_size*fuel_type + mix_consumption*fuel_type, data = df)

# View the summary of the model
summary(multi_model)


## -----------------------------------------------------------------------------
# Compute the residuals
residuals <- resid(slr_engine_model)

# Create a scatterplot of residuals against the fitted values
plot(fitted(slr_engine_model), residuals,
     xlab = "Fitted Values",
     ylab = "Residuals",
     main = "Residual Plot",
     pch = 19) 

# Add a Lowess curve to the plot
lines(lowess(fitted(slr_engine_model), residuals), col = "blue")


## -----------------------------------------------------------------------------
pol_engine_model <- lm(CO2_emission ~ poly(engine_size, 3), data=df)
summary(pol_engine_model)
#plot(df$engine_size, df$CO2_emission, xlab = "engine_size", ylab= "CO2 levels", col= "#B9BDC1", pch=20)

