//
//  ContentView.swift
//  iOS_IntroSwiftUI
//
//  Created by FDC.JEAZELLE-NC-WEB on 7/22/24.
//

import SwiftUI

struct ThumbnailView: View {
    let imageName: ImageResource
    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .background(.yellow)
    }
}

struct ItineraryImagesView: View {
    let imageName: ImageResource
    let title: String
    let description: String
    let time: String
    var body: some View {
        HStack(alignment: .top){
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .padding(20)
            VStack(alignment: .leading){
                Text(title)
                    .bold()
                Text(description)
            }
            Spacer()
            Text(time)
                .padding(.top, 3)
                .foregroundStyle(Color(red: 129/255.0, green: 133/255.0, blue: 137/255.0))
        }
    }
}


struct ContentView: View {
    var body: some View {
        ZStack(alignment: .bottom){
            
            VStack(alignment: .leading){
                Spacer()
                    .frame(height: 20)
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(.white)
                })
                Spacer()
                    .frame(height: 80)
                Text("iOS Dev\nTraining Batch 3")
                    .bold()
                    .font(.title)
                    .foregroundStyle(.white)
                Spacer()
                    .frame(height: 20)
                Text("July 15 - 28, 2024")
                    .foregroundStyle(.white)
                Spacer()
                    .frame(height: 50)
                HStack(spacing: -6) {
                    //apply iteration when it's repititive
                    ThumbnailView(imageName: .panda)
                    ThumbnailView(imageName: .jiraf)
                    ThumbnailView(imageName: .pig)
                    
                    Spacer()
                    Button {
                        //action
                    } label: {
                        Image(systemName: "checkmark")
                             .font(.largeTitle)
                        Text("You Joined")
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .padding(.trailing, 30)
                    .padding(.leading, 30)
                    .background(.black.opacity(0.25))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    
                    //ALTERNATIVE FOR BUTTON
    //                Button("You just joined"){
    //                    print("Hello world!")
    //                }
                }
                Spacer()
                    
            }
                .padding(20)
                .background(.yellow)
            ItineraryView()
        }
        .ignoresSafeArea()
    }
}


struct ItineraryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Spacer()
                .frame(height: 10)
            Text("Itinerary")
                .bold()
            Spacer()
                .frame(height: 5)
            
            ItineraryImagesView(imageName: .tent, title: "Building a tent", description: "Set up your tent and organize your campsite.", time: "4:00 PM")
        
            ItineraryImagesView(imageName: .mountain, title: "Adventure", description: "Choose a nearby hiking trail and embark on a morning hike. ", time: "5:30 PM")
       
            ItineraryImagesView(imageName: .bonfire, title: "Campfire", description: "Gather around the campfire for storytelling...", time: "8:00 PM")
            
            HStack{
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/,
                label: {
                    Image(systemName: "plus")
                         .resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(width: 30, height: 30)
                         .foregroundColor(.white)
                         .padding(20)
                })
                .frame(width: 50, height: 50)
                .padding(20)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            Spacer()
                .frame(height: 10)
            
        }
        .padding(.top, 10)
        .padding(.trailing, 20)
        .padding(.leading, 20)
        .padding(.bottom, 5)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        
    }
}

#Preview {
    ContentView()
}
