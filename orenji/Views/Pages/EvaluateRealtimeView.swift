import SwiftUI

struct EvaluateRealtimeView: View {
    @EnvironmentObject var router: Router
    @StateObject private var cameraService = CameraService()
    @StateObject private var poseDetector = PoseDetectionViewModel()
    var page: String = "realtime"
    

    // ukuran bounding box
    private let boxSize = CGSize(width: 250, height: 500)

    var body: some View {
        PreRecordView(warningText: "FOLLOW THE INSTRUCTIONS EACH PHASE!")
    }

    
    
}

// Preview
#Preview {
    EvaluateRealtimeView()
        .environmentObject(Router())
}
