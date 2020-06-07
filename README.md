# Police Reform

DATA SOURCES:
    
    1. Connor Brooks and Kevin M. Scott (2015), ``Number of arrest-related deaths,
    percent confirmed by survey respondents, and death-identification source,
    by state, June-August 2015,'' v 07/30/2019, Arrest-Related Deaths Program:
    Pilot Study of Redesigned Survey Methodology NCJ 252675, Bureau of Justice
    Statistics.

    2. 2010 US Census

    3. ``Police Use of Force Policy Analysis,'' Campaign Zero.
    
    4. Samuel Sinyangwe (2016), ``Examining the Role of Use of Force Policies in Ending 
    Police Violence.''

    5. Mapping Police Violence database (mappingpoliceviolence.org)

VARIABLES (arrest-related_deaths.csv):

num_deaths:    Number of deaths that met Arrest-Related Deaths
               program-eligibility criteria (June-August 2015) [1]
pct_confirmed: Percent of deaths confirmed by at least one survey respondent * [1]
pct_media:     Percent of deaths initially identified through media review [1]
pct_survey:    Percent of deaths initially identified by survey respondent [1]

Deaths were initially identified by a survey respondent or were
confirmed by either the law enforcement agency or medical examiner's/
coroner’s office respondent associated with a media-identified death.

VARIABLES (policies_by_city.csv; aggregated in cantwait_data.csv):

pop2010:             total population of city (NOT metro area) [2]
black_pop2010:       total Black population of city [2]
white_pop2010:       total white population of city [2]
deaths2016:          number of police killings, Jan 1-July 15 2016 [4]
all other variables: has the policy been enacted? (1 for yes; 0 for no) [3]


# City data budget Scrape:

Scripts to scrape data on city police budgets
- _scrape_citydata.R_:  code to scrape city-data.com
- large_city_budgets.csv: example dataset (cities over 450K pop)

## Issues:
- Connection will be blocked by host if you make too many requests
- dates scraped from web still interpreted as chr vectors instead of datetimes
- Should scrape Crime stats table as well (Anyone want to contribute?)

## Example Use:
```
# Get URLS for each city
city_urls <- states$URL %>%
  map_df(get_city_urls) 

# Get budgets for entire country
city_budgets <- city_urls$URL %>% 
  map_df(get_city_payroll)

# get budgets, single state
nv_urls <- city_urls %>% 
  filter(URL %>% str_detect("Nevada.html")) 
nv_budgets <- nv_urls$URL %>% 
  map_df(get_city_payroll)

```

## Example Output:
``` 
> nv_budgets
# A tibble: 326 x 9
   state  city      Function                 date_str   `Full-time_employe… `Part-time_employe… `Monthly_full-time_pay… `Average_yearly_full-tim… `Monthly_part-time_pay…
   <chr>  <chr>     <chr>                    <chr>                    <dbl>               <dbl>                   <dbl>                     <dbl>                   <dbl>
 1 Nevada Carson C… Correction               March 2016                  69                  12                  393180                     68379                   18111
 2 Nevada Carson C… Police Protection - Off… March 2016                  65                   0                  419167                     77385                       0
 3 Nevada Carson C… Judicial and Legal       March 2016                  63                   5                  368178                     70129                    9902
 4 Nevada Carson C… Firefighters             March 2016                  59                   5                  475073                     96625                    2682
 5 Nevada Carson C… Streets and Highways     March 2016                  49                   0                  268154                     65670                       0
 6 Nevada Carson C… Financial Administration March 2016                  34                   5                  191263                     67505                    4189
 7 Nevada Carson C… Police - Other           March 2016                  30                   7                  170473                     68189                    7832
 8 Nevada Carson C… Other Government Admini… March 2016                  29                   5                  155354                     64284                    5917
 9 Nevada Carson C… Other and Unallocable    March 2016                  29                   4                  141163                     58412                    5146
10 Nevada Carson C… Health                   March 2016                  28                   9                  155853                     66794                   17413
# … with 316 more rows
```
