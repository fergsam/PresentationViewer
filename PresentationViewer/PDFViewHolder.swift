//
//  PDFViewHolder.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/8/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//

import Cocoa
import Quartz

//protocol MyPDFViewHolderDelegate{
//    func nextPage()
//    func previousPage()
//}


class PDFViewHolder: NSViewController {

//    var delegate : NSWindowController?
    
    @IBOutlet weak var pdfViewer: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    override func keyDown(with event: NSEvent) {
        print("keyDown")
//        if (event.keyCode == 124){
//                delegate!.nextPage()
//        }
//        else if (event.keyCode == 123){
//                delegate!.previousPage(self)
//        }
    }
    override var acceptsFirstResponder : Bool {
      return true
    }
}
