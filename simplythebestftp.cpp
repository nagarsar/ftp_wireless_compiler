#include "simplythebestftp.h"

simplyTheBestFtp::simplyTheBestFtp(QObject *qmlForm)
{
    this->m_qmlForm = qmlForm;
    this->isDownloading = false;
    this->isUploading = false;

    this->got_bytes = 0;
    this->total_bytes = 0;
    this->username = "anonymous";
    this->port = 21;
    this->serverDir = "/";

    connect(this->m_qmlForm, SIGNAL(connectToServer(QString, QString, QString, QString)), this, SLOT(connectToServer(QString, QString, QString, QString)));
    connect(this->m_qmlForm, SIGNAL(disconnectFromServer()), this, SLOT(disconnectFromServer()));
    connect(this->m_qmlForm, SIGNAL(cdDir(QString)), this, SLOT(cdDir(QString)));
    connect(this->m_qmlForm, SIGNAL(download(QString,QString)), this, SLOT(download(QString,QString)));
    connect(this->m_qmlForm, SIGNAL(upload(QString,QString)), this, SLOT(upload(QString,QString)));

    connect(this, SIGNAL(stateChanged(int)), this, SLOT(processStateChanged(int)));
    connect(this, SIGNAL(listInfo(QUrlInfo)), this, SLOT(processListInfo(QUrlInfo)));
    connect(this, SIGNAL(commandFinished(int,bool)), this, SLOT(processCommandFinished(int,bool)));
    connect(this, SIGNAL(readyRead()), this, SLOT(processReadyRead()));
    connect(this, SIGNAL(dataTransferProgress(qint64,qint64)), this, SLOT(processProgress(qint64,qint64)));
}

void simplyTheBestFtp::log(const QString &msg) {
    QVariant returnedValue;
    QString str = msg;
    QMetaObject::invokeMethod(this->m_qmlForm, "log",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, str.replace("\n", " ")));
}

void simplyTheBestFtp::hex(const QString &msg) {
    QVariant returnedValue;
    QString str = msg;
    QMetaObject::invokeMethod(this->m_qmlForm, "hex",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, str.replace("\n", " ")));
}

void simplyTheBestFtp::listAll() {
    this->serverFiles.clear();
    if (this->state() == QFtp::LoggedIn) {
        QVariant returnedValue;
        QMetaObject::invokeMethod(this->m_qmlForm, "clearServerFiles",
                                  Q_RETURN_ARG(QVariant, returnedValue));
        QMetaObject::invokeMethod(this->m_qmlForm, "addServerFile",
                                  Q_RETURN_ARG(QVariant, returnedValue),
                                  Q_ARG(QVariant, "."),
                                  Q_ARG(QVariant, true));
        QMetaObject::invokeMethod(this->m_qmlForm, "addServerFile",
                                  Q_RETURN_ARG(QVariant, returnedValue),
                                  Q_ARG(QVariant, ".."),
                                  Q_ARG(QVariant, true));
        this->list();
    }
}

void simplyTheBestFtp::connectToServer(const QString &serverName, const QString &login, const QString &password, const QString &port) {
    if (this->state() == QFtp::Unconnected) {
        //qDebug() << "superconnect: " + login + ":" + password + "@" + serverName + ":" + port;
        this->currentHost = serverName;
        this->username = login;
        this->port = port.toInt();
        this->connectToHost(serverName, port.toInt());
        this->loginCmdId = this->login(this->username, password);
    }
}

void simplyTheBestFtp::disconnectFromServer() {
    if (this->state() != QFtp::Unconnected) {
        if (this->isDownloading && this->file.isOpen()) {
            this->abortDownload();
        }
        if (this->isUploading && this->file.isOpen()) {
            this->abortUpload();
        }
        this->serverFiles.clear();
        this->close();
    }
}

void simplyTheBestFtp::cdDir(const QString &dir) {
    this->cdCmdId = this->cd(dir);
    this->serverDir = dir;
}

void simplyTheBestFtp::download(const QString &pwd, const QString &fileName) {
    QString path = pwd.startsWith("file:///") ? pwd.right(pwd.length() - 7) : pwd;
    if (this->isDownloading) {
        qDebug() << "already in progress";
        this->log("Download is already in progress.");
        return;
    }
    if (this->isUploading) {
        qDebug() << "already in progress";
        this->log("Upload is already in progress.");
        return;
    }
    file.setFileName(path + "/" + fileName);

    this->log("Dwonload " + fileName + " to " + path + ".");
    if (this->file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        this->total_bytes = this->serverFiles[fileName].size();
        this->got_bytes = 0;
        this->updateDownloadProgress();
        this->isDownloading = true;
        this->downloadCmdId = this->get(fileName);
    } else {
        qDebug() << "write failed";
        this->log(this->file.errorString());
    }
}

