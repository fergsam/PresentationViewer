//
//
//
//  AppDelegate.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/2/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//

import Cocoa
import Quartz

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var pdfViewerWindows = [WindowController]()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        newPresentationWindow(self)
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    /**
     Create a new window, supports functionality for multiple windows with different presentaitons
    **/
    @IBAction func newPresentationWindow(_ sender: Any) {
       let presentationWindow = WindowController()
        pdfViewerWindows.append(presentationWindow)
        presentationWindow.showWindow(self)
    }
    
    /**
     Allows the user to open new PDF's. The Files are added to the presentation list
     of the appropriate window.
     **/
    @IBAction func openDocument(_ sender: AnyObject) {
        let filePicker : NSOpenPanel = NSOpenPanel()
        filePicker.allowsMultipleSelection = false
        filePicker.canChooseFiles = true
        filePicker.canChooseDirectories = false
        filePicker.allowedFileTypes = ["pdf"]
        filePicker.beginSheetModal(for: pdfViewerWindows[0].window!, completionHandler: {(returnCode)-> Void in
            if returnCode == NSModalResponseOK{
                let chosenFile = filePicker.url
                if chosenFile != nil {
                    let pdfImport = PDFDocument(url: chosenFile!)
                    self.pdfViewerWindows[0].addPDFToPresentation(document: pdfImport!)
                }
            }})
    }


}

