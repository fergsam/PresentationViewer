//
//  PresentationTableViewController.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/3/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//

import Cocoa
import Quartz


/**
 This is the Presentation Table View Controller, which also serves as its own model (**this should be refactored
 to better follow MVC best practices**). It also keeps track of the notes that are general to the whole Presentation
 **/
class PresentationTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource{
    
    @IBOutlet weak var presentationTable: NSTableView!
    
    open var delegate: WindowController? = nil
    var presentations = [PDFDocument]()
    
    var notes = [[String]]()
    var presentationNotes = [String]()
    
    var notesPresentationIndex : Int? = nil
    var notesPageIndex : Int? = nil
    
//    func alerDelegate(){
//        delegate?.updatePresentation(
//    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presentations.count
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return presentations[row].documentURL?.lastPathComponent
    }
    public func addToPresentation(doc : PDFDocument){
        presentations.append(doc)
        presentationTable.reloadData()
        
        //set notes to empty
        let index = presentations.index(of: doc)
        notes.insert([], at: index!)
        for _ in 0...doc.pageCount{
            notes[index!].append("")
        }
        
        presentationNotes.insert("", at: index!)
    }
    public func getNext(currentDoc: PDFDocument) -> PDFDocument?{
        let newIndex = presentations.index(of: currentDoc)! + 1
        if (newIndex < presentations.count){
            return presentations[newIndex]
        }
        print("couldn't increment")
        return nil
    }
    public func getPrev(currentDoc: PDFDocument) -> PDFDocument?{
        let newIndex = presentations.index(of: currentDoc)! - 1
        if(newIndex >= 0){
            return presentations[newIndex]
        }
        print("couldn't increment \(newIndex)")
        return nil
    }
    public func updateNotes(currentDoc: PDFDocument?, newNotes: String?) -> String?{
        if(notesPresentationIndex != nil){
            if(notesPageIndex != nil){
                if(newNotes != nil){
                    notes[notesPresentationIndex!][notesPageIndex!] = newNotes!
                }
                else{
                    notes[notesPresentationIndex!][notesPageIndex!] = ""
                }
            }
        }
        
        if(currentDoc == nil){
            return ""
        }
        if let currentPage = delegate!.pdfViewer!.currentPage{
            let pageNumber = currentDoc!.index(for: currentPage)
            let docNumber = presentations.index(of: currentDoc!)!
            notesPresentationIndex = docNumber
            notesPageIndex = pageNumber
            return notes[docNumber][pageNumber]
        }
        return nil
    }
    
    //Keeps track of notes that apply to the entire presentation being currently displayed
    public func setPresentationNotes(currentDoc: PDFDocument, newNotes:  String?){
        let docNumber = presentations.index(of: currentDoc)!
        if(newNotes != nil){
            presentationNotes[docNumber] = newNotes!
        }
        else{
            presentationNotes[docNumber] = ""
        }
    }
    
    //get the presentation wide notes for the newly selected presentation
    public func getPresentationNotes(currentDoc: PDFDocument?) -> String?{
        if(currentDoc == nil){
            return ""
        }
        let docNumber = presentations.index(of: currentDoc!)!
        return presentationNotes[docNumber]
    }
    
    //enabling presentation deleiting by using keyboard input
    override func keyDown(with event: NSEvent){
        if(event.keyCode == 51){
            deletePresentation()
        }else{
            delegate?.keyDown(with: event)
        }
    }
    
    //remove the presentation from the presentation list
    func deletePresentation(){
        let index = presentationTable.selectedRow
        
        let currentDocument = self.delegate!.pdfViewer!.document
        let deletedDocument = presentations[index]
        if(currentDocument == deletedDocument){
            delegate?.currentPresentation(nil)
        }

        presentations.remove(at: index)

        notes.remove(at: index)
        presentationNotes.remove(at: index)
        presentationTable.reloadData()
        self.delegate!.bookmarksTableViewController!.removeBookmarks(for: deletedDocument)
    }
    
    //double clicking on the presentation in this table opens that presentation
    @IBAction func doubleClick(_ sender: Any?) {
        if(presentationTable.clickedRow >= 0){
            delegate!.updateCurrentPresentation(presentations[presentationTable.clickedRow])
        }
    }

}
