#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDateTime>
#include <QDebug>
#include <QVariantList>
#include <QVariantMap>
#include <QCoreApplication>
#include <QSettings>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QTimer>
#include <QSslSocket>
#include <QUrlQuery>
#define IP_Server_define 127.0.0.1

class NetworkManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionChanged)
    Q_PROPERTY(QString serverUrl READ serverUrl WRITE setServerUrl NOTIFY serverUrlChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr)
        : QObject(parent),
        m_connected(false),
        m_networkManager(new QNetworkAccessManager(this)) {

        // Загружаем сохраненный URL сервера
        QSettings settings;
        m_serverUrl = settings.value("server/url", "http://IP_Server_define:8080").toString();

        // Проверяем соединение при старте
        QTimer::singleShot(1000, this, &NetworkManager::checkConnection);
    }

    ~NetworkManager() = default;

    bool isConnected() const { return m_connected; }
    QString connectionStatus() const {
        return m_connected ?
                   QString("✓ Подключено к %1").arg(m_serverUrl) :
                   QString("✗ Нет подключения к серверу");
    }

    QString serverUrl() const { return m_serverUrl; }

    void setServerUrl(const QString &url) {
        if (m_serverUrl != url) {
            m_serverUrl = url;

            // Сохраняем настройки
            QSettings settings;
            settings.setValue("server/url", url);

            emit serverUrlChanged(url);
            checkConnection();
        }
    }

    Q_INVOKABLE bool saveRecord(const QDateTime &dateTime,
                                const QString &tab1,
                                const QString &tab2,
                                const QString &tab3,
                                int tab4,
                                const QString &tab5) {

        // Не сохраняем, если только дата/время
        if (tab1.isEmpty() && tab2.isEmpty() && tab3.isEmpty() &&
            tab5.isEmpty() && tab4 == 0) {
            qDebug() << "Только дата/время - запись не создается";
            return true;
        }

        QJsonObject record;
        record["record_time"] = dateTime.toString(Qt::ISODate);
        record["tab1_text"] = tab1;
        record["tab2_text"] = tab2;
        record["tab3_text"] = tab3;
        record["tab4_value"] = tab4;
        record["tab5_text"] = tab5;

        QJsonDocument doc(record);
        QByteArray data = doc.toJson();

        QNetworkRequest request(QUrl(m_serverUrl + "/records"));
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

        QNetworkReply *reply = m_networkManager->post(request, data);

        connect(reply, &QNetworkReply::finished, this, [this, reply]() {
            if (reply->error() == QNetworkReply::NoError) {
                qDebug() << "Запись успешно сохранена";
                emit recordSaved();
            } else {
                QString error = reply->errorString();
                qWarning() << "Ошибка сохранения:" << error;
                emit errorOccurred(error);
            }
            reply->deleteLater();
        });

        return true; // Возвращаем true, так как запрос отправлен асинхронно
    }

    Q_INVOKABLE bool updateRecord(int id,
                                  const QDateTime &dateTime,
                                  const QString &tab1,
                                  const QString &tab2,
                                  const QString &tab3,
                                  int tab4,
                                  const QString &tab5) {

        QJsonObject record;
        record["id"] = id;
        record["record_time"] = dateTime.toString(Qt::ISODate);
        record["tab1_text"] = tab1;
        record["tab2_text"] = tab2;
        record["tab3_text"] = tab3;
        record["tab4_value"] = tab4;
        record["tab5_text"] = tab5;

        QJsonDocument doc(record);
        QByteArray data = doc.toJson();

        QNetworkRequest request(QUrl(m_serverUrl + "/records/" + QString::number(id)));
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

        QNetworkReply *reply = m_networkManager->put(request, data);

        connect(reply, &QNetworkReply::finished, this, [this, reply, id]() {
            if (reply->error() == QNetworkReply::NoError) {
                qDebug() << "Запись с ID" << id << "обновлена";
                emit recordUpdated();
            } else {
                QString error = reply->errorString();
                qWarning() << "Ошибка обновления записи:" << error;
                emit errorOccurred(error);
            }
            reply->deleteLater();
        });

        return true;
    }

    Q_INVOKABLE QVariantMap getRecordById(int id) {
        QVariantMap record;

        // Создаем синхронный запрос (для простоты)
        QNetworkRequest request(QUrl(m_serverUrl + "/records/" + QString::number(id)));
        QNetworkReply *reply = m_networkManager->get(request);

        QEventLoop loop;
        connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
        loop.exec();

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            QJsonObject obj = doc.object();

            record["id"] = obj["id"].toInt();
            record["record_time"] = QDateTime::fromString(obj["record_time"].toString(), Qt::ISODate);
            record["tab1_text"] = obj["tab1_text"].toString();
            record["tab2_text"] = obj["tab2_text"].toString();
            record["tab3_text"] = obj["tab3_text"].toString();
            record["tab4_value"] = obj["tab4_value"].toInt();
            record["tab5_text"] = obj["tab5_text"].toString();
        } else {
            QString error = reply->errorString();
            qWarning() << "Ошибка при получении записи:" << error;
            emit errorOccurred(error);
        }

        reply->deleteLater();
        return record;
    }

    Q_INVOKABLE QDateTime currentDateTime() const {
        return QDateTime::currentDateTime();
    }

    Q_INVOKABLE QVariantList getRecordsForDate(const QDateTime &dateTime) {
        QVariantList records;

        QString dateStr = dateTime.toString("yyyy-MM-dd");
        QUrl url(m_serverUrl + "/records");
        QUrlQuery query;
        query.addQueryItem("date", dateStr);
        url.setQuery(query);

        QNetworkRequest request(url);
        QNetworkReply *reply = m_networkManager->get(request);

        QEventLoop loop;
        connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
        loop.exec();

        if (reply->error() == QNetworkReply::NoError) {
            QByteArray response = reply->readAll();
            QJsonDocument doc = QJsonDocument::fromJson(response);
            QJsonArray array = doc.array();

            for (const QJsonValue &value : array) {
                QJsonObject obj = value.toObject();
                QVariantMap record;
                record["id"] = obj["id"].toInt();
                record["record_time"] = QDateTime::fromString(obj["record_time"].toString(), Qt::ISODate);
                record["tab1_text"] = obj["tab1_text"].toString();
                record["tab2_text"] = obj["tab2_text"].toString();
                record["tab3_text"] = obj["tab3_text"].toString();
                record["tab4_value"] = obj["tab4_value"].toInt();
                record["tab5_text"] = obj["tab5_text"].toString();
                records.append(record);
            }
        } else {
            QString error = reply->errorString();
            qWarning() << "Ошибка при получении записей:" << error;
            emit errorOccurred(error);
        }

        reply->deleteLater();
        return records;
    }

    Q_INVOKABLE bool deleteRecord(int recordId) {
        QNetworkRequest request(QUrl(m_serverUrl + "/records/" + QString::number(recordId)));
        QNetworkReply *reply = m_networkManager->deleteResource(request);

        connect(reply, &QNetworkReply::finished, this, [this, reply, recordId]() {
            if (reply->error() == QNetworkReply::NoError) {
                qDebug() << "Запись с ID" << recordId << "удалена";
                emit recordDeleted();
            } else {
                QString error = reply->errorString();
                qWarning() << "Ошибка удаления записи:" << error;
                emit errorOccurred(error);
            }
            reply->deleteLater();
        });

        return true;
    }

    Q_INVOKABLE void reconnect() {
        checkConnection();
    }

    Q_INVOKABLE void testConnection(const QString &url) {
        QString testUrl = url.isEmpty() ? m_serverUrl : url;

        QNetworkRequest request(QUrl(testUrl + "/health"));
        QNetworkReply *reply = m_networkManager->get(request);

        connect(reply, &QNetworkReply::finished, this, [this, reply, testUrl]() {
            if (reply->error() == QNetworkReply::NoError) {
                emit connectionTested(true, QString("Подключение к %1 успешно").arg(testUrl));
                if (testUrl != m_serverUrl) {
                    setServerUrl(testUrl);
                }
            } else {
                QString error = reply->errorString();
                emit connectionTested(false, QString("Ошибка подключения к %1: %2").arg(testUrl).arg(error));
            }
            reply->deleteLater();
        });
    }

    // Метод для проверки локальной сети
    Q_INVOKABLE QString getLocalIP() {
        return "IP_Server_define"; // Замените на реальный IP вашего сервера
    }

