DATA SOURCES:
    Connor Brooks and Kevin M. Scott (2015), ``Number of arrest-related deaths,
    percent confirmed by survey respondents, and death-identification source,
    by state, June-August 2015,'' v 07/30/2019, Arrest-Related Deaths Program:
    Pilot Study of Redesigned Survey Methodology NCJ 252675, Bureau of Justice
    Statistics.

    2010 US Census

    ``Police Use of Force Policy Analysis,'' Campaign Zero.

    Mapping Police Violence database (mappingpoliceviolence.org)

VARIABLES (custody_deaths.csv):
num_deaths:    Number of deaths that met Arrest-Related Deaths
               program-eligibility criteria (June-August 2015)
pct_confirmed: Percent of deaths confirmed by at least one survey respondent *
pct_media:     Percent of deaths initially identified through media review
pct_survey:    Percent of deaths initially identified by survey respondent

* Deaths were initially identified by a survey respondent or were
confirmed by either the law enforcement agency or medical examiner's/
coroner’s office respondent associated with a media-identified death.

VARIABLES (policies_by_city.csv; aggregated in cantwait_data.csv):
pop2010:             total population of city (NOT metro area), 2010 census
black_pop2010:       total Black population of city, 2010 census
white_pop2010:       total white population of city, 2010 census
all other variables: has the policy been enacted? (1 for yes; 0 for no)
