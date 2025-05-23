//
//  CSVHandler.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import Foundation

struct CSVHandler {
    func parseColumnsByName(fileName: String, columnNames: [String]) -> [[String]]? {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "csv") else {
            print("File not found")
            return nil
        }
        
        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            let rows = content.components(separatedBy: "\n")
            
            guard let headerRow = rows.first else {
                print("No header row found")
                return nil
            }
            
            let headers = headerRow.components(separatedBy: ",").map {$0.trimmingCharacters(in: .whitespaces) }
            
            let columnIndices = columnNames.compactMap { headers.firstIndex(of: $0) }
            
            if columnIndices.isEmpty {
                print("No matching columns found")
                return nil
            }

            
            var extractedData: [[String]] = []
            
            for row in rows.dropFirst() {
                if !row.trimmingCharacters(in: .whitespaces).isEmpty {
                    let fields = row.components(separatedBy: ",")
                    let selectedColumns = columnIndices.compactMap { index -> String? in
                        guard index < fields.count else { return nil }
                        return fields[index]
                    }
                    extractedData.append(selectedColumns)
                }
            }
            print(extractedData)
            print("inside method complete")
            return extractedData
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
}
