//
//  SQLiteHandler.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import Foundation
import SQLite3

class SQLiteHandler {
    var db: OpaquePointer?
    
    init() {
        openDatabase()
        createTable()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening Database")
        }
        else {
            print("Database Connected Successfully")
        }
    }
    
    func createTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS dog_poop_locations(
                unique_key INTEGER PRIMARY KEY AUTOINCREMENT,
                started_date NUMERIC NOT NULL,
                closed_date NUMERIC,
                longitude REAL,
                latitude REAL
            );
            """
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("ERROR CREATING TABLE: \(errmsg)")
        }
        else {
            print("TABLE CREATED SUCCESSFULLY")
        }
    }
    
    func insertNewMarkerFromUser() {
        
    }
    
    func insertBulkOpenData() {
        
    }
    
    func fetchAllMarkersWithinRegion() {
        
    }
    
    func resolveMarker() {
        
    }
    
    func fetchNonResolvedMarkers() {
        
    }
    

}
