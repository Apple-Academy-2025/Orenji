import SwiftUI

struct FinishRealtimeView: View {
    @EnvironmentObject var router: Router
    var loopCount: Int
    var durationInSeconds: Int
    
    var minutesText: String {
        let minutes = durationInSeconds / 60
        let seconds = durationInSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var displayLoopCount: Int {
        loopCount % 3
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("SESSION WRAP UP!")
                .padding(.horizontal, 80)
                .multilineTextAlignment(.center)
                .frame(alignment: .center)
                .background(.black)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            VStack {
                Text("You Spent")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                
                Text(minutesText)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                Text("Minutes")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
            }
            .frame(width: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(LinearGradient(colors: [.primer, .primer.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
            )
            .padding(.bottom, 32)
            
            VStack {
                Text("You did Shooting")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
                
                Text("\(displayLoopCount)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                Text("Times")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(LinearGradient(colors: [.primer, .primer.opacity(0.2)], startPoint: .top, endPoint: .bottom), lineWidth: 2)
            )
            
            Spacer()
            
            Button(action: {
                router.goTo(.Home)
            }) {
                Text("Finish")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.primer)
            .cornerRadius(14)
        }
        .frame(maxHeight: .infinity)
        .padding()
        .navigationBarBackButtonHidden()
        .background(.black)
    }
}

#Preview {
    FinishRealtimeView(loopCount: 7, durationInSeconds: 85)
        .environmentObject(Router())
}
