//
//  CMSampleBuffer.swift
//  scoop_the_poop
//
//  Created by Student on 4/23/25.
//

import AVFoundation
import CoreImage

extension CMSampleBuffer {
    
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
    
}
