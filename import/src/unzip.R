# vim: set ts=4 sts=0 sw=4 si fenc=utf-8 et:
# vim: set fdm=marker fmr={{{,}}} fdl=0 foldcolumn=4:

# load libs {{{
pacman::p_load(
    argparse,
    digest,
    dplyr,
    purrr,
    readr,
    tidyr
)
# }}}

# args {{{
parser <- ArgumentParser()
parser$add_argument("--inputdir", default = "input")
args <- parser$parse_args()
# }}}

lab_fn <- file.path(args$inputdir, "labels_only.tar.gz")
img_fn <- file.path(args$inputdir, "rvl-cdip.tar.gz")

lab_md5 <- digest(lab_fn, file = TRUE, algo = "md5")
img_md5 <- digest(img_fn, file = TRUE, algo = "md5")

stopifnot(
    img_md5 == "d641dd4866145316a1ed628b420d8b6c",
    lab_md5 == "9d22cb1eea526a806de8f492baaa2a57"
)

untar(lab_fn, exdir = "output")

labs <- tibble(fn = list.files("output/labels", full.names = TRUE, pattern = "*.txt")) %>%
    mutate(content = map(fn, read_delim,
                         delim=" ",
                         col_names = c("imgpath", "label"),
                         col_types = 'cn')) %>%
    unnest(content)
