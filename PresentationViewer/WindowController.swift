//
//  WindowController.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/2/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//

import Cocoa
import Quartz



/**
 This is the meat of a lot of this Application. It is the controller class for All of the windows
 **/
class WindowController: NSWindowController, PresentationViewerModelDelegate, MyViewDelegate{

    @IBOutlet weak var pageSelector: NSPopUpButtonCell!

    @IBOutlet var presentationNotesTextView: NSTextView!
    @IBOutlet var notesTextView: NSTextView!
    @IBOutlet weak var notesView: NSView!
    @IBOutlet weak var controlsView: NSView!
    @IBOutlet weak var topLevelView: NSView!
    @IBOutlet var windowOutlet: NSWindow!
    @IBOutlet weak var pdfViewer: PDFView!

    @IBOutlet weak var presentationsTableViewHolder: NSView!
    @IBOutlet weak var bookmarksTableViewHolder: NSView!
    
    var showControlsConstraints : [NSLayoutConstraint]?
    var hideControlsConstraints : [NSLayoutConstraint]?

    var presentationTableViewController : PresentationTableViewController!
    var bookmarksTableViewController : BookmarksTableViewController!
    
    
    //The idea behind presentView is it is an independant window that just holds a pdf, but mirrors
    //the normal presentation window - that is, it is the window that would be displayed to an audience,
    //while the presenter can keep their navigation/bookmarks/comments window open on their own device
    var presentView : PresentationWindow!
    
    //
    var presentationViewer : PresentationViewerModel? = nil
    
    static var windowCounter : Int = 0
    
