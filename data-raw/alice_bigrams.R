# data-raw/alice_bigrams.R
#
# Compute a 27x27 English character bigram count matrix from the full text of
# Alice's Adventures in Wonderland (Lewis Carroll, 1865).
# Source: Project Gutenberg text ID 11 (public domain).
#
# Run once to regenerate data/alice_bigrams.rda:
#   source("data-raw/alice_bigrams.R")
#
# Requires: gutenbergr

alice_raw <- gutenbergr::gutenberg_download(11, verbose = FALSE)
text      <- paste(alice_raw$text, collapse = " ")

chars27 <- c(letters, " ")
text    <- tolower(text)
text    <- gsub(" ", "_", text) # space -> _
text    <- gsub("[^a-z\\_]", "", text) # non-letters or _ -> empty
text    <- gsub("_", " ", text) # _ -> space
text    <- gsub(" +", " ", text) # collapse runs of spaces
text    <- trimws(text)
idx     <- match(strsplit(text, "")[[1]], chars27)
idx     <- idx[!is.na(idx)]
xi      <- idx[-length(idx)]
yi      <- idx[-1L]
# tabulate fills column-major, so swap to get M[i,j] = count(first=i, second=j)
tab     <- tabulate((yi - 1L) * 27L + xi, nbins = 729L)

alice_bigrams <- matrix(tab, 27L, 27L,
                        dimnames = list(x = chars27, y = chars27))

usethis::use_data(alice_bigrams, overwrite = TRUE)
