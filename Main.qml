import QtQuick

Window {
    id: mainWindow
    width: 360
    height: 640
    visible: true

    // Настройки шрифта для всех колонок
    property int columnFontSize: 24
    property color fontColor: "white"

    // Текущая активная колонка
    property int activeColumn: 0

    // Компоненты для каждой колонки
    property var columnComponents: [
        column1Component,  // Набор кнопок
        column2Component,  // Ввод текста
        column3Component,  // Слайдеры
        column4Component,  // Переключатели
        column5Component,  // Список
        column6Component   // Изображения
    ]

    Column {
        anchors.fill: parent
        spacing: 0

        // Верхняя панель с колонками
        Row {
            width: parent.width
            height: parent.height * 1/8

            Repeater {
                model: 6

                Rectangle {
                    width: parent.width / 6
                    height: parent.height
                    color: index === activeColumn ? Qt.darker(getColumnColor(index), 1.2) : getColumnColor(index)

                    // Функция для получения цвета колонки
                    function getColumnColor(idx) {
                        var colors = ["red", "green", "blue", "yellow", "orange", "purple"];
                        return colors[idx];
                    }

                    TapHandler {
                        onTapped: {
                            console.log("Колонка", index + 1)
                            activeColumn = index
                        }

                        // Визуальная обратная связь
                        onPressedChanged: {
                            if (pressed) {
                                parent.scale = 0.95
                            } else {
                                parent.scale = 1.0
                            }
                        }
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: index === 0 ? "Кнопки" :
                              index === 1 ? "Текст" :
                              index === 2 ? "Слайдеры" :
                              index === 3 ? "Перекл." :
                              index === 4 ? "Список" : "Изобр."
                        font.pixelSize: columnFontSize
                        color: fontColor
                    }
                }
            }
        }

        // Нижняя часть (динамическая)
        Loader {
            id: bodyLoader
            width: parent.width
            height: parent.height * 7/8
            sourceComponent: columnComponents[activeColumn]
        }
    }

    // === КОМПОНЕНТЫ ДЛЯ КАЖДОЙ КОЛОНКИ ===

    // Компонент 1: Набор кнопок
    Component {
        id: column1Component

        Rectangle {
            color: "#FF6B6B"

            Column {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "Панель кнопок"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Кнопка 1
                Rectangle {
                    width: 200
                    height: 50
                    color: "#4ECDC4"
                    radius: 10

                    TapHandler {
                        onTapped: console.log("Кнопка 1 нажата")
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Кнопка 1"
                        color: "white"
                    }
                }

                // Кнопка 2
                Rectangle {
                    width: 200
                    height: 50
                    color: "#FFD166"
                    radius: 10

                    TapHandler {
                        onTapped: console.log("Кнопка 2 нажата")
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Кнопка 2"
                        color: "white"
                    }
                }

                // Кнопка 3
                Rectangle {
                    width: 200
                    height: 50
                    color: "#06D6A0"
                    radius: 10

                    TapHandler {
                        onTapped: console.log("Кнопка 3 нажата")
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Кнопка 3"
                        color: "white"
                    }
                }
            }
        }
    }

    // Компонент 2: Ввод текста
    Component {
        id: column2Component

        Rectangle {
            color: "#4ECDC4"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                Text {
                    text: "Ввод текста"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Поле ввода
                Rectangle {
                    width: parent.width
                    height: 40
                    color: "white"
                    radius: 5
                    border.color: "#ccc"

                    TextInput {
                        id: textInput
                        anchors.fill: parent
                        anchors.margins: 10
                        font.pixelSize: 18
                     //   placeholderText: "Введите текст..."
                    }
                }

                // Кнопка сохранения
                Rectangle {
                    width: 150
                    height: 40
                    color: "#118AB2"
                    radius: 10

                    TapHandler {
                        onTapped: console.log("Сохранен текст:", textInput.text)
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "Сохранить"
                        color: "white"
                    }
                }

                // Отображение введенного текста
                Rectangle {
                    width: parent.width
                    height: 100
                    color: "#f0f0f0"
                    radius: 5

                    Text {
                        anchors.centerIn: parent
                        text: textInput.text || "Текст не введен"
                        color: "black"
                        font.pixelSize: 16
                        wrapMode: Text.WordWrap
                        width: parent.width - 20
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    // Компонент 3: Слайдеры
    Component {
        id: column3Component

        Rectangle {
            color: "#FFD166"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                Text {
                    text: "Слайдеры"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Слайдер 1
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Яркость: " + Math.round(slider1.value * 100) + "%"
                        color: "white"
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e0e0e0"
                        radius: 15

                        Rectangle {
                            width: (parent.width - 4) * slider1.value
                            height: parent.height - 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            color: "#3498db"
                            radius: 14
                        }

                        TapHandler {
                            onTapped: {
                                var pos = point.position.x
                                slider1.value = pos / parent.width
                            }
                        }
                    }
                }

                // Слайдер 2
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Громкость: " + Math.round(slider2.value * 100) + "%"
                        color: "white"
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e0e0e0"
                        radius: 15

                        Rectangle {
                            width: (parent.width - 4) * slider2.value
                            height: parent.height - 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            color: "#9b59b6"
                            radius: 14
                        }

                        TapHandler {
                            onTapped: {
                                var pos = point.position.x
                                slider2.value = pos / parent.width
                            }
                        }
                    }
                }

                // Слайдер 3
                Column {
                    width: parent.width
                    spacing: 5

                    Text {
                        text: "Скорость: " + Math.round(slider3.value * 100) + "%"
                        color: "white"
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        color: "#e0e0e0"
                        radius: 15

                        Rectangle {
                            width: (parent.width - 4) * slider3.value
                            height: parent.height - 4
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 2
                            color: "#e74c3c"
                            radius: 14
                        }

                        TapHandler {
                            onTapped: {
                                var pos = point.position.x
                                slider3.value = pos / parent.width
                            }
                        }
                    }
                }
            }

            // Значения слайдеров
            property real slider1: 0.5
            property real slider2: 0.3
            property real slider3: 0.7
        }
    }

    // Компонент 4: Переключатели
    Component {
        id: column4Component

        Rectangle {
            color: "#06D6A0"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.8

                Text {
                    text: "Переключатели"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Переключатель 1
                Row {
                    spacing: 10

                    Text {
                        text: "Wi-Fi"
                        color: "white"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        width: 60
                        height: 30
                        radius: 15
                        color: switch1 ? "#2ecc71" : "#e0e0e0"

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: switch1 ? parent.width - 28 : 2
                            color: "white"
                        }

                        TapHandler {
                            onTapped: switch1 = !switch1
                        }
                    }
                }

                // Переключатель 2
                Row {
                    spacing: 10

                    Text {
                        text: "Bluetooth"
                        color: "white"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        width: 60
                        height: 30
                        radius: 15
                        color: switch2 ? "#2ecc71" : "#e0e0e0"

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: switch2 ? parent.width - 28 : 2
                            color: "white"
                        }

                        TapHandler {
                            onTapped: switch2 = !switch2
                        }
                    }
                }

                // Переключатель 3
                Row {
                    spacing: 10

                    Text {
                        text: "Уведомления"
                        color: "white"
                        font.pixelSize: 18
                    }

                    Rectangle {
                        width: 60
                        height: 30
                        radius: 15
                        color: switch3 ? "#2ecc71" : "#e0e0e0"

                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: switch3 ? parent.width - 28 : 2
                            color: "white"
                        }

                        TapHandler {
                            onTapped: switch3 = !switch3
                        }
                    }
                }

                // Статус
                Rectangle {
                    width: parent.width
                    height: 80
                    color: "#f0f0f0"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "Wi-Fi: " + (switch1 ? "ВКЛ" : "ВЫКЛ") + "\n" +
                              "Bluetooth: " + (switch2 ? "ВКЛ" : "ВЫКЛ") + "\n" +
                              "Уведомления: " + (switch3 ? "ВКЛ" : "ВЫКЛ")
                        color: "black"
                        font.pixelSize: 16
                    }
                }
            }

            property bool switch1: true
            property bool switch2: false
            property bool switch3: true
        }
    }

    // Компонент 5: Список
    Component {
        id: column5Component

        Rectangle {
            color: "#118AB2"

            Column {
                anchors.fill: parent
                spacing: 10

                Text {
                    text: "Список элементов"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    padding: 10
                }

                // Список
                Column {
                    width: parent.width
                    height: parent.height - 50
                    spacing: 1

                    Repeater {
                        model: ["Элемент 1", "Элемент 2", "Элемент 3", "Элемент 4", "Элемент 5",
                                "Элемент 6", "Элемент 7", "Элемент 8", "Элемент 9", "Элемент 10"]

                        Rectangle {
                            width: parent.width
                            height: 40
                            color: index % 2 ? "#f0f0f0" : "white"

                            Row {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 10

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: Qt.hsla(index/10, 0.7, 0.7, 1)
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: index + 1
                                        color: "white"
                                        font.bold: true
                                    }
                                }

                                Text {
                                    text: modelData
                                    color: "black"
                                    font.pixelSize: 16
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            TapHandler {
                                onTapped: console.log("Выбран:", modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    // Компонент 6: Изображения
    Component {
        id: column6Component

        Rectangle {
            color: "#9B59B6"

            Column {
                anchors.centerIn: parent
                spacing: 20
                width: parent.width * 0.9

                Text {
                    text: "Галерея"
                    font.pixelSize: 24
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Изображение 1
                Rectangle {
                    width: parent.width
                    height: 100
                    color: "#e74c3c"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "Изображение 1"
                        color: "white"
                        font.pixelSize: 18
                    }

                    TapHandler {
                        onTapped: console.log("Изображение 1")
                    }
                }

                // Изображение 2
                Rectangle {
                    width: parent.width
                    height: 100
                    color: "#3498db"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "Изображение 2"
                        color: "white"
                        font.pixelSize: 18
                    }

                    TapHandler {
                        onTapped: console.log("Изображение 2")
                    }
                }

                // Изображение 3
                Rectangle {
                    width: parent.width
                    height: 100
                    color: "#2ecc71"
                    radius: 10

                    Text {
                        anchors.centerIn: parent
                        text: "Изображение 3"
                        color: "white"
                        font.pixelSize: 18
                    }

                    TapHandler {
                        onTapped: console.log("Изображение 3")
                    }
                }

                // Панель управления
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: "#34495e"

                        Text {
                            anchors.centerIn: parent
                            text: "←"
                            color: "white"
                            font.pixelSize: 24
                        }

                        TapHandler {
                            onTapped: console.log("Предыдущее")
                        }
                    }

                    Rectangle {
                        width: 50
                        height: 50
                        radius: 25
                        color: "#34495e"

                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            color: "white"
                            font.pixelSize: 24
                        }

                        TapHandler {
                            onTapped: console.log("Следующее")
                        }
                    }
                }
            }
        }
    }
}
