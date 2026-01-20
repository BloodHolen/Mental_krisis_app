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
#include <QSettings>
#include <QNetworkInterface>

class DatabaseManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(QString connectionType READ connectionType NOTIFY connectionChanged)

public:
    explicit DatabaseManager(QObject *parent = nullptr) : QObject(parent), m_connected(false) {
        initDatabase();
    }

    bool isConnected() const { return m_connected; }
    QString connectionType() const { return m_connectionType; }

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
        // Для совместимости с PostgreSQL и SQLite
        if (m_connectionType == "PostgreSQL") {
            query.prepare("SELECT id, record_time, tab1_text, tab2_text, tab3_text, tab4_value, tab5_text "
                          "FROM mental_records "
                          "WHERE DATE(record_time) = DATE(?) "
                          "ORDER BY record_time DESC");
        } else {
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

    // Метод для изменения настроек подключения к PostgreSQL
    Q_INVOKABLE void setConnectionParams(const QString &host, int port,
                                         const QString &database, const QString &user,
                                         const QString &password) {
        m_pgHost = host;
        m_pgPort = port;
        m_pgDatabase = database;
        m_pgUser = user;
        m_pgPassword = password;

        // Сохраняем настройки
        QSettings settings;
        settings.setValue("postgres/host", host);
        settings.setValue("postgres/port", port);
        settings.setValue("postgres/database", database);
        settings.setValue("postgres/user", user);
        settings.setValue("postgres/password", password);

        // Переподключаемся
        reconnect();
    }

    Q_INVOKABLE void reconnect() {
        m_connected = false;
        emit connectionChanged(m_connected);
        initDatabase();
    }

signals:
    void connectionChanged(bool connected);
    void recordSaved();
    void recordUpdated();
    void recordDeleted();

private:
    void initDatabase() {
        qDebug() << "Доступные драйверы БД:" << QSqlDatabase::drivers();

        // Закрываем старое соединение
        if (QSqlDatabase::contains()) {
            QSqlDatabase db = QSqlDatabase::database();
            if (db.isOpen()) {
                db.close();
            }
            QSqlDatabase::removeDatabase(QSqlDatabase::defaultConnection);
        }

        // Загружаем сохраненные настройки
        QSettings settings;
        m_pgHost = settings.value("postgres/host", "localhost").toString();
        m_pgPort = settings.value("postgres/port", 5432).toInt();
        m_pgDatabase = settings.value("postgres/database", "mental_krisis_db").toString();
        m_pgUser = settings.value("postgres/user", "postgres").toString();
        m_pgPassword = settings.value("postgres/password", "postgres").toString();

        // Определяем локальный IP для автонастройки
        QString localIP = getLocalIP();
        qDebug() << "Локальный IP:" << localIP;

        // Сначала пробуем PostgreSQL
        bool pgSuccess = tryPostgreSQL();

        if (!pgSuccess) {
            // Если PostgreSQL не удалось, пробуем SQLite
            qDebug() << "Не удалось подключиться к PostgreSQL, пробуем SQLite...";
            trySQLite();
        }

        emit connectionChanged(m_connected);
    }

    // Функция для получения локального IP адреса
    QString getLocalIP() {
        QString ipAddress;
        QList<QHostAddress> ipAddressesList = QNetworkInterface::allAddresses();

        for (const QHostAddress &address : ipAddressesList) {
            if (address != QHostAddress::LocalHost &&
                address.toIPv4Address() &&
                address.toString().startsWith("192.168.")) {
                ipAddress = address.toString();
                break;
            }
        }

        if (ipAddress.isEmpty()) {
            ipAddress = "localhost";
        }

        return ipAddress;
    }

    bool tryPostgreSQL() {
        // Проверяем наличие драйвера PostgreSQL
        if (!QSqlDatabase::isDriverAvailable("QPSQL")) {
            qDebug() << "Драйвер PostgreSQL не доступен";
            return false;
        }

        QSqlDatabase db = QSqlDatabase::addDatabase("QPSQL", "postgres_connection");

        // ============ НАСТРОЙКА ПОДКЛЮЧЕНИЯ К POSTGRESQL ============
        // ИЗМЕНИТЕ ЭТИ ПАРАМЕТРЫ ДЛЯ ПОДКЛЮЧЕНИЯ К ВАШЕМУ СЕРВЕРУ:
        QString host = m_pgHost;           // IP адрес или хостнейм
        int port = m_pgPort;               // Порт PostgreSQL (обычно 5432)
        QString database = m_pgDatabase;   // Имя базы данных
        QString user = m_pgUser;           // Имя пользователя
        QString password = m_pgPassword;   // Пароль
        // ============================================================

        qDebug() << "Попытка подключения к PostgreSQL:";
        qDebug() << "  Хост:" << host;
        qDebug() << "  Порт:" << port;
        qDebug() << "  База данных:" << database;
        qDebug() << "  Пользователь:" << user;

        db.setHostName(host);
        db.setPort(port);
        db.setDatabaseName(database);
        db.setUserName(user);
        db.setPassword(password);

        // Настройка таймаутов для мобильных устройств
        db.setConnectOptions("connect_timeout=10");

        if (db.open()) {
            qDebug() << "Успешное подключение к PostgreSQL!";

            // Создаем таблицу если не существует
            createPostgreSQLTables();

            m_connected = true;
            m_connectionType = "PostgreSQL";
            return true;
        } else {
            QString error = db.lastError().text();
            qWarning() << "Ошибка подключения к PostgreSQL:" << error;

            // Пробуем создать базу данных если она не существует
            if (error.contains("database") && error.contains("does not exist")) {
                qDebug() << "База данных не существует, пытаемся создать...";
                if (createPostgreSQLDatabase()) {
                    if (db.open()) {
                        createPostgreSQLTables();
                        m_connected = true;
                        m_connectionType = "PostgreSQL";
                        return true;
                    }
                }
            }

            return false;
        }
    }

    bool createPostgreSQLDatabase() {
        // Подключаемся к серверу PostgreSQL без выбора конкретной БД
        QSqlDatabase tempDb = QSqlDatabase::addDatabase("QPSQL", "temp_postgres_connection");
        tempDb.setHostName(m_pgHost);
        tempDb.setPort(m_pgPort);
        tempDb.setDatabaseName("postgres");  // Подключаемся к системной БД
        tempDb.setUserName(m_pgUser);
        tempDb.setPassword(m_pgPassword);

        if (tempDb.open()) {
            QSqlQuery query(tempDb);
            QString createDbSQL = QString("CREATE DATABASE %1").arg(m_pgDatabase);

            if (query.exec(createDbSQL)) {
                qDebug() << "База данных успешно создана";
                tempDb.close();
                QSqlDatabase::removeDatabase("temp_postgres_connection");
                return true;
            } else {
                qWarning() << "Не удалось создать базу данных:" << query.lastError().text();
            }
            tempDb.close();
        } else {
            qWarning() << "Не удалось подключиться к серверу PostgreSQL:" << tempDb.lastError().text();
        }

        QSqlDatabase::removeDatabase("temp_postgres_connection");
        return false;
    }

    void createPostgreSQLTables() {
        QSqlDatabase db = QSqlDatabase::database("postgres_connection");
        QSqlQuery query(db);

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

    void trySQLite() {
        QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE", "sqlite_connection");

        QString dbPath;

#ifdef Q_OS_ANDROID
        // На Android: внутреннее хранилище приложения
        dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/mental_krisis.db";
        qDebug() << "Android SQLite database path:" << dbPath;
#else
        // На десктопе: обычный путь
        QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir dir(dataDir);
        if (!dir.exists()) {
            dir.mkpath(".");
        }
        dbPath = dataDir + "/mental_krisis.db";
        qDebug() << "Desktop SQLite database path:" << dbPath;
#endif

        db.setDatabaseName(dbPath);

        if (db.open()) {
            qDebug() << "SQLite база данных открыта:" << dbPath;
            createSQLiteTables();
            m_connected = true;
            m_connectionType = "SQLite";
        } else {
            qWarning() << "Ошибка SQLite:" << db.lastError().text();
            m_connected = false;
        }
    }

    void createSQLiteTables() {
        QSqlDatabase db = QSqlDatabase::database("sqlite_connection");
        QSqlQuery query(db);

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
    QString m_connectionType;

    // Параметры подключения к PostgreSQL
    QString m_pgHost;
    int m_pgPort;
    QString m_pgDatabase;
    QString m_pgUser;
    QString m_pgPassword;
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
