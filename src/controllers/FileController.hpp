/*
 * FileController.hpp
 *
 *  Created on: Apr 29, 2017
 *      Author: misha
 */

#ifndef FILECONTROLLER_HPP_
#define FILECONTROLLER_HPP_

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QList>
#include <QNetworkReply>
#include "../webdav/qwebdav.h"
#include "../webdav/qwebdavdirparser.h"
#include "../Common.hpp"
#include "../util/FileUtil.hpp"
#include "loaders/FileDownloader.hpp"
#include "loaders/PreviewLoader.hpp"

#include <QFileInfo>

class FileController: public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList queue READ getQueue NOTIFY queueChanged)
    Q_PROPERTY(QVariantList selectedFiles READ getSelectedFiles NOTIFY selectedFilesChanged)
    Q_PROPERTY(QVariantList sharedFiles READ getSharedFiles WRITE setSharedFiles NOTIFY sharedFilesChanged)
    Q_PROPERTY(QString currentPath READ getCurrentPath WRITE setCurrentPath NOTIFY currentPathChanged)
    Q_PROPERTY(FileDownloader* downloader READ getDownloader)
    Q_PROPERTY(PreviewLoader* previewLoader READ getPreviewLoader)

public:
    FileController(FileUtil* fileUtil, QObject* parent = 0);
    virtual ~FileController();

    Q_INVOKABLE void loadPath(const QString& path = "/", const int& amount = 0, const int& offset = 0);
    Q_INVOKABLE void loadFile(const QString& filename, const QString& path);
    Q_INVOKABLE void openFile(const QString& filename, const QString& path);
    Q_INVOKABLE void createDir(const QString& dirname, const QString& currentPath);
    Q_INVOKABLE void requestDeletion(const QString& name, const QString& currentPath);
    Q_INVOKABLE void deleteFileOrDir(const QString& name, const QString& currentPath);
    Q_INVOKABLE void upload(const QString& sourceFilePath, const QString& targetPath);
    Q_INVOKABLE void rename(const QString& currentName, const QString& currentPath, const QString& newName, const bool& isDir, const QString& ext = "");
    Q_INVOKABLE void move(const QString& name, const QString& fromPath, const QString& toPath, const bool& isDir, const QString& ext = "", const int& size = 0);
    Q_INVOKABLE QVariantList getQueue();
    Q_INVOKABLE QVariantList getSelectedFiles() const;
    Q_INVOKABLE void selectFile(const QVariantMap& file);
    Q_INVOKABLE void clearSelectedFiles();
    Q_INVOKABLE const QString& getCurrentPath() const;
    Q_INVOKABLE void setCurrentPath(const QString& currentPath);
    Q_INVOKABLE void showProps(const QVariantMap& fileMap);
    Q_INVOKABLE const QVariantList& getSharedFiles() const;
    Q_INVOKABLE void setSharedFiles(const QVariantList& sharedFiles);
    Q_INVOKABLE void clearSharedFiles();
    Q_INVOKABLE void publish(const QString& path, const bool& isDir);
    Q_INVOKABLE void unpublish(const QString& path, const bool& isDir);
    Q_INVOKABLE void checkPublicity(const QString& path, const bool& isDir);

    Q_INVOKABLE QDateTime getLastModified(QString filePath) const; //KS inserted from opendataspace-cascades-master, Ekkehard Gentz (ekke), Rosenheim, Germany
    Q_INVOKABLE QDateTime getCreated(QString filePath) const;

    Q_INVOKABLE FileDownloader* getDownloader() const;
    Q_INVOKABLE PreviewLoader* getPreviewLoader() const;

    void initWebdav(QWebdav* webdav, QWebdavDirParser* parser);


    Q_SIGNALS:
        void dataLoaded(const QVariantList& data);
        void fileLoaded(const QString& filename, const QString& path);
        void fileOpened(const QString& filename, const QString& path);
        void dirCreated(const QString& direname, const QString& currentPath);
        void deletionRequested(const QString& name, const QString& currentPath);
        void fileOrDirDeleted(const QString& name, const QString& currentPath);
        void uploadProgress(const QString& remoteUri, qint64 sent, qint64 total);
        void uploadFinished(const QString& createdAt);
        void fileUploaded(const QString targetPath, const QVariantMap file);
        void fileRenamed(const QString& prevName, const QString& prevPath, const QString& newName, const QString& namePath);
        void fileMoved(const QString& name, const QString& prevPath, const QString& newPath, const QString& currentPath, const bool& isDir, const QString& ext, const int& size);
        void queueChanged(const QVariantList& queue);
        void selectedFilesChanged(const QVariantList& selectedFiles);
        void currentPathChanged(const QString& currentPath);
        void propsPageRequested(const QVariantMap& fileMap);
        void sharedFilesChanged(const QVariantList& sharedFiles);
        void publicMade(const QString& path, const QString& link);
        void unpublicMade(const QString& path);
        void publicityChecked(const QString& path, const QString& publicUrl);

    private slots:
        void onLoad();
        void onFileLoaded();
        void onDirCreated();
        void onFileOrDirDeleted();
        void onUploadProgress(qint64 sent, qint64 total);
        void onUploadFinished();
        void onFileRenamed();
        void onFileMoved();
        void onPublicMade();
        void onUnpublicMade();
        void onPublicityChecked();


private:
    QWebdav* m_pWebdav;
    QWebdavDirParser* m_pParser;

    FileUtil* m_pFileUtil;
    FileDownloader* m_pDownloader;
    PreviewLoader* m_pPreviewLoader;

    QList<QNetworkReply*> m_replies;
    QList<QNetworkReply*> m_uploadReplies;
    QVariantList m_queue;
    QVariantList m_selectedFiles;
    QString m_currentPath;
    QVariantList m_sharedFiles;

    void startUpload(const QString& remoteUri);
    void savePublicUrl(const QString& path, const QString& publicUrl, const bool& isDir);
    void removePublicUrl(const QString& path, const bool& isDir);
    void sendCheckPublicity(const QString& path, const bool& isDir);
    QString readPublicUrl(const QString& filepath);
};

#endif /* FILECONTROLLER_HPP_ */
