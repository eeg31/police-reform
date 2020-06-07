library(tidyverse)
library(rvest)
library(janitor)

# Data scrap of city-data.com for local govt budgets
# @imaginary_nums 2020

# Input: url to state page
# Value: Tibble of city urls
get_city_urls <- function(url) {
  city_nodes <- url %>% 
    read_html %>% 
    html_nodes(xpath = '//*[@id="cityTAB"]') 
  
  urls <- city_nodes %>% 
    html_nodes("a") %>% 
    html_attr("href") %>% 
    as_tibble() %>% 
    rename(URL = value) %>% 
    mutate(URL = paste0("http://www.city-data.com/city/", URL))
  
  cities <- city_nodes %>%
    first %>%
    html_table %>%
    as_tibble %>%
    select(Name, Population) %>%
    cbind(urls) %>% 
    mutate(Population = as.integer(str_remove_all(Population, ","))) %>% 
    filter(URL %>% str_detect("html")) %>% 
    unique()
    
  return(cities)
}

# Input: url to city page
# Value: Tibble of city payroll data
get_city_payroll <- function(url) {
  city_page <- read_html(url)
  citystate <- city_page %>% 
    html_nodes(xpath = '/html/body/div[3]/div[4]/h1/span')  %>% 
    html_text() %>% 
    str_split(pattern = ", ") %>% 
    unlist
  
  city_name <- citystate[1]
  state_name <- citystate[2]
  
  city_govt_node <- city_page %>% 
    html_node(xpath = '//*[@id="government-employment"]') 
  
  if (is.na(city_govt_node) ){
    return(NULL)
  }
  
  city_govt <- city_govt_node %>% 
    html_node("table") %>% 
    html_table %>% 
    as_tibble
  
  date <- city_govt[1,1] %>% 
    str_extract("\\(.*\\)") %>% 
    str_remove_all("[\\(\\)]")
  
  # add in city, date data
  gov <- city_govt %>% tail(n = -1L) %>% 
    row_to_names(row_number = 1) %>% 
    mutate(date_str = date,
           city = city_name,
           state = state_name) 
  
  # remove spaces from column names
  gov %>% 
    names %>% 
    str_replace_all(" ", "_") -> 
    names(gov) 
  
  # data type conversion, reorder
  gov <- gov %>% 
    mutate_at(c(2,5), as.numeric) %>% 
    mutate_at(c(3,4,6), ~ as.numeric(str_remove_all(.x, pattern = "[$,]"))) %>% 
    select(c(9, 8, 1, 7, 2, 5, 3, 4, 6)) %>% 
    unique()
  
  
  return(gov)
}

main_url<- "http://www.city-data.com/"
main_page <- read_html(main_url)

# Get URLS for each state
states <- main_page %>% 
  html_nodes(xpath = '//*[@id="tabs_by_category"]/div[3]') %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  as_tibble() %>% 
  rename(URL = value) %>% 
  filter(URL %>% str_detect("/city/"))

# Get URLS for each city
cities <- states$URL %>%
  map_df(get_city_urls)

# Get budgets for entire country, large cities

large_cities <- cities %>% 
  filter(Population >= 450000)

large_city_budgets <- large_cities$URL %>% 
  map_df(get_city_payroll)


## Plot:
large_city_budgets %>% 
  select(state, city, Function, date_str,`Monthly_full-time_payroll`) %>%
  filter(str_detect(Function, "(Protection|Totals)")) %>%  
  filter(`Monthly_full-time_payroll` >= 0)  %>% 
  pivot_wider(names_from = Function, values_from =  `Monthly_full-time_payroll`) %>% 
  ggplot(aes(x=`Totals for Government`, y=`Police Protection - Officers`)) + 
  geom_point() +
  geom_text(aes(label=ifelse(`Police Protection - Officers` > 22000000, city, '')),hjust=0, vjust=0) +
  ylim(0, 100000000) +
  ggtitle("Municipal monthly spending, police vs total")
  

# get budgets, single state
ca_urls <- city_urls %>% 
  filter(URL %>% str_detect("California.html")) 
ca_budgets <- ca_urls$URL %>% 
  map_df(get_city_payroll)


