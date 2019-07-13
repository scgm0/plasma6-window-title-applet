/*
*  Copyright 2019 Michail Vourlakos <mvourlakos@gmail.com>
*
*  This file is part of applet-window-title
*
*  Latte-Dock is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License as
*  published by the Free Software Foundation; either version 2 of
*  the License, or (at your option) any later version.
*
*  Latte-Dock is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.7

Item {
    id: latteWindowsTracker
    readonly property bool existsWindowActive: selectedTracker.lastActiveWindow.isValid && !activeTaskItem.isMinimized

    function requestToggleMaximized() {
        selectedTracker.lastActiveWindow.requestToggleMaximized();
    }

    readonly property QtObject selectedTracker: plasmoid.configuration.filterByScreen ? latteBridge.windowsTracker.currentScreen : latteBridge.windowsTracker.allScreens

    readonly property Item activeTaskItem: Item {
        id: taskInfoItem

        readonly property string appName: modelAppName !== ""  ? modelAppName : discoveredAppName
        readonly property bool isMinimized: selectedTracker.lastActiveWindow.isMinimized
        readonly property bool isMaximized: selectedTracker.lastActiveWindow.isMaximized
        readonly property bool isActive: selectedTracker.lastActiveWindow.isActive
        readonly property bool isOnAllDesktops: selectedTracker.lastActiveWindow.isOnAllDesktops
        property var icon: selectedTracker.lastActiveWindow.icon

        readonly property string modelAppName: selectedTracker.lastActiveWindow.appName

        property string title: ""
        property string discoveredAppName: ""

        function cleanupTitle() {
            var text = selectedTracker.lastActiveWindow.display;
            var t = text;
            var sep = t.lastIndexOf(" —– ");
            var spacer = 4;

            if (sep === -1) {
                sep = t.lastIndexOf(" -- ");
                spacer = 4;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" -- ");
                spacer = 4;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" — ");
                spacer = 3;
            }

            if (sep === -1) {
                sep = t.lastIndexOf(" - ");
                spacer = 3;
            }

            var dTitle = "";
            var dAppName = "";

            if (sep>-1) {
                dTitle = text.substring(0, sep);
                discoveredAppName = text.substring(sep+spacer, text.length);

                console.log(dTitle + "  **  " + modelAppName);

                if (dTitle.startsWith(modelAppName)) {
                    dTitle = discoveredAppName;
                    discoveredAppName = modelAppName;
                }
            }

            if (sep>-1) {
                title = dTitle;
            } else {
                title = t;
            }
        }

        Connections {
            target: selectedTracker.lastActiveWindow
            onDisplayChanged: taskInfoItem.cleanupTitle()
            onAppNameChanged: taskInfoItem.cleanupTitle()
        }

        Component.onCompleted: taskInfoItem.cleanupTitle()
    }
}

