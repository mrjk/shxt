import logging
import os
import shutil
from distutils.dir_util import copy_tree

import shutil


logger = logging.getLogger("mkdocs")


# def copy_get(config, **kwargs):
#     site_dir = config["site_dir"]
#     logger.info("Copying logo from hook")
#     copy_tree("../logo/", os.path.join(site_dir, "logo"))

# def copy_exec(config, **kwargs):
#     site_dir = config["site_dir"]
#     dst = os.path.join(site_dir, "shxt.sh")
#     logger.info("Copying shxt.sh from hook")
#     shutil.copyfile("../shxt.sh", dst)
#     logger.info(f"dest: {site_dir} as {dst}")


# def on_pre_build(config, **kwargs):
#     copy_exec(config, **kwargs)

#     return config


from mkdocs.structure.files import File
import os

def on_files(files, config):

    # Add raw dist
    src_path = os.path.abspath("../shxt.sh")
    f = File(
        path="shxt.sh",
        src_dir=os.path.dirname(src_path),
        dest_dir=config["site_dir"],
        use_directory_urls=config["use_directory_urls"]
    )

    logger.info("Copying shxt.sh from hook")
    files.append(f)

    return files