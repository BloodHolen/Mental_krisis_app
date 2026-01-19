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

class DatabaseManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr) : QObject(parent), m_connected(false), m_usingPostgreSQL(false) {
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
            emit recordSaved(); // Сигнал о сохранении новой записи
        }

        return success;
    }

    Q_INVOKABLE QDateTime currentDateTime() const {
        return QDateTime::currentDateTime();
    }

    // Новый метод: получение записей за выбранную дату
    Q_INVOKABLE QVariantList getRecordsForDate(const QDateTime &dateTime) {
        QVariantList records;
        if (!m_connected) {
            return records;
        }

        QSqlQuery query;
        // Для PostgreSQL
        if (m_usingPostgreSQL) {
            query.prepare("SELECT id, record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text "
                          "FROM mental_records "
                          "WHERE DATE(record_time) = DATE(?) "
                          "ORDER BY record_time DESC");
        } else {
            // Для SQLite
            query.prepare("SELECT id, record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text "
                          "FROM mental_records "
                          "WHERE DATE(record_time) = DATE(?) "
                          "ORDER BY record_time DESC");
        }

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

    // Новый метод: удаление записи по ID
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
            emit recordDeleted(); // Сигнал об удалении записи
        }

        return success;
    }

signals:
    void connectionChanged(bool connected);
    void recordSaved();    // Сигнал о сохранении новой записи
    void recordDeleted();  // Сигнал об удалении записи

