//
//  CameraView.swift
//  scoop_the_poop
//
//  Created by Student on 4/23/25.
//
import SwiftUI
import MapKit

struct CameraView: View {
    @StateObject private var model: DataModel
    @Environment(\.dismiss) var dismiss
    private static let barHeightFactor = 0.15
    
    init(handler: SQLiteHandler, locationManager: LocationManager) {
        _model = StateObject(wrappedValue: DataModel(locationManager: locationManager, handler: handler))
    }
    
    var body: some View {
        
        NavigationStack {
            GeometryReader { geometry in
                ViewfinderView(image:  $model.viewfinderImage )
                    .overlay(alignment: .top) {
                        Color.black
                            .opacity(0.75)
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                    }
                    .overlay(alignment: .bottom) {
                        buttonsView()
                            .frame(height: geometry.size.height * Self.barHeightFactor)
                            .background(.black.opacity(0.75))
                    }
                    .overlay(alignment: .center)  {
                        Color.clear
                            .frame(height: geometry.size.height * (1 - (Self.barHeightFactor * 2)))
                            .accessibilityElement()
                            .accessibilityLabel("View Finder")
                            .accessibilityAddTraits([.isImage])
                    }
                    .background(.black)
            }
            .task {
                await model.camera.start()
                await model.loadPhotos()
                await model.loadThumbnail()
            }
            .navigationTitle("Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            .ignoresSafeArea()
            .statusBar(hidden: true)
        }
    }
    
    private func buttonsView() -> some View {
        HStack(spacing: 60) {
            
            Spacer()
            
            NavigationLink {
                PhotoCollectionView(photoCollection: model.photoCollection)
                    .onAppear {
                        model.camera.isPreviewPaused = true
                    }
                    .onDisappear {
                        model.camera.isPreviewPaused = false
                    }
            } label: {
                Label {
                    Text("Gallery")
                } icon: {
                    ThumbnailView(image: model.thumbnailImage)
                }
            }
            
            Button {
                model.camera.takePhoto()
                dismiss()
            } label: {
                Label {
                    Text("Take Photo")
                } icon: {
                    ZStack {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 62, height: 62)
                        Circle()
                            .fill(.white)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            Button {
                model.camera.switchCaptureDevice()
            } label: {
                Label("Switch Camera", systemImage: "arrow.triangle.2.circlepath")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
        }
        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding()
    }
}
//    let cameraManager = CameraManager()
//    @Binding var image: CGImage?
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack {
//                if let image {
//                    Image(uiImage: UIImage(cgImage: image))
//                        .resizable()
//                        .scaledToFit()
//                    
//                } else {
//                    ContentUnavailableView("No camera feed", systemImage: "xmark.circle.fill")
//                        .frame(width: geometry.size.width,
//                               height: geometry.size.height)
//                }
//            }
//            .onAppear {
//                Task {
//                    let isAuthorized = await cameraManager.isAuthorized
//                    if isAuthorized {
//                        // Start the camera preview
//                        for await image1 in cameraManager.previewStream {
//                            print("image1")
//                            image = image1
//                        }
//                    } else {
//                        print("Camera permissions are not granted.")
//                    }
//                }
//            }
//            
//        }
//    }
