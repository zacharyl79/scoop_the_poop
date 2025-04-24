//
//  PoopDescription.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import SwiftUI
import MapKit

struct PoopDescription: View {
    @ObservedObject var handler: SQLiteHandler
    @Environment(\.dismiss) var dismiss
    @Binding var resolvedPoopID: [Int32: CGFloat]
    var poopInfo: PoopMarker
    
    var body: some View {
        VStack {
            if let image = poopInfo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo.artframe")
                    .resizable()
                    .frame(width: 135, height: 110)
            }
            Text("Date found: \(poopInfo.started_date)")
                .font(.caption)
                .padding()
            Button("Remove marker") {
                dismiss()
                withAnimation(.easeOut(duration: 3)) {
                    resolvedPoopID[poopInfo.id] = CGFloat(100)
                }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Wait for the animation to finish
                handler.resolveMarker(unique_identifier: poopInfo.id) // Remove marker logic
                handler.fetchNonResolvedMarkers() // Refresh the data
            }
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding()
        }
    }
}

//#Preview {
//    PoopDescription()
//}
