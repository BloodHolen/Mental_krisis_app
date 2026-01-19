#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QVariantList>
#include <QVariantMap>
#include <QCoreApplication>

class DatabaseManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr) : QObject(parent), m_connected(false) {
        initDatabase();
    }

    bool isConnected() const { return m_connected; }

    Q_INVOKABLE bool saveRecord(const QDateTime &dateTime,
                                const QString &tab1,
                                const QString &tab2,
                                const QString &tab3,
                                int tab4,
                                const QString &tab5) {
        if (!m_connected) {
            qWarning() << "База данных не подключена";
            return false;
        }

        // Не сохраняем, если только дата/время
        if (tab1.isEmpty() && tab2.isEmpty() && tab3.isEmpty() &&
            tab5.isEmpty() && tab4 == 0) {
            qDebug() << "Только дата/время - запись не создается";
            return true;
        }

        QSqlQuery query;
        query.prepare("INSERT INTO mental_records "
                      "(record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text) "
                      "VALUES (?, ?, ?, ?, ?, ?)");

        query.addBindValue(dateTime);
        query.addBindValue(tab1);
        query.addBindValue(tab2);
        query.addBindValue(tab3);
        query.addBindValue(tab4);
        query.addBindValue(tab5);

        bool success = query.exec();
        if (!success) {
            qWarning() << "Ошибка сохранения:" << query.lastError().text();
        } else {
            qDebug() << "Запись успешно сохранена. ID:" << query.lastInsertId().toString();
            emit recordSaved();
        }

        return success;
    }

    Q_INVOKABLE bool updateRecord(int id,
                                  const QDateTime &dateTime,
                                  const QString &tab1,
                                  const QString &tab2,
                                  const QString &tab3,
                                  int tab4,
                                  const QString &tab5) {
        if (!m_connected) {
            qWarning() << "База данных не подключена";
            return false;
        }

        QSqlQuery query;
        query.prepare("UPDATE mental_records SET "
                      "record_time = ?, "
                      "tab1_text = ?, "
                      "tab2_text = ?, "
                      "tab3_text = ?, "
                      "tab4_value = ?, "
                      "tab5_text = ? "
                      "WHERE id = ?");

        query.addBindValue(dateTime);
        query.addBindValue(tab1);
        query.addBindValue(tab2);
        query.addBindValue(tab3);
        query.addBindValue(tab4);
        query.addBindValue(tab5);
        query.addBindValue(id);

        bool success = query.exec();
        if (!success) {
            qWarning() << "Ошибка обновления записи:" << query.lastError().text();
        } else {
            qDebug() << "Запись с ID" << id << "обновлена";
            emit recordUpdated();
        }

        return success;
    }

    Q_INVOKABLE QVariantMap getRecordById(int id) {
        QVariantMap record;
        if (!m_connected) {
            return record;
        }

        QSqlQuery query;
        query.prepare("SELECT id, record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text "
                      "FROM mental_records "
                      "WHERE id = ?");
        query.addBindValue(id);

        if (query.exec() && query.next()) {
            record["id"] = query.value("id").toInt();
            record["record_time"] = query.value("record_time").toDateTime();
            record["tab1_text"] = query.value("tab1_text").toString();
            record["tab2_text"] = query.value("tab2_text").toString();
            record["tab3_text"] = query.value("tab3_text").toString();
            record["tab4_value"] = query.value("tab4_value").toInt();
            record["tab5_text"] = query.value("tab5_text").toString();
        } else {
            qWarning() << "Ошибка при получении записи:" << query.lastError().text();
        }

        return record;
    }

    Q_INVOKABLE QDateTime currentDateTime() const {
        return QDateTime::currentDateTime();
    }

    Q_INVOKABLE QVariantList getRecordsForDate(const QDateTime &dateTime) {
        QVariantList records;
        if (!m_connected) {
            return records;
        }

        QSqlQuery query;
        query.prepare("SELECT id, record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text "
                      "FROM mental_records "
                      "WHERE DATE(record_time) = DATE(?) "
                      "ORDER BY record_time DESC");

        query.addBindValue(dateTime);

        if (query.exec()) {
            while (query.next()) {
                QVariantMap record;
                record["id"] = query.value("id").toInt();
                record["record_time"] = query.value("record_time").toDateTime();
                record["tab1_text"] = query.value("tab1_text").toString();
                record["tab2_text"] = query.value("tab2_text").toString();
                record["tab3_text"] = query.value("tab3_text").toString();
                record["tab4_value"] = query.value("tab4_value").toInt();
                record["tab5_text"] = query.value("tab5_text").toString();
                records.append(record);
            }
        } else {
            qWarning() << "Ошибка при получении записей:" << query.lastError().text();
        }

        return records;
    }

    Q_INVOKABLE bool deleteRecord(int recordId) {
        if (!m_connected) {
            return false;
        }

        QSqlQuery query;
        query.prepare("DELETE FROM mental_records WHERE id = ?");
        query.addBindValue(recordId);

        bool success = query.exec();
        if (!success) {
            qWarning() << "Ошибка удаления записи:" << query.lastError().text();
        } else {
            qDebug() << "Запись с ID" << recordId << "удалена";
            emit recordDeleted();
        }

        return success;
    }

