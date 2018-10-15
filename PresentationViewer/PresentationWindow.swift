//
//  PresentationWindow.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/6/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//
//  The Delegate class for PresentationWindow
//  Presentation Window mirrors the normal Window, except it has no controls or notes.
//  The purpose behind this is to enable the presentation window to simply show the 

import Cocoa
import Quartz

class PresentationWindow: NSWindowController {

    @IBOutlet weak var presentView: PDFView!
    
    open var delegate: WindowController? = nil
    
    convenience init() {
        self.init(windowNibName: "PresentationWindow")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()


        NotificationCenter.default.addObserver(forName: NSNotification.Name("PDFViewChangedPage"), object: presentView, queue: nil) {_ in
//            self.updateDelegate() //need to check and see which way page went...if it is forward, then call next() otherwise call prev()
        }
        
    }
    
    func delegateNextPage(){
        delegate!.nextPage(self)
    }
    
    public func setPresentView(doc: PDFDocument?, page: PDFPage?){
        if(doc == nil){
            presentView.document = nil
        }else{
            presentView.document = doc!
            if(page != nil){ presentView.go(to: page!
            ) }
        }
    }
    func nextPage(){
//                print("go to next")

        if (presentView.canGoToNextPage){
            delegate!.pdfViewer!.goToNextPage(self)
            presentView.goToNextPage(self)
            
        }else{
            if let currentDisplayedPresentation = delegate!.presentationViewer!.displayedPresentation{
                if let nextDoc = delegate!.presentationTableViewController.getNext(currentDoc:   currentDisplayedPresentation){
                    delegate!.updateCurrentPresentation(nextDoc)
                }
            }
        }
        if(delegate!.pdfViewer!.document != nil){delegate!.updatePageSelectorSelected()}
    }
    func previousPage(){
//        print("previousPage")
    }
    override func keyDown(with event: NSEvent) {
        print("in key down")
        if (event.keyCode == 124){
//            print("next page")
            nextPage()
        }
        else if (event.keyCode == 123){
//            print("previous Page")
        }
    }
    
    
}
