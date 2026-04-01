/*
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls

import org.kde.kirigami as Kirigami

import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.faces as Faces

Kirigami.FormLayout {
    id: root

    property alias cfg_removeDecimalPoint: removeDecimalPointCheckbox.checked
    Controls.CheckBox {
        id: removeDecimalPointCheckbox
        Layout.fillWidth: true
        text: "Remove decimal point"
    }

    property alias cfg_fontScalePercent: fontScalePercentSpinBox.value
    Controls.SpinBox {
        id: fontScalePercentSpinBox
        Kirigami.FormData.label: "Font scale percent"

        stepSize: 1
        from: 10
        to: 400
    }

    property alias cfg_spacingScalePercent: spacingScalePercentSpinBox.value
    Controls.SpinBox {
        id: spacingScalePercentSpinBox
        Kirigami.FormData.label: "Sensor spacing scale percent"

        stepSize: 1
        from: 20
        to: 500
    }

    property alias cfg_nameSpacing: nameSpacingSpinBox.value
    Controls.SpinBox {
        id: nameSpacingSpinBox
        Kirigami.FormData.label: "Name Spacing px (between sensor value and name)"
        from: -60
        to: 60
        stepSize: 1
    }

    property alias cfg_paddingTop: paddingTopSpinBox.value
    Controls.SpinBox {
        id: paddingTopSpinBox
        Kirigami.FormData.label: "Padding Top px"
        from: -60
        to: 60
        stepSize: 1
    }

    property alias cfg_paddingLeft: paddingLeftSpinBox.value
    Controls.SpinBox {
        id: paddingLeftSpinBox
        Kirigami.FormData.label: "Padding Left px"
        from: 0
        to: 60
        stepSize: 1
    }

    property alias cfg_paddingRight: paddingRightSpinBox.value
    Controls.SpinBox {
        id: paddingRightSpinBox
        Kirigami.FormData.label: "Padding Right px"
        from: 0
        to: 60
        stepSize: 1
    }
}

