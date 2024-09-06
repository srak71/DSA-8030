library(fortunes)
help(package="fortunes")
ls("package:fortunes")

fortune()
fortune("Ripley")
fortune(17)

# Section comment
library(cowsay)
help(package="cowsay")

names(animals)
say(by='cow')

say("GO TIGERS!", by="chicken")

say("GO BERKELEY!", by="yoda")

say(paste(fortune(), collapse="\n"), by="monkey")
