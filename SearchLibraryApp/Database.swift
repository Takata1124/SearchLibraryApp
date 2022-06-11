//
//  Database.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/06/04.
//

import Foundation
import SQLite

let FILE_NAME = "table.db"

class Database {
    
    private let table = Table("table")
    private let id = Expression<Int64>("id")
    private let isNewOreder = Expression<Bool>("isNewOrder")
    private let db: Connection
    
    init() {
        
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(FILE_NAME).path
        db = try! Connection(filePath)
  
        do {
            try db.run(table.create { t in
                t.column(Expression<Int64>("id"), primaryKey: true)
                t.column(Expression<Bool>("isNewOrder"))
            })
        } catch {}
    }
    
    func insert(isNewOrder: Bool) throws {
        let insert = table.insert(self.isNewOreder <- isNewOrder)
        try db.run(insert)
    }
    
    func findById(id: Int64) -> [Order] {
        var results = [Order]()
        
        guard let users = try? db.prepare(table.where(self.id == id)) else {
            return results
        }
        
        for row in users {
            results.append(Order(id: row[self.id], isNewOrder: row[self.isNewOreder]))
        }
        return results
    }
    
    func delete(rowId: Int64) {
        
        let selectTable = table.filter(id == rowId)
        
        do {
            try db.run(selectTable.delete())
        } catch {
            print(error)
        }
    }
    
    func update(rowId: Int64, isNewOrder: Bool) {
        
        let selectTable = table.filter(id == rowId)
        
//        print(isNewOrder)
        
        do {
            try db.run(selectTable.update(self.isNewOreder <- isNewOrder))
        } catch {
            print(error)
        }
    }
}
