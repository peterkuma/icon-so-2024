#!/usr/bin/env Rscript

library(sp)
library(rgdal)
source('lib/R/jdf/jdf.R', chdir=TRUE)


map.plot <- function(
    land,
    tracks,
    col,
	label.col,
    labels,
    points,
    points.labels,
    points.col,
    geo.points,
    geo.labels,
    regions
) {
    proj <- "+proj=stere +lat_0=-90 +lat_ts=-71 +lon_0=180 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"
    crs <- CRS(proj)
    crs.lonlat <- CRS('+proj=longlat +datum=NAD27')

    plot(
        spTransform(land, crs),
        xlim=c(-6300000, 6300000),
        ylim=c(-6300000, 6300000),
        col='#e0e0e0',
        # border=NA
        border='#666666',
        lwd=0.5
    )
    for (i in seq_along(tracks)) {
        track <- tracks[[i]]
        lon <- track[['lon']]
        lat <- track[['lat']]
        mask <- which(lat < -30)
        mask <- sort(sample(mask, min(length(mask), 1000)))
        lon <- lon[mask]
        lat <- lat[mask]
        lines <- SpatialLines(list(Lines(Line(cbind(lon,lat)), ID='lines')), crs.lonlat)
        plot(spTransform(lines, crs), add=TRUE, col=col[i])
    }

    pts <- SpatialPoints(rbind(
        c(-180, -20),
        c(0, -20),
        c(180, -80),
        c(180, -20)
    ), crs.lonlat)
    gl <- gridlines(pts, easts=seq(-180, 180, 20), ndiscr=100)
    lines(spTransform(gl, crs), lwd=0.1, col='#aaaaaa', lty=1)

    l <- labels(spTransform(gl, crs), crs.lonlat, side=2)
    l$pos <- NULL
    text(l, cex=0.9, adj=c(-0.1, -0.3), col='#555555')

    if (length(points) > 0) {
        points(
            spTransform(SpatialPoints(do.call(rbind, points), crs.lonlat), crs),
            # pch=18,
            cex=1.2,
            lwd=2,
            col=points.col
        )
    }

    pts <- SpatialPoints(do.call(rbind, geo.points), crs.lonlat)
    points(spTransform(pts, crs), pch=16, cex=0.3)
    text(coordinates(spTransform(pts, crs)), geo.labels, adj=c(1, -0.5), cex=0.7, font=3)

    for (i in seq_along(regions)) {
        region <- regions[[i]]
        name <- region[[1]]
        lon <- region[[2]][,1]
        lat <- region[[2]][,2]
        plot(spTransform(SpatialPolygons(list(Polygons(list(Polygon(cbind(
            c(
                seq(lon[1], lon[2], length.out=100),
                seq(lon[2], lon[1], length.out=100)
            ),
            c(
                rep(lat[1], 100),
                rep(lat[2], 100)
            )
        ))), 'regions')), proj4string=crs.lonlat), crs), border='#4b5effa0', lwd=2, add=TRUE)
        text(coordinates(spTransform(SpatialPoints(
            rbind(c(mean(lon), mean(lat))),
        crs.lonlat), crs)), name, col='#4b5eff', font=2)
    }

    legend(
        'topright',
        c(labels, points.labels),
        col=c(label.col[seq_along(labels)], points.col),
        border='#00000000',
        bg='#f5f5f5',
        box.col='#00000000',
        cex=1,
        y.intersp=1.3,
        lty=c(
            rep(1, length(labels)),
            rep(NA, length(points.labels))
        ),
        lwd=2,
        seg.len=1.5,
        pch=c(
            rep(NA, length(labels)),
            rep(1, length(points.labels))
        )
    )

    box()
}


map <- function(tracks, output, ...) {
    cairo_pdf(output, family="Open Sans")
    par(mar=c(0,0,0,0))
    land <- readOGR('input/natural-earth/ne_50m_land/ne_50m_land.shp', layer='ne_50m_land')
    ds <- list()
    for (track in tracks) {
        d <- jdf.from.hdf5(track)
        ds[[track]] <- d
    }
    map.plot(land, ds, ...)
    dev.off()
}
