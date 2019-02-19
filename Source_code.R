expandContractions <- function(doc) {
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", " not", doc)
  doc <- gsub("'ll", " will", doc)
  doc <- gsub("'re", " are", doc)
  doc <- gsub("'ve", " have", doc)
  doc <- gsub("'m", " am", doc)
  doc <- gsub("it's", "it is", doc)
  return(doc)
}

toSpace <- content_transformer(function(x, pattern) gsub(pattern, " ", x))

removeSpecial <- content_transformer(function(x)
  iconv(x, "ASCII", "UTF-8", sub = ""))

createCleanCorpus <- function(texts) {
  texts <- expandContractions(texts)
  filtered <- VCorpus(VectorSource(texts))
  filtered <- tm_map(filtered, removeNumbers)
  filtered <- tm_map(filtered, toSpace, "/|@|\\|")
  filtered <- tm_map(filtered, removeSpecial)
  filtered <- tm_map(filtered, content_transformer(tolower))
  filtered <- tm_map(filtered, removePunctuation, preserve_intra_word_dashes = TRUE)
  filtered <- tm_map(filtered, stripWhitespace)
}

wordCount <- function(text) {
  length(unlist(strsplit(text, " ")))
}

lastWords <- function(text, n) {
  paste(tail(unlist(strsplit(text, " ")), n), collapse = " ")
}

# Match n-gram based on frequencies
findBestMatches <- function(words, nf, count) {
  nf.size <- length(unlist(strsplit(as.character(nf$word[1]), " ")))
  words.pre <- lastWords(words, nf.size - 1)
  f <- head(nf[grep(paste("^", words.pre, " ", sep = ""), nf$word), ], count)
  r <- gsub(paste("^", words.pre, " ", sep = ""), "", as.character(f$word))
  r[!r %in% c("s", "<", ">", ":", "-", "o", "j", "c", "m")]
}

# Predict next word, first try guadgram, then trigram, bigram and unigram
predictNextWord <- function(text, nfl, count) {
  text.wc <- wordCount(text)
  prediction <- NULL
  if(text.wc > 4) prediction <- findBestMatches(text, nfl$f6, count)
  if(length(prediction)) return(prediction)
  if(text.wc > 3) prediction <- findBestMatches(text, nfl$f5, count)
  if(length(prediction)) return(prediction)
  if(text.wc > 2) prediction <- findBestMatches(text, nfl$f4, count)
  if(length(prediction)) return(prediction)
  if(text.wc > 1) prediction <- findBestMatches(text, nfl$f3, count)
  if(length(prediction)) return(prediction)
  prediction <- findBestMatches(text, nfl$f2, count)
  if(length(prediction)) return(prediction)
  as.character(sample(head(nfl$f1$word, 30), count))
}

# Predict next word, cleaning the input text first
cleanPredictNextWord <- function(text, nfl, count) {
  text <- as.character(createCleanCorpus(text)[[1]], remove.punct=TRUE)
  predictNextWord(text, nfl, count)
}

# Predict current word being typed based on the partial last word
predictCurrentWord <- function(text, nfl, count) {
  current <- as.character(createCleanCorpus(lastWords(text, 1))[[1]])
  nf <- nfl$f1
  f <- head(nf[grep(paste("^", current, sep = ""), nf$word), ], count)
  as.character(head(f$word, count))
}
