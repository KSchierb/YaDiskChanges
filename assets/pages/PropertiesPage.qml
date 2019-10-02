import bb.cascades 1.4
import bb.system 1.2
import "../components"

Page {
    id: root
    
    property bool dir: false
    property string name: ""
    property string path: ""
    property string ext: ""
    property int size: 0
    //property int contentSize: 0 //KS deleted
    property date lastModified: new Date()
    property string publicUrl: ""
    property string sizeString //KS inserted
        
    signal propertiesDone()
    
    
    actions: [//KS inserted new actions to get it similar to native browser
        ActionItem {
            id: renameAction
            title: qsTr("Rename") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_rename.png"
            ActionBar.placement: ActionBarPlacement.OnBar
        
            onTriggered: {
                if (root.dir == false) {
                    var ext = "." + root.ext.toLowerCase();
                    var regEx = new RegExp(ext, "");
                    var name = root.name.replace(regEx, "");
                    renamePrompt.inputField.defaultText = name;
                } else {
                    var name = root.name;
            }
            renamePrompt.inputField.defaultText = name;
            renamePrompt.show();
            }
        
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                
                    onTriggered: {
                        renameAction.triggered();
                    }
                }
            ]
            
            attachedObjects: [
                SystemPrompt {
                    id: renamePrompt
                    
                    title: qsTr("Enter new name") + Retranslate.onLocaleOrLanguageChanged
                    dismissAutomatically: true
                    
                    onFinished: {
                        var name = root.name;
                        if (root.dir == false) {
                            var ext = "." + root.ext.toLowerCase();
                            var newName = renamePrompt.inputFieldTextEntry() + ext;
                            if (value === 2) {
                                var newName = renamePrompt.inputFieldTextEntry();
                                _fileController.rename(root.name, root.path, newName, root.dir, root.ext);
                                console.log("RENAME " + root.name+ root.path+ newName+ root.dir+ root.ext)
                                root.path = root.path.replace(root.name, newName);
                                root.name = newName + ext;
                            }
                        } else {
                            var ext = "." + root.ext.toLowerCase();
                            var newName = renamePrompt.inputFieldTextEntry()
                            if (value === 2) {
                                _fileController.rename(root.name, root.path, newName, root.dir, root.ext);
                                root.path = root.path.replace(root.name, newName);
                                root.name = newName;
                            }
                        }
                        
                    }    
                }
            ]
        },
        
        ActionItem {
            id: downloadAction
            title: qsTr("Download") + Retranslate.onLocaleOrLanguageChanged
            imageSource: "asset:///images/ic_copy.png"
            enabled: !dir
            
            onTriggered: {
                var name = root.name; 
                toast.body = (qsTr("Download started: " + Retranslate.onLocaleOrLanguageChanged) + name);
                toast.position = SystemUiPosition.MiddleCenter
                toast.show();
                
                _fileController.downloader.download(name, root.path);
            }
        
        },
        
        ActionItem {
            id: publishAction
            title: {
                if (publicUrl) {
                    return qsTr("Unpublish") + Retranslate.onLocaleOrLanguageChanged;
                }
                return qsTr("Publish") + Retranslate.onLocaleOrLanguageChanged;
            }
            imageSource: "asset:///images/ic_share.png"
            
            onTriggered: {
                if (publicUrl) {
                    _fileController.unpublish(path, dir);
                } else {
                    _fileController.publish(path, dir);
                }
            }
            
            shortcuts: [
                Shortcut {
                    key: "s"
                    
                    onTriggered: {
                        publishAction.triggered();
                    }
                }
            ]
        }
    ]   
    
    titleBar: TitleBar {
        title: qsTr("Properties") + Retranslate.onLocaleOrLanguageChanged
        
        acceptAction: ActionItem {
            title: qsTr("Done") + Retranslate.onLocaleOrLanguageChanged
            
            onTriggered: {
                propertiesDone();
            }
        }
    }
        
    //KS end of insertion
    ScrollView {
        
        Container {
            id: imageHolder
                
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                //background: ui.palette.background //KS olde value: ui.palette.plain
                preferredHeight: ui.du(36)//KS: old value 26
                
                Container {
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    maxWidth: ui.du(32)//KS: old value 22
                    maxHeight: ui.du(32)//KS: old value 26
                    //background: ui.palette.background
                    
                    margin.topOffset: ui.du(2)
                    
                    Container {
                        horizontalAlignment: HorizontalAlignment.Center
                        maxWidth: ui.du(30)//KS: old value 21
                        maxHeight: ui.du(30)//KS: old value 20
                        //background: ui.palette.background // KS: old value ui.palette.plain
                        
                        //margin.leftOffset: ui.du(1) // KS: omitt black frame
                        //margin.topOffset: ui.du(1)
                        //margin.rightOffset: ui.du(1)
                        //margin.bottomOffset: ui.du(1)
                        
                        layout: DockLayout {}
                        
                        ImageView {
                            id: preview
                            
                            imageSource: {
                                if (root.dir) {
                                    return "asset:///images/ic_folder.png";
                                } else {//KS some additions to allow suitable icons for other extensions
                                    var ext = root.ext.toLowerCase();
                                    if (_file.isImage(ext)) {
                                        return "asset:///images/IMG_photo.png";
                                    } else if (_file.isVideo(ext)) {
                                        return "asset:///images/IMG_video.png";
                                    } else if (_file.isAudio(ext)) {
                                        return "asset:///images/IMG_music.png";
                                    } else if (_file.isPdf(ext)) {
                                        return "asset:///images/IMG_pdf.png";
                                    } else if (_file.isDoc(ext)) {
                                        return "asset:///images/IMG_doc.png";
                                    } else if (_file.isSpreadSheet(ext)) {
                                        return "asset:///images/IMG_xls.png";
                                    } else if (_file.isPresentation(ext)) {
                                        return "asset:///images/IMG_ppt.png";
                                    } else if (_file.isTxt(ext)) {
                                        return "asset:///images/IMG_txt.png";
                                    } else if (_file.isApk(ext)) {
                                        return "asset:///images/IMG_apk.png";
                                    } else if (_file.isZip(ext)) {
                                        return "asset:///images/IMG_zip.png";
                                    } else if (_file.isCalendar(ext)) {
                                        return "asset:///images/IMG_calendar.png";
                                    } else if (_file.isContact(ext)) {
                                        return "asset:///images/IMG_contact.png";
                                    } else if (_file.isHtml(ext)) {
                                        return "asset:///images/IMG_doc_web.png";
                                    } else {
                                        return "asset:///images/IMG_generic.png";
                                    }
                                }
                            }
                            preferredWidth: ui.du(30) //KS: 21
                            preferredHeight: ui.du(30) //KS:20
                            filterColor: {
                              if (root.dir) {
                                 return ui.palette.primary;
                             }
                              return ui.palette.textOnPlain;
                            }
                            opacity: root.dir ? 0.5 : 1.0//KS old value 0.25 : 1.0
                            
                        }
                        
                       // ImageView {// KS deleted, not necessary in connection with changed images
                        //   id: opacBackground
                        //   visible: !root.dir && !_file.isImage(root.ext)
                        //    imageSource: "asset:///images/opac_bg.png"
                        //   opacity: 0.5
                        // }
                    }  
                }    
            }
            
            Header {
                title: {
                    if (root.dir) {
                        return qsTr("Folder properties") + Retranslate.onLocaleOrLanguageChanged
                    }
                    return qsTr("File properties") + Retranslate.onLocaleOrLanguageChanged
                }
            }
            
            PropListItem {
                name: qsTr("Name") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: root.name
            }
            
            PropListItem {
                visible: !root.dir
                name: qsTr("Type") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: root.ext.toLowerCase()
            }
            
            PropListItem {
                name: qsTr("Last modified") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: _date.str(root.lastModified);
            }
            
            PropListItem {
                visible: !root.dir
                name: qsTr("Size") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: calcSize(root.size) + Retranslate.onLocaleOrLanguageChanged
                
                function calcSize(){//KS inserted to give more precise sizes, calculation taken from "opendataspace-cascades-master", Ekkehard Gentz (ekke), Rosenheim, Germany
                    if (!dir) {
                        if (size === undefined){}
                        else {
                            var f = size;
                            if (f > 1000000000) {
                                var sf = Math.round(f/1000000000.0);
                                sizeString = sf.toString() + " GB";
                            } else if (999999999 > f && f > 1000000) {
                                var sf = Math.round(f/1000000.0);
                                sizeString = sf.toString() + " MB";
                            } else if (999999 > f && f > 1000) {
                                var sf = Math.round(f/1000.0);
                                sizeString = sf.toString() + " KB";
                            } else {
                                var sf = Math.round(f);
                                sizeString = sf.toString() + " bytes";
                            }
                            return sizeString;
                        }
                    }
                }
            }
            
            PropListItem {
                name: qsTr("Path") + Retranslate.onLocaleOrLanguageChanged + ":"//KS old value: qsTr("Placement") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: root.path
            }
            
            PropListItem {
                id: propListPublicUrl
                visible: root.publicUrl !==  ""
                name: qsTr("Public URL") + Retranslate.onLocaleOrLanguageChanged + ":"
                value: root.publicUrl
            }
            
            Container {
                id: containerPublicUrl
                visible: root.publicUrl !== ""
                horizontalAlignment: HorizontalAlignment.Fill
                
                leftPadding: ui.du(1)
                topPadding: ui.du(1)
                rightPadding: ui.du(1)
                bottomPadding: ui.du(1)
                
                Button {
                    horizontalAlignment: HorizontalAlignment.Fill
                    text: qsTr("Copy link to clipboard") + Retranslate.onLocaleOrLanguageChanged
                    
                    onClicked: {
                        if (_app.copyToClipboard(root.publicUrl)) {
                            toast.body = qsTr("Copied to clipboard") + Retranslate.onLocaleOrLanguageChanged;
                            toast.position = SystemUiPosition.MiddleCenter
                            toast.show();
                        }
                    }
                }
            }
        }
    }
    
    function setPreview(path, previewPath) {
        if (_file.isImage(root.ext)) {
            var localPath = "file://" + previewPath;
            preview.imageSource = localPath;
            //     opacBackground.visible = false; 
        }
    }
    
    
    
    function cleanUp() {
        _fileController.previewLoader.loaded.disconnect(root.setPreview);
        _fileController.publicityChecked.disconnect(root.setPublicUrl);
        _fileController.checkPublicity(root.path, root.dir);
    }
    
    onCreationCompleted: {
        _fileController.previewLoader.loaded.connect(root.setPreview);
        _fileController.publicityChecked.connect(root.setPublicUrl);
        //_fileController.checkPublicity(root.path, root.dir);
    }
    
    onPathChanged: {
        _fileController.previewLoader.load(root.name, root.path);
        _fileController.checkPublicity(root.path, root.dir);
    }
    
    function setPublicUrl(path, publicUrl) {
        root.publicUrl = publicUrl;
    }
    
    attachedObjects: [
        DateTimePicker {
            id: dateTimePicker
            mode: DateTimePickerMode.Time
            value: root.lastModified
        },
        
        SystemToast {
            id: toast
        }
    ]
}
