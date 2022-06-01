
# -------------------------------------------------- #
# -------------------------------------------------- #
# Calcualte ETo using FAO Penman-Monteith equation   #
# -------------------------------------------------- #
#                    Yingjie Li                      #
#     liyj@msu.edu; Yingjieli.edu@gmail.com          #
#               https://yingjieli.me/                #
#           Last update: 2018-09-22 10:01            #
# -------------------------------------------------- #
# -------------------------------------------------- #


remove(list = ls())
init <- Sys.time()

# ---- parallel ----
myCluster <- makeCluster(3, type = "PSOCK") # 3: number of cores to use; # type of cluster
detectCores()
registerDoParallel(myCluster)

library(readxl)
library(dplyr)
library(zoo)


# set work dir
path <- rstudioapi::getSourceEditorContext()$path
wddir  <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(wddir)

# header of txt files
cols <- c('id', 'yy', 'mm', 'dd', 'pre_night', 'pre_day', 'pre', 
          'tem', 'tmax', 'tmin', 't_groundmean','t_groundmax', 't_groundmin', 
          'Tsun', 'wind', 'RH', 'evap_pan', 'long', 'lat', 'h')
# elements for ET caculation
cols_ET <- c('id', 'yy', 'mm', 'dd', 'tmax', 'tmin', 'RH', 'wind', 'Tsun',
             'long', 'lat', 'h')
# read data
dayid  <- './dayid.xlsx'
sheet = "dayid"
days = read_excel(path = dayid, sheet = sheet, col_names = T)
names(days)
days$date <- apply(days[, 1:3], 1, paste0, collapse="-")
days$date <- as.Date(days$date)
str(days)

# ----------------------------------------------- #
# - function for cal ET0 
# ----------------------------------------------- #
ET_cal <- function(df) {
  dt0 = read.table(file = df, header = F,  
                    sep="", 
                    col.names=cols, fill = T,
                    strip.white=TRUE)
  dt1 <- dt0[, cols_ET]
  dt1$date <- apply(dt1[, 2:4], 1, paste0, collapse="-")
  dt1$date <- as.Date(dt1$date)
  
  # using the same units  
  dt2 <- dt1 %>%
    filter(yy >= 1965) %>%
    mutate(tmax_approx = na.approx(tmax) *10, # 0.1 Celsius
           tmin_approx = na.approx(tmin) *10, # 0.1 Celsius
           rh_a        = na.approx(RH),       # 1%
           wind_a      = na.approx(wind) *10, # 0.1 m/s
           Tsun_approx = na.approx(Tsun) *10) # 0.1 h
  
  # select cols you r going to use
  cols_select <- c('id', 'yy', 'mm', 'dd', 'tmax_approx', 'tmin_approx', 'rh_a', 'wind_a', 'Tsun_approx',
                   'long', 'lat', 'h')
  # rename col names
  cols_rename <- c('id', 'yy', 'mm', 'dd', 'tmax', 'tmin', 'rh', 'wind', 'tsun',
                   'long', 'lat', 'h')
  dt3 <- dt2[, cols_select]
  names(dt3) <- cols_rename
  
  # create a date col
  dt3$date <- apply(dt3[, 2:4], 1, paste0, collapse="-")
  dt3$date <- as.Date(dt3$date)
  
  # add the dayid col into dataframe
  dt33 <- merge(x = dt3, y = days, by.x = 'date', by.y = 'date', all.x = TRUE)
  
  # degree to rad
  rad2deg <- function(rad) {(rad * 180) / (pi)}
  deg2rad <- function(deg) {(deg * pi) / (180)}
  
  # FAO Penman-Monteith equation to ETo
  # see details at http://www.fao.org/docrep/x0490e/x0490e06.htm (BOX 6)
  dt4 <- dt33 %>%
    mutate(Jd      = dayid,
           kpa     = 101.3*(((293-0.0065*h)/293)^(5.26)),
           lat_rad = deg2rad(lat), 
           r       = 1.013*kpa/1000/0.622/2.45,
           t       = (tmax+tmin)/2,
           es      = (exp(17.27*tmax*0.1/(237.3+tmax*0.1))*0.6108+exp(17.27*tmin*0.1/(237.3+tmin*0.1))*0.6108)/2,
           ea      = es*rh/100,
           delta_low = sin(2*3.1415927*Jd/365-1.39)*0.409,
           ws      = acos(-tan(lat_rad)*tan(delta_low)),
           N       = 24*ws/3.1415927,
           dr      = 1+0.033*cos(2*3.1415927*Jd/365),
           Ra      = (24*60*0.082*dr/3.1415926)*(ws*sin(lat_rad)*sin(delta_low)+cos(lat_rad)*cos(delta_low)*sin(ws)),
           Rs      = (0.25+0.5*tsun*0.1/N)*Ra,
           Rns     = (1-0.23)*Rs,
           Rso     = (0.75+2*(10)^(-5)*h)*Ra,
           Rnl     = -4.903*((10)^(-9))*(1.35*Rs/Rso-0.35)*(0.34-0.14*((ea)^(0.5)))*((tmax*0.1+273.2)^(4)+(tmin*0.1+273.2)^(4))/2,
           Rn      = Rnl + Rns,
           Delta_up= 4098*(0.6108*exp(17.27*t*0.1/(t*0.1+237.3)))/((t*0.1+237.3)^(2)),
           U2      = wind * 0.72, # U2 is the wind speed at 2m; should multiply 0.72 (empirical coefficient)to correct
           ET0     = (Delta_up*Rn*0.408+r*900*(4.87*(U2*0.1)/log(67.8*10-5.42))*(es-ea)/(t*0.1+273))/(Delta_up+r*(1+0.34*(4.87*(U2*0.1)/log(67.8*10-5.42))))
    )
  
  # output the results to wording dir
  wd <- './ET_result_hlj/'
  result.name <- paste(wd, 'ET_', df, ".csv", sep="")
  write.csv(dt4, file = result.name)
}

# ----------------------------------------------- #
# - stations within Heilongjaing 
# ----------------------------------------------- #

stations0 <- read.csv(file = './my_stations.csv',header = T)
stations <- as.character(unlist(stations0$files))

# ----------------------------------------------- #
# - loop over all files
# ----------------------------------------------- #
getwd()
# dir of climate data
wd_data <- './climate_data_591_1960-2016'
setwd(wd_data)
for (s in stations){
  print(paste0("[In processing] Current working on: ", s))
  ET_cal(s)
  print('Done!')
}

# total running time 
Sys.time() - init
# stop the cluster when you have finished
stopCluster(myCluster)


# ----------------------------------------------- #
# get all the results together
# ----------------------------------------------- #
wd.now <- getwd(); wd.now
wd.update <- paste(wd.now, '/ET_result_hlj', sep = ''); wd.update
setwd(wd.update)
myfiles = list.files(pattern="^ET_*");
myfiles
length(myfiles)

# --- test file
# test <- read.csv("ET_50353.csv")[, c(1:6, 12:14, 37)]

# rbind all the results to one file
file.list <- myfiles
ETo_all = do.call(rbind, lapply(file.list, function(x)
  read.csv(file = x)[, c(1:6, 12:14, 37)])
  )

