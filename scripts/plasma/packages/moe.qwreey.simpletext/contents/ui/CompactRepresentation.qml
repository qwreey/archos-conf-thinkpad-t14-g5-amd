import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

Faces.CompactSensorFace {
    id: root

    readonly property bool isVertical: {
        switch (Plasmoid.formFactor) {
            case PlasmaCore.Types.Vertical:
                return true;
            case PlasmaCore.Types.Horizontal:
                return false;
            case PlasmaCore.Types.Planar:
            case PlasmaCore.Types.MediaCenter:
            case PlasmaCore.Types.Application:
            default:
                return height > width;
        }
    }

    Layout.preferredWidth:  isVertical ? -1 : layout.implicitWidth
    Layout.preferredHeight: isVertical ? layout.implicitHeight : -1

    contentItem: GridLayout {
        id: layout

        columnSpacing: Kirigami.Units.smallSpacing * (root.controller.faceConfiguration.spacingScalePercent / 100)
        rowSpacing: Kirigami.Units.smallSpacing * (root.controller.faceConfiguration.spacingScalePercent / 100)

        anchors.fill: parent
        flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

        Repeater {
            id: repeater
            model: root.controller.highPrioritySensorIds

            delegate: SmallTextDelegate {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                nameSpacing: root.controller.faceConfiguration.nameSpacing
                Layout.topMargin: root.controller.faceConfiguration.paddingTop
                Layout.leftMargin: (index == 0) ? root.controller.faceConfiguration.paddingLeft : 0
                Layout.rightMargin: (index == root.controller.highPrioritySensorIds.length - 1) ? root.controller.faceConfiguration.paddingRight : 0

                removeDecimalPoint: root.controller.faceConfiguration.removeDecimalPoint
                fontScale: root.controller.faceConfiguration.fontScalePercent / 100
                sensorName: root.controller.sensorLabels[modelData] || sensor.name
                sensorValue: sensor.formattedValue
                Sensors.Sensor {
                    id: sensor
                    sensorId: modelData
                    updateRateLimit: root.controller.updateRateLimit
                }
            }
        }
    }
}
