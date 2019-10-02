import bb.cascades 1.4
import bb.cascades.pickers 1.0

Sheet {
    id: sheet
    
    signal uploadStarted();
    
    property string targetPath: ""
    
    Page {
        id: page
        
        titleBar: TitleBar {
            title: qsTr("Choose a type") + Retranslate.onLocaleOrLanguageChanged
            
            dismissAction: ActionItem {
                title: qsTr("Cancel") + Retranslate.onLocaleOrLanguageChanged
                
                onTriggered: {
                    sheet.close();
                }
            }
        }
        
        ListView {
            id: pickersList
            
            dataModel: ArrayDataModel {
                id: pickersDataModel
            }
            
            listItemComponents: [
                ListItemComponent {
                    CustomListItem {
                        horizontalAlignment: HorizontalAlignment.Fill
                        Container {
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            layout: StackLayout {
                                orientation: LayoutOrientation.LeftToRight
                            }
                            
                            ImageView {
                                verticalAlignment: VerticalAlignment.Center
                                filterColor: Color.create(ListItemData.color)
                                imageSource: ListItemData.icon
                                preferredWidth: ui.du(11)//KS inserted
                                preferredHeight: ui.du(11)//KS inserted 
                            }
                            
                            Label {
                                verticalAlignment: VerticalAlignment.Center
                                text: ListItemData.title
                                textStyle.base: SystemDefaults.TextStyles.TitleText
                            }
                        }
                    }
                }
            ]
            
            onTriggered: {
                var item = pickersDataModel.data(indexPath);
                switch (item.picker) {
                    case FileType.Picture: picturePicker.open(); break;
                    case FileType.Document: docPicker.open(); break;
                    case FileType.Music: musicPicker.open(); break;
                    case FileType.Video: videoPicker.open(); break;
                    case FileType.Other: otherPicker.open(); break; //KS inserted to allow the selection of files != doc, picture etc
                }
            }
            
            onCreationCompleted: {
                var data = [];
                //KS changes:
                data.push({icon: "asset:///images/IMG_photo.png", title: qsTr("Picture") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Picture});
                data.push({icon: "asset:///images/IMG_generic.png", title: qsTr("Document") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Document});
                data.push({icon: "asset:///images/IMG_music.png", title: qsTr("Music") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Music});
                data.push({icon: "asset:///images/IMG_video.png", title: qsTr("Video") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Video});
                data.push({icon: "asset:///images/IMG_generic.png", title: qsTr("Other") + Retranslate.onLocaleOrLanguageChanged, picker: FileType.Other}); //KS inserted
                pickersDataModel.append(data);
            }
        }
        
        attachedObjects: [
            FilePicker {
                id: picturePicker
                
                type: FileType.Picture
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                mode: FilePickerMode.PickerMultiple

                onFileSelected: {
                    page.startUpload(selectedFiles);
                }
            },
            
            FilePicker {
                id: docPicker
                
                type: FileType.Document
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                mode: FilePickerMode.PickerMultiple

                onFileSelected: {
                    page.startUpload(selectedFiles);
                }
            },
            
            FilePicker {
                id: musicPicker
                
                type: FileType.Music
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                mode: FilePickerMode.PickerMultiple
                
                onFileSelected: {
                    page.startUpload(selectedFiles);
                }
            },
            
            FilePicker {
                id: videoPicker
                
                type: FileType.Video
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                mode: FilePickerMode.PickerMultiple
                
                onFileSelected: {
                    page.startUpload(selectedFiles);
                }
            },
            
            FilePicker {//KS inserted
                id: otherPicker
                
                type: FileType.Other
                title: qsTr("Select a file") + Retranslate.onLocaleOrLanguageChanged
                mode: FilePickerMode.PickerMultiple
                
                onFileSelected: {
                    page.startUpload(selectedFiles);
                }
            } //end of insertion
        ]
        
        function startUpload(selectedFiles) {
            sheet.uploadStarted();
            selectedFiles.forEach(function(f) {
                _fileController.upload(f, targetPath);
            });
        }
    }
    
    onTargetPathChanged: {
        console.debug("target path: ", targetPath);
    }
    
    onClosed: {
        sheet.targetPath = "";
    }
}