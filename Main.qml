import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: mainWindow
    width: 360
    height: 640
    visible: true
    title: "Mental Krisis App"

    // Данные для текущей записи
    property date currentDateTime: database.currentDateTime()
    property string tab1Text: ""
    property string tab2Text: ""
    property string tab3Text: ""
    property int tab4Value: 0
    property string tab5Text: ""
    property int currentRecordId: 0
    property bool isEditMode: false

    // Текущая активная вкладка
    property int currentTabIndex: 0

    // Список записей за текущую дату
    property var recordsList: []

    // Функция для форматирования даты
    function formatDate(date) {
        return Qt.formatDate(date, "dd.MM.yyyy")
    }

    // Функция для форматирования времени
    function formatTime(date) {
        return Qt.formatTime(date, "HH:mm")
    }

    // Функция для форматирования времени для кнопок
    function formatTimeShort(date) {
        return Qt.formatTime(date, "HH:mm:ss")
    }

    // Флаг, показывающий, что сегодняшний день
    property bool isToday: {
        var today = new Date();
        return currentDateTime.getDate() === today.getDate() &&
               currentDateTime.getMonth() === today.getMonth() &&
               currentDateTime.getFullYear() === today.getFullYear();
    }

    // Функция обновления списка записей
    function updateRecords() {
        recordsList = database.getRecordsForDate(currentDateTime);
    }

    // Функция загрузки записи в форму
    function loadRecord(recordId) {
        var record = database.getRecordById(recordId);
        if (record && record.id) {
            currentRecordId = record.id;
            currentDateTime = record.record_time;
            tab1Text = record.tab1_text || "";
            tab2Text = record.tab2_text || "";
            tab3Text = record.tab3_text || "";
            tab4Value = record.tab4_value || 0;
            tab5Text = record.tab5_text || "";
            isEditMode = true;

            // Обновляем UI элементы
            tab1TextArea.text = tab1Text;
            tab2TextArea.text = tab2Text;
            tab3TextArea.text = tab3Text;
            tab4Slider.value = tab4Value;
            tab4SpinBox.value = tab4Value;
            tab5TextArea.text = tab5Text;

            // Переключаемся на вторую вкладку (Текст 1)
            currentTabIndex = 1;
        }
    }

    // Функция сброса формы
    function resetForm() {
        currentRecordId = 0;
        currentDateTime = database.currentDateTime();
        tab1Text = "";
        tab2Text = "";
        tab3Text = "";
        tab4Value = 0;
        tab5Text = "";
        tab1TextArea.text = "";
        tab2TextArea.text = "";
        tab3TextArea.text = "";
        tab4Slider.value = 0;
        tab4SpinBox.value = 0;
        tab5TextArea.text = "";
        isEditMode = false;
        currentTabIndex = 0;
    }

    // Функция для получения краткого описания записи
    function getRecordSummary(record) {
        var summary = "";
        if (record.tab1_text && record.tab1_text.length > 0) summary += "Т1 ";
        if (record.tab2_text && record.tab2_text.length > 0) summary += "Т2 ";
        if (record.tab3_text && record.tab3_text.length > 0) summary += "Т3 ";
        if (record.tab4_value > 0) summary += "Ч:" + record.tab4_value + " ";
        if (record.tab5_text && record.tab5_text.length > 0) summary += "Т4";
        return summary.trim() || "Только время";
    }

    // Верхняя панель с вкладками (компактная)
    Row {
        id: tabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        spacing: 0

        // Вкладка 0: Записи
        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 0 ? "#4CAF50" : "#E8F5E9"
            border.width: 1
            border.color: "#388E3C"
            Text {
                anchors.centerIn: parent
                text: "Записи"
                color: currentTabIndex === 0 ? "white" : "#388E3C"
                font.pixelSize: 12
                font.bold: currentTabIndex === 0
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 0
            }
        }

        // Вкладка 1: Текст 1
        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 1 ? "#F44336" : "#FFEBEE"
            border.width: 1
            border.color: "#D32F2F"
            Text {
                anchors.centerIn: parent
                text: "Текст 1"
                color: currentTabIndex === 1 ? "white" : "#D32F2F"
                font.pixelSize: 12
                font.bold: currentTabIndex === 1
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 1
            }
        }

        // Вкладка 2: Текст 2
        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 2 ? "#9E9E9E" : "#FAFAFA"
            border.width: 1
            border.color: "#616161"
            Text {
                anchors.centerIn: parent
                text: "Текст 2"
                color: currentTabIndex === 2 ? "white" : "#616161"
                font.pixelSize: 12
                font.bold: currentTabIndex === 2
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 2
            }
        }

        // Вкладка 3: Число (синий)
        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 3 ? "#2196F3" : "#E3F2FD"
            border.width: 1
            border.color: "#1976D2"
            Text {
                anchors.centerIn: parent
                text: "Число"
                color: currentTabIndex === 3 ? "white" : "#1976D2"
                font.pixelSize: 12
                font.bold: currentTabIndex === 3
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 3
            }
        }

        // Вкладка 4: Текст 3 (фиолетовый)
        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 4 ? "#9C27B0" : "#F3E5F5"
            border.width: 1
            border.color: "#7B1FA2"
            Text {
                anchors.centerIn: parent
                text: "Текст 3"
                color: currentTabIndex === 4 ? "white" : "#7B1FA2"
                font.pixelSize: 12
                font.bold: currentTabIndex === 4
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 4
            }
        }
    }

    // Основной контент
    Rectangle {
        id: mainContent
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: bottomPanel.top
        color: "#FFFFFF"

        // Вкладка 0: Список записей
        Item {
            visible: currentTabIndex === 0
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5

                // Заголовок с датой
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: isToday ? "#E8F5E9" : "#FFF3E0"
                    border.width: 1
                    border.color: isToday ? "#4CAF50" : "#FF9800"
                    radius: 5

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: isToday ? "Сегодня" : formatDate(currentDateTime)
                                font.bold: true
                                font.pixelSize: 14
                                color: isToday ? "#4CAF50" : "#FF9800"
                            }

                            Text {
                                text: formatTime(currentDateTime)
                                font.pixelSize: 12
                                color: "#666"
                            }
                        }

                        Column {
                            spacing: 2

                            Button {
                                text: "Сейчас"
                                width: 70
                                height: 25
                                font.pixelSize: 10
                                onClicked: {
                                    currentDateTime = database.currentDateTime();
                                }
                            }

                            Button {
                                text: "Сегодня"
                                width: 70
                                height: 25
                                font.pixelSize: 10
                                onClicked: {
                                    var today = new Date();
                                    currentDateTime = new Date(today.getFullYear(),
                                                              today.getMonth(),
                                                              today.getDate(),
                                                              currentDateTime.getHours(),
                                                              currentDateTime.getMinutes());
                                    updateRecords();
                                }
                            }
                        }
                    }
                }

                // Управление временем
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    columns: 3
                    columnSpacing: 2
                    rowSpacing: 2

                    Button {
                        text: "+15 мин"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() + 15);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "+30 мин"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() + 30);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "+1 час"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setHours(newTime.getHours() + 1);
                            currentDateTime = newTime;
                        }
                    }

                    Button {
                        text: "-15 мин"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() - 15);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "-30 мин"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() - 30);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "-1 час"
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        font.pixelSize: 11
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setHours(newTime.getHours() - 1);
                            currentDateTime = newTime;
                        }
                    }
                }

                // Список записей
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#FFFFFF"
                    border.width: 1
                    border.color: "#E0E0E0"
                    radius: 5

                    ColumnLayout {
                        anchors.fill: parent

                        Text {
                            text: "Записи за " + formatDate(currentDateTime) + " (" + recordsList.length + ")"
                            font.bold: true
                            font.pixelSize: 12
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 5
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true

                            Column {
                                width: parent.width
                                spacing: 1

                                Repeater {
                                    model: recordsList

                                    Rectangle {
                                        width: parent.width
                                        height: 50
                                        color: index % 2 === 0 ? "#F5F5F5" : "#FFFFFF"
                                        border.width: 1
                                        border.color: "#E0E0E0"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 3

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 1

                                                Text {
                                                    text: formatTimeShort(modelData.record_time)
                                                    font.bold: true
                                                    font.pixelSize: 12
                                                    color: "#2196F3"
                                                }

                                                Text {
                                                    text: getRecordSummary(modelData)
                                                    font.pixelSize: 10
                                                    color: "#666"
                                                    elide: Text.ElideRight
                                                }
                                            }

                                            Button {
                                                text: "✏️"
                                                Layout.preferredWidth: 35
                                                Layout.preferredHeight: 35
                                                font.pixelSize: 14
                                                onClicked: {
                                                    loadRecord(modelData.id);
                                                }
                                            }

                                            Button {
                                                text: "🗑️"
                                                Layout.preferredWidth: 35
                                                Layout.preferredHeight: 35
                                                font.pixelSize: 14
                                                background: Rectangle {
                                                    color: "#F44336"
                                                    radius: 3
                                                }
                                                onClicked: {
                                                    deleteDialog.recordId = modelData.id;
                                                    deleteDialog.open();
                                                }
                                            }
                                        }
                                    }
                                }

                                Text {
                                    width: parent.width
                                    height: 50
                                    text: "Нет записей"
                                    color: "#999"
                                    font.pixelSize: 12
                                    font.italic: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    visible: recordsList.length === 0
                                }
                            }
                        }
                    }
                }
            }
        }

        // Вкладка 1: Текст 1 (полный экран)
        Item {
            visible: currentTabIndex === 1
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5

                Text {
                    text: "Текст 1"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#D32F2F"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab1TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 14
                    onTextChanged: tab1Text = text
                }
            }
        }

        // Вкладка 2: Текст 2 (полный экран)
        Item {
            visible: currentTabIndex === 2
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5

                Text {
                    text: "Текст 2"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#616161"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab2TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 14
                    onTextChanged: tab2Text = text
                }
            }
        }

        // Вкладка 3: Число (полный экран)
        Item {
            visible: currentTabIndex === 3
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text {
                    text: "Число от 0 до 100"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#1976D2"
                    Layout.alignment: Qt.AlignHCenter
                }

                Slider {
                    id: tab4Slider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    value: tab4Value
                    onValueChanged: tab4Value = Math.round(value)
                }

                RowLayout {
                    spacing: 10
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: "Значение:"
                        font.bold: true
                        font.pixelSize: 14
                    }

                    SpinBox {
                        id: tab4SpinBox
                        from: 0
                        to: 100
                        value: tab4Value
                        onValueChanged: tab4Value = value
                        width: 80
                        font.pixelSize: 12
                    }

                    Rectangle {
                        width: 60
                        height: 35
                        color: "#E3F2FD"
                        border.width: 2
                        border.color: "#1976D2"
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: tab4Value
                            font.bold: true
                            font.pixelSize: 16
                            color: "#1976D2"
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Вкладка 4: Текст 3 (полный экран)
        Item {
            visible: currentTabIndex === 4
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 5

                Text {
                    text: "Текст 3"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#7B1FA2"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab5TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: 14
                    onTextChanged: tab5Text = text
                }
            }
        }
    }

    // Нижняя панель управления
    Rectangle {
        id: bottomPanel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#F5F5F5"
        border.width: 1
        border.color: "#E0E0E0"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 3

            // Индикатор режима
            Text {
                text: isEditMode ? "✏️ Ред." : "➕ Нов."
                color: isEditMode ? "#FF9800" : "#4CAF50"
                font.pixelSize: 12
                Layout.preferredWidth: 60
            }

            // Время и дата
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: formatDate(currentDateTime)
                    font.pixelSize: 11
                    color: "#666"
                }

                Text {
                    text: formatTime(currentDateTime)
                    font.pixelSize: 12
                    color: "#2196F3"
                    font.bold: true
                }
            }

            // Кнопки управления
            Row {
                spacing: 3

                Button {
                    text: "🆕"
                    width: 35
                    height: 35
                    font.pixelSize: 14
                    onClicked: {
                        resetForm();
                        saveIndicator.text = "🆕";
                        saveIndicator.color = "#2196F3";
                        newIndicatorTimer.start();
                    }
                }

                Button {
                    text: "🗑️"
                    width: 35
                    height: 35
                    font.pixelSize: 14
                    onClicked: {
                        tab1Text = "";
                        tab2Text = "";
                        tab3Text = "";
                        tab4Value = 0;
                        tab5Text = "";
                        tab1TextArea.text = "";
                        tab2TextArea.text = "";
                        tab3TextArea.text = "";
                        tab4Slider.value = 0;
                        tab4SpinBox.value = 0;
                        tab5TextArea.text = "";

                        saveIndicator.text = "↺";
                        saveIndicator.color = "#FF9800";
                        clearIndicatorTimer.start();
                    }
                }

                Button {
                    text: isEditMode ? "💾" : "✓"
                    width: 35
                    height: 35
                    font.pixelSize: 14
                    background: Rectangle {
                        color: isEditMode ? "#FF9800" : "#4CAF50"
                        radius: 5
                    }
                    onClicked: {
                        var success;
                        if (isEditMode) {
                            success = database.updateRecord(currentRecordId, currentDateTime,
                                                           tab1Text, tab2Text, tab3Text,
                                                           tab4Value, tab5Text);
                            if (success) {
                                saveIndicator.text = "✓";
                                saveIndicator.color = "#FF9800";
                                updateRecords();
                            } else {
                                saveIndicator.text = "✗";
                                saveIndicator.color = "#F44336";
                            }
                        } else {
                            success = database.saveRecord(currentDateTime,
                                                         tab1Text, tab2Text, tab3Text,
                                                         tab4Value, tab5Text);
                            if (success) {
                                saveIndicator.text = "✓";
                                saveIndicator.color = "#4CAF50";
                                resetForm();
                                updateRecords();
                            } else {
                                saveIndicator.text = "✗";
                                saveIndicator.color = "#F44336";
                            }
                        }

                        saveIndicatorTimer.restart();
                    }
                }
            }

            // Индикатор сохранения
            Text {
                id: saveIndicator
                text: ""
                font.pixelSize: 14
                font.bold: true
                width: 35
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Timer {
            id: saveIndicatorTimer
            interval: 2000
            onTriggered: {
                saveIndicator.text = "";
            }
        }

        Timer {
            id: clearIndicatorTimer
            interval: 1000
            onTriggered: {
                saveIndicator.text = "";
            }
        }

        Timer {
            id: newIndicatorTimer
            interval: 1000
            onTriggered: {
                saveIndicator.text = "";
            }
        }
    }

    // Диалог подтверждения удаления
    Dialog {
        id: deleteDialog
        title: "Удаление записи"
        anchors.centerIn: parent
        width: 280
        height: 120
        modal: true

        property int recordId: -1

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Text {
                text: "Удалить эту запись?"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
            }

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: "Отмена"
                    Layout.fillWidth: true
                    onClicked: deleteDialog.close()
                }

                Button {
                    text: "Удалить"
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: "#F44336"
                    }
                    contentItem: Text {
                        text: "Удалить"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (database.deleteRecord(deleteDialog.recordId)) {
                            updateRecords();
                            if (currentRecordId === deleteDialog.recordId) {
                                resetForm();
                            }
                            deleteDialog.close();
                        }
                    }
                }
            }
        }
    }

    // Обновляем поля при изменении даты/времени
    onCurrentDateTimeChanged: {
        updateRecords();
    }

    // Обновляем список записей при сохранении, обновлении или удалении
    Connections {
        target: database
        onRecordSaved: updateRecords()
        onRecordUpdated: updateRecords()
        onRecordDeleted: updateRecords()
    }

    // Инициализация при загрузке
    Component.onCompleted: {
        updateRecords();
    }
}
