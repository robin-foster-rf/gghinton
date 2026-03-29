#' English character bigram counts from Alice's Adventures in Wonderland
#'
#' A 27x27 integer matrix of character-pair (bigram) counts computed from the
#' full text of *Alice's Adventures in Wonderland* by Lewis Carroll (1865).
#' The source text is Project Gutenberg item 11 (public domain).
#'
#' The 27 characters are the 26 lower-case letters `a`-`z` plus a space
#' character (represented as `" "`).  Non-letter characters in the original
#' text (punctuation, digits, newlines) are ignored, and runs of
#' multiple spaces are collapsed to one before counting.
#'
#' `alice_bigrams[x, y]` gives the number of times character `x` is
#' immediately followed by character `y` in the processed text.
#'
#' @format A 27 x 27 integer matrix.  Row names and column names are
#'   `c(letters, " ")`.
#'
#' @source Project Gutenberg, \url{https://www.gutenberg.org/ebooks/11}.
#'   Downloaded and processed by `data-raw/alice_bigrams.R`.
#'
#' @examples
#' # Most common bigrams
#' tail(sort(alice_bigrams), 10)
#'
#' # "th" count
#' alice_bigrams["t", "h"]
#'
#' # Visualise as a Hinton diagram
#' df <- matrix_to_hinton(alice_bigrams / sum(alice_bigrams))
#' \donttest{
#' ggplot2::ggplot(df, ggplot2::aes(x = col, y = row, weight = weight)) +
#'   geom_hinton() +
#'   scale_fill_hinton() +
#'   ggplot2::coord_fixed() +
#'   theme_hinton()
#' }
"alice_bigrams"
