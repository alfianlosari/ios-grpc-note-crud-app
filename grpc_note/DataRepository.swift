//
//  DataRepository.swift
//  grpc_note
//
//  Created by Alfian Losari on 9/9/18.
//  Copyright © 2018 Alfian Losari. All rights reserved.
//

import Foundation
import SwiftGRPC

class DataRepository {
    
    static let shared = DataRepository()
    private init() {}

    private let client = NoteServiceServiceClient.init(address: "127.0.0.1:50051", secure: false)
    
    func listNotes(completion: @escaping([Note]?, CallResult?) -> Void) {
        _ = try? client.list(Empty(), completion: { (notes, result) in
            DispatchQueue.main.async {
                completion(notes?.notes, result)
            }
        })
    }
    
    
    func insertNote(note: Note, completion: @escaping(Note?, CallResult?) -> Void) {
        _ = try? client.insert(note, completion: { (createdNote, result) in
            DispatchQueue.main.async {
                completion(createdNote, result)
            }
        })
    }
    
    func delete(noteId: String, completion: @escaping(Bool) -> ()) {
        _ = try? client.delete(NoteRequestId(id: noteId), completion: { (success, result) in
            DispatchQueue.main.async {
                if let _ = success {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        })
    }

}

extension NoteRequestId {
    
    init(id: String) {
        self.id = id
    }
}

extension Note {
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
}
