.rblog <- function(r) {
    r %>% xml2::read_html() %>%
        rvest::html_nodes("a") %>%
        rvest::html_attr("href") %>%
        grep("^https://www.r-bloggers.com", ., value = TRUE) %>%
        tryCatch(error = function(e) return(NA_character_))
}

rblog <- function(n) {
    r <- paste0(
        "https://www.r-bloggers.com/page/",
        seq_len(n), "/?mashsb-refresh")
    lapply(r, .rblog) %>%
        unlist(use.names = FALSE) %>%
        unique
}
