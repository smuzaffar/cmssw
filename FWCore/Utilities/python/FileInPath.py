from os import environ
from os.path import join,exists

def getFileInPath(dataFile):
    for s in environ["CMSSW_SEARCH_PATH"].split(":"):
        filePath = join(s,dataFile)
        if exists(filePath):
            return filePath
    return None
