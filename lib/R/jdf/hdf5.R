suppressMessages(library(rhdf5))

jdf.to.hdf5 <- function(d, filename) {
    suppressWarnings(file.remove(filename))
    f <- h5createFile(filename)
    for (name in names(d)) {
        if (grepl('^\\.', name)) {
            next
        }
        data <- d[[name]]
        if (!is.null(d$.header)) {
            for (namex in names(d$.header[[name]])) {
                if (grepl('^\\.', namex)) {
                    next
                }
                attr(data, namex) <- d$.header[[name]][[namex]]
            }
            attr(data, '.dims') <- d$.header[[name]]$.dims
        }
        h5write(data, filename, name, write.attributes=TRUE)
        H5close()
    }
}

jdf.from.hdf5 <- function(filename, variables=NULL) {
    names <- h5ls(filename)$name
    d <- list()
    for (name in names) {
        if (!is.null(variables) && !(name %in% variables)) {
            next
        }
        d[[name]] <- h5read(filename, name)
    }
    d
}
