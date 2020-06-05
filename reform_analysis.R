require(dplyr)
require(tidyr)
require(rio)
require(ggplot2)
require(purrr)

policies <- rio::import('cantwait_data.csv')
deaths_raw <- rio::import('MPV_data.csv') %>%
              mutate(city=case_when(
                city=='St. Paul'~'St Paul',
                city=='Saint Paul'~'St Paul',
                city=='St. Petersburg'~'St Petersburg',
                city=='Saint Petersburg'~'St Petersburg',
                city=='St. Louis'~'St Louis',
                city=='Saint Louis'~'St Louis',
                city=='Arlington' & state!='TX'~'NA',
                city=='Aurora' & state!='CO'~'NA',
                city=='Austin' & state!='TX'~'NA',
                city=='Aurora' & state!='CO'~'NA',
                city=='Boston' & state!='MA'~'NA',
                city=='Buffalo' & state!='NY'~'NA',
                city=='Cleveland' & state!='OH'~'NA',
                city=='Columbus' & state!='OH'~'NA',
                city=='Dallas' & state!='TX'~'NA',
                city=='Durham' & state!='NC'~'NA',
                city=='Glendale' & state!='AZ'~'NA',
                city=='Greensboro' & state!='NC'~'NA',
                city=='Henderson' & state!='NV'~'NA',
                city=='Houston' & state!='TX'~'NA',
                city=='Jacksonville' & state!='FL'~'NA',
                city=='Kansas City' & state!='MO'~'NA',
                city=='Las Vegas' & state!='NV'~'NA',
                city=='Lexington' & state!='KY'~'NA',
                city=='Lincoln' & state!='NE'~'NA',
                city=='Louisville' & state!='KY'~'NA',
                city=='Madison' & state!='WI'~'NA',
                city=='Mesa' & state!='AZ'~'NA',
                city=='Miami' & state!='FL'~'NA',
                city=='Nashville' & state!='TN'~'NA',
                city=='Newark' & state!='NJ'~'NA',
                city=='Norfolk' & state!='VA'~'NA',
                city=='Orlando' & state!='FL'~'NA',
                city=='Phoenix' & state!='AZ'~'NA',
                city=='Portland' & state!='OR'~'NA',
                city=='Reno' & state!='NV'~'NA',
                city=='Rochester' & state!='NY'~'NA',
                city=='Stockton' & state!='CA'~'NA',
                TRUE~city
              ))
deaths_DOJ <- rio::import('custody_deaths.csv')
cities <- rio::import('policies_by_city.csv') %>%
          filter(state!='DC')


deaths <- deaths_raw %>%
          filter(city %in% c(cities$city)) %>%
          mutate(date=as.Date(date, format='%m/%d/%y'))

breakdown <- table(deaths$city, deaths$victim_race)

original_study <- table(filter(deaths, date>='2016-01-01' & date <='2016-07-15')$city)

cities <- cities %>%
          mutate(all_deaths = purrr::map_dbl(city, function(i){
            if(i %in% rownames(breakdown)) return(sum(breakdown[i,]))
            0
            }),
            black_deaths = purrr::map_dbl(city, function(i){
              if(i %in% rownames(breakdown)) return(breakdown[i,'Black'])
              0
            }),
            deaths_original2016 = purrr::map_dbl(city, function(i){
              out <- original_study[i]
              if(is.na(out)) return(0)
              out
            }),
            row=1:nrow(.),
            policy_index = purrr::map_dbl(row, function(i){
              sum(cities[i,6:13])
            }))
            
ggplot(cities) +
  geom_jitter(aes(x=policy_index, 
                  group=policy_index,
                  y=all_deaths/pop2010)) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('per capita deaths by law enforcement', limits=c(0,1.3e-4))+
  theme_classic() +
  guides(fill=FALSE)

ggplot(cities) +
  geom_jitter(aes(x=policy_index, 
                  group=policy_index,
                  y=all_deaths/pop2010),
              width=0.2) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('per capita deaths by law enforcement')+
  theme_classic() +
  guides(fill=FALSE)

ggplot(cities) +
  geom_jitter(aes(x=policy_index, 
                  group=policy_index,
                  y=deaths_original2016/pop2010),
              width=0.2) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('per capita deaths by law enforcement')+
  theme_classic() +
  guides(fill=FALSE)

ggplot(cities) +
  geom_violin(aes(x=policy_index, 
                  group=policy_index,
                  y=black_deaths/black_pop2010,
                  fill=policy_index)) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('per capita Black deaths by law enforcement')+
  theme_classic() +
  scale_fill_viridis_c() +
  guides(fill=FALSE)

ggplot(cities) +
  geom_violin(aes(x=policy_index, 
                  group=policy_index,
                  y=black_deaths/all_deaths/(black_pop2010/pop2010),
                  fill=policy_index)) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('bias ratio')+
  theme_classic() +
  scale_fill_viridis_c() +
  guides(fill=FALSE)