    convenience init() {
        self.init(windowNibName: "WindowController")
        presentationViewer = PresentationViewerModel()
        presentationViewer!.delegate = self
    }
    /**
     Settup the constraints for the view to enable toggling between showing and hiding the controls panel
     **/
    func initializeConstraintArrays(){
        //settup the constraints for when the controls are hidden
        let topConstraintH = pdfViewer.topAnchor.constraint(equalTo: self.topLevelView.topAnchor)
        let bottomConstraintH = pdfViewer.bottomAnchor.constraint(equalTo: self.topLevelView.bottomAnchor)
        let leftConstraintH = pdfViewer.leadingAnchor.constraint(equalTo: self.topLevelView.leadingAnchor)
        let rightConstraintH = pdfViewer.trailingAnchor.constraint(equalTo: self.topLevelView.trailingAnchor)
        hideControlsConstraints = [topConstraintH, bottomConstraintH, leftConstraintH, rightConstraintH]
        
        
        //settup the constraints for when the controls are shown
        let topConstraintS = pdfViewer.topAnchor.constraint(equalTo: self.topLevelView.topAnchor)
        let bottomConstraintS = pdfViewer.bottomAnchor.constraint(equalTo: self.topLevelView.bottomAnchor)
        let leftConstraintS = pdfViewer.leadingAnchor.constraint(equalTo: self.topLevelView.leadingAnchor)
        let rightConstraintS = pdfViewer.trailingAnchor.constraint(equalTo: self.topLevelView.trailingAnchor, constant: -200.0)
        showControlsConstraints = [topConstraintS, bottomConstraintS, leftConstraintS, rightConstraintS]
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        presentationTableViewController = PresentationTableViewController(nibName: nil, bundle: nil)
        presentationTableViewController.delegate = self
        
        bookmarksTableViewController = BookmarksTableViewController(nibName: nil, bundle: nil)
        bookmarksTableViewController.delegate = self
    
        window?.makeFirstResponder(presentationTableViewController)
        
        presentationsTableViewHolder.addSubview(presentationTableViewController.view)
        
        bookmarksTableViewHolder.addSubview(bookmarksTableViewController.view)
        
        
        initializeConstraintArrays()
        showHideControls()
        showHideNotes()
//        constrainNotesView()
                
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PDFViewChangedPage"), object: pdfViewer, queue: nil) {_ in
            self.updatePageDisplay()
        }
    }
    
    /**
     A function for updating the current page shown, and the neccessary components in including the page list and the notes
     **/
    func updatePageDisplay(){
        self.updatePageSelectorSelected()
        self.notesTextView.string = self.presentationTableViewController.updateNotes(currentDoc: self.pdfViewer.document, newNotes: self.notesTextView.string)
        if(self.presentationViewer!.presentViewDisplayed){
            self.presentView.setPresentView(doc: self.pdfViewer.document, page: self.pdfViewer.currentPage)
        }
    }
    
    /**
     A function for opening showing and hiding the presentView window (used to mirror the normal view, without displayng the
     controls, bookmarks, comments
    **/
    @IBAction func togglePresentView(_ sender: Any) {
        if(presentationViewer!.presentViewDisplayed){
            presentView!.close()
            presentationViewer!.togglePresentView()
        }else{
            presentView = PresentationWindow()
            presentView.delegate = self
            presentView.showWindow(self)
            presentView.setPresentView(doc: pdfViewer.document, page: pdfViewer.currentPage)
            presentationViewer!.togglePresentView()
        }
    }
    
    
    /**
     enable the application to show and hide the control panel, toggle between the proper view layouts as necessary
    **/
    func showHideControls(){
        pdfViewer.translatesAutoresizingMaskIntoConstraints = false

        var currentConstraints = presentationViewer!.currentConstraints
        if (currentConstraints == nil){
            currentConstraints = showControlsConstraints
        }
        NSLayoutConstraint.deactivate(currentConstraints!)

        var newRightConstraint : NSLayoutConstraint
        if presentationViewer!.navigatorDisplayed{
            newRightConstraint = pdfViewer.trailingAnchor.constraint(equalTo: self.topLevelView.trailingAnchor)
                self.controlsView.isHidden = true
        }else{
            newRightConstraint = pdfViewer.trailingAnchor.constraint(equalTo: self.topLevelView.trailingAnchor, constant: -200.0)
                self.controlsView.isHidden = false
        }
        presentationViewer!.toggleNavigator()
        currentConstraints![3] = newRightConstraint
        NSLayoutConstraint.activate(currentConstraints!)
        presentationViewer?.storeCurrentConstraints(currentConstraints!)
    }
    
    /**
     Toggle between showing and hiding the notes panel, updating the view constraints as neccessary
    **/
    func showHideNotes(){
        pdfViewer.translatesAutoresizingMaskIntoConstraints = false

        var currentConstraints = presentationViewer!.currentConstraints
        if (currentConstraints == nil){
            currentConstraints = showControlsConstraints
        }
        NSLayoutConstraint.deactivate(currentConstraints!)

        var newLeftConstraint : NSLayoutConstraint
        if presentationViewer!.notesViewDisplayed{
            newLeftConstraint = pdfViewer.leftAnchor.constraint(equalTo: self.topLevelView.leftAnchor)
                self.notesView.isHidden = true
        }else{
            newLeftConstraint = pdfViewer.leftAnchor.constraint(equalTo: self.topLevelView.leftAnchor, constant: 200.0)
                self.notesView.isHidden = false
        }
        presentationViewer!.toggleNotes()
        currentConstraints![2] = newLeftConstraint
        
        NSLayoutConstraint.activate(currentConstraints!)
        presentationViewer?.storeCurrentConstraints(currentConstraints!)
    }
    
    /**
     Settup the view conxstraints for the Notes View. By default they are shown.
    **/
    func constrainNotesView(){
        notesView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = notesView.topAnchor.constraint(equalTo: self.pdfViewer.bottomAnchor)
        let bottomConstraint  = notesView.bottomAnchor.constraint(equalTo: self.topLevelView.bottomAnchor)
        let leftConstraint = notesView.leadingAnchor.constraint(equalTo: self.topLevelView.leftAnchor)
        let rightConstraint = notesView.trailingAnchor.constraint(equalTo: self.pdfViewer.trailingAnchor)
     
        let notesConstraints = [topConstraint, bottomConstraint, leftConstraint, rightConstraint]
        
        NSLayoutConstraint.activate(notesConstraints)
    }

    
    @IBAction func showNotes(_ sender: Any) {
        showHideNotes()
    }
    @IBAction func showControlsButton(_ sender: Any) {
        showHideControls()
    }
    @IBAction func hideControlsButton(_ sender: Any) {
        showHideControls()
    }
    
    //Used to set the current Presentation as the PDF document passed in
    func currentPresentation(_ doc: PDFDocument?) {
        if let oldDocument = pdfViewer.document{
            presentationTableViewController!.setPresentationNotes(currentDoc: oldDocument, newNotes: presentationNotesTextView.string)
        }
        pdfViewer.document = doc
//        self.notesTextView.string = self.presentationTableViewController.updateNotes(currentDoc: self.pdfViewer.document, newNotes: self.notesTextView.string)
        presentationNotesTextView.string = presentationTableViewController.getPresentationNotes(currentDoc: doc)
        updatePageSelectorContents()

    }
    
    /**
     Update the current Presentation in the model
    **/
    func updateCurrentPresentation(_ doc: PDFDocument?){
        presentationViewer!.updateDisplayedPresentation(doc)
    }
    
    //Jumping to a bookmark when clicked by user
    func goToBookmark(_ page: PDFPage){
        presentationViewer!.updateDisplayedPresentation(page.document)
        pdfViewer.go(to: page)
//        self.notesTextView.string = self.presentationTableViewController.updateNotes(currentDoc: self.pdfViewer.document, newNotes: self.notesTextView.string)
        updatePageSelectorSelected()
    }
    
    //updating the page selector list to represent both the current page and presentation, set to '-' if nil
    func updatePageSelectorContents(){
        pageSelector.removeAllItems()
        var pages = [String]()
        let currentDocument = pdfViewer.document
        if(currentDocument == nil){
            pageSelector.addItem(withTitle:"-")
            return
        }
        let lastPage = pdfViewer.document!.pageCount
        for i in 0..<lastPage{
            pages.append("page \(i+1)")
        }
        pageSelector.addItems(withTitles: pages)
        updatePageSelectorSelected()
    }
    
    //update the model
    func updatePageSelectorSelected(){
        if(pdfViewer.document != nil){
            pageSelector.selectItem(at: pdfViewer.document!.index(for: pdfViewer.currentPage!))
        }
    }
    
    //called when user selects a new page to jump to, updates the current controls and notes displayed to
    //accurately represent this information
    @IBAction func pageSelected(_ sender: Any) {
        let indexSelected = pageSelector.indexOfSelectedItem
        if(pageSelector.item(at: indexSelected)?.title != "-"){
            let pdfPageToGo = pdfViewer.document!.page(at: indexSelected)
            pdfViewer.go(to: pdfPageToGo!)
        }
        updatePageDisplay()
    }
    
    @IBOutlet var mainWindow: NSWindow!
    
    @IBAction func bookmarkCurrentPage(_ sender: Any) {
            bookmarksTableViewController.addBookmark(page: pdfViewer.currentPage)
    }

    /**
     Add a new presentation to the Application. Opens a sheet modal to select the desired pdf.
     call 'addPDFToPresentation' to update Window controls and state to represent the change.
     
     If there is no presentation being displayed, sets the added presentation to the one just added
    **/
    @IBAction func addNewPresentation(_ sender: Any) {
        let filePicker : NSOpenPanel = NSOpenPanel()
        filePicker.allowsMultipleSelection = false
        filePicker.canChooseFiles = true
        filePicker.canChooseDirectories = false
        filePicker.allowedFileTypes = ["pdf"]
        filePicker.beginSheetModal(for: mainWindow,
                completionHandler: { (returnCode)-> Void in
                    if returnCode == NSModalResponseOK {
                        if let chosenFile = filePicker.url{
                            let pdfImport = PDFDocument(url: chosenFile)
                            self.addPDFToPresentation(document: pdfImport!)
                            if self.pdfViewer.document == nil{
                                self.updateCurrentPresentation(pdfImport)
                            }
                        }
                    }
                })
        

    }
    func addPDFToPresentation(document: PDFDocument){
        presentationTableViewController.addToPresentation(doc: document)
    }
    
    
    //simple pagination, should be called by clicking next or by using the right arrow key
    @IBAction func nextPage(_ sender: Any) {
        if (pdfViewer.canGoToNextPage){
            pdfViewer.goToNextPage(sender)
        }else{
            if let currentDisplayedPresentation = self.presentationViewer!.displayedPresentation{
                if let nextDoc = presentationTableViewController.getNext(currentDoc:   currentDisplayedPresentation){
                    self.updateCurrentPresentation(nextDoc)
                }
            }
        }
        if(pdfViewer.document != nil){updatePageSelectorSelected()}
    }
    
    //The compliment function to next page, go back one page if possible; called by the previous button or using the left arrow
    @IBAction func previousPage(_ sender: Any) {
        if(pdfViewer.canGoToPreviousPage){
            pdfViewer.goToPreviousPage(sender)
//            self.notesTextView.string = self.presentationTableViewController.updateNotes(currentDoc: self.pdfViewer.document, newNotes: self.notesTextView.string)
        }else{
            if let currentDisplayedPresentation = self.presentationViewer!.displayedPresentation{
                if let prevDoc = presentationTableViewController.getPrev(currentDoc:   currentDisplayedPresentation){
                    self.updateCurrentPresentation(prevDoc)
                    pdfViewer.goToLastPage(self)
                }
            }
        }
        if(pdfViewer.document != nil){updatePageSelectorSelected()}
    }
    
    
    //listen for key pressed events to go to the next or previous page if necessary
    override func keyDown(with event: NSEvent) {
        print("keyDown")
        if (event.keyCode == 124){
                nextPage(self)
        }
        else if (event.keyCode == 123){
                previousPage(self)
        }
    }
    
    
}
