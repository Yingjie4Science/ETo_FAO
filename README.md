# ETo_FAO
A demo function to calculate Reference evapotranspiration (ETo) according to FAO standards.


## code:
  - ET_cal_demo.R is the final code file

## data:
  - folder named '1960-2016' is a collection of meteorological data for 
    519 stations in China


### variables
cols <- c('id', 'yy', 'mm', 'dd', 'pre_night', 'pre_day', 'pre', 
          'tem', 'tmax', 'tmin', 't_groundmean','t_groundmax', 't_groundmin', 
          'Tsun', 'wind', 'RH', 'evap_pan', 'long', 'lat', 'h')

id: station id
yy: year
mm: month
dd: day
pre: precipitation; (mm)
tem: temperature; ()
tmax: max tem
tmin: min tem
t_groundmen: tem at ground level
Tsun: sunshine hours; (h)
wind: wind speed; (m/s)
RH: Relative humidity; (%)
evap_pan: evaporation measured in evaporation pan (mm)
long: longitude
lat: latitude
h: elevation; (m)
