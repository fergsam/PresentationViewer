//
//  BookmarksTableViewController.swift
//  PresentationViewer
//
//  Created by Sam Ferguson on 10/5/17.
//  Copyright © 2017 Sam Ferguson. All rights reserved.
//

import Cocoa
import Quartz


//This is not necessarily following MVC best preactices - ideally the delegate and data source would be split out into their own model and controller
//however, this table is simpler and more readable if we keep it all together
//  -> Should refactor here
class BookmarksTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource{
    
    @IBOutlet weak var bookmarksTable: NSTableView!
    
    open var delegate: WindowController? = nil
    var bookmarks = [PDFPage]()

    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarks.count
    }
    open func removeBookmarks(for document: PDFDocument){
        for page in bookmarks{
            if page.document == document{
                let index = bookmarks.index(of: page)
                bookmarks.remove(at: index!)
            }
        }
        bookmarksTable.reloadData()
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return "Bookmark \(row + 1)"
    }
    public func addBookmark(page : PDFPage?){
        if let realPage = page{
            bookmarks.append(realPage)
            bookmarksTable.reloadData()
        }
    }
    
    func deletePresentation(){
        let index = bookmarksTable.selectedRow
        bookmarks.remove(at: index)
        bookmarksTable.reloadData()
    }
    override func keyDown(with event: NSEvent) {
        if(event.keyCode == 51){
            deletePresentation()
        }
    }
    @IBAction func doubleClick(_ sender: Any) {
        if(bookmarksTable.clickedRow >= 0){
            delegate!.goToBookmark(bookmarks[bookmarksTable.clickedRow])
        }
    }
}
