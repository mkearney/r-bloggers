#! /Users/mwk/r/r-bloggers/

## load rtweet pkg
suppressPackageStartupMessages(library(rtweet))

## scrape content
url <- "https://www.r-bloggers.com"
r <- httr::GET(url)

## select and filter links
links <- r %>%
    xml2::read_html() %>%
    rvest::html_nodes("a") %>%
    rvest::html_attr("href") %>%
    grep("https://www.r-bloggers.com/", ., value = TRUE) %>%
    grep(paste0(
        "(/20)|(/search)|(/contact)|(/add-your)|(/about)|",
        "(/author)|(/blogs-list)|(/page)|(bloggers.com/$)|",
        "(/welcome)|(r-jobs)|(how-to-learn-r)"),
        ., invert = TRUE, value = TRUE) %>%
    unique()

## clear scraper
rm(r)

## read files
## setwd("/Users/mwk/r/r-bloggers/R")
files <- list.files("/Users/mwk/r/r-bloggers/data")
spacetimes <- gsub(".rds$", "", files) %>%
    as.POSIXct(format = "%m-%d-%y-%H-%M",
               tz = "America/Chicago")
newest <- files[order(spacetimes, decreasing = TRUE)][1]
newest <- file.path("/Users/mwk/r/r-bloggers/data", newest)
previous <- readRDS(newest)

## post tweet
if (!identical(links, previous)) {
    url2tweet <- links[!links %in% previous]
    for (i in url2tweet) {
        txt2tweet <- i %>%
            gsub("(^https://www.r-bloggers.com/)|(/)",
                 "", .) %>%
            gsub("-", " ", .)
        post_tweet(paste0(txt2tweet, " ", i))
    }
}

## save new file
spacetime <- paste0(format(
    Sys.time(), "%m-%d-%y-%H-%M",
    tz = "America/Chicago"),
    ".rds")
save_as <- file.path("/Users/mwk/r/r-bloggers/data",
                     spacetime)

## save file
saveRDS(links, save_as)
