input :=  input/rvl-cdip.tar.gz
thumbnails := output/thumbnails.done
src := src/

.PHONY: all

all: $(thumbnails)

$(thumbnails): src/process.jl $(input)
	-mkdir output
	julia --project=. -e "using Pkg; Pkg.instantiate();"
	JULIA_NUM_THREADS=4 julia --project=. $<

# done.
