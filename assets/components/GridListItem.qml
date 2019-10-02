import bb.cascades 1.4
import bb.device 1.4
import bb.system 1.2

CustomListItem {
    id: listItem
    
    property string currentPath: ""
    
    property variant highLight: HighlightAppearance.Default //KS inserted
   
    opacity: listItem.ListItem.selected ? 0.5 : 1.0
    
    highlightAppearance: highLight //KS inserted
    
    onCurrentPathChanged: {//KS inserted
        if (currentPath == "/"){
            listItem.highLight =  HighlightAppearance.Default;
        } else {
            listItem.highLight =  HighlightAppearance.Frame;
        }
     } // end of insertion
    
    function getTextStyle() {
        if (displayInfo.pixelSize.width === 1440) {
            return SystemDefaults.TextStyles.BodyText;
        }
        return SystemDefaults.TextStyles.SubtitleText;
    }
    
    function getImage() {
        if (!ListItemData.dir) {
            var ext = ListItemData.ext.toLowerCase();
            if (_file.isImage(ext)) {
                if (ListItemData.previewPath) {
                    return ListItemData.previewPath;
                }
                return "asset:///images/ks_7_image.png";
            } else if (_file.isVideo(ext)) {
                return "asset:///images/ks_7_video.png";
            } else if (_file.isAudio(ext)) {
                return "asset:///images/ks_7_audio.png";
            } else if (_file.isPdf(ext)) {
                return "asset:///images/ks_7_pdf.png";
            } else if (_file.isDoc(ext)) {
                return "asset:///images/ks_7_doc.png";
            } else if (_file.isSpreadSheet(ext)) {
                return "asset:///images/ks_7_xls.png";
            } else if (_file.isPresentation(ext)) {
                return "asset:///images/ks_7_ppt.png";
            } else if (_file.isApk(ext)) {
                return "asset:///images/ks_7_apk.png";
            } else if (_file.isTxt(ext)) {
                return "asset:///images/ks_7_txt.png";
            } else if (_file.isZip(ext)) {
                return "asset:///images/ks_7_zip.png";
            } else if (_file.isCalendar(ext)) {
                return "asset:///images/ks_7_calendar.png";
            } else if (_file.isContact(ext)) {
                return "asset:///images/ks_7_contact.png";
            } else if (_file.isHtml(ext)) {
                return "asset:///images/ks_7_doc_web.png";
            } else {
                return "asset:///images/ks_7_generic.png";
            }
        }
        return "asset:///images/ic_folder.png";
    }
    
    function filterColor() {
        if(Application.themeSupport.theme.colorTheme.style === VisualStyle.Dark) { //KS changed)
            if (!ListItemData.previewPath) {
                if (!ListItemData.dir) {
                    return ui.palette.textOnPlain;
                }
                return ui.palette.primary; //KS for folders
            }
            return 0;
        } else { //KS inserted
            if (!ListItemData.dir) {
                return 0;
            }
            return ui.palette.primary;
        }
}
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        background: ui.palette.background //KS old value: ui.palette.plain
        
        layout: DockLayout {}
        
        ImageView {
            id: preview
            imageSource: listItem.getImage();
            filterColor: listItem.filterColor();
            
            opacity: ListItemData.dir ? 0.5 : 1.0 //KS old value: 0.25 : 1.0
            preferredWidth: ListItemData.dir || (ListItemData.previewPath !== undefined) ? listItemLUH.layoutFrame.width : ui.du(22)// ui.du(20)
            preferredHeight: ui.du(22);//{
                //if (ListItemData.dir) {
                //    return listItemLUH.layoutFrame.height;// - ui.du(2);
               // } else if (ListItemData.previewPath !== undefined) {
          //          return listItemLUH.layoutFrame.height;
         //       } else {
          //          return ui.du(22);//KS changed
          //      } 
            //}
            verticalAlignment: {
                if (ListItemData.dir) {
                    return VerticalAlignment.Bottom;
               // } else if (ListItemData.previewPath !== undefined) {//KS deleted
               //     return VerticalAlignment.Fill;
               // } else {
                    return VerticalAlignment.Center;
                }
            }
            horizontalAlignment: ListItemData.dir ? HorizontalAlignment.Fill : HorizontalAlignment.Fill //KS old value: HorizontalAlignment.Fill : HorizontalAlignment.Center
        }
        
        ImageView {
            visible: !ListItemData.dir && ListItemData.previewPath != undefined  //KS changed old value: previewPath === undefined
            imageSource: "asset:///images/opac_bg.png"
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            opacity: 0.2 //KS old value: 0.5
        }
        
        Container {
            visible: !ListItemData.dir && ListItemData.previewPath !== undefined
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Bottom
            
            preferredHeight: ui.du(8)
            
            opacity: 0.5
        }
        
        Label {
            verticalAlignment: VerticalAlignment.Bottom
            text: ListItemData.name
            textStyle.base: SystemDefaults.TextStyles.SubtitleText
            textStyle.fontWeight: ListItemData.dir ? FontWeight.W500 : FontWeight.W400//KS: old value FontWeight.W500 : FontWeight.W300 
            textStyle.fontSize: FontSize.XSmall//KS: ohne
            
            margin.leftOffset: ui.du(1);
            margin.bottomOffset: ListItemData.dir ? ui.du(4.5) : ui.du(1.5)//KS old value: ui.du(5.5) : ui.du(4)
            
            textStyle.color: ListItemData.dir ? ui.palette.textOnPlain : ui.palette.textOnPrimary
        }
        
        Label {
            id: labelLastModified
            visible: false //KS: old value!ListItemData.dir
            
            text: _date.str(ListItemData.lastModified);
            verticalAlignment: VerticalAlignment.Bottom
            textStyle.color: ui.palette.textOnPrimary
            textStyle.base: SystemDefaults.TextStyles.SmallText
            textStyle.fontWeight: FontWeight.W100
            
            margin.leftOffset: ui.du(1);
            margin.bottomOffset: ui.du(1)
        }
        
        ImageView {
            visible: ListItemData.publicUrl !== undefined && ListItemData.publicUrl !== ""
            horizontalAlignment: HorizontalAlignment.Right
            verticalAlignment: {
                if (ListItemData.dir) {
                    return VerticalAlignment.Center;
                } else {
                    return VerticalAlignment.Top;
                }
            }
            imageSource: "asset:///images/ic_website_link.png"
            maxWidth: ui.du(5)
            maxHeight: ui.du(5)
        }
        
        attachedObjects: [
            LayoutUpdateHandler {
                id: listItemLUH
            }
        ]
    }
    
    attachedObjects: [
        DisplayInfo {
            id: displayInfo
        },
        
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
                        listItem.ListItem.view.deleteFolderAndView(data.path); //KS inserted
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
                        _fileController.currentPath = listItem.currentPath;
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
                
                    onTriggered: {
                        _fileController.downloader.download(ListItemData.name, ListItemData.path);
                        listItem.ListItem.view.pushDownloadPage(); //KS inserted
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
}
