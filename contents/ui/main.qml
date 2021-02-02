/*
 * Copyright 2021 Michail Vourlakos <mvourlakos@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.latte.abilities.client 0.1 as AbilityClient
import org.kde.latte.abilities.items 0.1 as AbilityItem

Item {
    id: root
    Layout.fillHeight: plasmoid.formFactor !== PlasmaCore.Types.Vertical
    Layout.fillWidth: plasmoid.formFactor === PlasmaCore.Types.Vertical
    Layout.minimumWidth: -1
    Layout.minimumHeight: -1
    Layout.preferredWidth: appletAbilities.layoutWidth
    Layout.preferredHeight: appletAbilities.layoutHeight
    Layout.maximumWidth: -1
    Layout.maximumHeight: -1

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation

    readonly property bool inDesktop: plasmoid.location === PlasmaCore.Types.Floating
                                      || plasmoid.location === PlasmaCore.Types.Desktop
    readonly property bool inPlasmaPanel: !latteBridge && !inDesktop


    //BEGIN Latte Communicator
    property QtObject latteBridge: null
    //END Latte Communicator

    AbilityClient.AppletAbilities {
        id: appletAbilities
        bridge: latteBridge
        layout: list.contentItem

        //! Calculate iconSize for plasma desktop and panels
        //!   In this example iconSize is based on plasma panel thickness and has a maximum size of 64px.
        metrics.local.iconSize: Math.min(64,((plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.width : root.height) - 2*metrics.local.margin.thickness))
        metrics.local.margin.thickness: 2
        metrics.local.margin.length: 4
        //! Center items for plasma panels
        //!   All BasicItems are aligned based on the screen edge that are found. In order to center them
        //!   in plasma panels we can use the local applet screenEdge property
        metrics.local.margin.screenEdge: inPlasmaPanel ? Math.max(0, ((plasmoid.formFactor === PlasmaCore.Types.Vertical ? root.width : root.height) - metrics.local.iconSize - 2*metrics.local.margin.thickness)/2) : 0
    }

    ListModel {
        id: colorsModel
        ListElement {
            color: "red"
            tooltip: "Hello"
        }
        ListElement {
            color: "green"
            tooltip: "Latte"
        }
        ListElement {
            color: "blue"
            tooltip: "World !!!"
        }
    }

    ListView {
        id: list
        model: colorsModel

        delegate: AbilityItem.BasicItem{
            abilities: appletAbilities
            thinTooltipText: model.tooltip
            indicator.isTask: true
            indicator.isActive: activated

            property bool activated: false

            onShortcutRequestedActivate: activated = !activated;

            contentItem: Item {
                anchors.fill: parent

                Rectangle {
                    anchors.fill: parent
                    color: activated ? "purple" : model.color
                    opacity: 0.55
                    border.width: 1
                    border.color: "white"
                }

                Text {
                    anchors.centerIn: parent
                    text: itemThickness + "px."
                    color: "white"
                    font.bold: true

                    readonly property real itemThickness: {
                        var thick = Math.min(parent.width, parent.height);
                        return (thick % 10 === 0) ? thick : thick.toFixed(1);
                    }
                }
            }
        }
    }
}
