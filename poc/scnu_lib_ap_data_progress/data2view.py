import matplotlib.pyplot as plt
import json
import os

from test import *
dataRoot = './data'


jsonFiles = [i for i in os.listdir(dataRoot) if i.endswith('.json')]

dataMap = {}
batchIndexGap = 0

for jsonFileName in jsonFiles:
  with open(os.path.join(dataRoot, jsonFileName), 'r', encoding='utf8') as file:
    apData = json.loads(file.read())
    dataLength = len(apData['data'])

    for batchIndex in range(dataLength):
      batch = apData['data'][batchIndex]
      for apBSSID in batch:
        absbatchIndex = batchIndex + batchIndexGap
        #TODO json data format error ssid:
        if not 'SCNU' in batch[apBSSID]['ssid:']:
          continue
        try:
          dataMap[apBSSID][absbatchIndex] = batch[apBSSID]['level']
        except KeyError as e:
          dataMap[apBSSID] = {absbatchIndex: batch[apBSSID]['level']}

  # add missing value
  batchSumSet = tuple((i for i in range(dataLength)))
  for ap in dataMap:
    diffSet = batchSumSet - dataMap[ap].keys()
    if (len(diffSet) > 0):
      for index in diffSet:
        dataMap[ap][index] = float('nan')


  temp_map = {}
  temp_map['xTick'] = [
  ]

  temp_map['x'] = [i for i in range(0, dataLength)]  # 点的横坐标
  temp_map['y_list'] = [[dataMap[i][j] for j in sorted(dataMap[i].keys())] for i in dataMap.keys()]
  temp_map['y_names'] = [i for i in dataMap]
  temp_map['y_min'] = -110
  temp_map['y_max'] = 1

  app = QtWidgets.QApplication(sys.argv)
  temp_widget = LineShowManager()
  temp_widget.show()
  temp_widget.plot_data(temp_map)
  sys.exit(app.exec_())
