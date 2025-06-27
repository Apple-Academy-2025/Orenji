//
//  CardHistory.swift
//  orenji
//
//  Created by Fariz Ajy Putra on 26/06/25.
//

import SwiftUI

struct CardHistory: View {
    @EnvironmentObject var router: Router
    var preparationElbow : String
    var preparationLeg : String
    var bendingElbow : String
    var bendingLeg : String
    var followThroughElbow : String
    var followThroughLeg : String
    var preparationElbowColor : UIColor
    var preparationLegColor : UIColor
    var bendingElbowColor : UIColor
    var bendingLegColor : UIColor
    var followThroughElbowColor : UIColor
    var followThroughLegColor : UIColor
    var Time : String
    var PhaseDatas : PhaseData
    @Binding var selectedTab : Int
    @State private var showDetail = false
    
    var body: some View {
        VStack{
            VStack{
                HStack{
                    Text("\(Time)")
                        .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .onTapGesture {
                            router.goTo(.HistoryDetailView(PhaseData: PhaseDatas, selectedTab: selectedTab))
                        }
                        .foregroundColor(Color(uiColor: UIColor(hex: "#FF7200")))
                }
                Spacer().frame(height: 16)
                HStack(alignment: .top)
                {
                VStack(alignment: .leading){
                    Spacer()
                    HStack{
                        Image(systemName: "angle")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.white)
                        Text("ELBOW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.white)
                    }
                    .frame(height: 40)
                    HStack{
                    Image(systemName: "angle")
                            .foregroundColor(Color.white)
                            .font(.system(size: 10, weight: .bold))
                    Text("LEG")
                            .foregroundColor(Color.white)
                            .frame(height: 40)
                            .font(.system(size: 10, weight: .bold))
                            
                }
                }
                .frame(height: 100)
                    VStack
                    {
                        Text("Preparation")
                            .foregroundColor(Color.white)
                            .font(.system(size: 10, weight: .bold))
                        Spacer()
                            .frame(height: 10)
                        Text("\(Int(Double(preparationElbow) ?? 0))°")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(preparationElbowColor))
                        Spacer()
                            .frame(height: 20)
                        Text("\(Int(Double(preparationLeg) ?? 0))°")
                            .foregroundColor(Color(preparationLegColor))
                            .font(.system(size: 20, weight: .bold))
                    }.frame(width: 70)
                    VStack
                    {
                        Text("Bending")
                            .foregroundColor(Color.white)
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 80)
                        Spacer()
                            .frame(height: 10)
                        Text("\(Int(Double(bendingElbow) ?? 0))°")
                            .foregroundColor(Color(bendingElbowColor))
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                            .frame(height: 20)
                        Text("\(Int(Double(bendingLeg) ?? 0))°")
                            .foregroundColor(Color(bendingLegColor))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .frame(width: 70)
                    VStack
                    {
                        Text("FollowThrough")
                            .foregroundColor(Color.white)
                                .font(.system(size: 10, weight: .bold))
                                .frame(width: 80)
                        Spacer()
                            .frame(height: 10)
                        Text("\(Int(Double(followThroughElbow) ?? 0))°")
                            .foregroundColor(Color(followThroughElbowColor))
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                            .frame(height: 20)
                        Text("\(Int(Double(followThroughLeg) ?? 0))°")
                            .foregroundColor(Color(followThroughLegColor))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .frame(width: 70)
                    
                }
            }.padding(16)
        }
        .navigationBarBackButtonHidden(true)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(colors: [Color(uiColor: UIColor(hex: "#1C1C1E")),Color(uiColor: UIColor(hex: "#262627"))], startPoint: .top, endPoint: .bottom)
                )
        )
    }
}

//#Preview {
//    CardHistory(preparationElbow: "90", preparationLeg: "90", bendingElbow: "90", bendingLeg: "90", followThroughElbow: "90", followThroughLeg: "90", preparationElbowColor: .red, preparationLegColor: .red, bendingElbowColor: .red, bendingLegColor: .red, followThroughElbowColor: .red, followThroughLegColor: .red, Time: "21-01-2021")
//}