signals:
    void connectionChanged(bool connected);
    void recordSaved();
    void recordUpdated();
    void recordDeleted();
    void errorOccurred(const QString &error);
    void connectionTested(bool success, const QString &message);
    void serverUrlChanged(const QString &url);

private slots:
    void checkConnection() {
        QNetworkRequest request(QUrl(m_serverUrl + "/health"));
        QNetworkReply *reply = m_networkManager->get(request);

        connect(reply, &QNetworkReply::finished, this, [this, reply]() {
            bool wasConnected = m_connected;
            m_connected = (reply->error() == QNetworkReply::NoError);

            if (wasConnected != m_connected) {
                emit connectionChanged(m_connected);
            }

            reply->deleteLater();
        });
    }

private:
    bool m_connected;
    QString m_serverUrl;
    QNetworkAccessManager *m_networkManager;
};

#include "main.moc"

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setOrganizationName("MentalKrisis");
    app.setApplicationName("MentalKrisisApp");

    qDebug() << "=== Запуск клиентского приложения Mental Krisis ===";
    qDebug() << "Платформа:" << QSysInfo::productType();

    NetworkManager networkManager;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("network", &networkManager);

    const QUrl url(QStringLiteral("qrc:/qt/qml/Mental_krisis_app/Main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
                     &app, []() {
                         qCritical() << "Не удалось создать QML объекты";
                         QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "Не удалось загрузить QML файл:" << url.toString();
        return -1;
    }

    qDebug() << "✓ QML успешно загружен";
    qDebug() << "✓ Клиентское приложение запущено";

    return app.exec();
}
