import QtQuick

Window {
    id: mainWindow
    width: 360
    height: 640
    visible: true
    Row{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height / 12
        Rectangle{
            width: parent.width/5
            height: parent.height
            color: "green"
            border.pixelAligned: 2
            border.color: "black"
        }
        Rectangle{
            width: parent.width/5
            height: parent.height
            color: "red"
            border.pixelAligned: 2
            border.color: "black"
        }
        Rectangle{
            width: parent.width/5
            height: parent.height
            color: "lightgray"
            border.pixelAligned: 2
            border.color: "black"
        }
        Rectangle{
            width: parent.width/5
            height: parent.height
            color: "blue"
            border.pixelAligned: 10
            border.color: "black"
        }
        Rectangle{
            width: parent.width/5
            height: parent.height
            color: "purple"
            border.pixelAligned: 10
            border.color: "black"
        }
    }
}
