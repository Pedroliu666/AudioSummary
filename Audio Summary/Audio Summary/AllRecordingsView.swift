import SwiftUI
import Speech

    


class AudioPlayerHelper: ObservableObject {
    var audioPlayer: AVAudioPlayer?

    func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Playback failed for url: \(url.absoluteString), error: \(error.localizedDescription)")
        }
    }
}



//struct SummaryDetailView: View {
//    let summary: String
//
//    var body: some View {
//        ScrollView {
//            Text(summary)
//                .padding()
//        }
//        .navigationTitle("Summary Detail")
//    }
//}


struct AllRecordingsView: View 
{

    @StateObject private var audioPlayerHelper = AudioPlayerHelper()
    @EnvironmentObject var globaldata: GlobalData

    
    var body: some View
    {
        
        ZStack
        {
            // Background image
            Image("storage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all) // Ensure it goes under the navigation bar
                .scaledToFit()
            
            VStack
            {
                List(globaldata.recordings.indices, id: \.self)
                {
                    index in
                    VStack(alignment: .leading)
                    {
                        Text(globaldata.recordings[index].title)
                            .font(.headline)
                    }
                    
                    HStack
                    {
                        // Playback Button
                        Button("Play")
                        {
                            audioPlayerHelper.playAudio(from: globaldata.recordings[index].fileURL)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding(.bottom, 5) // Add some space between this button and the next UI element
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        NavigationLink(destination: Analyze(index: index).environmentObject(globaldata))
                        {
                            Text("Analyze")
                                .font(.headline) // Make the font larger than caption2 for better visibility
                                .foregroundColor(.white) // Change text color to white for contrast
                                .padding(.vertical, 10) // Add vertical padding
                                .padding(.horizontal, 20) // Add horizontal padding
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)) // Gradient background
                                .clipShape(Capsule()) // Capsule shape makes it look more button-like
                                .shadow(color: .gray, radius: 5, x: 0, y: 5) // Add shadow for depth
                        }
                        .padding(.top, 10) // Optionally add padding around the NavigationLink to space it out from other elements
                        
                    }
                }
            }
        }
    }
}

//


#Preview {
    AllRecordingsView()
}
