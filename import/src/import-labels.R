# vim: set ts=4 sts=0 sw=4 si fenc=utf-8 et:
# vim: set fdm=marker fmr={{{,}}} fdl=0 foldcolumn=4:

# load libs {{{
pacman::p_load(
    argparse,
    arrow,
    digest,
    dplyr,
    fs,
    purrr,
    readr,
    tidyr,
    tools
)
# }}}

# args {{{
parser <- ArgumentParser()
parser$add_argument("--input", default = "input/labels_only.tar.gz")
parser$add_argument("--outdir", default = "output")
args <- parser$parse_args()
# }}}

untar(args$input, exdir = args$outdir)

output <- file.path(args$outdir, "labels.parquet")
imgdir <- file.path(args$outdir, "images")
labdir <- file.path(args$outdir, "labels")

fsplit <- function(fname) file_path_sans_ext(basename(fname))

valid_images <- fs::dir_ls(imgdir, type = "file", recurse = TRUE)

out <- fs::dir_ls(labdir, type = "file", recurse = FALSE) %>%
    map_dfr(read_delim,
            col_names = c("filename", "label"), col_types = 'ci',
            .id = "split") %>%
    mutate(filename = file.path(imgdir, filename)) %>%
    filter(filename %in% valid_images) %>%
    mutate(split = fsplit(split))

write_parquet(out, output)

# done.
