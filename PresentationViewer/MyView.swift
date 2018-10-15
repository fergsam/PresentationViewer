//
//  MyPDFView.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/8/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//
//  A pretty simple NSView class, Main functionaity is to make sure that WindowController hears about keyEvents
//

import Cocoa

protocol MyViewDelegate{
    func nextPage(_ sender: Any)
    func previousPage(_ sender: Any)
}

class MyView: NSView {
    
    var delegate : MyViewDelegate?
    
    override func keyDown(with event: NSEvent) {
//        print("keyDown")
        if (event.keyCode == 124){
                delegate!.nextPage(self)
        }
        else if (event.keyCode == 123){
                delegate!.previousPage(self)
        }
    }
    override var acceptsFirstResponder : Bool {
      return true
    }
}
