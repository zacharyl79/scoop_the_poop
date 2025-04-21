//
//  SQLiteHandler.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import Foundation
import SQLite3

class SQLiteHandler: ObservableObject {
    @Published var markers: [PoopMarker] = []
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
                started_date TEXT NOT NULL,
                closed_date TEXT,
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
    
    func insertNewMarkerFromUser(newRecord: PoopMarker) {
        let insertQuery = "INSERT INTO dog_poop_locations (started_date, closed_date, longitude, latitude) VALUES (?, ?, ?, ?) ON CONFLICT(started_date, closed_date, longitude, latitude) DO NOTHING;;"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, newRecord.started_date, -1, nil)
            sqlite3_bind_text(statement, 2, newRecord.closed_date ?? "NULL", -1, nil)
            sqlite3_bind_text(statement, 3, String(newRecord.longitude), -1, nil)
            sqlite3_bind_text(statement, 4, String(newRecord.latitude), -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully Inserted New Marker")
            }
            else {
                print("Could Not Insert Marker")
            }
        }
    }
    
    func insertBulkOpenData() {
        if let extractedData = CSVHandler().parseColumnsByName(fileName: "dog_poop_20250411", columnNames: ["Unique Key", "Created Date", "Closed Date", "Latitude", "Longitude"]) {
            for row in extractedData {
                let insertQuery = "INSERT OR IGNORE INTO dog_poop_locations (unique_key, started_date, closed_date, longitude, latitude) VALUES (?, ?, ?, ?, ?);"
                var statement: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_text(statement, 1, row[0], -1, nil)
                    sqlite3_bind_text(statement, 2, row[1], -1, nil)
                    sqlite3_bind_text(statement, 3, row[2], -1, nil)
                    sqlite3_bind_text(statement, 4, row[3], -1, nil)
                    sqlite3_bind_text(statement, 5, row[4], -1, nil)
                    
                    if sqlite3_step(statement) == SQLITE_DONE {
                        print("Successfully Inserted New Marker")
                    }
                    else {
                        print("Could Not Insert Marker")
                    }
                }
            }
        }
        else {
            print("Could Not Extract Data From CSV")
        }
    }
    
    
    func resolveMarker(unique_identifier: Int32) {
        let query = "UPDATE dog_poop_locations SET closed_date = NULL WHERE unique_key = ?"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_int(statement, 1, unique_identifier)
                if sqlite3_step(statement) == SQLITE_DONE {
                    if sqlite3_changes(db) > 0 {
                        print("Successfully Resolved Marker")
                    } else {
                        print("No matching marker found.")
                    }
                }
                else {
                    print("Could Not Resolve Marker")
                }
            } else {
                print("Cannot Retrive Markers From Table")
            }
            sqlite3_finalize(statement)
    }
    
    func fetchNonResolvedMarkers() {
        let query = "SELECT * FROM dog_poop_locations;"
            var statement: OpaquePointer?
            var poopMarkers: [PoopMarker] = []

            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let unique_key = sqlite3_column_int(statement, 0)
                    let started_date = String(cString: sqlite3_column_text(statement, 1))
                    let closed_date = String(cString: sqlite3_column_text(statement, 2))
                    let longitude = Double(sqlite3_column_double(statement, 3))
                    let latitude = Double(sqlite3_column_double(statement, 4))
                    
                    let poopMarker = PoopMarker(id: unique_key, started_date: started_date, closed_date: closed_date, longitude: longitude, latitude: latitude)
                    poopMarkers.append(poopMarker)
                }
            } else {
                print("Cannot Retrive Markers From Table")
            }
            sqlite3_finalize(statement)

            markers = poopMarkers
    }
}