void simplyTheBestFtp::upload(const QString &pwd, const QString &fileName) {
    QString path = pwd.startsWith("file:///") ? pwd.right(pwd.length() - 7) : pwd;
    if (this->isDownloading) {
        qDebug() << "already in progress";
        this->log("Download is already in progress.");
        return;
    }
    if (this->isUploading) {
        qDebug() << "already in progress";
        this->log("Upload is already in progress.");
        return;
    }
    file.setFileName(path + "/" + fileName);

    this->log("Upload " + fileName + " to " + this->serverDir + ".");
    this->hex( fileName );



    /*QQmlEngine engine;
    QQmlComponent component(&engine, "main.qml");
    QObject *object = component.create();

    //qDebug() << "Property value1:" << QQmlProperty::read(object, "hexName").toString();
    QQmlProperty::write(object, "hexName", fileName);

    //qDebug() << "Property value2:" << object->property("hexName").toString();
    object->setProperty("hexName", fileName);
    */
    //QObject *rect = object->findChild<QObject*>("hexNameObject");
    //if (rect)
    //    rect->setProperty("text", fileName);






    if (this->file.open(QIODevice::ReadOnly)) {
        this->total_bytes = this->file.size();
        this->got_bytes = 0;
        this->updateUploadProgress();
        this->isUploading = true;
        this->uploadCmdId = this->put(&this->file, fileName);
    } else {
        qDebug() << "read failed";
        this->log(this->file.errorString());
    }
}

void simplyTheBestFtp::processCommandFinished(int cmd, bool error) {
    if (this->cdCmdId == cmd) {
        if (!error) {
            this->listAll();
        } else {
            qDebug() << "cd error";
            this->log(this->errorString());
        }
    } else if (this->loginCmdId == cmd) {
        if (!error) {
            this->listAll();
        } else {
            qDebug() << "login error";
            this->log(this->errorString());
        }
    } else if (this->downloadCmdId == cmd) {
        if (!error) {
            this->downloadFinished();
        } else {
            qDebug() << "get error";
            this->log(this->errorString());
            this->downloadFinished();
        }
    } else if (this->uploadCmdId == cmd) {
        if (!error) {
            this->uploadFinished();
        } else {
            qDebug() << "put error";
            this->log(this->errorString());
            this->uploadFinished();
        }
    }
}

void simplyTheBestFtp::processStateChanged(int state) {
    QString strState = "";

    switch (state) {
    case QFtp::Unconnected:
        strState = "Unconnected";
        break;
    case QFtp::HostLookup:
        strState = "Host lookup " + this->currentHost;
        break;
    case QFtp::Connecting:
        strState = "Connecting " + this->currentHost;
        break;
    case QFtp::Connected:
        strState = "Connected";
        break;
    case QFtp::LoggedIn:
        strState = "Logged in as " + this->username;
        break;
    case QFtp::Closing:
        strState = "Closing";
        break;
    default:
        break;
    };

    this->log(strState);
}

void simplyTheBestFtp::processListInfo(QUrlInfo entry) {
    QString entryType = (entry.isDir() ? "dir: " : "file ");

    this->serverFiles.insert(entry.name(), entry);

    QVariant returnedValue;
    QMetaObject::invokeMethod(this->m_qmlForm, "addServerFile",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, entry.name()),
                              Q_ARG(QVariant, entry.isDir()));
}

void simplyTheBestFtp::processReadyRead() {
    this->got_bytes += this->file.write(this->readAll());
    this->updateDownloadProgress();
}

void simplyTheBestFtp::updateDownloadProgress() {
    QVariant returnedValue;
    QMetaObject::invokeMethod(this->m_qmlForm, "updateProgress",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, this->got_bytes),
                              Q_ARG(QVariant, this->total_bytes));
}

void simplyTheBestFtp::updateUploadProgress() {
    QVariant returnedValue;
    QMetaObject::invokeMethod(this->m_qmlForm, "updateProgress",
                              Q_RETURN_ARG(QVariant, returnedValue),
                              Q_ARG(QVariant, this->got_bytes),
                              Q_ARG(QVariant, this->total_bytes));
}

void simplyTheBestFtp::abortDownload() {
    this->downloadFinished();
    this->abort();
}

void simplyTheBestFtp::abortUpload() {
    this->uploadFinished();
    this->abort();
}

void simplyTheBestFtp::downloadFinished() {
    if (this->file.isOpen()) {
        this->file.close();
    }
    this->log("Download finished.");
    this->isDownloading = false;
    this->got_bytes = 0;
    this->total_bytes = 1;
    this->updateDownloadProgress();
}

void simplyTheBestFtp::uploadFinished() {
    if (this->file.isOpen()) {
        this->file.close();
    }
    this->log("Upload finished.");
    this->isUploading = false;
    this->got_bytes = 0;
    this->total_bytes = 1;
    this->updateUploadProgress();
    this->listAll();
}

void simplyTheBestFtp::processProgress(qint64 got, qint64 total) {
    this->got_bytes = got;
    this->total_bytes = total;
    this->updateUploadProgress();
}
