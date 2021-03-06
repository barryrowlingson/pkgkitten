##  pkgKitten -- A saner way to create packages to build upon
##
##  Copyright (C) 2014 Dirk Eddelbuettel <edd@debian.org>
##
##  This file is part of pkgKitten
##
##  pkgKitten is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 2 of the License, or
##  (at your option) any later version.
##
##  pkgKitten is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with pkgKitten.  If not, see <http://www.gnu.org/licenses/>.


##' The \code{kitten} function create an (almost) empty example
##' package.
##' 
##' The \code{kitten} function can be used to initialize a simple
##' package.  It is created with the minimal number of files. What
##' distinguished it from the function \code{package.skeleton()} in
##' base R (which it actually calls) is that the resulting package
##' passes \code{R CMD check cleanly}.
##'
##' Because every time you create a new package which does \emph{not}
##' pass \code{R CMD check}, a kitten experiences an existential
##' trauma. Just think about the kittens.
##' @title Create a very simple package 
##' @param name The name of the package to be created, defaults to \dQuote{anPackage}
##' @param path The path to the location where the package is to be
##' created, defaults to the current directory.
##' @param author The name of the author, defaults to \dQuote{Your Name}.
##' @param maintainer The name of the maintainer, defaults to
##' \dQuote{Your Name} or \code{author} if the latter is given.
##' @param email The maintainer email address.
##' @param license The license of the new package, default to \dQuote{GPL-2}.
##' @return Nothing is returned as the function is invoked for its
##' side effect of creating a new package.
##' @author Dirk Eddelbuettel
kitten <- function(name = "anRpackage",
                   path = ".",
                   author = "Your Name",
                   maintainer = if (missing(author)) "Your Name" else author,
                   email = "your@email.com",
                   license = "GPL (>= 2)") {
  
    call <- match.call()                	# how were we called
    call[[1]] <- as.name("package.skeleton")    # run as if package.skeleton() was called
    env <- parent.frame(1)                      # access to what is in the environment
    assign("kitten.fake.fun", function() {}, envir = env)
    
    call <- call[ c(1L, which(names(call) %in% names(formals(package.skeleton)))) ]
    call[["list"]] <- "kitten.fake.fun"
    
    tryCatch(eval(call, envir = env), error = function(e){
        stop(sprintf("error while calling `package.skeleton` : %s", conditionMessage(e)))
    })
    
    message("\nAdding pkgKitten overides.")

    root <- file.path(path, name)    ## now pick things up from here
    DESCRIPTION <- file.path(root, "DESCRIPTION")
    if (file.exists(DESCRIPTION)) {
        x <- read.dcf(DESCRIPTION)
        x[, "Author"] <- author
        x[, "Maintainer"] <- sprintf("%s <%s>", maintainer, email)
        x[, "License"] <- license
        write.dcf(x, file = DESCRIPTION)
    }
    
    helptgt <- file.path(root, "man", sprintf( "%s-package.Rd", name))
    helpsrc <- system.file("replacements", "manual-page-stub.Rd", package="pkgKitten")
    file.copy(helpsrc, helptgt, overwrite=TRUE)
    
    rtgt <- file.path(root, "R", "hello.R")
    rsrc <- system.file("replacements", "hello.R", package="pkgKitten")
    file.copy(rsrc, rtgt, overwrite=TRUE)
    
    rdtgt <- file.path(root, "man", "hello.Rd")
    rdsrc <- system.file("replacements", "hello.Rd", package="pkgKitten")
    file.copy(rdsrc, rdtgt, overwrite=TRUE)
    
    rm("kitten.fake.fun", envir = env)
    unlink(file.path(root, "R"  , "kitten.fake.fun.R"))
    unlink(file.path(root, "man", "kitten.fake.fun.Rd"))
    unlink(file.path(root, "Read-and-delete-me"))
    message("Deleted 'Read-and-delete-me'.")
    message("Done.\n")

    message("Consider readingg the documentation for all the packaging details.")
    message("A good start is the 'Writing R Extensions' manual.\n")

    message("And run 'R CMD check'. Run it frequently. And think of those kittens.\n")
    
    invisible(NULL)
}

