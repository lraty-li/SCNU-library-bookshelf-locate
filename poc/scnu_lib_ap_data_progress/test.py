from PyQt5 import QtWidgets
import pyqtgraph as pg
from typing import Any, Dict
import random
import sys


class RotateAxisItem(pg.AxisItem):
  def drawPicture(self, p, axisSpec, tickSpecs, textSpecs):
    p.setRenderHint(p.Antialiasing, False)
    p.setRenderHint(p.TextAntialiasing, True)

    # draw long line along axis
    pen, p1, p2 = axisSpec
    p.setPen(pen)
    p.drawLine(p1, p2)
    p.translate(0.5, 0)  # resolves some damn pixel ambiguity

    for pen, p1, p2 in tickSpecs:
      p.setPen(pen)
      p.drawLine(p1, p2)

    p.setPen(self.pen())
    for rect, flags, text in textSpecs:
      # this is the important part
      p.save()
      p.translate(rect.x(), rect.y())
      p.rotate(-30)
      p.drawText(-rect.width(), rect.height(), rect.width(), rect.height(), flags, text)
      # restoring the painter is *required*!!!
      p.restore()


class LineShowManager(QtWidgets.QWidget):
  def __init__(self):
    super().__init__()

    self.y_datas = []

    self.init_ui()
    pass

  def init_ui(self) -> None:

    pg.setConfigOptions(leftButtonPan=False, antialias=True)
    pg.setConfigOption('background', 'w')
    pg.setConfigOption('foreground', 'k')

    xax = RotateAxisItem(orientation='bottom')
    xax.setHeight(h=80)
    self.pw = pg.PlotWidget(axisItems={'bottom': xax})
    self.pw.setLabel("left", "值")
    self.pw.setLabel("bottom", "时间")
    self.label = pg.TextItem()
    layout = QtWidgets.QVBoxLayout()
    layout.addWidget(self.pw)
    self.setLayout(layout)
    pass

  def plot_data(self, data: Dict[str, Any]):
    self.pw.clear()
    self.pw.addLegend()
    # xTick x  多条曲线共用x轴数据
    xTick = [data['xTick']]
    x = data['x']
    y_list = data['y_list']
    y_names = data['y_names']
    y_min = data['y_min']
    y_max = data['y_max']
    self.y_datas = y_list
    self.x_data = xTick
    self.y_names = y_names

    xax = self.pw.getAxis('bottom')
    xax.setTicks(xTick)

    for i in range(len(y_names)):
      self.pw.plot(x, y_list[i], connect='finite', pen=pg.mkPen(
          {'color': (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255)), 'width': 2}),
          name=y_names[i])
    self.vLine = pg.InfiniteLine(angle=90, movable=False)
    self.hLine = pg.InfiniteLine(angle=0, movable=False)
    self.pw.addItem(self.vLine, ignoreBounds=True)
    self.pw.addItem(self.hLine, ignoreBounds=True)
    self.pw.addItem(self.label, ignoreBounds=True)
    self.pw.setRange(xRange=[0, len(x)], yRange=[y_min, y_max])
    self.vb = self.pw.getViewBox()
    self.proxy = pg.SignalProxy(self.pw.scene().sigMouseMoved, rateLimit=60, slot=self.mouseMoved)
    pass

  def mouseMoved(self, evt):
    pos = evt[0]
    if len(self.y_datas) <= 0:
      return
    if self.pw.sceneBoundingRect().contains(pos):
      mousePoint = self.vb.mapSceneToView(pos)
      index = int(mousePoint.x())
      pos_y = int(mousePoint.y())

      if index >= 0 and index < len(self.y_datas[0]):
        # Here we have obtained the mouse x point
        # So lets use a for loop for each curve to set the Pos
        time_str = self.x_data[0][index][1]
        # time_str = ''
        data_str = ''
        for m in range(len(self.y_datas)):
          data_str += '<p style="color:black;">' + self.y_names[m] + ':' + str(
              self.y_datas[m][index]) + '</p>'
        html_str = '<p style="color:black;">' + time_str + '</p>' + data_str
        self.label.setHtml(html_str)
        self.label.setPos(mousePoint.x(), mousePoint.y())
      self.vLine.setPos(mousePoint.x())
      self.hLine.setPos(mousePoint.y())
    pass

  def showEvent(self, QShowEvent):
    self.showMaximized()
