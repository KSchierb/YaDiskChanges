import bb.cascades 1.4
import bb.system 1.2


CustomListItem {
    id: listListItem
    
    property string currentPath: "/"
    property string bytesSize: "" //KS inserted
    
        
    opacity: listListItem.ListItem.selected ? 0.5 : 1.0
    
    attachedObjects: [
        SystemPrompt {
            id: renamePrompt
            
            title: qsTr("Enter new name") + Retranslate.onLocaleOrLanguageChanged
            dismissAutomatically: true
            
            onFinished: {
                if (value === 2) {
                    var newName = renamePrompt.inputFieldTextEntry();
                    _fileController.rename(ListItemData.name, ListItemData.path, newName, ListItemData.dir, ListItemData.ext);
                }
            }    
        },
        
        SystemToast {//KS inserted
            id: toast
        }
    ]
    
    contextActions: [
        ActionSet {
            
            actions: [
                DeleteActionItem {
                    id: deleteAction
                    
                    onTriggered: {
                        var data = ListItemData;
                        _fileController.requestDeletion(data.name, data.path);
                        listListItem.ListItem.view.deleteFolderAndView(data.path); //KS inserted
                    }
                    
                    shortcuts: [
                        Shortcut {
                            key: "d"
                            
                            onTriggered: {
                                deleteAction.triggered();
                            }
                        }
                    ]
                },
                
                
                ActionItem {
                    id: moveAction
                    title: qsTr("Move") + Retranslate.onLocaleOrLanguageChanged
                    imageSource: "asset:///images/ic_forward.png"
                    
                    onTriggered: {
                        _fileController.currentPath = listListItem.currentPath;
                        _fileController.clearSelectedFiles();
                        _fileController.selectFile(ListItemData);
                    }
                    
                    shortcuts: [
                        Shortcut {
                            key: "m"
                            
                            onTriggered: {
                                moveAction.triggered();
                            }
                        }
                    ]
                },
                
                ActionItem {
                    id: downloadAction
                    title: qsTr("Download") + Retranslate.onLocaleOrLanguageChanged
                    imageSource: "asset:///images/ic_download.png"
                    enabled: !ListItemData.dir
                
                    onTriggered: {//KS inserted
                        _fileController.downloader.download(ListItemData.name, ListItemData.path);
                        listListItem.ListItem.view.pushDownloadPage(); //KS inserted
                        //_app.toast((qsTr("Download started: ") + Retranslate.onLocaleOrLanguageChanged) + _file.filename(currentPath));
                    }
                },
                
                ActionItem {
                    id: propsAction
                    title: qsTr("Properties") + Retranslate.onLocaleOrLanguageChanged
                    imageSource: "asset:///images/ic_properties.png"
                    
                    onTriggered: {
                        _fileController.showProps(ListItemData);
                    }
                    
                    shortcuts: [
                        Shortcut {
                            key: "p"
                            
                            onTriggered: {
                                propsAction.triggered();
                            }
                        }
                    ]
                },
                
                ActionItem {
                    id: renameAction
                    title: qsTr("Rename") + Retranslate.onLocaleOrLanguageChanged
                    imageSource: "asset:///images/ic_rename.png"
                    
                    onTriggered: {
                        if (!ListItemData.dir) {
                            var ext = "." + ListItemData.ext.toLowerCase();
                            var regEx = new RegExp(ext, "ig");
                            var name = ListItemData.name.replace(regEx, "");
                            renamePrompt.inputField.defaultText = name;
                        } else {
                            renamePrompt.inputField.defaultText = ListItemData.name;
                        }
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
                },
                
                
                ActionItem {
                    id: publishAction
                    title: {
                        if (ListItemData.publicUrl) {
                            return qsTr("Unpublish") + Retranslate.onLocaleOrLanguageChanged;
                        }
                        return qsTr("Publish") + Retranslate.onLocaleOrLanguageChanged;
                    }
                    imageSource: "asset:///images/ic_share.png"
                    
                    onTriggered: {
                        if (ListItemData.publicUrl) {
                            _fileController.unpublish(ListItemData.path, ListItemData.dir);
                        } else {
                            _fileController.publish(ListItemData.path, ListItemData.dir);
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
        }
    ]
    
    function getImage() {
        if (!ListItemData.dir) {
            var ext = ListItemData.ext.toLowerCase();
            if (_file.isImage(ext)) {
                if (ListItemData.previewPath !== undefined) {
                    return ListItemData.previewPath;
                }
                return "asset:///images/IMG_image.png";
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
            } else if (_file.isApk(ext)) {
                return "asset:///images/IMG_apk.png";
            } else if (_file.isTxt(ext)) {
                return "asset:///images/IMG_txt.png";
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
        return "asset:///images/ic_folder.png";
    }
    
    function filterColor() {
        if (!ListItemData.dir) {
            if (ListItemData.previewPath === undefined) {
                return 0; //KS ui.palette.textOnPlain;
            } else {
                return 0;
            }
        }
        return ui.palette.primary;
    }
    
    function calcSize(){
        if (!ListItemData.dir) {
            if (ListItemData.size === undefined){}
            else {
                var f = ListItemData.size;
                if (f > 1000000000) {
                    var sf = Math.round(f/1000000000.0);
                    bytesSize = sf.toString() + " GB";
                } else if (999999999 > f && f > 1000000) {
                    var sf = Math.round(f/1000000.0);
                    bytesSize = sf.toString() + " MB";
                } else if (999999 > f && f > 1000) {
                    var sf = Math.round(f/1000.0);
                    bytesSize = sf.toString() + " KB";
                } else {
                    bytesSize = "0 KB";
                }
                return bytesSize;
            }
        }
    }
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layout: StackLayout {
            orientation: LayoutOrientation.LeftToRight
        }
        
        preferredHeight: ui.du(12) //KS inserted
        
        Container {
            id: contentContainer
            background: ui.palette.background //KS old value: ui.palette.plain
                        
            layout: DockLayout {
            }
            
            verticalAlignment: VerticalAlignment.Center //KS inserted
            preferredHeight: ui.du(10)//KS inserted
            
            ImageView {
                imageSource: listListItem.getImage();
                filterColor: listListItem.filterColor();
                margin.leftOffset: ui.du(0.5) //KS inserted
                
                opacity: ListItemData.dir ?  0.5 : 1.0 //KS old value: 0.25 : 1.0
                preferredWidth: ui.du(10)//KS old value: 11
                preferredHeight: ui.du(10)//KS old value: 11
                
            }
            
            //ImageView { //KS: omitted
            //   visible: !ListItemData.dir && ListItemData.previewPath === undefined
            //    imageSource: "asset:///images/opac_bg.png"
                
            //    opacity: 0.5
            //        preferredWidth: ui.du(11)
            //     preferredHeight: ui.du(11)
            // }
        }                            
        
        //  Container {
        //  horizontalAlignment: HorizontalAlignment.Fill
            
        //   layoutProperties: StackLayoutProperties {
        //    spaceQuota: 2
                //   }
            
            //leftPadding: ui.du(1)
            // topPadding: {
            //  if (!ListItemData.dir) {
            //      return ui.du(1);
            //   }
            // }
            // rightPadding: ui.du(1)
            // bottomPadding: {
            //     if (!ListItemData.dir) {
            //         return ui.du(1);
            //     }
            // }
            
            //    verticalAlignment: {
            //       if (ListItemData.dir) {
            //           return VerticalAlignment.Center
            //     }
        //      return VerticalAlignment.Fill
        //    }
            
        // layout: DockLayout {}
            
        //  Container {
        //    layout: StackLayout {
        //        orientation: LayoutOrientation.LeftToRight
        //    }
                
                
        //  }
                
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            layoutProperties: StackLayoutProperties {
                spaceQuota: 4
            }
            
            margin.leftOffset: ui.du(2) //KS inserted
            maxHeight: ui.du(10) //KS inserted
            verticalAlignment: VerticalAlignment.Center
            
            Container {//KS inserted
                maxHeight: ui.du(5) 
                verticalAlignment: VerticalAlignment.Top
                
                Label {
                    text: ListItemData.name
                    //verticalAlignment: VerticalAlignment.Top
                    //horizontalAlignment: HorizontalAlignment.Left
                    //textStyle.base: SystemDefaults.TextStyles.SubtitleText
                    textStyle.fontSize: FontSize.Medium
                    textStyle.fontWeight: FontWeight.Normal //KS old value W100
                }
            }
                
            Container {
                maxHeight: ui.du(5) 
                verticalAlignment: VerticalAlignment.Bottom
                
                Label {
                    visible: !ListItemData.dir
                    //verticalAlignment: VerticalAlignment.Center
                    //horizontalAlignment: HorizontalAlignment.Left
                
                    text: _date.str(ListItemData.lastModified);//);//KS new value:?
                    //textStyle.base: SystemDefaults.TextStyles.SubtitleText
                    textStyle.fontSize: FontSize.Small
                    textStyle.fontWeight: FontWeight.W200 //KS old value W100
                }
            }
        } //KS inserted
            
        Container {
            layout: StackLayout {
                orientation: LayoutOrientation.RightToLeft
            }
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: VerticalAlignment.Center
            //preferredWidth: ui.du(5)
            
            Label {
                id: labelBytes
                visible: !ListItemData.dir
                verticalAlignment: VerticalAlignment.Center//KS old value: Bottom
                horizontalAlignment: HorizontalAlignment.Right
                margin.rightOffset: ui.du(1) //KS inserted
                //text: Number(ListItemData.size / (1024 * 1024)).toFixed(1) + " " + qsTr("MB") + Retranslate.onLocaleOrLanguageChanged //KS changed
                text: calcSize() //KS inserted
                textStyle.base: SystemDefaults.TextStyles.SmallText//KS old value: SubtitleText
                textStyle.fontWeight: FontWeight.W200
            }
            
            ImageView {//KS shifted top
                visible: ListItemData.publicUrl !== undefined && ListItemData.publicUrl !== ""
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Top//Center
                imageSource: "asset:///images/ic_website_link.png"
                maxWidth: ui.du(5)
                maxHeight: ui.du(5)
                }
        }
    }
}
    //}
//}
