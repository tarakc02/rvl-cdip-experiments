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
    img = load(IOBuffer(read(stream)))
    small = imresize(img, (250, 192))
    save(outpath, small)
    true
end

function resize_dir(tarlist; max=100)
    counter = 0;
    seekstart(tarlist)
    for (hdr, stream) in tarlist
        counter >= max && break
        outpath = joinpath("output", hdr.path)
        isfile(outpath) || save_thumbnail(stream, outpath)
        counter += 1
    end
    true
end

@time resize_dir(listing, max=1000)

