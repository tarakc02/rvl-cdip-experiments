using DataLoaders
import LearnBase: nobs, getobs
using Images: load, imresize, channelview
using Flux
using Flux: onehot

struct RvlDataset
    image::Vector{String}
    label::Matrix{Int64}
end

function RvlDataset(fn::String)
    out = Tuple{String, Int64}[]
    for line in eachline(fn)
        path, lab = split(line)
        path = joinpath("../import/output/images", path)
        isfile(path) || continue
        push!(out, (path, parse(Int64, lab)))
    end
    RvlDataset([img for (img, lab) in out],
               onehotbatch([lab for (img, lab) in out], 0:15))
end

nobs(ds::RvlDataset) = length(ds.image)
function getobs(ds::RvlDataset, idx::Int) 
    image, label = ds.image[idx], ds.label[:, idx]
    img = imresize(load(image), 125, 96) |> channelview
    mat = convert.(Float32, reshape(img, 125, 96, :))
    return mat, label
end

trainlist = RvlDataset("../import/input/labels/train.txt")
vallist = RvlDataset("../import/input/labels/val.txt")
testlist = RvlDataset("../import/input/labels/test.txt")

getobs(vallist, 1) .|> typeof

train = DataLoader(trainlist, 32)
val = DataLoader(vallist, 32);
test = DataLoader(testlist, 32)

model = Chain(Conv((3, 3), 1 => 32, relu),
              MaxPool((3,3)),
              Conv((3,3), 32 => 32, relu),
              MaxPool((3,3)),
              Conv((3,3), 32 => 16, relu),
              MaxPool((3,3)),
              Flux.flatten,
              Dense(96, 96, relu),
              Dense(96, 16))

tmp = first(val);
model(tmp[1]) |> size

opt = ADAM(.001)
Flux.train!((x,y) -> Flux.logitcrossentropy(model(x), y), Flux.params(model), val, opt)

Flux.logitcrossentropy(model(tmp[1]), tmp[2])
