# vim: set ts=8 sts=0 sw=8 si fenc=utf-8 noet:
# vim: set fdm=marker fmr={{{,}}} fdl=0 foldcolumn=4:

imgs   :=  input/rvl-cdip.tar.gz
thumbs := output/thumbnails.done

labs_in  := input/labels_only.tar.gz
labs_out := output/labels.parquet

.PHONY: all clean

all: $(thumbs) $(labs_out)

clean: 
	-rm -r output/*


$(thumbs): src/thumbnail.jl $(imgs)
	-mkdir output
	julia --project --threads=auto -e "using Pkg; Pkg.instantiate();"
	julia --project --threads=auto $< $(imgs)
	touch $@

$(labs_out): src/import-labels.R $(labs_in) $(thumbs)
	-mkdir output
	Rscript --vanilla $< \
		--input=$(labs_in) \
		--outdir=output
	
# done.
