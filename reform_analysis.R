require(dplyr)
require(tidyr)
require(rio)
require(ggplot2)
require(purrr)

policies <- rio::import('cantwait_data.csv')
deaths_raw <- rio::import('MPV_data.csv')
deaths_DOJ <- rio::import('custody_deaths.csv')
cities <- rio::import('policies_by_city.csv')


deaths <- deaths_raw %>%
          filter(city %in% cities$city)

breakdown <- table(deaths$city, deaths$victim_race)
cities <- cities %>%
          mutate(all_deaths = purrr::map_dbl(city, function(i){
            if(i %in% rownames(breakdown)) return(sum(breakdown[i,]))
            0
            }),
            black_deaths = purrr::map_dbl(city, function(i){
              if(i %in% rownames(breakdown)) return(breakdown[i,'Black'])
              0
            }),
            row=1:nrow(.),
            policy_index = purrr::map_dbl(row, function(i){
              sum(cities[i,6:13])
            }))
            
ggplot(cities) +
  geom_violin(aes(x=policy_index, 
                  group=policy_index,
                  y=all_deaths/pop2010,
                  fill=policy_index)) +
  scale_x_continuous('number of 8 Can\'t Wait policies enacted')+
  scale_y_continuous('per capita deaths by law enforcement')+
  theme_classic() +
  scale_fill_viridis_c() +
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