private:
    void initDatabase() {
        qDebug() << "Доступные драйверы БД:" << QSqlDatabase::drivers();

        // Закрываем и удаляем предыдущее соединение, если есть
        if (QSqlDatabase::contains()) {
            QSqlDatabase db = QSqlDatabase::database();
            if (db.isOpen()) {
                db.close();
            }
            QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
        }

        // ==================== НАСТРОЙКИ ПОДКЛЮЧЕНИЯ К БАЗЕ ДАННЫХ ====================
        // ИЗМЕНИТЕ ЭТИ ПАРАМЕТРЫ ДЛЯ ПОДКЛЮЧЕНИЯ К ДРУГОМУ СЕРВЕРУ:
        QString hostName = "localhost";      // ← ИЗМЕНИТЕ "localhost" на IP адрес сервера
        int port = 5432;                     // ← Порт PostgreSQL (обычно 5432)
        QString databaseName = "mental_krisis_db"; // ← Имя базы данных
        QString userName = "postgres";       // ← Имя пользователя PostgreSQL
        QString password = "postgres";       // ← Пароль пользователя
        // ============================================================================

        // Сначала пробуем PostgreSQL
        if (tryPostgreSQL(hostName, port, databaseName, userName, password)) {
            m_usingPostgreSQL = true;
            qDebug() << "Используется PostgreSQL";
        } else {
            // Если PostgreSQL не удалось, пробуем SQLite
            qDebug() << "Переключаемся на SQLite...";
            m_usingPostgreSQL = false;
            trySQLite();
        }

        emit connectionChanged(m_connected);
    }

    bool tryPostgreSQL(const QString &hostName, int port, const QString &databaseName,
                       const QString &userName, const QString &password) {
        QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL");

        db.setHostName(hostName);
        db.setPort(port);
        db.setDatabaseName(databaseName);
        db.setUserName(userName);
        db.setPassword(password);

        m_status = "Попытка подключения к PostgreSQL...";
        qDebug() << m_status;

        if (db.open()) {
            qDebug() << "Соединение с PostgreSQL установлено!";

            createTablesForPostgreSQL();
            m_connected = true;
            return true;
        } else {
            QString error = db.lastError().text();
            m_status = "Ошибка PostgreSQL: " + error;
            qWarning() << m_status;

            if (error.contains("database") && error.contains("does not exist")) {
                qDebug() << "База данных не существует, пытаемся создать...";
                if (createPostgreSQLDatabase(hostName, port, userName, password)) {
                    if (db.open()) {
                        createTablesForPostgreSQL();
                        m_connected = true;
                        return true;
                    }
                }
            }

            return false;
        }
    }

    bool createPostgreSQLDatabase(const QString &hostName, int port,
                                  const QString &userName, const QString &password) {
        QSqlDatabase tempDb = QSqlDatabase::addDatabase("QPSQL", "temp_connection");
        tempDb.setHostName(hostName);
        tempDb.setPort(port);
        tempDb.setDatabaseName("postgres");
        tempDb.setUserName(userName);
        tempDb.setPassword(password);

        if (tempDb.open()) {
            QSqlQuery query(tempDb);
            if (query.exec("CREATE DATABASE mental_krisis_db")) {
                qDebug() << "База данных mental_krisis_db успешно создана";
                tempDb.close();
                QSqlDatabase::removeDatabase("temp_connection");
                return true;
            } else {
                qWarning() << "Не удалось создать базу данных:" << query.lastError().text();
            }
            tempDb.close();
        } else {
            qWarning() << "Не удалось подключиться для создания БД:" << tempDb.lastError().text();
        }
        QSqlDatabase::removeDatabase("temp_connection");
        return false;
    }

    void trySQLite() {
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");

        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(dataDir);
        if (!dir.exists()) {
            if (dir.mkpath(".")) {
                qDebug() << "Создана директория для базы данных:" << dataDir;
            }
        }

        QString dbPath = dataDir + "/mental_krisis.db";
        db.setDatabaseName(dbPath);

        m_status = "Попытка подключения к SQLite...";
        qDebug() << m_status;

        if (db.open()) {
            qDebug() << "SQLite база данных:" << dbPath;
            createTablesForSQLite();
            m_connected = true;
        } else {
            m_status = "Ошибка SQLite: " + db.lastError().text();
            qWarning() << m_status;
            m_connected = false;
        }
    }

    void createTablesForPostgreSQL() {
        QSqlQuery query;

        QString sql =
            "CREATE TABLE IF NOT EXISTS mental_records ("
            "id SERIAL PRIMARY KEY,"
            "record_time TIMESTAMP NOT NULL,"
            "tab1_text TEXT,"
            "tab2_text TEXT,"
            "tab3_text TEXT,"
            "tab4_value INTEGER,"
            "tab5_text TEXT)";

        if (!query.exec(sql)) {
            qWarning() << "Ошибка создания таблицы в PostgreSQL:" << query.lastError().text();
        } else {
            qDebug() << "Таблица в PostgreSQL создана/уже существует";
        }
    }

    void createTablesForSQLite() {
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
    bool m_usingPostgreSQL;
    QString m_status;
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

    // Пробуем загрузить QML из разных мест
    QStringList qmlPaths;
    qmlPaths << QCoreApplication::applicationDirPath() + "/Main.qml"
             << QCoreApplication::applicationDirPath() + "/../Main.qml"
             << QCoreApplication::applicationDirPath() + "/../../Main.qml"
             << ":/Mental_krisis_app/Main.qml"
             << "qrc:/Mental_krisis_app/Main.qml";

    QUrl qmlUrl;
    bool qmlFound = false;

    for (const QString &path : qmlPaths) {
        if (path.startsWith("qrc:") || path.startsWith(":/")) {
            if (QFile::exists(path.mid(path.indexOf(':') + 1))) {
                qmlUrl = QUrl(path);
                qDebug() << "Найден QML в ресурсах:" << path;
                qmlFound = true;
                break;
            }
        } else if (QFile::exists(path)) {
            qmlUrl = QUrl::fromLocalFile(path);
            qDebug() << "Найден QML файл:" << path;
            qmlFound = true;
            break;
        }
    }

    if (!qmlFound) {
        qCritical() << "QML файл не найден!";
        return -1;
    }

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qCritical() << "Не удалось создать QML объекты";
                         QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(qmlUrl);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Не удалось загрузить QML файл:" << qmlUrl.toString();
        return -1;
    }

    qDebug() << "QML успешно загружен из:" << qmlUrl.toString();
    return app.exec();
}
