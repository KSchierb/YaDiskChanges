 import bb.cascades 1.4
import bb.device 1.4
import bb.system 1.2
import basket.helpers 1.0
import "../components"



Page {
    id: root
    
    signal loadPath(string dirName, string path, int amount, int offset, bool existingPage)
    signal loadFile(string filename, string path)
    signal openFile(string filename, string path)
    signal upload(string path)
    signal uploadsPageRequested()
    signal downloadsPageRequested() 
            
    property string dirName: "Root"
    property string cursor: ""
    property bool hasMore: true
    property int limit: 50
    property variant account: undefined
    property variant spaceUsage: undefined
    property variant data: undefined//[] //KS: undefined
    property variant filteredData: [] //KS inserted because of the search action
    property string path: ""
    property string fileOrDirToDelete: ""
    property string pathToDelete: ""
    property variant selectedFiles: []
    property int bytesInGB: 1073741824
    property int countElements: 0  //KS inserted to count elements of folders
    
    property int page: 1
    property int pageSize: 25
    property bool hasNext: true
    
    property string myFio: "" //KS inserted
    property string myLogin: "" //KS inserted
    property string myBytes: "" //KS inserted
    property int count: 0 //KS inserted
    property string publicURL: "" //KS inserted
    property string files_view_types: "list"
    
    
    onFiles_view_typesChanged: {//KS inserted because of the persistance of grid/list views for individual folders 
        var allItems = [];
        for (var i = 0; i < dataModel.size(); i++) {
            allItems.push(dataModel.value(i));
        }
        dataModel.clear();
        dataModel.append(allItems); 
        
        if (files_view_types === "" || files_view_types === "grid") {
            viewActionItem.imageSource = "asset:///images/ic_view_list.png";
            viewActionItem.title = qsTr("List") + Retranslate.onLocaleOrLanguageChanged
            listView.layout = gridListLayout;
            addPath(path);
        } else {
            viewActionItem.imageSource = "asset:///images/ic_view_grid.png";
            viewActionItem.title = qsTr("Grid") + Retranslate.onLocaleOrLanguageChanged
            listView.layout = stackListLayout;
            searchAndRemovePath(path);
        }
    }
    
    titleBar: defaultTitleBar
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: DockLayout {}
        
        Container {
            verticalAlignment: VerticalAlignment.Center
            
            Header {
                id: header
                visible: path !== "/"
                title: path
            }
            
            FilesMover {
                path: root.path
            }
            
            FilesUploader {
                path: root.path
                
                onStartUpload: {
                    uploadsPageRequested();
                }
            }
            
            ListView {
                id: listView
                scrollRole: ScrollRole.Main
                
                property string currentPath: root.path
                property bool searchMode:false //KS: inserted from "basket, FolderPage.qml"
                
                verticalAlignment: VerticalAlignment.Bottom
                
                margin.leftOffset: ui.du(0.5)
                margin.rightOffset: ui.du(0.5)
                
                dataModel: ArrayDataModel {
                    id: dataModel
                }
                
                layout: {
                    //var view = _appConfig.get("files_view");//KS deleted
                    //if (view ==="" || view === "grid") {
                    //    return gridListLayout;
                    //}
                    //return stackListLayout;
                    //var vis = bytesLabel.visible;
                    if (files_view_types === "grid"){//KS inserted because of the persistance of grid/list views for individual folders 
                        return gridListLayout;
                    } else {
                        return stackListLayout
                    }
                }
                
                
                
                attachedObjects: [
                    ListScrollStateHandler {
                        onScrollingChanged: {
                            if (atEnd) {
                                if (!spinner.running) {
                                    if (root.hasNext) {
                                        spinner.start();
                                        var currPageSize = _app.currentPageSize();
                                        var offset = currPageSize * root.page;
                                        loadPath(root.dirName, root.path, currPageSize, offset, true);
                                        root.page++;
                                    }
                                }
                            }
                        }
                        
                        onAtEndChanged: { //KS inserted because of the implementation of a search action
                             if (dataModel.size() > 0 && !listView.searchMode) {
                                if (atEnd) {
                                     listView.up();
                                } else {
                                     listView.down();
                                }
                            }
                        } //KS: end of insertion
                        
                    }
                ]
                
                multiSelectAction: MultiSelectActionItem {}
                
                multiSelectHandler {//KS sequence altered in correspondence to the native file browser
                    status: "0 " + (qsTr("files") + Retranslate.onLocaleOrLanguageChanged)
                    actions: [
                        DeleteActionItem {
                            id: multiDeleteAction
                            
                            onTriggered: {
                                var data = [];
                                listView.selectionList().forEach(function(indexPath) {
                                        data.push(dataModel.data(indexPath));
                                });
                            root.selectedFiles = data;
                            
                            var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
                            if (doNotAsk && doNotAsk === "true") {
                                deleteSelectedFiles();
                            } else {
                                deleteMultipleDialog.show();
                            }
                            }
                        },
                        
                        ActionItem {
                            id: moveAction
                            title: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
                            imageSource: "asset:///images/ic_forward.png"
                            
                            onTriggered: {
                                _fileController.currentPath = root.path;
                                listView.selectionList().forEach(function(indexPath) {
                                    _fileController.selectFile(dataModel.data(indexPath));
                                 });
                            }
                        },
                        
                        ActionItem {
                            id: downloadAction
                            title: qsTr("Download") + Retranslate.onLocaleOrLanguageChanged
                            imageSource: "asset:///images/ic_download.png"
                            
                            onTriggered: {//KS inserted because of the automative loading of DownloadPage.qml
                                
                                var max = listView.selectionList().length;
                                max = max + 1;
                                listView.selectionList().forEach(function(indexPath) {
                                    var data = dataModel.data(indexPath);
                                    if (!data.dir) {
                                        _fileController.downloader.download(data.name, data.path);
                                        count++;
                                        if (count == 1){
                                            root.downloadsPageRequested(); //KS inserted
                                        }
                                        if (count == max){
                                            count = 0;
                                        }
                                    }
                                });
                            }
                        }
                    ]
                }
                
                onSelectionChanged: {
                    if (selectionList().length > 1) {
                        multiSelectHandler.status = selectionList().length + " " + (qsTr("files") + Retranslate.onLocaleOrLanguageChanged);
                    } else if (selectionList().length == 1) {
                        multiSelectHandler.status = "1 " + (qsTr("file") + Retranslate.onLocaleOrLanguageChanged);
                    } else {
                        multiSelectHandler.status = qsTr("None selected") + Retranslate.onLocaleOrLanguageChanged;
                    }
                }
                
                
                onTriggered: {
                    var data = dataModel.data(indexPath);
                    if (data.dir) {
                        loadPath(data.name, data.path, _app.currentPageSize(), 0, false);
                    } else {
                        spinner.start();
                        openFile(data.name, data.path);
                    }
                }
                
                function up() {//KS: inserted from "basket/FolderPage.qml"
                  listView.translationY = listView.translationY; //KS: - ui.du(12);
                }
                
                function down() {
                       listView.translationY = 0;
                } 
                                
                function itemType(data, indexPath) {
                    if (layout.objectName === "stackListLayout") {
                        return "listItem";
                    } else {
                        return "gridItem";
                    }
                }//KS: end of insertion
                
                function pushDownloadPage(){//KS inserted to enable opening of DownloadPage.qml from both, GridListItem.qml and StackListItem.qml
                    root.openDownloadPage();
                }
                
                function deleteFolderAndView(path){//KS inserted to destroy paths of deleted folder from the gridview-array (persistent)
                    searchAndRemovePath(path);
                    searchAndRemovePathSorting(path);
                }
                
                listItemComponents: [
                    ListItemComponent {
                        
                        type: "listItem"
                       
                        StackListItem {
                            id: stackLI   
                        
                            currentPath: ListItem.view.currentPath
                        }
                    },
                    
                    ListItemComponent {
                        
                        type: "gridItem"
                        
                        GridListItem {id: gridList
                            currentPath: ListItem.view.currentPath
                        }
                     }
                ]
            }
        }
        
        ActivityIndicator {
            id: spinner

            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            
            minWidth: ui.du(10)
        }
    }
    
    attachedObjects: [
        
        GridListLayout {
            id: gridListLayout
            objectName: "gridListLayout"
            columnCount: {
                if (rootDisplayInfo.pixelSize.width === 1440) {
                    return 4;
                }
                return 4; //KS old value: 3 (more suitable for BB Q20 classic
            }
        },
        
        StackListLayout {
            id: stackListLayout
            objectName: "stackListLayout"
        },
        
        DisplayInfo {
            id: rootDisplayInfo
        },
        
        SystemPrompt {
            id: createDirPrompt
            
            title: qsTr("Enter folder name") + Retranslate.onLocaleOrLanguageChanged
            dismissAutomatically: true
            
            onFinished: {
                if (value === 2) {
                    spinner.start();
                    _fileController.createDir(createDirPrompt.inputFieldTextEntry(), root.path);
                }
            }
        },
        
        SystemPrompt {
            id: publicUrlPrompt
            
            title: qsTr("Public URL") + Retranslate.onLocaleOrLanguageChanged
            dismissAutomatically: true    
        
        },
        
        SystemDialog {
            id: deleteDialog
            
            title: qsTr("Confirm the deleting") + Retranslate.onLocaleOrLanguageChanged
            body: qsTr("This action cannot be undone. Continue?") + Retranslate.onLocaleOrLanguageChanged
            
            includeRememberMe: true
            rememberMeText: qsTr("Don't ask again") + Retranslate.onLocaleOrLanguageChanged
            rememberMeChecked: {
                var dontAsk = _appConfig.get("do_not_ask_before_deleting");
                return dontAsk !== "" && dontAsk === "true";
            }
            
            onFinished: {
                if (value === 2) {
                    spinner.start();
                    _appConfig.set("do_not_ask_before_deleting", deleteDialog.rememberMeSelection() + "");
                    _fileController.deleteFileOrDir(root.fileOrDirToDelete, root.pathToDelete);
                } else {
                    root.pathToDelete = "";
                    root.fileOrDirToDelete = "";
                }
            }
        },
        
        SystemDialog {
            id: deleteMultipleDialog
            
            title: qsTr("Confirm the deleting") + Retranslate.onLocaleOrLanguageChanged
            body: qsTr("This action cannot be undone. Continue?") + Retranslate.onLocaleOrLanguageChanged
            
            includeRememberMe: true
            rememberMeText: qsTr("Don't ask again") + Retranslate.onLocaleOrLanguageChanged
            rememberMeChecked: {
                var dontAsk = _appConfig.get("do_not_ask_before_deleting");
                return dontAsk !== "" && dontAsk === "true";
            }
            
            onFinished: {
                if (value === 2) {
                    _appConfig.set("do_not_ask_before_deleting", deleteDialog.rememberMeSelection() + "");
                    deleteSelectedFiles();
                } else {
                    root.selectedFiles = [];
                }
            }
        },
        
        SystemToast {
            id: toast
        },
        
        InputTitleBar {//KS: copied from "basket, FolderPage.qml" and inserted here; copy InputTitleBar.qml from basket into components
           id: searchTitleBar
            
            onCancel: {
               listView.searchMode = false;
               dataModel.clear();
               dataModel.append(root.data);
               root.filteredData = []; 
               searchTitleBar.reset();
               root.titleBar = defaultTitleBar;
            }    
            
            onTyping: {
                searchTimer.stop();
                root.filteredData = root.data.filter(function(f) {
                    return f.name.toLowerCase().indexOf(text.toLowerCase()) !== -1;
                });
                searchTimer.start();
            }
        },
        
        Timer {//KS inserted from "basket"
              id: searchTimer
              singleShot: true
              onTimeout: {
                  dataModel.clear();
                  dataModel.append(root.filteredData);
                  root.downListView();
               }
        }, 
        
        Timer {
            id: listViewTimer
                     
            interval: 500
            singleShot: true    
                    
            onTimeout: {
                listView.down();
            }
        },//KS: end of insertion
         
        TitleBar {
            id: defaultTitleBar
                
            kind: TitleBarKind.FreeForm
            kindProperties: FreeFormTitleBarKindProperties {
                         
            content: Container {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                             
                leftPadding: ui.du(1)
                topPadding: ui.du(0.5)
                rightPadding: ui.du(1)
                bottomPadding: ui.du(1)
                             
                layout: DockLayout {
                }
                             
                Label {
                    visible: root.path !== "/"
                    verticalAlignment: VerticalAlignment.Center
                    text: root.dirName
                    textStyle.base: SystemDefaults.TextStyles.TitleText
                    textStyle.fontWeight: FontWeight.W500
                }
                             
                Label {
                    id: fioLabel
                    visible: root.path === "/" && _userController.user !== null
                    verticalAlignment: VerticalAlignment.Top
                    textStyle.fontWeight: FontWeight.W500
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 8 //KS old value: 10 (adjustment for BB Q20 classic)
                }
                             
                Label {
                    id: loginLabel
                    visible: root.path === "/" && _userController.user !== null
                    verticalAlignment: VerticalAlignment.Bottom
                    textStyle.base: SystemDefaults.TextStyles.SubtitleText
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6 // KS old value: 7 (adjustment for BB Q20 classic)
                }
                             
                Label {
                    id: bytesLabel
                    visible: root.path === "/" && _userController.user !== null
                    verticalAlignment: VerticalAlignment.Bottom
                    horizontalAlignment: HorizontalAlignment.Right
                    textStyle.base: SystemDefaults.TextStyles.SubtitleText
                    textStyle.fontSize: FontSize.PointValue
                    textStyle.fontSizeValue: 6 // KS old value: 7 (adjustment for BB Q20 classic)
                }
            }
            }
        },
        
        SystemListDialog {//KS copied from Basket, FolderPage.qml and modified correspondingly
            id: sortingDialog
            
            title: qsTr("Sort by:") + Retranslate.onLocaleOrLanguageChanged
            includeRememberMe: true
            rememberMeText: qsTr("Descending order") + Retranslate.onLocaleOrLanguageChanged
            
            onFinished: {
                if (value === SystemUiResult.ConfirmButtonSelection) {
                    configure();
                    if (rememberMeSelection() === true){
                        addPathSorting(path);
                    } else {
                        searchAndRemovePathSorting(path);
                    }
                    dataModel.clear();
                    appendData(data);
                }
            }
            
            function configure() {
                clearList()
                appendItem(qsTr("Name") + Retranslate.onLocaleOrLanguageChanged, true, "name");
                if (determineDesc() === true)  {
                        rememberMeChecked = true;
                } else {
                        rememberMeChecked = false;
                }  
            }
        }
    ]
    
    actions: [
        ActionItem { //KS: section "search" copied from "basket, FolderPage.qml" and inserted here
            id: search
            title: qsTr("Search") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_search.png"
            ActionBar.placement: ActionBarPlacement.Signature
            
            onTriggered: {
                var d = [];
                for (var i = 0; i < dataModel.size(); i++) {
                    d.push(dataModel.value(i));
                }
                root.data = d;
                listView.searchMode = true;
                root.titleBar = searchTitleBar;
                root.titleBar.focus();
            }
            
            shortcuts: Shortcut {
                key: "s"
                
                onTriggered: {
                    search.triggered();
                }
            }
        }, // end of insertion
        
        ActionItem {
            id: createDirAction
            imageSource: "asset:///images/ic_add_folder.png"
            title: qsTr("Create folder") + Retranslate.onLocaleOrLanguageChanged
            ActionBar.placement: ActionBarPlacement.InOverflow//KS .Signature
            
            onTriggered: {
                createDirPrompt.show();
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                    
                    onTriggered: {
                        createDirAction.triggered();
                    }
                }
            ]
        },
        
        ActionItem {
            id: uploadAction
            title: qsTr("Upload") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_uploads.png"
            ActionBar.placement: ActionBarPlacement.InOverflow //KS old value: OnBar  
            
            onTriggered: {
                upload(root.path);
            }
            
            shortcuts: [
                Shortcut {
                    key: "u"
                    
                    onTriggered: {
                        uploadAction.triggered();
                    }
                }
            ]
        },
        //KS: The next action item omitted 
        //ActionItem {
        //   id: uploadsAction
        //   imageSource: "asset:///images/ic_uploads.png"
        //    title: qsTr("Uploads") + Retranslate.onLocaleOrLanguageChanged
        //    
        //   onTriggered: {
        //       root.uploadsPageRequested();
        //    }
        // },
        
        
        ActionItem {
            id: viewActionItem
            imageSource: {
                if (files_view_types === "grid"){
                    return "asset:///images/ic_view_list.png";
                } else {
                    return "asset:///images/ic_view_grid.png";
                } 
                //var view = _appConfig.get("files_view");
                //if (view === files_view_types.GRID) {
                //if (view === "" || view === "grid"){
                    //return "asset:///images/ic_view_list.png";
                //}
                //return "asset:///images/ic_view_grid.png";
            }
            title: {
                if(files_view_types === "grid"){
                    return qsTr("List") + Retranslate.onLocaleOrLanguageChanged;
                } else {
                    return qsTr("Grid") + Retranslate.onLocaleOrLanguageChanged;
                } 
                //var view = _appConfig.get("files_view");
                //if (view === files_view_types.GRID) {
                //if(view === "" || view === "grid") {
                    //return qsTr("List") + Retranslate.onLocaleOrLanguageChanged;
                //}
                //return qsTr("Grid") + Retranslate.onLocaleOrLanguageChanged;
            }
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                //var view = _appConfig.get("files_view");
                //if (view === "" || view === "grid") {
                     //_appConfig.set("files_view", "list");
                //} else {
                   // _appConfig.set("files_view", "grid");
                //}
                     
                if (files_view_types === "grid") {
                    files_view_types = "list";
                } else {
                    files_view_types = "grid";
                }
            }
        },
        
        ActionItem {
            id: sort
            title: qsTr("Sort") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_sort.png"
            
            onTriggered: {
                sortingDialog.configure();
                sortingDialog.show();
            }
            
            shortcuts: Shortcut {
                key: "o"
                
                onTriggered: {
                    sort.triggered();
                }
            }
        }
    ]
    
    onCreationCompleted: {
        spinner.start();
        _fileController.fileLoaded.connect(root.stopSpinner);
        _fileController.fileOpened.connect(root.stopSpinner);
        _fileController.dirCreated.connect(root.onDirCreated);
        _fileController.deletionRequested.connect(root.onDeletionRequested);
        _fileController.fileOrDirDeleted.connect(root.deleteFileOrDir);
        _fileController.fileUploaded.connect(root.onFileUploaded);
        _fileController.fileRenamed.connect(root.onFileRenamed);
        _fileController.fileMoved.connect(root.onFileMoved);
        _fileController.previewLoader.loaded.connect(root.setPreview);
        _fileController.publicMade.connect(root.showPublicUrl);
        _fileController.unpublicMade.connect(root.hidePublicUrl);
        _fileController.publicityChecked.connect(root.setPublicUrl);
        _userController.userChanged.connect(root.updateUser);
        _appConfig.settingsChanged.connect(root.onSettingsChanged);
        if (_appConfig.get("view") === undefined){
            _appConfig.set("view",[""]);
        }
    }
    
    onDataChanged: {
        dataModel.clear();
        appendData(data);
        spinner.stop();
        files_view_types = determineGrid();
    }
    
    onPathChanged: {
        if (path === "/") {
            _userController.userinfo();
            _userController.diskinfo();
            sort.enabled = false; //KS inserted to disable sort action in the root
        } else {
            sort.enabled = true; //KS inserted to enable sort action
        }
        _fileController.checkPublicity(path, true);
        files_view_types = determineGrid();
    } 
    
    function openDownloadPage(){//KS inserted
        root.downloadsPageRequested();
    }
    
    function updateUser(user) {
        fioLabel.text = user.fio;
        loginLabel.text = user.login;
        if (user.available_bytes !== 0) {
            bytesLabel.text = (Number(user.used_bytes / bytesInGB).toFixed(1) + qsTr("GB") + Retranslate.onLocaleOrLanguageChanged) + 
            "/" + (Number(user.available_bytes / bytesInGB).toFixed(1) + qsTr("GB") + Retranslate.onLocaleOrLanguageChanged);
            root.myFio = fioLabel.text;
            root.myLogin = loginLabel.text;
            root.myBytes = bytesLabel.text;
        }
    }
    
    function loadPreview(file) {
        if (!file.dir && _file.isImage(file.ext.toLowerCase())) {
            _fileController.previewLoader.load(file.name, file.path);
        }
    }
    
    function setPreview(path, localPath) {
        for (var i = 0; i < dataModel.size(); i++) {
            var f = dataModel.value(i);
            if (_file.isImage(f.ext)) {
                if (f.path === path && localPath.indexOf(f.name) !== -1) {
                    f.previewPath = "file://" + localPath;
                    dataModel.replace(i, f);
                }
            }
        }
    }
    
    function stopSpinner() {
        spinner.stop();
    }
    
    function onDirCreated(dirname, path) {
        spinner.stop();
        if (path === root.path) {
            var dirObj = {path: path + dirname + "/", name: dirname, ext: "", dir: true, lastModified: new Date()};
            dataModel.insert(0, dirObj);
            updateData();
        }
    }
    
    function updateData(){
        var data = [];//KS inserted to update data; necessary if sort action is done!
        for (var i = 0; i < dataModel.size(); i++) {
            data.push(dataModel.value(i)); 
        }
        root.data = data; //KS end of insertion
    }
    
    function onDeletionRequested(name, path) {
        var dir = isDir(path);
        var comparablePath = getComparablePath(dir, name);
        if (path === comparablePath) {
            
            root.pathToDelete = path;
            root.fileOrDirToDelete = name;
            
            var doNotAsk = _appConfig.get("do_not_ask_before_deleting");
            if (doNotAsk && doNotAsk === "true") {
                spinner.start();
                _fileController.deleteFileOrDir(root.fileOrDirToDelete, root.pathToDelete);
            } else {
                deleteDialog.show();
            }
        }
    }
    
    function deleteSelectedFiles() {
        spinner.start();
        root.selectedFiles.forEach(function(file) {
            _fileController.deleteFileOrDir(file.name, file.path);
            if (isDir(file.path) === true){//KS inserted to remove potential gridview´s paths
                searchAndRemovePath(file.path);  
            }
        });
        root.selectedFiles = [];
        spinner.stop();
    }
    
    function deleteFileOrDir(name, path) {
        spinner.stop();
        var dir = isDir(path);
        var comparablePath = getComparablePath(dir, name);
        if (path === comparablePath) {
            for (var i = 0; i < dataModel.size(); i++) {
                var d = dataModel.value(i);
                if (d.path === path) {
                    dataModel.removeAt(i);
                }
            }
            updateData();
        }
        _userController.diskinfo();
    }
    
    function getComparablePath(isDir, name) {
        return root.path + name + (isDir ? "/" : "");
    }
    
    function isDir(path) {
        return path.lastIndexOf("/") === path.length - 1;
    }
    
    function onSettingsChanged() {
        var dontAsk = _appConfig.get("do_not_ask_before_deleting");
        var dontAskBool = dontAsk !== "" && dontAsk === "true";
        deleteDialog.rememberMeChecked = dontAskBool;
        
        //var view = _appConfig.get("files_view"); //KS deleted and partly shifted to on onFiles_view_typesChanged:
        //var allItems = [];
        //for (var i = 0; i < dataModel.size(); i++) {
        //    allItems.push(dataModel.value(i));
        //}
        //dataModel.clear();
        
        //if (view === "" || view === "grid") {
        //   viewActionItem.imageSource = "asset:///images/ic_view_list.png";
        //   viewActionItem.title = qsTr("List") + Retranslate.onLocaleOrLanguageChanged
        //   listView.layout = gridListLayout;
        //} else {
        //    viewActionItem.imageSource = "asset:///images/ic_view_grid.png";
        //    viewActionItem.title = qsTr("Grid") + Retranslate.onLocaleOrLanguageChanged
        //   listView.layout = stackListLayout;
        //}
        //dataModel.append(allItems);
    }
    
    function onFileUploaded(targetPath, file) {
        if (root.path === targetPath) {
            var exists = false;
            for (var i = 0; i < dataModel.size(); i++) {
                if (dataModel.value(i).path === file.path) {
                    exists = true;
                }
            }
            if (!exists) {
                dataModel.append(file);
            }
            updateData();
        }
        _fileController.previewLoader.load(file.name, file.path);//KS inserted
        _userController.diskinfo();
    }
    
    function onFileRenamed(prevName, prevPath, newName, newPath) {
        spinner.stop();
        for (var i = 0; i < dataModel.size(); i++) {
            var data = dataModel.value(i);
            if (data.path === prevPath) {
                var newData = {};
                newData.ext = data.ext;
                newData.name = newName;
                newData.path = newPath;
                newData.lastModified = new Date();// KS: it would be better to have the creation time ("createdAt") visible in addition
                newData.dir = data.dir;
                newData.size = data.size; //KS inserted to enable size after renaming of files
                newData.previewPath = data.previewPath;//KS inserted
                newData.publicUrl = data.publicUrl;//KS inserted
                dataModel.replace(i, newData);
            }
        }
        updateData();
    }
    
               
    function onFileMoved(name, prevPath, newPath, currentPath, isDir, ext, size) {
        if (root.path === currentPath) {
            var data = {};
            data.name = name;
            data.path = newPath;
            data.ext = ext;
            data.dir = isDir;
            data.lastModified = new Date();// KS: it would be better to have the creation time ("createdAt") visible in addition
            data.size = size;//KS inserted to enable size after moving of files
            
            dataModel.append(data);
            _fileController.checkPublicity(newPath, isDir);
            _fileController.previewLoader.load(name, newPath);
            updateData();
        }
        if (root.path === _fileController.currentPath) {
            for (var i = 0; i < dataModel.size(); i++) {
                if (dataModel.value(i).path === prevPath) {
                    dataModel.removeAt(i);
                }
            }
            updateData();
            
        } 
    }
    
    function setData(data) {
        if (root.data === undefined || root.data.length === 0) {
            root.data = data;
        } else {
            appendData(data);
        }
        
        spinner.stop();
    }
    
    function appendData(data) {//KS modified to include sorting order action
        if (determineDesc() == false || dirName == "Root"){
            if (data) {
                root.hasNext = data.length === _app.currentPageSize();
                data.forEach(
                    function(f) {
                        dataModel.append(f);
                        root.loadPreview(f);
                        _fileController.checkPublicity(f.path, f.dir);
                    }
                );
            }
        } else {//sorting rule: display folders always top
            if (dirName != "Root"){
                var arrayFolder = [];
                var arrayFiles = [];
                for (var i = 0; i < data.length; i++){
                    if(data[i].valueOf().ext == ""){
                        arrayFolder.push(data[i]);
                    } else {
                        arrayFiles.push(data[i]);
                    }
                }
                var arrayFolderReverse = arrayFolder.reverse();
                var array = arrayFolderReverse.concat(arrayFiles.reverse());
                array.forEach(
                    function(f) {
                        dataModel.append(f);
                        root.loadPreview(f);
                        _fileController.checkPublicity(f.path, f.dir);
                    }
                );
            }
        } 
    }
    
       
    function showPublicUrl(path, publicUrl) {
        if (root.path === path) {
            publicUrlPrompt.inputField.defaultText = publicUrl;
            publicUrlPrompt.show();
        } else {
            var hasChild = replaceItemPublicUrl(path, publicUrl);
            
            if (hasChild) {
                publicUrlPrompt.inputField.defaultText = publicUrl;
                publicUrlPrompt.show();
            }
        }
    }
    
    function hidePublicUrl(path) {
        for (var i = 0; i < dataModel.size(); i++) {
            var data = dataModel.value(i);
            if (data.path === path) {
                data.publicUrl = undefined;
                root.publicURL = "";//KS inserted
                dataModel.replace(i, data);
            }
        }
    }
    
    function setPublicUrl(path, publicUrl) {
        replaceItemPublicUrl(path, publicUrl);
    }
    
    function replaceItemPublicUrl(path, publicUrl) {
        var hasChild = false;
        for (var i = 0; i < dataModel.size(); i++) {
            if (!hasChild) {
                var data = dataModel.value(i);
                if (data.path === path) {
                    data.publicUrl = publicUrl;
                    root.publicURL = data.publicUrl;//KS inserted
                    dataModel.replace(i, data);
                    hasChild = true;
                }
            }
        }
        return hasChild;
    }
    
    function downListView() { //KS: inserted from FolderPage.qml
        listViewTimer.start();
    } //end of insertion
    
    function searchAndRemovePath(path){//KS: inserted ("Make individual folders´view persistent"), all folder paths with selected grid views are put into an array "pathsGridView"
        var pathsGridView =_appConfig.get("view");
        var selectedIndex = pathsGridView.indexOf(path);
        if (selectedIndex != -1) {
            var split1 = pathsGridView.slice(0, selectedIndex);
            var split2 = pathsGridView.slice(selectedIndex + 1, pathsGridView.length);
            var pathsGridView = split1.concat(split2);
            _appConfig.set("view", pathsGridView);
        }
    }
    
    function addPath(path) {//KS: inserted ("Make individual folders´view persistent")
        var pathsGridView =_appConfig.get("view");
        var selectedIndex = pathsGridView.indexOf(path);
        if (selectedIndex === -1){
            var pathsGridView = pathsGridView.concat(Array(path));    
            _appConfig.set("view", pathsGridView); 
        } else {}
     }
    
    function determineGrid(){//KS: inserted ("Make individual folders´view persistent")
        var pathsGridView =_appConfig.get("view");
        var selectedIndex = pathsGridView.indexOf(path);
        if (selectedIndex === -1){
            return "list";    
        } else {
            return "grid";
        }
    }
    
    function searchAndRemovePathSorting(path){//KS: inserted ("Make individual folders´view persistent"), all folder paths with selected descending order are put into an array "pathsDescOrder"
        var pathsDescOrder =_appConfig.get("sorting");
        var selectedIndex = pathsDescOrder.indexOf(path);
        if (selectedIndex != -1) {
            var split1 = pathsDescOrder.slice(0, selectedIndex);
            var split2 = pathsDescOrder.slice(selectedIndex + 1, pathsDescOrder.length);
            var pathsDescOrder = split1.concat(split2);
            _appConfig.set("sorting", pathsDescOrder);
        }
    }
        
    function addPathSorting(path) {//KS: inserted ("Make individual folders´view persistent")
        var pathsDescOrder =_appConfig.get("sorting");
        var selectedIndex = pathsDescOrder.indexOf(path);
        if (selectedIndex === -1){
            var pathsDescOrder = pathsDescOrder.concat(Array(path));    
            _appConfig.set("sorting", pathsDescOrder); 
        } else {}
    }
    
    
    function determineDesc(){//KS: inserted ("Make individual folders´ sorting order persistent")
        var pathsDescOrder =_appConfig.get("sorting");
        var selectedIndex = pathsDescOrder.indexOf(path);
        if (selectedIndex === -1){
            return false;    
        } else {
            return true;// true for descending sorting order
        }
    }
        
    function cleanUp() {
        _fileController.fileLoaded.disconnect(root.stopSpinner);
        _fileController.fileOpened.disconnect(root.stopSpinner);
        _fileController.dirCreated.disconnect(root.onDirCreated);
        _fileController.deletionRequested.disconnect(root.onDeletionRequested);
        _fileController.fileOrDirDeleted.disconnect(root.deleteFileOrDir);
        _fileController.fileUploaded.disconnect(root.onFileUploaded);
        _fileController.fileRenamed.disconnect(root.onFileRenamed);
        _fileController.fileMoved.disconnect(root.onFileMoved);
        _fileController.previewLoader.loaded.disconnect(root.setPreview);
        _userController.userChanged.disconnect(root.updateUser);
        _fileController.publicMade.disconnect(root.showPublicUrl);
        _fileController.unpublicMade.disconnect(root.hidePublicUrl);
        _fileController.publicityChecked.disconnect(root.setPublicUrl);
        _appConfig.settingsChanged.disconnect(root.onSettingsChanged);
        
    }
}
