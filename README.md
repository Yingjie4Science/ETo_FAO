# ETo_FAO
A demo function to calculate Reference evapotranspiration (ETo) according to FAO standards.

FAO Penman-Monteith equation, see details at http://www.fao.org/docrep/x0490e/x0490e06.htm (BOX 6)


## code:
  - `ET_cal_demo.R` is the final code file

## data:
  - folder named '1960-2016' is a collection of meteorological data for 
    519 stations in China


### variables
cols <- c('id', 'yy', 'mm', 'dd', 'pre_night', 'pre_day', 'pre', 
          'tem', 'tmax', 'tmin', 't_groundmean','t_groundmax', 't_groundmin', 
          'Tsun', 'wind', 'RH', 'evap_pan', 'long', 'lat', 'h')
```
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
```


**Citation** 
```
李英杰,延军平,王鹏涛.北方农牧交错带参考作物蒸散量时空变化与成因分析[J].中国农业气象,2016,37(2):166-173

Li, Yingjie., Yan, Junping., Wang, Pengtao. Temporal and spatial change and causes analysis of the reference crop evapotranspiration in Farming-Pastroral Ecotone of Northern China. Chinese Journal of Agrometeorology, 2016, 37(2):166-173.(in Chinese) 
```
