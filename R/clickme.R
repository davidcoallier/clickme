#' @import knitr
generate_visualization <- function(data, opts){
    visualization <- knit_expand(opts$path$template_file)
    capture.output(knit(text = visualization, output = opts$path$html_file))
}

#' Generates a JavaScript visualization
#'
#' @param data input data
#' @param ractive template id, it must match a folder within \code{set_root_path}
#' @param params list containing the parameters and values that will be accessible from the template
#' @param data_name name used to identify the output HTML file, default "data"
#' @param html_file_name name of the output HTML file that contains the visualization, default "data_name-ractive.html"
#' @param browse open browser, default TRUE
#' @param port port used to open a local browser, default 8888
#' @export
#' @examples
#'
#' library(clickme)
#'
#' # visualize a zoomable phylogenetic tree (www.onezoom.org)
#' mammals_path <- system.file(file.path("examples", "one_zoom", "data", "mammals.tree"), package="clickme")
#' clickme(mammals_path, "one_zoom")
#'
#' # visualize a force-directed interactive graph
#' items <- paste0("GENE_", 1:40)
#' n <- 30
#' df1 <- data.frame(a = sample(items, n, replace = TRUE), b = sample(items, n, replace = TRUE), type = sample(letters[1:3], n, replace=TRUE))
#' clickme(df1, "force_directed")
#'
#' # visualize a line plot that allows zooming along the x-axis
#' n <- 30
#' cities <- c("Boston", "NYC", "Philadelphia")
#' df2 <- data.frame(name = rep(cities, each = n), x = rep(1:n, length(cities)), y = c(sort(rnorm(n)), -sort(rnorm(n)),sort(rnorm(n))))
#' clickme(df2, "line_with_focus")
#'
#' # visualize an interactive heatmap next to a parallel coordinates plot
#' df3 <- matrix(rnorm(200), ncol = 8,nrow = 25)
#' rownames(df3) <- paste0("GENE_", 1:25)
#' colnames(df3) <- paste0("sample_", 1:8)
#' clickme(df3, "longitudinal_heatmap") # you will need to have a local server for this one.
clickme <- function(data, ractive, params = NULL, data_name = "data", html_file_name = NULL, browse = interactive(), port = 8888){
    opts <- get_opts(ractive, params = params, data_name = data_name, html_file_name = html_file_name)

    data <- validate_data_names(data, opts)
    opts <- translate_data(data, opts)
    generate_visualization(data, opts)

    if (opts$template_config$require_server){
        url <- paste0("http://localhost:", port, "/", opts$name$html_file)
        message("Make sure you have a server running at: ", get_root_path())
        message("Try running: python -m SimpleHTTPServer")
    } else {
        url <- opts$path$html_file
    }

    if (browse) browseURL(url)

    invisible(url)
}

translate_data <- function(data, opts) {
    source(opts$path$translator_file)
    opts <- translate(data, opts)
    opts
}
