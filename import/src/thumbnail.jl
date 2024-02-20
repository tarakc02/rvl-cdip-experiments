# vim: set ts=4 sts=0 sw=4 si fenc=utf-8 et:
# vim: set fdm=marker fmr={{{,}}} fdl=0 foldcolumn=4:

using CodecZlib, TarIterators
using FileIO: load, save
using ImageTransformations: imresize

tar_fn = ARGS[1]
cmplist = GzipDecompressorStream(open(tar_fn))
listing = TarIterator(cmplist, :file, close_stream=false)

function save_thumbnail(stream, outpath)
    contains(outpath, r"\.tif$") || return true
    img = load(IOBuffer(read(stream)))
    img === nothing && return true
    small = imresize(img, (250, 192))
    save(outpath, small)
    true
end

function resize_dir(tarlist)
    seekstart(tarlist)
    for (hdr, stream) in tarlist
        outpath = joinpath("output", hdr.path)
        isfile(outpath) || save_thumbnail(stream, outpath)
    end
    true
end

resize_dir(listing)

# done.
