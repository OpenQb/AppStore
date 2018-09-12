import ZeUi 1.0
import Qb.Core 1.0
import QtQuick 2.11

ZSOneAppUi{
    id: objMainAppUi
    dockLogo: objMainAppUi.absoluteURL("/app.svg")
    changeWindowPosition: true

    QbSettings{
        id: objSettings
        name: "AppStore"
        property alias windowWidth: objMainAppUi.windowWidth
        property alias windowHeight: objMainAppUi.windowHeight
        property alias windowX: objMainAppUi.windowX
        property alias windowY: objMainAppUi.windowY
    }

    Component.onCompleted: {
        objMainAppUi.addPage("/Home.qml",{});
    }
}
