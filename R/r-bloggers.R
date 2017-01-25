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
rblinks <- readRDS("/Users/mwk/r/r-bloggers/data/rbloggers_links.rds")
if (!all(links %in% rblinks)) {
    token <- readRDS("/Users/mwk/rtw.rds")
    url2tweet <- links[!links %in% rblinks]
    yesno <- vector("logical", length(url2tweet))
    for (i in url2tweet) {
        txt2tweet <- i %>%
            gsub("(^https://www.r-bloggers.com/)|(/)",
                 "", .) %>%
            gsub("-", " ", .)
        if (nchar(txt2tweet) > 40) {
            txt2tweet <- strsplit(txt2tweet, " ")[[1]]
            txt2tweet <- txt2tweet %>%
                .[suppressWarnings(is.na(as.numeric(txt2tweet)))]
            txt2tweet <- txt2tweet %>%
                .[nchar(.) %>% cumsum() < 40]
            txt2tweet <- paste(txt2tweet, collapse = " ")
            txt2tweet <- paste0(txt2tweet, "...")
            ##if ((nchar(txt2tweet) + nchar(i) + 12) > 140) {
            ##    txt2tweet <- strsplit(txt2tweet, " ")[[1]]
            ##    txt2tweet <- txt2tweet %>%
            ##        .[nchar(.) %>% cumsum() < (127 - nchar(i))]
            ##    txt2tweet <- paste(txt2tweet, collapse = " ")
            ##    txt2tweet <- paste0(txt2tweet, "...")
            ##}
        }
        pt <- post_tweet(
            paste0(txt2tweet, " #rstats ", i),
            token = token)
        if (isTRUE(pt$all_headers[[1]][["status"]] == 200)) {
            yesno[i] <- TRUE
        } else {
            yesno[i] <- FALSE
        }
    }

    ## save new file
    spacetime <- paste0(format(
        Sys.time(), "%m-%d-%y-%H-%M",
        tz = "America/Chicago"),
        ".rds")
    save_as <- file.path("/Users/mwk/r/r-bloggers/data",
                         spacetime)
    saveRDS(links, save_as)

    ## save comprehensive link file (if tweet was successful)
    rblinks <- c(rblinks, links[yesno])
    saveRDS(rblinks,
            "/Users/mwk/r/r-bloggers/data/rbloggers_links.rds")

} else {
    message("Sorry, there are no new R-bloggers.com posts to tweet!")
}
