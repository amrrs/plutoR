library(dbplyr)
library(dplyr)
library(odbc)
library(RPostgres)
library(plutoR)
options("scipen"=999)
source("../R/config.R")

equitiesIndiaNse <- EquitiesIndiaNse()

# fetch the earliest 10 listed equity

print("earliest 10 listed equity")
equitiesIndiaNse$Tickers() %>%
  top_n(-10, wt = DATE_LISTING) %>%
  print(n)

# fetch some "misc" info for State Bank of India

maxDt <- (equitiesIndiaNse$MiscInfo() %>%
  summarize(MAX_DT = max(TIME_STAMP)) %>%
  collect())$MAX_DT[[1]]

print("SBIN's latest misc info: ")
equitiesIndiaNse$MiscInfo() %>%
  filter(TIME_STAMP == maxDt & SYMBOL == 'SBIN') %>%
  print(n=Inf)

# fetch the market-cap decile of DHFL since we started capturing the data-set

print("market-cap deciles for DHFL over time:")
equitiesIndiaNse$MarketCapDecile() %>%
  filter(SYMBOL == 'DHFL') %>%
  arrange(TIME_STAMP) %>%
  print(n=Inf)

# fetch the latest end-of-day prices for State Bank of India

maxDt <- (equitiesIndiaNse$EodTimeSeries() %>%
  summarize(MAX_DT = max(TIME_STAMP)) %>%
  collect())$MAX_DT[[1]]

print("latest end-of-day prices for SBIN:")
equitiesIndiaNse$EodTimeSeries() %>%
  filter(TIME_STAMP == maxDt & SYMBOL == 'SBIN') %>%
  print()

# fetch the last 10 day EOD prices for State Bank of India equity

print("last 10 day EOD prices for SBIN equity:")
equitiesIndiaNse$EodTimeSeries() %>%
  filter(SYMBOL == 'SBIN' & (SERIES == 'EQ' | SERIES == 'BE')) %>%
  top_n(10, wt = TIME_STAMP) %>%
  print(n=Inf)

# UPL did a 1:2 bonus on 2019-07-02. see unadjusted eod vs. adjusted eod

startDt <- as.Date("2019-06-15")
endDt <- as.Date("2019-07-15")

print("unadjusted eod")

equitiesIndiaNse$EodTimeSeries() %>%
  filter(SYMBOL == "UPL" & TIME_STAMP >= startDt & TIME_STAMP <= endDt) %>%
  arrange(TIME_STAMP) %>%
  print(n=Inf)

print("adjusted eod")

equitiesIndiaNse$EodAdjustedTimeSeries() %>%
  filter(SYMBOL == "UPL" & TIME_STAMP >= startDt & TIME_STAMP <= endDt) %>%
  arrange(TIME_STAMP) %>%
  print(n=Inf)

# fetch the last 10 day returns for State Bank of India

print("the last 10 day returns for SBIN: ")
equitiesIndiaNse$DailyReturns() %>%
  filter(SYMBOL == "SBIN") %>%
  top_n(10, wt = TIME_STAMP) %>%
  print(n=Inf)

# fetch the last 10 corporate actions for State Bank of India

print("the last 10 corporate actions for SBIN: ")
equitiesIndiaNse$CorporateActions() %>%
  filter(SYMBOL == "SBIN") %>%
  top_n(10, wt = EX_DATE) %>%
  print(n=Inf)

# fetch the last 10 corporate events for State Bank of India

print("the last 10 corporate events for SBIN: ")
equitiesIndiaNse$CorporateEvents() %>%
  filter(SYMBOL == "SBIN") %>%
  top_n(10, wt = EVENT_DATE) %>%
  print(n=Inf)

# fetch the last 24 quarter EPS for State Bank of India

print("the last 24 quarter EPS for SBIN: ")
refs <- equitiesIndiaNse$CorporateResultsMeta() %>%
  filter(SYMBOL == 'SBIN' & IS_CONSOLIDATED == 0 & PERIOD %like% '%quarter') %>%
  top_n(24, wt=PERIOD_END) %>%
  select(REF_ID, PERIOD_END, PERIOD) %>%
  collect()

print(refs)

for(i in 1:nrow(refs)){
  ref <- refs[i,]
  print(ref)

  rid <- ref$REF_ID[1]
  equitiesIndiaNse$CorporateResults() %>%
    filter(REF_ID == rid & KEY %like% '%diluted%before%') %>%
    print(n=Inf)
}


