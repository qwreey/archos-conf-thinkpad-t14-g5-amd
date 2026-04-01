import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents

ColumnLayout {
    id: delegate

    property string sensorName
    property string sensorValue
    property double fontScale
    property bool removeDecimalPoint
    property int nameSpacing

    spacing: nameSpacing

    PlasmaComponents.Label {
        id: valueLabel
        Layout.alignment: Qt.AlignHCenter

        font: {
            let font = Object.assign({}, Kirigami.Theme.defaultFont);
            font.pointSize *= fontScale;
            font.pixelSize = undefined;
            font.features = { "tnum": 1 };
            return font;
        }

        text: processText(sensorValue)
        color: Kirigami.Theme.textColor
    }

    PlasmaComponents.Label {
        id: nameLabel
        Layout.alignment: Qt.AlignRight

        opacity: 0.6

        font: {
            let font = Object.assign({}, Kirigami.Theme.smallFont);
            font.pointSize *= fontScale;
            font.pixelSize = undefined;
            font.features = { "tnum": 1 };
            return font;
        }

        text: processText(sensorName)
        color: Kirigami.Theme.textColor
    }

    function processText(text : string) : string {
        if (removeDecimalPoint) {
            return text.replace(/\.\d+/, "");
        } else {
            return text;
        }
    }
}
