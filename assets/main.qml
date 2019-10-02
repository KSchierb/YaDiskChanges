/*
 * Copyright (c) 2011-2015 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.4
import bb.system 1.2
import "sheets"
import "pages"


NavigationPane {
    id: navPane
    
    Menu.definition: MenuDefinition {
        settingsAction: SettingsActionItem {
            onTriggered: {
                var sp = settingsPage.createObject();
                navPane.push(sp);
                Application.menuEnabled = false;
            }
        }
        
        helpAction: HelpActionItem {
            title: qsTr("About") + Retranslate.onLocaleOrLanguageChanged
            onTriggered: {
                var hp = helpPage.createObject();
                navPane.push(hp);
                Application.menuEnabled = false;
            }
        }
        
        actions: [
            ActionItem {
                title: qsTr("Send feedback") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_feedback.png"
                
                onTriggered: {
                    invokeFeedback.trigger(invokeFeedback.query.invokeActionId);
                }
            },
            
            ActionItem {
                title: qsTr("Logout") + Retranslate.onLocaleOrLanguageChanged
                imageSource: "asset:///images/ic_sign_out.png"
                
                onTriggered: {
                    _app.logout();
                }
            }
        ]
    }
    
    signal publicUrlNavPane(string pubUrl) //KS inserted because publish/unpubish action is now also possible from Settings.qml
    
    onPublicUrlNavPane: {//KS inserted because publish/unpubish action is now also possible from Settings.qml
        propsPage.publicUrlPropsPage = pubUrl;
    }
    
    onPopTransitionEnded: {
        
        if (page.cleanUp !== undefined) {
            page.cleanUp();
        }
        page.destroy();
        Application.menuEnabled = true;
    }
    
    onCreationCompleted: {
        if (!_app.hasToken()) {
            oauth.open();
        }
        _fileController.dataLoaded.connect(newPage);
        _fileController.propsPageRequested.connect(showProps);
        _app.loggedOut.connect(navPane.onLoggedOut);
        
        Application.thumbnail.connect(navPane.onThumbnail);//KS inserted
        Application.themeSupport.setPrimaryColor(calcPrimaryColor(), calcPrimaryBaseColor());//KS inserted
    }
    
    function calcPrimaryColor() {//KS inserted
        var val = _appConfig.get("color");
        if (val == 0) {
            return Color.create("#0092CC");
        } else if (val == 1){
            return Color.create("#CC3333");
        } else if (val == 2){
            return Color.create("#779933");
        } else {
            return Color.create("#DCD427");
        }
    }
    
    function calcPrimaryBaseColor() {//KS inserted
        var val = _appConfig.get("color");
        if (val == 0) {
            return Color.create("#087099");
        } else if (val == 1){
            return Color.create("#FF3333");
        } else if (val == 2){
            return Color.create("#5C7829");
        } else {
            return Color.create("#B7B327");
        }
    }
    
    
    attachedObjects: [
        OAuth {
            id: oauth
            
            onAccessTokeReceived: {
                oauth.close();
                _app.setToken(accessToken, expiresIn);
            }
        },
        
        FilePickersSheet {
            id: pickersSheet
            
            onUploadStarted: {
                pickersSheet.close();
                navPane.push(uploadsPage.createObject());
            }
        },
        
        ComponentDefinition {
            id: uploadsPage
            UploadsPage {
                paneProperties: {//KS inserted
                    setBackButtonsVisible(false);
                }//end of insertion
                
                onUploadsDone: {
                    resetBackButtonsVisible();//KS inserted
                    navPane.pop();
                }
            }    
        },
        
        ComponentDefinition {
            id: downloadsPage
            DownloadsPage {
                paneProperties: {//KS inserted because the "Done" button is the only way to navigate back
                    setBackButtonsVisible(false);
                }//end of insertion
                
                onDownloadsDone: {
                    resetBackButtonsVisible();//KS inserted
                    navPane.pop();
                }
            }    
        },
        
        ComponentDefinition {
            id: settingsPage
            SettingsPage {}    
        },
        
        ComponentDefinition {
            id: propsPage
            property string publicUrlPropsPage: ""//KS inserted because publish/unpubish action is now also possible from Settings.qml
                       
            PropertiesPage {
                
                property string publicUrlPP: propsPage.publicUrlPropsPage
                
                onPublicUrlPPChanged: {//KS inserted because publish/unpubish action is now also possible from Settings.qml
                    publicUrl = publicUrlPP;
                }
                
                paneProperties: {//KS inserted because the "Done" button is the only way to navigate back
                    setBackButtonsVisible(false);
                }//end of insertion
                
                onPropertiesDone: {
                    resetBackButtonsVisible();//KS inserted
                    navPane.pop();
                }
            }    
        },
        
        Invocation {
            id: invokeFeedback
            query {
                uri: "mailto:yadisk.bbapp@gmail.com?subject=Ya%20Disk:%20Feedback"
                invokeActionId: "bb.action.SENDEMAIL"
                invokeTargetId: "sys.pim.uib.email.hybridcomposer"
            }
        },
        
        ComponentDefinition {
            id: helpPage
            HelpPage {}    
        },
        
        ComponentDefinition {
            id: dirPage
            DirPage {
                
                onMyFioChanged: {//KS inserted
                    highCover.account = {email: myLogin, name: {display_name: myFio}};
                }
                onMyLoginChanged: {
                    highCover.account = {email: myLogin, name: {display_name: myFio}};
                }
                onMyBytesChanged: {
                    highCover.spaceUsage =  myBytes;
                } //end of insertion
                
                onLoadPath: {
                    if (!existingPage) {
                        var dp = dirPage.createObject();
                        dp.path = path;
                        dp.dirName = dirName;
                        navPane.push(dp);
                    }
                    _fileController.loadPath(path, amount, offset);
                }
                
                onLoadFile: {
                    _fileController.loadFile(filename, path);
                }
                
                onOpenFile: {
                    _fileController.openFile(filename, path);
                }
                
                onUpload: {
                    pickersSheet.targetPath = path;
                    pickersSheet.open();
                }
                
                onUploadsPageRequested: {
                    navPane.push(uploadsPage.createObject());
                }
                
                onDownloadsPageRequested: {
                    navPane.push(downloadsPage.createObject());
                }
                
                onPublicURLChanged: {//KS inserted because publish/unpubish action is now also possible from Settings.qml
                    publicUrlNavPane(publicURL);
                }
            
            }
        },
        
        SceneCover {//KS inserted because of the implementation of an active frame
            id: cover
            content: HighCover {
                id: highCover
            }
        }
    ]
    
    function onLoggedOut() {
        while (navPane.count() !== 0) {
            navPane.pop();
        }
        oauth.open();
    }
    
    function showProps(file) {
        var pp = propsPage.createObject();
        pp.ext = file.ext;
        pp.name = file.name;
        pp.dir = file.dir;
        pp.size = file.size;
        pp.path = file.path;
        if (file.lastModified != undefined){
            pp.lastModified = file.lastModified;
        } else {};
        navPane.push(pp);
    }
    
    function newPage(data) {
        if (navPane.count() === 0) {
            var dp = dirPage.createObject();
            
            dp.data = data;
            dp.path = "/";
            dp.dirName = qsTr("Root") + Retranslate.onLocaleOrLanguageChanged
            navPane.push(dp);
        } else {
            var dp = navPane.at(navPane.count() - 1);
            if (dp.data === undefined) {
                dp.data = data;
            } else {
                dp.setData(data);
            }
        }
    }
    
    function onThumbnail() {//KS inserted
        Application.setCover(cover);
    }
}

