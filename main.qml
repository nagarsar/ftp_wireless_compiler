import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4
import Qt.labs.folderlistmodel 2.1

import "wifi.js" as Sender

ApplicationWindow {
    signal connectToServer(string server, string login, string password, string port)
    signal disconnectFromServer()
    signal cdDir(string dir)
    signal download(string pwd, string file)
    signal upload(string pwd, string file)

    function clearServerFiles() {
        serverFilesListModel.clear();
    }

    function addServerFile(name, isDir) {
        serverFilesListModel.append({ fileName: name, fileIsDir: isDir })
    }

    function updateProgress(got, total) {
        progressBar.value = got/total;
    }

    function log(msg) {
        logListModel.append({msgText: (new Date()).toLocaleString(locale, "dd.MM.yyyy hh.mm.ss") + ": " + msg})
        if (msg === "Connected"){
            connected=true;
            flashButton.opacity = 0.6
        }
        if (msg === "Unconnected"){
            connected=false;
            flashButton.opacity = 0
        }
    }
    function hex(msg) {
        //nameHexFilelab.append({msgText: (new Date()).toLocaleString(locale, "dd.MM.yyyy hh.mm.ss") + ": " + msg})
        //nameHexFilelab.text = msg
        hexName = msg
        console.log("hexName:", hexName)
     }


    property alias serverNameText: serverName.text
    property var locale: Qt.locale()
    property variant settings;
    property bool settingsActive: false
    property string port: "21";
    property string username: "esp8266";
    property string password: "esp8266";
    property string hexName: "";
    property string ip_address: "192.168.43.58"
    property bool connected: false


    id: mainWindow
    objectName: "mainWindow"
    title: qsTr("Wireless Compiler FTP client")
    width: 800
    height: 640
    visible: true
    //color: "#edd2a4"
    color: "#474747"
    opacity: 1

    GridView
    {
        width: parent.width
        height: parent.height
        visible: true


        Image{
            id: background
            source: "icons/fond.png"

            width: parent.width
            height: parent.height
         }
    }

            /*ProgressBar {
                id: progressBar;
                x: rectangledown.x
                y: rectangledown.y + rectangledown.height - 10
                width: rectangledown.width
                height: 10
                style: ProgressBarStyle {
                    Rectangle {
                        ColorAnimation { from: "white"; to: "black"; duration: 200 }
                    }
                }
                value: 0;
                visible: true;
            }*/

            Rectangle {
                id: rectangleup
                x: 0
                y: 0
                width: parent.width*1
                height: 60
                radius: 10
                //opacity: 0.6
                opacity: 0
                border.width: 0
                border.color: "#000000"

            }




            Rectangle {
                id: rectanglecon
                //x: serverName.x + serverName.width + parent.width*0.03125
                y: 10
                anchors.right: rectanglediscon.left
                anchors.rightMargin: 5
                width: 100
                height: rectangleup.height
                radius:50
                opacity: 0.3
                color: "#90eb1e"
                border.width: 1
                border.color: "#000000"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        parent.opacity = 1
                    }
                    onClicked: {
                        serverName.accepted();
                        serverFilesListModel.clear();
                        mainWindow.connectToServer(serverNameText, username, password, port);
                    }
                    onExited: {
                        parent.opacity = 0.3
                    }
                }
            }
            Rectangle {
                id: rectanglediscon
                //x: rectanglecon.x + rectanglecon.width
                y: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 108
                height: rectangleup.height
                radius:50
                opacity: 0.3
                color: "#f34631"
                border.width: 1
                border.color: "#000000"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 1
                    onClicked: {
                        serverName.accepted()
                        mainWindow.disconnectFromServer()
                        serverFilesListModel.clear()
                        //serverName.cursorShape = Qt.BlankCursor
                    }
                    onExited: parent.opacity = 0.3
                }
            }
            Rectangle {
                id: rectangleyourfiles
                x: rectangledown.x
                //x: mainWindow.width*0.1525
                y: rectangledown.y
                //width: parent.width*0.36125
                width: parent.width*0.4
                height: 29
                opacity: 0.9
                radius: 10
                color: "#808080"
                border.width: 1
                border.color: "#000000"
            }

            Rectangle {
                id: rectangleserverfiles
                //x: rectangleyourfiles.x + mainWindow.width*0.48625
                y: rectangledown.y
                anchors.right: parent.right
                anchors.rightMargin: 5
                width: parent.width*0.4
                height: 29
                opacity: 0.9
                radius: 10
                color: "#808080"
                border.width: 1
                border.color: "#000000"
            }
            Rectangle {
                id: rectangleupload
                x: clientFiles.x+5
                y: 200
                //width: mainWindow.width*0.425
                width: clientFiles.width + 90
                radius:10
                height: 85
                opacity: 0.6
                color: "#808080"
                border.width: 1
                border.color: "#000000"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered:
                        parent.opacity = 1
                    onClicked: {
                        serverName.accepted();
                        //parent.source = "icons/uploadDocumentOnClick.png";
                        var file = folderModel.get(clientFiles.currentIndex, "fileName");
                        var isDir = folderModel.get(clientFiles.currentIndex, "fileIsDir");
                        var pwd = folderModel.folder;
                        if (folderModel.count && !isDir) {
                            mainWindow.upload(pwd, file);
                        }
                    }
                    onExited: {
                        parent.opacity = 0.6
                    }
                }
            }
            /*Rectangle {
                id: rectangledownload
                x: rectangleserverfiles.x - mainWindow.width*0.1
                y: 323
                width: mainWindow.width
                height: 85
                opacity: 0.6
                color: "#808080"
                border.width: 1
                border.color: "#000000"
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered:
                        parent.opacity = 1

                    onExited: {
                        parent.opacity = 0.6
                    }
                }
            }*/
            Rectangle {
                id: rectangledown
                x: 5
                anchors.horizontalCenter: mainWindow.horizontalCenter
                y: 100
                width: parent.width - 10
                height: mainWindow.height*0.6015625
                color: "#ffffff"
                radius: 10
                opacity: 0.3
                //border.width: 1
                //border.color: "#000000"
            }





            Rectangle {
                id: flashButton
                y: rectangledown.height + 125
                width: parent.width
                anchors.horizontalCenter: mainWindow.horizontalCenter
                height: 35
                radius: 10
                opacity: connected === true ? 0.6 : 0
                state : connected === true ? true : false
                //color: "#07c1b7"
                border.width: 1
                border.color: "#000000"
                MouseArea {
                    id:flashButtonMA
                    anchors.fill: parent
                    hoverEnabled: connected === true ? true : false
                    onEntered: {
                        parent.opacity = 1
                        parent.color = "#f34631"
                    }

                    onExited: {
                        parent.opacity = 0.6
                        parent.color = "#ffffff"
                    }
                    onClicked: {
                        // ONCLICKKK
                        serverName.accepted()
                        log("Start Flashing: ["+hexName+"] to: "+ip_address)
                        Sender.sendWifiRequest("http://"+ip_address+"/control?name="+hexName+"&state=true")
                    }
                }


                Label {
                    id: flashButtonlab
                    anchors.fill: parent
                    anchors.horizontalCenter: flashButton.horizontalCenter
                    anchors.verticalCenter: flashButton.verticalCenter
                    height: 35
                    //width: content.width
                    text: qsTr("START FLASHING ")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pointSize: 12
                    font.family: "Courier"
                }


                Label {
                    objectName: "hexNameObject"
                    id: nameHexFilelab
                    //property string hexName: ""
                    //opacity: hexName === "" ? 0 : 1
                    //anchors.fill: parent
                    //x: flashButtonlab.x + 130
                    //anchors.left: flashButtonlab.left
                    //anchors.leftMargin: 5
                    anchors.top: flashButtonlab.bottom
                    anchors.topMargin: 1
                    anchors.horizontalCenter: flashButton.horizontalCenter
                    //anchors.verticalCenter: flashButton.verticalCenter
                    height: 35
                    width: parent.width
                    text: hexName//fileUploadedName
                    color: "#ef1010"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignHCenter
                    font.bold: true
                    font.pointSize: 12
                    font.family: "Courier"   
                }

            }









            Rectangle {
                id: rectanglelog
                x: 0
                y: rectangledown.y + rectangledown.height + 98
                anchors.right: mainWindow.right
                anchors.rightMargin: 5
                anchors.left: mainWindow.left
                anchors.leftMargin: 5
                width: parent.width
                height: mainWindow.height
                radius: 10
                opacity: 0.6
                border.width: 1
                border.color: "#000000"
                ListView {
                    id: logListView
                    width: parent.width
                    height: mainWindow.height - parent.y - 4
                    clip: true
                    model: ListModel { id: logListModel }
                    delegate: Rectangle {
                        width: parent.width
                        height: 25
                        radius: 10
                        Label {
                            id: statusLabel
                            text: msgText
                            font.family: "Arial"
                            font.italic: true
                            font.pointSize: 11
                        }
                    }
                    onCountChanged: {
                        var newIndex = count - 1 // last index
                        positionViewAtEnd()
                        currentIndex = newIndex
                    }
                }
            }

    ListView {
        id: clientFiles
        objectName: "clientFiles"
        x: rectangleyourfiles.x
        y: rectangleyourfiles.y + 32
        width: rectangleyourfiles.width
        //height: mainWindow.height*0.484375
        height: rectangledown.height - yourfileslab.height - 5
        cacheBuffer: 319
        model: folderModel
        delegate: clientFileDelegate
        clip: true
    }
    ListView {
        id: serverFiles
        objectName: "serverFiles"
        x: rectangleserverfiles.x
        y: rectangleyourfiles.y + 32
        width: rectangleserverfiles.width
        //height: mainWindow.height*0.484375
        height: rectangledown.height - yourfileslab.height - 5
        cacheBuffer: 319
        model: serverFilesListModel
        delegate: serverFileDelegate
        clip : true
    }
    Label {
        id: ftpserverlab
        x: 11
        y: 28
        height: 25
        width: 124
        text: qsTr("FTP server: ")
        font.bold: true
        font.pointSize: 12
        font.family: "Courier"
        color: "#ffffff"
    }
    TextField {
        id: serverName
        objectName: "serverName"
        x: ftpserverlab.x + ftpserverlab.width
        y: 30
        //width: parent.width*0.51625
        width: 200
        height: 30
        text: ip_address
        inputMethodHints: Qt.ImhFormattedNumbersOnly


        onFocusChanged: {
            console.log("Focus changed to "+focus);
        }
        onAccepted: {
            console.log("Force focus to secondInput");
            serverName.focus= false
        }
        Keys.onReturnPressed:{
            serverName.accepted();
        }
        Keys.onEnterPressed: {
            serverName.accepted();
        }
        z: 2
        font.bold: true
        font.family: "Courier"
        font.pointSize: 12
        style: TextFieldStyle {
            background:
                Rectangle {
                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: "#c7f4ab" //vert clair
                        }
                        GradientStop {
                            position: 1
                            color: "#a1e476" //vert foncé
                        }
                    }
                }
        }

    }

        Label {
            id: yourfileslab
            x: rectangleyourfiles.x
            y: rectangleyourfiles.y
            width: rectangleyourfiles.width
            height: rectangleyourfiles.height
            text: qsTr("Your files")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            font.family: "Courier"
            font.pointSize: 12
            font.italic: false
            font.bold: true
        }
        Label {
            id: serverfileslab
            x: rectangleserverfiles.x
            y: rectangleserverfiles.y
            width: rectangleserverfiles.width
            height: rectangleserverfiles.height
            text: qsTr("Server files")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignHCenter
            font.family: "Courier"
            font.pointSize: 12
            font.italic: false
            font.bold: true
        }
        Rectangle {
            id: connect
            x: rectanglecon.x
            y: rectanglecon.y
            width: 100
            height: 122
            color: "#00000000"

            Image{
                id: connectIcon
                width: 40
                height: rectangleup.height
                opacity: 1
                anchors.horizontalCenterOffset: 2
                source: "icons/network.png"
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter

                /*MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered:
                        parent.source = "icons/networkOnHover.png"
                    onClicked: {
                        parent.source = "icons/networkOnClick.png"
                        mainWindow.connectToServer(serverNameText, username, password, port);
                    }
                    onExited:
                        parent.source = "icons/network.png"
                }*/
            }
        }
        Rectangle {
            id: disconnect
            x: rectanglediscon.x
            y: rectanglediscon.y
            width: 108
            height: 122
            color: "#00000000"
            Image{
                id: disconnectIcon
                width: 40
                height: rectangleup.height
                opacity: 1
                anchors.horizontalCenterOffset: 1
                source: "icons/disconnect.png"
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
                /*MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.source = "icons/disconnectOnHover.png"
                    onClicked: {
                        parent.source = "icons/disconnectOnClick.png"
                        mainWindow.disconnectFromServer()
                        serverFilesListModel.clear()
                    }
                    onExited: parent.source = "icons/disconnect.png"
                }*/
            }
        }
        Rectangle {
            id: upload
            x: rectangleupload.x + rectangleupload.width - 80
            y: rectangleupload.y + 14
            width: 66
            height: 51
            color: "#00000000"
            z: 1
            Image{
                id: uploadIcon
                width: 64
                height: 64
                anchors.horizontalCenterOffset: 1
                source: "icons/uploadDocument.png"
                anchors.horizontalCenter: parent.horizontalCenter
                /*MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.source = "icons/uploadDocumentOnHover.png"
                    onClicked: {
                        parent.source = "icons/uploadDocumentOnClick.png";
                        var file = folderModel.get(clientFiles.currentIndex, "fileName");
                        var isDir = folderModel.get(clientFiles.currentIndex, "fileIsDir");
                        var pwd = folderModel.folder;
                        if (folderModel.count && !isDir) {
                            mainWindow.upload(pwd, file);
                        }
                    }
                    onExited: parent.source = "icons/uploadDocument.png"
                }*/
            }
        }
        /*Rectangle {
            id: download
            x: rectangledownload.x + 3
            y: rectangledownload.y
            width: 66
            height: 51
            color: "#00000000"
            z: 1
            Image{
                id: downloadIcon
                width: 64
                height: 64
                anchors.horizontalCenterOffset: 1
                source: "icons/downloadDocument.png"
                anchors.horizontalCenter: parent.horizontalCenter
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.source = "icons/downloadDocumentOnHover.png"
                    onClicked: {
                        parent.source = "icons/downloadDocumentOnClick.png";
                        var file = serverFilesListModel.get(serverFiles.currentIndex).fileName;
                        var isDir = serverFilesListModel.get(serverFiles.currentIndex).fileIsDir;
                        var pwd = folderModel.folder;
                        if (serverFilesListModel.count && !isDir) {
                            mainWindow.download(pwd, file);
                        }
                    }
                    onExited: parent.source = "icons/downloadDocument.png"
                }
            }
        }*/
        Label {
            id: connectlab
            x: connect.x
            y: connectIcon.height + 8
            width: connect.width
            text: qsTr("Connect")
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            font.family: "Courier"
            font.pointSize: 10
            font.italic: false
            font.bold: true
        }
        Label {
            id: disconnectlab
            x: disconnect.x
            y: disconnectIcon.height + 8
            width: disconnect.width
            text: qsTr("Disconnect")
            color: "#ffffff"
            horizontalAlignment: Text.AlignHCenter
            font.family: "Courier"
            font.pointSize: 10
            font.italic: false
            font.bold: true
        }
        Label {
            id: uploadlab
            x: upload.x
            y: upload.y - 14
            text: qsTr("Upload")
            font.italic: false
            font.pointSize: 12
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            font.family: "Courier"
        }





    FolderListModel {
        id: folderModel
        folder: Qt.platform.os === "linux" ? "/home/" : "file:///"
        showDirs: true
        showDotAndDotDot: true
        Component.onCompleted: {
            console.log(Qt.platform.os)
        }
    }

    ListModel {
        id: serverFilesListModel
        objectName: "serverFilesListModel"
    }

    Component {
        id: clientFileDelegate
        Rectangle {
            width: rectangleyourfiles.width
            //height: 25
            height: 40
            radius: 10
            border.width: 1
            border.color: "#000000"

            gradient: Gradient {
                GradientStop {
                    position: 0
                    //color: "#ffe78f"
                    color: clientFiles.currentIndex === index ? "#2596db" : "#98d8ff"
                }
                GradientStop {
                    position: 1
                    color: clientFiles.currentIndex === index ? "#2596db" : "#98d8ff"
//                    color: clientFiles.currentIndex === index ? "#a1e476" : "#f2dc61"

                }
            }
            Image{
                id: filesIcon
                x: 5;
                width: 25
                anchors.horizontalCenterOffset: 2;
                source: fileIsDir ? "icons/kdedocumentopen.ico" : "icons/files.ico";
            }
            Text { id: nameClientText; x: filesIcon.x + filesIcon.width; width: parent.width; text: " " + fileName }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    clientFiles.currentIndex = index
                }
                onDoubleClicked: {
                    if (fileIsDir) {
                        folderModel.folder = fileURL
                    }
                }
            }

        }
    }


    Component {
        id: serverFileDelegate
        Rectangle {
            id: bodyRect
            width: rectangleserverfiles.width
            height: 40
            radius: 10
            border.width: 1
            border.color: "#000000"

            gradient: Gradient {
                GradientStop {
                    position: 0
                    //color: "#ffe78f"
                    color: clientFiles.currentIndex === index ? "#2596db" : "#98d8ff"
                }
                GradientStop {
                    position: 1
                    color: clientFiles.currentIndex === index ? "#2596db" : "#98d8ff"
//                    color: clientFiles.currentIndex === index ? "#a1e476" : "#f2dc61"

                }
            }
            Image{
                id: filesIcon
                x: 5;
                width:25;
                anchors.horizontalCenterOffset: 2;
                source: fileIsDir ? "icons/kdedocumentopen.ico" : "icons/files.ico";
            }

            Text { id: nameServerText; width: parent.width; x: 25; text: " " + fileName }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    serverFiles.currentIndex = index
                }
                onDoubleClicked: {
                    var name = fileName;
                    if (fileIsDir) {
                        mainWindow.cdDir(name);
                    }
                }
            }

        }
    }
}
