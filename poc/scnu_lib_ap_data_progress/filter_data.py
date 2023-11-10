import numpy as np
import pandas as pd
from scipy.stats import kstest


import json

AP_VALIDATE_THEADHOLD = 0.7  # 有80%以上的信号才当作有效


def loadJson(filePath):
    data = {}
    with open(filePath, "r", encoding="utf8") as file:
        data = json.loads(file.read())
        return data

def OutlierDetection(data):
    df = pd.DataFrame(data, columns=['value'])
    # 计算均值
    u = df["value"].mean()
    # 计算标准差
    std = df["value"].std()
    # 识别异常值
    error = df[np.abs(df["value"] - u) > 3 * std]
    # 剔除异常值，保留正常的数据
    data_c = df[np.abs(df["value"] - u) <= 3 * std]
    # 输出异常数据
    # print(error)
    return data_c["value"].mean()


def count_rate(filePath):
    data = loadJson(filePath=filePath)
    countingMap = {}
    countingMapKeys = countingMap.keys()  # TODO view?
    apDataScans = data["data"]
    for scan in apDataScans:
        scanResults = list(scan.keys())
        for ap in scanResults:
            if not "SCNU" in scan[ap]["ssid:"]:
                continue
            if ap in countingMapKeys:
                countingMap[ap]["times"] += 1
                countingMap[ap]["levels"].append(scan[ap]["level"])
            else:
                countingMap[ap] = {
                    "levels": [
                        scan[ap]["level"],
                    ],
                    "times": 1,
                }
    threadedAP = []
    for i in countingMap:
        rate = countingMap[i]["times"] / len(apDataScans)
        if rate < AP_VALIDATE_THEADHOLD:
            continue
        threadedAP.append(i)
        outP = "{}  {}  {:.4f}".format(i, countingMap[i]["times"], rate)
        print(outP)

    # filter extrem value
    filteredData = {}
    for ssid in threadedAP:
        filteredMean=OutlierDetection(countingMap[ssid]['levels'])
        filteredData[ssid] = filteredMean
    return filteredData


threadedAP = count_rate("./2_1.json")
