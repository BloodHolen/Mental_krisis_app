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

    // ==================== НАСТРОЙКИ ПОДКЛЮЧЕНИЯ К БАЗЕ ДАННЫХ ====================
    // Чтобы изменить IP адрес сервера, найдите в main.cpp следующие строки:
    // db.setHostName("localhost"); // ← Измените "localhost" на нужный IP
    // db.setPort(5432);           // ← Порт PostgreSQL
    // db.setUserName("postgres");  // ← Имя пользователя
    // db.setPassword("postgres");  // ← Пароль
    // ============================================================================

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

    // Функция для получения цвета в зависимости от значения (0-100)
    function getValueColor(value) {
        if (value < 30) return "#4CAF50";      // зеленый
        else if (value < 70) return "#FF9800"; // оранжевый
        else return "#F44336";                // красный
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
            tab4Slider.value = tab4Value;
            tab4SpinBox.value = tab4Value;
            tab5TextArea.text = tab5Text;

            // Переключаемся на вкладку редактирования
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
        if (record.tab4_value > 0) summary += "Ч:" + record.tab4_value + " ";
        if (record.tab5_text && record.tab5_text.length > 0) summary += "Т3";
        return summary.trim() || "Только время";
    }

    // Верхняя панель с вкладками
    Row {
        id: tabBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height / 14
        spacing: 0

        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 0 ? "green" : "lightgreen"
            border.width: 1
            border.color: "black"
            Text {
                anchors.centerIn: parent
                text: "Записи"
                color: "white"
                font.pixelSize: parent.height * 0.3
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 0
            }
        }

        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 1 ? "red" : "pink"
            border.width: 1
            border.color: "black"
            Text {
                anchors.centerIn: parent
                text: "Текст 1"
                color: "white"
                font.pixelSize: parent.height * 0.3
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 1
            }
        }

        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 2 ? "lightgray" : "white"
            border.width: 1
            border.color: "black"
            Text {
                anchors.centerIn: parent
                text: "Текст 2"
                font.pixelSize: parent.height * 0.3
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 2
            }
        }

        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 3 ? "blue" : "lightblue"
            border.width: 1
            border.color: "black"
            Text {
                anchors.centerIn: parent
                text: "Число"
                color: "white"
                font.pixelSize: parent.height * 0.3
            }
            MouseArea {
                anchors.fill: parent
                onClicked: currentTabIndex = 3
            }
        }

        Rectangle {
            width: parent.width/5
            height: parent.height
            color: currentTabIndex === 4 ? "purple" : "lavender"
            border.width: 1
            border.color: "black"
            Text {
                anchors.centerIn: parent
                text: "Текст 3"
                color: "white"
                font.pixelSize: parent.height * 0.3
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

        // Вкладка 0: Список записей и управление временем
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
                    Layout.preferredHeight: mainContent.height * 0.08
                    color: isToday ? "#E8F5E9" : "#FFF3E0"
                    border.width: 1
                    border.color: isToday ? "#4CAF50" : "#FF9800"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5

                        Text {
                            text: isToday ? "Сегодня" : formatDate(currentDateTime)
                            font.bold: true
                            font.pixelSize: mainContent.height * 0.035
                            color: isToday ? "#4CAF50" : "#FF9800"
                        }

                        Item { Layout.fillWidth: true }

                        Button {
                            text: "Сегодня"
                            Layout.preferredHeight: parent.height * 0.8
                            font.pixelSize: mainContent.height * 0.025
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

                // Управление временем
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainContent.height * 0.1
                    spacing: 5

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 2
                            Text {
                                text: "Дата:"
                                font.pixelSize: mainContent.height * 0.025
                            }
                            TextField {
                                id: dateField
                                Layout.fillWidth: true
                                text: formatDate(currentDateTime)
                                font.pixelSize: mainContent.height * 0.025
                                onEditingFinished: {
                                    var dateParts = text.split(".");
                                    if (dateParts.length === 3) {
                                        var day = parseInt(dateParts[0]);
                                        var month = parseInt(dateParts[1]) - 1;
                                        var year = parseInt(dateParts[2]);
                                        var newDate = new Date(year, month, day);
                                        newDate.setHours(currentDateTime.getHours());
                                        newDate.setMinutes(currentDateTime.getMinutes());
                                        currentDateTime = newDate;
                                        updateRecords();
                                    }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 2
                            Text {
                                text: "Время:"
                                font.pixelSize: mainContent.height * 0.025
                            }
                            TextField {
                                id: timeField
                                Layout.fillWidth: true
                                text: formatTime(currentDateTime)
                                font.pixelSize: mainContent.height * 0.025
                                onEditingFinished: {
                                    var timeParts = text.split(":");
                                    if (timeParts.length >= 2) {
                                        currentDateTime = new Date(currentDateTime.getFullYear(),
                                                                  currentDateTime.getMonth(),
                                                                  currentDateTime.getDate(),
                                                                  parseInt(timeParts[0]),
                                                                  parseInt(timeParts[1]));
                                    }
                                }
                            }
                            Button {
                                text: "Сейчас"
                                Layout.preferredHeight: timeField.height
                                font.pixelSize: mainContent.height * 0.025
                                onClicked: {
                                    currentDateTime = database.currentDateTime();
                                }
                            }
                        }
                    }
                }

                // Быстрые интервалы времени
                GridLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: mainContent.height * 0.12
                    columns: 3
                    columnSpacing: 2
                    rowSpacing: 2

                    Button {
                        text: "+15"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() + 15);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "+30"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() + 30);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "+1ч"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setHours(newTime.getHours() + 1);
                            currentDateTime = newTime;
                        }
                    }

                    Button {
                        text: "-15"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() - 15);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "-30"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
                        onClicked: {
                            var newTime = new Date(currentDateTime);
                            newTime.setMinutes(newTime.getMinutes() - 30);
                            currentDateTime = newTime;
                        }
                    }
                    Button {
                        text: "-1ч"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: mainContent.height * 0.02
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

                    ColumnLayout {
                        anchors.fill: parent

                        Text {
                            text: "Записи за " + formatDate(currentDateTime) + " (" + recordsList.length + ")"
                            font.bold: true
                            font.pixelSize: mainContent.height * 0.03
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 5
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            anchors.margins: 2
                            clip: true

                            Column {
                                width: parent.width
                                spacing: 1

                                Repeater {
                                    model: recordsList

                                    Rectangle {
                                        width: parent.width
                                        height: mainContent.height * 0.1
                                        color: index % 2 === 0 ? "#F5F5F5" : "#FFFFFF"
                                        border.width: 1
                                        border.color: "#E0E0E0"

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 5

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2

                                                Text {
                                                    text: formatTimeShort(modelData.record_time)
                                                    font.bold: true
                                                    font.pixelSize: mainContent.height * 0.025
                                                    color: "#2196F3"
                                                }

                                                Text {
                                                    text: getRecordSummary(modelData)
                                                    font.pixelSize: mainContent.height * 0.02
                                                    color: "#666"
                                                }
                                            }

                                            Button {
                                                text: "✏️"
                                                Layout.preferredWidth: mainContent.height * 0.08
                                                Layout.preferredHeight: mainContent.height * 0.08
                                                font.pixelSize: mainContent.height * 0.025
                                                onClicked: {
                                                    loadRecord(modelData.id);
                                                }
                                            }

                                            Button {
                                                text: "🗑️"
                                                Layout.preferredWidth: mainContent.height * 0.08
                                                Layout.preferredHeight: mainContent.height * 0.08
                                                font.pixelSize: mainContent.height * 0.025
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
                                    height: mainContent.height * 0.1
                                    text: "Нет записей"
                                    color: "#999"
                                    font.pixelSize: mainContent.height * 0.025
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

        // Вкладка 1: Текст 1
        Item {
            visible: currentTabIndex === 1
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Текст 1"
                    font.bold: true
                    font.pixelSize: mainContent.height * 0.04
                    color: "#D32F2F"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab1TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: mainContent.height * 0.03
                    onTextChanged: tab1Text = text
                }
            }
        }

        // Вкладка 2: Текст 2
        Item {
            visible: currentTabIndex === 2
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Текст 2"
                    font.bold: true
                    font.pixelSize: mainContent.height * 0.04
                    color: "#616161"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab2TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: mainContent.height * 0.03
                    onTextChanged: tab2Text = text
                }
            }
        }

        // Вкладка 3: Число
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
                    font.pixelSize: mainContent.height * 0.04
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
                        font.pixelSize: mainContent.height * 0.03
                    }

                    SpinBox {
                        id: tab4SpinBox
                        from: 0
                        to: 100
                        value: tab4Value
                        onValueChanged: tab4Value = value
                        Layout.preferredWidth: mainContent.width * 0.3
                        font.pixelSize: mainContent.height * 0.025
                    }

                    Rectangle {
                        width: mainContent.width * 0.4
                        height: mainContent.height * 0.1
                        color: "#E3F2FD"
                        border.width: 2
                        border.color: "#1976D2"
                        radius: 5

                        Text {
                            anchors.centerIn: parent
                            text: tab4Value
                            font.bold: true
                            font.pixelSize: mainContent.height * 0.05
                            color: "#1976D2"
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        // Вкладка 4: Текст 3
        Item {
            visible: currentTabIndex === 4
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: "Текст 3"
                    font.bold: true
                    font.pixelSize: mainContent.height * 0.04
                    color: "#7B1FA2"
                    Layout.alignment: Qt.AlignHCenter
                }

                TextArea {
                    id: tab5TextArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Введите текст..."
                    wrapMode: TextArea.Wrap
                    font.pixelSize: mainContent.height * 0.03
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
        height: parent.height / 10
        color: "#F5F5F5"
        border.width: 1
        border.color: "#E0E0E0"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5

            // Индикатор режима
            Text {
                text: isEditMode ? "✏️ Редакт." : "➕ Новая"
                color: isEditMode ? "#FF9800" : "#4CAF50"
                font.pixelSize: bottomPanel.height * 0.25
                Layout.preferredWidth: bottomPanel.width * 0.2
            }

            // Время и дата
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: formatDate(currentDateTime)
                    font.pixelSize: bottomPanel.height * 0.2
                    color: "#666"
                }

                Text {
                    text: formatTime(currentDateTime)
                    font.pixelSize: bottomPanel.height * 0.25
                    color: "#2196F3"
                    font.bold: true
                }
            }

            // Кнопки управления
            Row {
                spacing: 2

                Button {
                    text: "🆕"
                    width: bottomPanel.height * 0.8
                    height: bottomPanel.height * 0.8
                    font.pixelSize: bottomPanel.height * 0.4
                    onClicked: {
                        resetForm();
                        saveIndicator.text = "🆕";
                        saveIndicator.color = "#2196F3";
                        newIndicatorTimer.start();
                    }
                }

                Button {
                    text: "🗑️"
                    width: bottomPanel.height * 0.8
                    height: bottomPanel.height * 0.8
                    font.pixelSize: bottomPanel.height * 0.4
                    onClicked: {
                        tab1Text = "";
                        tab2Text = "";
                        tab3Text = "";
                        tab4Value = 0;
                        tab5Text = "";
                        tab1TextArea.text = "";
                        tab2TextArea.text = "";
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
                    width: bottomPanel.height * 0.8
                    height: bottomPanel.height * 0.8
                    font.pixelSize: bottomPanel.height * 0.4
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
                font.pixelSize: bottomPanel.height * 0.4
                font.bold: true
                Layout.preferredWidth: bottomPanel.height * 0.8
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
        width: parent.width * 0.8
        height: parent.height * 0.2
        modal: true

        property int recordId: -1

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Text {
                text: "Удалить эту запись?"
                font.pixelSize: deleteDialog.height * 0.15
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
        dateField.text = formatDate(currentDateTime);
        timeField.text = formatTime(currentDateTime);
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
