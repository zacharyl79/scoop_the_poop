//
//  PoopDescription.swift
//  scoop_the_poop
//
//  Created by Student on 4/11/25.
//

import SwiftUI

struct PoopDescription: View {
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
            
            Button("Remove marker") {
                
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding()
        }
    }
}

//#Preview {
//    PoopDescription()
//}
