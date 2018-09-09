//
//  NoteListViewController.swift
//  grpc_note
//
//  Created by Alfian Losari on 9/9/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import UIKit

class NoteListViewController: UITableViewController {
    
    let dataRepository = DataRepository.shared
    var notes = [Note]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl(frame: .zero)
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        
        refresh()
    }
    
    @objc func add() {
        let alertController = UIAlertController(title: "Add Note", message: "Fill the fields", preferredStyle: .alert)
        alertController.addTextField { $0.placeholder = "Title" }
        alertController.addTextField { $0.placeholder = "Content" }
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            let titleTextField = alertController.textFields![0]
            let contentTextField = alertController.textFields![1]
            guard let title = titleTextField.text, !title.isEmpty,
                let content = contentTextField.text, !content.isEmpty
                else {
                    return
            }
            
            let note = Note(title: title, content: content)
            self.dataRepository.insertNote(note: note, completion: {[weak self] (createdNote, _) in
                self?.refresh()

            })
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func refresh() {
        dataRepository.listNotes {[weak self] (notes, result) in
            self?.refreshControl?.endRefreshing()
            self?.notes = notes ?? []
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let note = notes[indexPath.row]
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = note.content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let note = notes[indexPath.row]
        dataRepository.delete(noteId: note.id) {[weak self](success) in
            if success {
                self?.refresh()
            }
        }
    }
    
    
}
