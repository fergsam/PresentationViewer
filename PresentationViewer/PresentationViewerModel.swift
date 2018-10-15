//
//  PresentationViewerModel.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/2/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//
import Foundation
import Quartz

public protocol PresentationViewerModelDelegate {
    func currentPresentation(_ doc: PDFDocument?)

}


/**
 This is the Model class for each Presentation View window
    It stores the Presentation View state, which has to do with the layout of the window
 
 Note that this is distinct from the presentation window, (presentation window mirrors
 this element but without the controls, bookmarks, and notes)
 **/
open class PresentationViewerModel : NSObject {

    //Different user options for layouts of the UI (
    private(set) var navigatorDisplayed : Bool = false
    private(set) var notesViewDisplayed : Bool = false
    private(set) var currentConstraints : [NSLayoutConstraint]? = nil
    private(set) var presentViewDisplayed : Bool = false
    
    open var delegate : PresentationViewerModelDelegate? = nil
    
    private(set) var presentationNotes : PDFDocument? = nil
    private(set) var displayedPresentation : PDFDocument? = nil

    
    func alertDelegate(){
        delegate?.currentPresentation(displayedPresentation)
    }
    func updateDisplayedPresentation(_ doc : PDFDocument?){
        displayedPresentation = doc
        alertDelegate()
    }
    func toggleNavigator(){
        navigatorDisplayed = !navigatorDisplayed
    }
    func toggleNotes(){
        notesViewDisplayed = !notesViewDisplayed
    }
    func storeCurrentConstraints(_ newConstraints: [NSLayoutConstraint]){
        currentConstraints = newConstraints
    }
    func togglePresentView(){
        presentViewDisplayed = !presentViewDisplayed
    }
}
