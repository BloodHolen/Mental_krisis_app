import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: mainWindow
    width: 1000
    height: 700
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

    // Функция для форматирования времени с секундами (для отображения записей)
    function formatDateTime(date) {
        return Qt.formatDateTime(date, "dd.MM.yyyy HH:mm:ss")
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

    // Функция для получения краткого текста
    function getShortText(text, maxLength) {
        if (text.length <= maxLength) return text;
        return text.substring(0, maxLength) + "...";
    }

    // Основной контейнер
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Левая панель - управление и вкладки
        ColumnLayout {
            Layout.preferredWidth: 600
            Layout.fillHeight: true
            spacing: 0

            // Верхняя панель с вкладками
            Row {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 0

                Rectangle {
                    width: parent.width/5
                    height: parent.height
                    color: swipeView.currentIndex === 0 ? "#4CAF50" : "#E8F5E9"
                    border.width: 1
                    border.color: "#388E3C"
                    Text {
                        anchors.centerIn: parent
                        text: "Время"
                        color: swipeView.currentIndex === 0 ? "white" : "#388E3C"
                        font.bold: swipeView.currentIndex === 0
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: swipeView.currentIndex = 0
                    }
                }

                Rectangle {
                    width: parent.width/5
                    height: parent.height
                    color: swipeView.currentIndex === 1 ? "#F44336" : "#FFEBEE"
                    border.width: 1
                    border.color: "#D32F2F"
                    Text {
                        anchors.centerIn: parent
                        text: "Текст 1"
                        color: swipeView.currentIndex === 1 ? "white" : "#D32F2F"
                        font.bold: swipeView.currentIndex === 1
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: swipeView.currentIndex = 1
                    }
                }

                Rectangle {
                    width: parent.width/5
                    height: parent.height
                    color: swipeView.currentIndex === 2 ? "#9E9E9E" : "#FAFAFA"
                    border.width: 1
                    border.color: "#616161"
                    Text {
                        anchors.centerIn: parent
                        text: "Текст 2"
                        color: swipeView.currentIndex === 2 ? "white" : "#616161"
                        font.bold: swipeView.currentIndex === 2
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: swipeView.currentIndex = 2
                    }
                }

                Rectangle {
                    width: parent.width/5
                    height: parent.height
                    color: swipeView.currentIndex === 3 ? "#2196F3" : "#E3F2FD"
                    border.width: 1
                    border.color: "#1976D2"
                    Text {
                        anchors.centerIn: parent
                        text: "Число"
                        color: swipeView.currentIndex === 3 ? "white" : "#1976D2"
                        font.bold: swipeView.currentIndex === 3
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: swipeView.currentIndex = 3
                    }
                }

                Rectangle {
                    width: parent.width/5
                    height: parent.height
                    color: swipeView.currentIndex === 4 ? "#9C27B0" : "#F3E5F5"
                    border.width: 1
                    border.color: "#7B1FA2"
                    Text {
                        anchors.centerIn: parent
                        text: "Текст 3"
                        color: swipeView.currentIndex === 4 ? "white" : "#7B1FA2"
                        font.bold: swipeView.currentIndex === 4
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: swipeView.currentIndex = 4
                    }
                }
            }

            // Основной контент - SwipeView с вкладками
            SwipeView {
                id: swipeView
                Layout.fillWidth: true
                Layout.fillHeight: true
                interactive: false

                // Вкладка 1: Время
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 10

                        Text {
                            text: isToday ? "Сегодня" : formatDate(currentDateTime)
                            font.bold: true
                            font.pixelSize: 18
                            color: isToday ? "#4CAF50" : "#FF9800"
                        }

                        // Выбор даты
                        RowLayout {
                            spacing: 10
                            Label {
                                text: "Дата:"
                                Layout.preferredWidth: 50
                            }
                            TextField {
                                id: dateField
                                Layout.fillWidth: true
                                text: formatDate(currentDateTime)
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
                            Button {
                                text: "Сегодня"
                                Layout.preferredWidth: 100
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

                        // Выбор времени
                        RowLayout {
                            spacing: 10
                            Label {
                                text: "Время:"
                                Layout.preferredWidth: 50
                            }
                            TextField {
                                id: timeField
                                Layout.fillWidth: true
                                text: formatTime(currentDateTime)
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
                                Layout.preferredWidth: 100
                                onClicked: {
                                    currentDateTime = database.currentDateTime();
                                }
                            }
                        }

                        // Быстрые интервалы времени
                        Text {
                            text: "Быстрое изменение времени:"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        GridLayout {
                            columns: 3
                            columnSpacing: 5
                            rowSpacing: 5

                            Button {
                                text: "+15 мин"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setMinutes(newTime.getMinutes() + 15);
                                    currentDateTime = newTime;
                                }
                            }
                            Button {
                                text: "+30 мин"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setMinutes(newTime.getMinutes() + 30);
                                    currentDateTime = newTime;
                                }
                            }
                            Button {
                                text: "+1 час"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setHours(newTime.getHours() + 1);
                                    currentDateTime = newTime;
                                }
                            }

                            Button {
                                text: "-15 мин"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setMinutes(newTime.getMinutes() - 15);
                                    currentDateTime = newTime;
                                }
                            }
                            Button {
                                text: "-30 мин"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setMinutes(newTime.getMinutes() - 30);
                                    currentDateTime = newTime;
                                }
                            }
                            Button {
                                text: "-1 час"
                                Layout.fillWidth: true
                                onClicked: {
                                    var newTime = new Date(currentDateTime);
                                    newTime.setHours(newTime.getHours() - 1);
                                    currentDateTime = newTime;
                                }
                            }
                        }
                    }
                }

                // Вкладка 2: Текст 1
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "Текстовое поле 1"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#D32F2F"
                        }

                        TextArea {
                            id: tab1TextArea
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "Введите текст для вкладки 1..."
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14
                            onTextChanged: tab1Text = text
                        }
                    }
                }

                // Вкладка 3: Текст 2
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "Текстовое поле 2"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#616161"
                        }

                        TextArea {
                            id: tab2TextArea
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "Введите текст для вкладки 2..."
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14
                            onTextChanged: tab2Text = text
                        }
                    }
                }

                // Вкладка 4: Число
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        Text {
                            text: "Число от 0 до 100"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#1976D2"
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
                            Label {
                                text: "Значение:"
                                font.bold: true
                            }
                            SpinBox {
                                id: tab4SpinBox
                                from: 0
                                to: 100
                                value: tab4Value
                                onValueChanged: tab4Value = value
                                Layout.preferredWidth: 100
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 40
                                color: "#E3F2FD"
                                border.width: 1
                                border.color: "#1976D2"
                                radius: 3
                                Text {
                                    anchors.centerIn: parent
                                    text: tab4Value
                                    font.bold: true
                                    font.pixelSize: 20
                                    color: "#1976D2"
                                }
                            }
                        }
                    }
                }

                // Вкладка 5: Текст 3
                Item {
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        Text {
                            text: "Текстовое поле 3"
                            font.bold: true
                            font.pixelSize: 16
                            color: "#7B1FA2"
                        }

                        TextArea {
                            id: tab5TextArea
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "Введите текст для вкладки 3..."
                            wrapMode: TextArea.Wrap
                            font.pixelSize: 14
                            onTextChanged: tab5Text = text
                        }
                    }
                }
            }

            // Панель управления (компактная)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#F5F5F5"
                border.width: 1
                border.color: "#E0E0E0"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 5
                    spacing: 10

                    // Индикатор сохранения
                    Rectangle {
                        id: saveIndicator
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 15
                        color: "transparent"
                        border.width: 2
                        border.color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 16
                            font.bold: true
                        }
                    }

                    // Текущая дата и время
                    Text {
                        Layout.fillWidth: true
                        text: formatDate(currentDateTime) + " " + formatTime(currentDateTime)
                        font.pixelSize: 12
                        color: "#666"
                    }

                    // Кнопки управления
                    Row {
                        spacing: 5

                        Button {
                            text: "Очистить"
                            width: 100
                            height: 30
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

                                saveIndicator.border.color = "#FF9800";
                                saveIndicator.color = "#FFF3E0";
                                saveIndicator.children[0].text = "↺";
                                saveIndicator.children[0].color = "#FF9800";
                                clearIndicatorTimer.start();
                            }
                        }

                        Button {
                            text: "Сохранить"
                            width: 100
                            height: 30
                            highlighted: true
                            onClicked: {
                                var success = database.saveRecord(currentDateTime,
                                                                 tab1Text,
                                                                 tab2Text,
                                                                 tab3Text,
                                                                 tab4Value,
                                                                 tab5Text);
                                if (success) {
                                    saveIndicator.border.color = "#4CAF50";
                                    saveIndicator.color = "#E8F5E9";
                                    saveIndicator.children[0].text = "✓";
                                    saveIndicator.children[0].color = "#4CAF50";

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

                                    swipeView.currentIndex = 0;
                                    updateRecords();
                                } else {
                                    saveIndicator.border.color = "#F44336";
                                    saveIndicator.color = "#FFEBEE";
                                    saveIndicator.children[0].text = "✗";
                                    saveIndicator.children[0].color = "#F44336";
                                }

                                saveIndicatorTimer.restart();
                            }
                        }
                    }
                }

                Timer {
                    id: saveIndicatorTimer
                    interval: 2000
                    onTriggered: {
                        saveIndicator.border.color = "transparent";
                        saveIndicator.color = "transparent";
                        saveIndicator.children[0].text = "";
                    }
                }

                Timer {
                    id: clearIndicatorTimer
                    interval: 1000
                    onTriggered: {
                        saveIndicator.border.color = "transparent";
                        saveIndicator.color = "transparent";
                        saveIndicator.children[0].text = "";
                    }
                }
            }
        }

        // Правая панель - список записей
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#FAFAFA"
            border.width: 1
            border.color: "#E0E0E0"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Заголовок панели записей
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#2196F3"

                    Text {
                        anchors.centerIn: parent
                        text: "Записи за " + formatDate(currentDateTime)
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                    }
                }

                // Список записей
                ListView {
                    id: recordsListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: recordsList
                    clip: true
                    spacing: 2

                    delegate: Rectangle {
                        width: recordsListView.width
                        height: 120
                        color: index % 2 === 0 ? "#FFFFFF" : "#F5F5F5"
                        border.width: 1
                        border.color: "#E0E0E0"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            // Левая часть - основная информация
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 5

                                // Время записи
                                Text {
                                    text: formatDateTime(modelData.record_time)
                                    font.bold: true
                                    font.pixelSize: 14
                                    color: "#2196F3"
                                }

                                // Текстовые поля
                                RowLayout {
                                    spacing: 10

                                    // Текст 1
                                    Column {
                                        visible: modelData.tab1_text && modelData.tab1_text.length > 0
                                        Text {
                                            text: "Текст 1:"
                                            font.pixelSize: 11
                                            color: "#666"
                                        }
                                        Text {
                                            text: getShortText(modelData.tab1_text, 30)
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#D32F2F"
                                        }
                                    }

                                    // Текст 2
                                    Column {
                                        visible: modelData.tab2_text && modelData.tab2_text.length > 0
                                        Text {
                                            text: "Текст 2:"
                                            font.pixelSize: 11
                                            color: "#666"
                                        }
                                        Text {
                                            text: getShortText(modelData.tab2_text, 30)
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#616161"
                                        }
                                    }

                                    // Числовое значение
                                    Column {
                                        visible: modelData.tab4_value > 0
                                        Text {
                                            text: "Значение:"
                                            font.pixelSize: 11
                                            color: "#666"
                                        }
                                        Text {
                                            text: modelData.tab4_value
                                            font.pixelSize: 16
                                            font.bold: true
                                            color: getValueColor(modelData.tab4_value)
                                        }
                                    }

                                    // Текст 3
                                    Column {
                                        visible: modelData.tab5_text && modelData.tab5_text.length > 0
                                        Text {
                                            text: "Текст 3:"
                                            font.pixelSize: 11
                                            color: "#666"
                                        }
                                        Text {
                                            text: getShortText(modelData.tab5_text, 30)
                                            font.pixelSize: 12
                                            font.bold: true
                                            color: "#7B1FA2"
                                        }
                                    }
                                }

                                // Если все поля пустые (только дата/время)
                                Text {
                                    visible: !modelData.tab1_text && !modelData.tab2_text &&
                                             !modelData.tab3_text && modelData.tab4_value === 0 &&
                                             !modelData.tab5_text
                                    text: "Только дата/время (запись не сохранена)"
                                    font.pixelSize: 12
                                    font.italic: true
                                    color: "#999"
                                }
                            }

                            // Правая часть - кнопка удаления
                            Button {
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 30
                                text: "Удалить"
                                background: Rectangle {
                                    color: "#F44336"
                                    radius: 3
                                }
                                contentItem: Text {
                                    text: "Удалить"
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    deleteDialog.recordId = modelData.id;
                                    deleteDialog.open();
                                }
                            }
                        }
                    }

                    // Если записей нет
                    Text {
                        anchors.centerIn: parent
                        visible: recordsListView.count === 0
                        text: "Нет записей за " + formatDate(currentDateTime)
                        color: "#999"
                        font.pixelSize: 16
                        font.italic: true
                    }
                }

                // Статистика
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    color: "#E3F2FD"
                    border.width: 1
                    border.color: "#BBDEFB"

                    Text {
                        anchors.centerIn: parent
                        text: "Всего записей: " + recordsListView.count
                        font.pixelSize: 12
                        color: "#1976D2"
                    }
                }
            }
        }
    }

    // Диалог подтверждения удаления
    Dialog {
        id: deleteDialog
        title: "Подтверждение удаления"
        anchors.centerIn: parent
        width: 300
        height: 150
        modal: true

        property int recordId: -1

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            Text {
                text: "Вы уверены, что хотите удалить эту запись?"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
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

    // Обновляем список записей при сохранении новой записи
    Connections {
        target: database
        onRecordSaved: {
            updateRecords();
        }
        onRecordDeleted: {
            updateRecords();
        }
    }

    // Инициализация при загрузке
    Component.onCompleted: {
        updateRecords();
    }
}
