//
//  Untitled.swift
//  RecordFeature
//
//  Created by Fariz Ajy Putra on 22/06/25.
//

import SwiftUI


struct RecordPageCameraFrame: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showCamera: Bool
    var onVideoRecorded: ((URL) -> Void)? = nil

    @State private var isRecording = false
    @State private var lastVideoURL: URL? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CameraView(isRecording: $isRecording, onFinish: { url in
                lastVideoURL = url
                showCamera = false
                onVideoRecorded?(url)
            })
            .edgesIgnoringSafeArea(.all)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("XIcon")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .bold))
                    .padding()
                    .frame(width: 46, height: 46)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.top, 8)
            .padding(.trailing, 24)
            
            VStack {
                Spacer()
                Button(action: {
                    isRecording.toggle()
                }) {
                    Text(isRecording ? "Stop" : "Rekam")
                        .font(.title3)
                        .frame(width: 100, height: 44)
                        .background(isRecording ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(22)
                }
                .padding(.bottom, 45)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .statusBar(hidden: true)
    }
}


