# vim: set ts=4 sts=0 sw=4 si fenc=utf-8 et:
# vim: set fdm=marker fmr={{{,}}} fdl=0 foldcolumn=4:

using CodecZlib, TarIterators
using FileIO: load, save
using ImageTransformations: imresize

tar_fn = "input/rvl-cdip.tar.gz"
cmplist = GzipDecompressorStream(open(tar_fn))
listing = TarIterator(cmplist, :file, close_stream=false)

seekstart(listing)

function save_thumbnail(stream, outpath)
    contains(outpath, r"\.tif$") || return true
    img = load(IOBuffer(read(stream)))
    small = imresize(img, (250, 192))
    save(outpath, small)
    true
end

function resize_dir(tarlist)
    seekstart(tarlist)
    for (hdr, stream) in tarlist
        outpath = joinpath("output", hdr.path)
        isfile(outpath) && return true
        try
            save_thumbnail(stream, outpath)
        catch e
            continue
        end
    end
    true
end

resize_dir(listing)

# done.
