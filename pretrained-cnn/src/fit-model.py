# dependencies
from fastai.vision.all import *
import pandas as pd
import argparse
import logging
from sys import stdout

# arg handling
def getargs():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", default = "../import/output/labels.parquet")
    parser.add_argument("--output")
    return parser.parse_args()


# setup logging
def get_logger(sname, file_name=None):
    logger = logging.getLogger(sname)
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(asctime)s - %(levelname)s " +
                                  "- %(message)s", datefmt='%Y-%m-%d %H:%M:%S')
    stream_handler = logging.StreamHandler(stdout)
    stream_handler.setFormatter(formatter)
    logger.addHandler(stream_handler)
    if file_name:
        file_handler = logging.FileHandler(file_name)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
    return logger


def get_dataloaders(data):
    return ImageDataLoaders.from_df(data,
            path="../import",
            fn_col = 'filename',
            label_col = 'label'
            )


def setup_model(dls):
    mps = torch.device("mps")
    learn = vision_learner(dls,
            resnet18,
            metrics=error_rate,
            path = "output",
            model_dir = ".")
    learn.to(mps)
    learn.dls.to(mps)
    return learn


if __name__ == '__main__':

args = getargs()
logger = get_logger(__name__)
tuning_n = 3

# read data, initial verification
logger.info("Loading data and initializing model")

labs = pd.read_parquet(args.input)
labs['valid'] = labs.split == 'val'

test = labs[labs.split == 'test']
train = labs[labs.split.isin(['train', 'val'])]

train_dls = get_dataloaders(train)
learn = setup_model(train_dls)

logger.info(f"before training, validation error rate is {learn.validate()[1]}")

logger.info("determining the learning rate for fine tuning")
lr = learn.lr_find()
logger.info(f"using tuning_n: {tuning_n}")
logger.info(f"using learning rate: {lr.valley}")
logger.info("training the model")

learn.fine_tune(10, lr.valley)

logger.info("model training done")
logger.info(f"after training, validation error rate is {learn.validate()[1]}")
logger.info("saving trained model")

# moving data/models back to cpu to export, i don't think this is necessary
# (you should be able to move it across devices when you load it either
# way) but i wasn't sure, esp. when working locally on M1
#learn.to('cpu')
#learn.dls.cpu()

# note: we want to use learn.export, but currently (as of sep-9 2022) that
# isn't working on M1 device (it does work as of pytorch-nightly, but not
# release, and nightly doesn't work with fastai). workaround is we save the
# plain pytorch model. downside to that is that we then need to redefine
# the methods to set up the datalaoders, will do that in the predict script
learn.save(args.output, with_opt=False)

learn.export("page-classifier.pkl")

logger.info("done.")


# done.

