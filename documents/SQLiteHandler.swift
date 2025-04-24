//
//  SQLiteHandler.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import Foundation
import SQLite3
import UIKit

class SQLiteHandler: ObservableObject {
    @Published var markers: [PoopMarker] = []
    var db: OpaquePointer?
    
    init() {
        openDatabase()
        createTable()
        fetchNonResolvedMarkers()
        print(markers)
        print("Number of markers \(markers.count)")
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
                latitude REAL,
                longitude REAL,
                image BLOB
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
        print("called")
        let insertQuery = "INSERT OR REPLACE INTO dog_poop_locations (started_date, closed_date, longitude, latitude, image) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, newRecord.started_date, -1, nil)

            if let closedDate = newRecord.closed_date {
                sqlite3_bind_text(statement, 2, closedDate, -1, nil)
            } else {
                sqlite3_bind_null(statement, 2)
            }

            sqlite3_bind_double(statement, 3, Double(newRecord.longitude))
            sqlite3_bind_double(statement, 4, Double(newRecord.latitude))

            if let image = newRecord.image, let imageData = image.jpegData(compressionQuality: 1.0) {
                sqlite3_bind_blob(statement, 5, (imageData as NSData).bytes, Int32(imageData.count), nil)
            } else {
                sqlite3_bind_blob(statement, 5, nil, 0, nil)
            }

            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully Inserted New Marker")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db))
                print("Could Not Insert Marker: (errmsg)")
            }
        } else {
            let errmsg = String(cString: sqlite3_errmsg(db))
            print("SQL Prepare Error: (errmsg)")
        }
        sqlite3_finalize(statement)
    }
    
    // Doesn't Work
    func insertBulkOpenData() {
        if let extractedData = CSVHandler().parseColumnsByName(fileName: "test", columnNames: ["Unique Key", "Created Date", "Closed Date", "Latitude", "Longitude"]) {
            for row in extractedData {
                print(row)
                let insertQuery = "INSERT OR IGNORE INTO dog_poop_locations (unique_key, started_date, closed_date, latitude, longitude) VALUES (?, ?, ?, ?, ?);"
                var statement: OpaquePointer?
                
                if sqlite3_prepare_v2(db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                    sqlite3_bind_int(statement, 1, Int32(row[0]) ?? 0)
                    sqlite3_bind_text(statement, 2, row[1], -1, nil)
                    sqlite3_bind_text(statement, 3, row[2], -1, nil)
                    sqlite3_bind_double(statement, 4, Double(row[3]) ?? 0.0)
                    sqlite3_bind_double(statement, 5, Double(row[4]) ?? 0.0)
                    
                    if sqlite3_step(statement) == SQLITE_DONE {
                        print("Successfully Inserted New Marker")
                    }
                    else {
                        print("Could Not Insert Marker")
                    }
                }
                sqlite3_finalize(statement)
            }
        }
        else {
            print("Could Not Extract Data From CSV")
        }
    }
    
    
    func resolveMarker(unique_identifier: Int32) {
        let query = "DELETE FROM dog_poop_locations WHERE unique_key = ?;"
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
                    let closed_date = (sqlite3_column_text(statement, 2) != nil) ? String(cString: sqlite3_column_text(statement, 2)) : nil
                    let latitude = Double(sqlite3_column_double(statement, 3))
                    let longitude = Double(sqlite3_column_double(statement, 4))
                    // Retrieve the size of the BLOB
                    let blobBytes = sqlite3_column_blob(statement, 5)
                    let blobLength = sqlite3_column_bytes(statement, 5)

                    // Ensure the BLOB exists
                    let image: UIImage?
                    if let blobBytes = blobBytes, blobLength > 0 {
                        let data = Data(bytes: blobBytes, count: Int(blobLength))
                        image = UIImage(data: data)
                    } else {
                        image = nil // Handle the case where there is no image
                    }
                    
                    let poopMarker = PoopMarker(id: unique_key, started_date: started_date, closed_date: closed_date, longitude: longitude, latitude: latitude, image: image)
                    poopMarkers.append(poopMarker)
                }
            } else {
                print("Cannot Retrive Markers From Table")
            }
            sqlite3_finalize(statement)

            DispatchQueue.main.async {
                self.markers = poopMarkers
            }
    }
}
