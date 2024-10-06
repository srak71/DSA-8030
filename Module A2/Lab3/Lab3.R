# Fortunes
# Loading package fortures
library(fortunes)

# Using help function to explore fortunes package
help(package="fortunes")

# Displaying package contents
ls("package:fortunes")

# Providing random fortune
fortune()

# Providing random fortune containing the word "Ripley"
fortune("Ripley")

# Providing fortune number 17
fortune(17)

# Cowsay
# Loading package cowsay
library(cowsay)

# Using the help function to explore the cowsay package
help(package="cowsay")

# Displaying package content
ls("package:cowsay")

# Looking at names of values stored in animals vector
names(animals)

# Using basic form of say function
say()

# Using say() function to say "hi"
say("hi")

# Using say but rendering from object cow
say(by='cow')

# Using other "name" values from animal vector
say("GO TIGERS!", by="chicken")
say("GO BERKELEY!", by="yoda")

# Using package fortune to load a random fortune, and pasting it 
# as input to cowsay
say(paste(fortune(), collapse="\n"), by="monkey")

