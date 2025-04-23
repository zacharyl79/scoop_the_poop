//
//  CIImage.swift
//  scoop_the_poop
//
//  Created by Student on 4/23/25.
//

import CoreImage

extension CIImage {
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    
}
