import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page{
    id: canvasPage

    title: qsTr("Canvas Page")

    property alias newComment: newComment
//    property alias canvasMouseArea: canvasMouseArea
    property alias pinList: pinList

    ListModel{
        id: pinList
    }

    Component.onCompleted:{
        root.navBar.visible= true;
        root.navBar.flickable = flickable
        root.navBar.sheet = sheet;
        root.navBar.rcBackground = rcBackground;
        root.navBar.popup= newComment;
        root.navBar.canvasMouseArea = canvasMouseArea;
    }

    Rectangle {
        id: rcImage

        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        color: "transparent"
        clip: true

        Flickable {
            id: flickable

            width: parent.width
            height: parent.height

            contentWidth: image.width * imageScale.xScale
            contentHeight: image.height * imageScale.yScale


            Image {
                id: image

                source: "qrc:/resources/images/Bitmap.png"
                
                fillMode: Image.PreserveAspectFit
                transform: Scale {
                    id: imageScale
                    xScale: 1
                    yScale: 1
                }
            }


            Repeater{
                model: pinList

                delegate: MyPin{
                    pinId: model.pinId
                    x: model.x
                    y: model.y
                    visible: model.visible
                }
            }

            // Mouse Area To Add Pin On Click Event
            MouseArea {
                id: canvasMouseArea

                visible: true
                anchors.fill: parent

                onClicked: function(event){
                    console.log("On Clicked")
                    // Creat Pin
                    canvasPage.pinList.append({
                        pinId: canvasPage.pinList.count,
                        x: (event.x - flickable.contentX) / imageScale.xScale,
                        y: (event.y - flickable.contentY) / imageScale.yScale,
                        visible: false
                    });
                }
            }

        }
    }

    // Button Reset
    Button{
        id: zoomReset

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        text: "Reset"

        onClicked: {
            imageScale.xScale = 1;
            imageScale.yScale = 1;
            canvasPage.pinList.clear();
        }
    }

    // Button Zoom In And Zoom Out
    RowLayout{
        anchors.right: parent.right
        anchors.bottom: rcImage.bottom
        anchors.bottomMargin: 10
        anchors.rightMargin: 10

        Button{
            id: zoomIn

            text: "+"

            onClicked: {
                imageScale.xScale += 0.1;
                imageScale.yScale += 0.1;
            }
        }

        Button{
            id: zoomOut

            text: "-"

            onClicked: {
                imageScale.xScale -= 0.1;
                imageScale.yScale -= 0.1;
            }
        }
    }

    // Sheet Comment
    Rectangle {
        id: sheet

        width: parent.width
        height: parent.height

        color: "#FFF"
        radius: 10

        y: parent.height + 10
        x: 0
        z: 1

        Rectangle{
            width: 40
            height: 5
            radius: 5
            color: "#CCC"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
        }

        states: [

            State {
                name: "visible"
                PropertyChanges { target: sheet; y: canvasPage.height / 6 }
            },

            State {
                name: "hidden"
                PropertyChanges { target: sheet; y: canvasPage.height + 10 }
            }
        ]

        transitions: [

            Transition {
                from: "hidden"; to: "visible"
                NumberAnimation { properties: "y"; duration: 300 }
            },

            Transition {
                from: "visible"; to: "hidden"
                NumberAnimation { properties: "y"; duration: 300 }
            }
        ]

        Flickable{
            anchors{
                fill: parent
                topMargin: 20
                leftMargin: 10
                rightMargin: 10
            }
            clip: true
            contentHeight: clAll.implicitHeight

            ColumnLayout{
                id: clAll

                width: parent.width
                Label{
                    id: label
                    text: "Comments"
                    font.pointSize: 34
                    font.styleName: "Bold"
                    leftPadding: 20
                    bottomPadding: 15
                }

                ColumnLayout{
                    id: listInfoContent

                    Layout.fillWidth: true

                    Repeater{
                        model: root.commentList

                        delegate: CommentCumponent {
                            Layout.fillWidth: true
                            
                            commentID: model.index
                            usernameText: model.username
                            commentText: model.comment
                            timeText: model.time
                            awner: model.awner
                            replyList: model.replyList

                            Text{
                                text: model.index + " " + commentID
                            }
                        }
                    }
                }

                Rectangle{
                    opacity: 0
                    height: 100
                    Layout.fillWidth: true
                }
            }
        }
    }

    // Background
    Rectangle{
        id: rcBackground

        anchors.fill: parent
        color: "black"
        opacity: 0
        visible: false

        MouseArea{
            anchors.fill: parent

            onClicked:{
                if (sheet.state === "hidden") {
                    sheet.state = "visible";
                    rcBackground.visible = true;
                } else {
                    sheet.state = "hidden";
                    rcBackground.visible = false;
                }
            }
        }
    }

    // Input Comment
    Popup {
        id: newComment

        anchors.centerIn: parent
        width: parent.width - 40
        height: 200
        modal: true

        property string commentID: ""
        property string replyID: ""
        property string type: ""
        property alias newCommentTextField: newCommentTextField

        ColumnLayout {
            anchors.fill: parent

            Label {
                text: qsTr("New Comment")
                font.styleName: "Semibold"

                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: newCommentTextField

                placeholderText: qsTr("Enter project name")

                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                Keys.onReturnPressed: {
                    if(btnAdd.enabled)
                        btnAdd.clicked()
                }
            }

            RowLayout{
                Layout.alignment: Qt.AlignHCenter
                Button {
                    id: btnAdd
                    text: qsTr("Add Comment")

                    Layout.alignment: Qt.AlignHCenter

                    onClicked: {                       
                        var commentText = newCommentTextField.text;
                        
                        if(newComment.type === "addComment")
                            root.commentList.append({
                                username: "@user",
                                comment: newCommentTextField.text,
                                time: "Just now",
                                awner: true,
                                replyList: []
                            });

                        if(newComment.type === "updateComment")
                            root.commentList.get(newComment.commentID).comment = newCommentTextField.text;

                        if(newComment.type === "addReply")
                            root.commentList.get(newComment.commentID).replyList.append({
                                username: "@user",
                                comment: newCommentTextField.text,
                                time: "Just now",
                                awner: true
                            });

                        if(newComment.type === "updateReply")
                            root.commentList.get(newComment.commentID).replyList.get(newComment.replyID).comment = newCommentTextField.text;

                        newCommentTextField.text = "";
                        newComment.commentID = "";
                        newComment.close();
                    }
                }

                Button {
                    id: btnCancel
                    text: qsTr("Cancel")
                    flat: true

                    Layout.alignment: Qt.AlignHCenter

                    onClicked: {
                        newComment.close()
                    }
                }
            }
        }
    }

}
