



import SwiftUI

struct RecordingView: View {
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            if connectivityManager.recordingDisplay != .activelyRealtime {
                if let image = connectivityManager.receivedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Rectangle().foregroundColor(.gray.opacity(0.5))
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.largeTitle).foregroundColor(.white)
                    Text("Menunggu iPhone...").font(.caption).foregroundColor(.white).offset(y: 30)
                }
            }
            
            switch connectivityManager.recordingDisplay {
            case .detectingPose:
                GeometryReader { geometry in
                    let borderColor = connectivityManager.isCameraPoseCorrect ? Color.green : Color.red
                    let strokeStyle = StrokeStyle(lineWidth: 3, dash: [4, 8])
                    
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(borderColor, style: strokeStyle)
                        .frame(width: 102,height: 200)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
            case .showingMessage:
                Text("ONLY DO YOUR\nFREE-THROW\nSHOOTING ONCE!").fontWeight(.bold).multilineTextAlignment(.center).foregroundColor(.white).padding()
                
            case .countingDown(let number):
                ZStack {
                    Circle().stroke(Color.orange, lineWidth: 10)
                    Text("\(number)").font(.system(size: 80, weight: .bold, design: .rounded)).foregroundColor(.white)
                }
                .padding(30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .showingStart:
                Text("START!")
                    .font(.system(size: 40))
                    .bold()
                    .foregroundColor(.white)
            case .activelyRecording:
                VStack {
                    HStack {
                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 12, height: 12)
                        Text("MEREKAM")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(6)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    Spacer()
                }
                .padding(.top, 8)
            case .activelyRealtime:
                RealtimeView()
            }
            
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .onAppear {
            self.showAlert = true
        }
        .alert("Before you start!", isPresented: $showAlert) {
            Button("Close", role: .cancel) {
                showAlert = false
            }
        } message: {
            Text("Make sure to keep your body aligned within this frame to start")
        }
    }
}

#Preview {
    RecordingView()
}