signals:
    void connectionChanged(bool connected);
    void recordSaved();
    void recordUpdated();
    void recordDeleted();

private:
    void initDatabase() {
        qDebug() << "Доступные драйверы БД:" << QSqlDatabase::drivers();

        if (QSqlDatabase::contains()) {
            QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
        }

        // НА Android используем только SQLite
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

        // На Android используем специальный путь
        QString dbPath;

#ifdef Q_OS_ANDROID
        // На Android: внутреннее хранилище приложения
        dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/mental_krisis.db";
        qDebug() << "Android database path:" << dbPath;
#else
        // На десктопе: обычный путь
        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(dataDir);
        if (!dir.exists()) {
            dir.mkpath(".");
        }
        dbPath = dataDir + "/mental_krisis.db";
#endif

        db.setDatabaseName(dbPath);

        if (db.open()) {
            qDebug() << "SQLite база данных:" << dbPath;
            createTables();
            m_connected = true;
        } else {
            qWarning() << "Ошибка SQLite:" << db.lastError().text();
            m_connected = false;
        }

        emit connectionChanged(m_connected);
    }

    void createTables() {
        QSqlQuery query;

        QString sql =
            "CREATE TABLE IF NOT EXISTS mental_records ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT,"
            "record_time DATETIME NOT NULL,"
            "tab1_text TEXT,"
            "tab2_text TEXT,"
            "tab3_text TEXT,"
            "tab4_value INTEGER,"
            "tab5_text TEXT)";

        if (!query.exec(sql)) {
            qWarning() << "Ошибка создания таблицы в SQLite:" << query.lastError().text();
        } else {
            qDebug() << "Таблица в SQLite создана/уже существует";
        }
    }

    bool m_connected;
};

#include "main.moc"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MentalKrisis");
    app.setApplicationName("MentalKrisisApp");

    qDebug() << "Запуск приложения...";

    DatabaseManager dbManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("database", &dbManager);

    // На Android всегда используем ресурсы
    const QUrl url(QStringLiteral("qrc:/qt/qml/Mental_krisis_app/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qCritical() << "Не удалось создать QML объекты";
                         QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Не удалось загрузить QML файл:" << url.toString();

        // Пробуем альтернативный путь на Android
#ifdef Q_OS_ANDROID
        const QUrl altUrl(QStringLiteral("qrc:/Main.qml"));
        engine.load(altUrl);

        if (engine.rootObjects().isEmpty()) {
            qCritical() << "Не удалось загрузить QML файл и по альтернативному пути";
            return -1;
        }
#else
        return -1;
#endif
    }

    qDebug() << "QML успешно загружен из:" << url.toString();
    return app.exec();
}
