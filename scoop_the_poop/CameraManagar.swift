//
//  CameraManagar.swift
//  scoop_the_poop
//
//  Created by Student on 4/23/25.
//
import Foundation
import AVFoundation

class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    var deviceInput: AVCaptureDeviceInput?
    var videoOutput: AVCaptureVideoDataOutput?
    let systemPreferredCamera = AVCaptureDevice.default(for: .video)
    var sessionQueue = DispatchQueue(label: "video.preview.session")
    var isAuthorized: Bool {
            get async {
                let status = AVCaptureDevice.authorizationStatus(for: .video)
                
                // Determine if the user previously authorized camera access.
                var isAuthorized = status == .authorized
                
                // If the system hasn't determined the user's authorization status,
                // explicitly prompt them for approval.
                if status == .notDetermined {
                    isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
                }
                
                return isAuthorized
            }
        }
    var addToPreviewStream: ((CGImage) -> Void)?
    lazy var previewStream: AsyncStream<CGImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { cgImage in
                continuation.yield(cgImage)
            }
        }
    }()
    override init() {
        super.init()
        Task {
            await configureSession()
            await startSession()
        }
    }
    func configureSession() async {
        guard await isAuthorized,
                  let systemPreferredCamera,
                  let deviceInput = try? AVCaptureDeviceInput(device: systemPreferredCamera)
            else { return }
        captureSession.beginConfiguration()
        defer {
                self.captureSession.commitConfiguration()
        }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        guard captureSession.canAddInput(deviceInput) else {
            print("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            print("Unable to add video output to capture session.")
            return
        }
        captureSession.addInput(deviceInput)
        captureSession.addOutput(videoOutput)
    }
    func startSession() async {
        guard await isAuthorized else { return }
            if !captureSession.isRunning{
                captureSession.startRunning()
            }
        }
    
}
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        print("Capture output called") // Add this line for debugging
        guard let currentFrame = sampleBuffer.cgImage else { return }
        addToPreviewStream?(currentFrame)
    }
    
}
