//
//  Analyze.swift
//  Audio Summary
//
//  Created by 柳培铎 on 3/28/24.
//

import SwiftUI
import Speech


func recognizeFile(url: URL) async -> String? {
    guard let myRecognizer = SFSpeechRecognizer() else {
        print("The system doesn't support the user's default language.")
        return nil
    }
    
    guard myRecognizer.isAvailable else {
        print("The recognizer isn't available.")
        return nil
    }
    
    let request = SFSpeechURLRecognitionRequest(url: url)
    
    return await withCheckedContinuation { continuation in
        myRecognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                print("Recognition failed with error: \(error)")
                continuation.resume(returning: nil)
                return
            }
            
            guard let result = result else {
                print("No result and no error was provided.")
                return // Don't resume the continuation here as it might not be the final call
            }
            
            if result.isFinal {
                continuation.resume(returning: result.bestTranscription.formattedString)
            }
            // If not final, don't resume the continuation; wait for the next callback invocation.
        }
    }
}



struct Analyze: View {
    @State public var index : Int
    @EnvironmentObject var globaldata: GlobalData
    @StateObject public var viewModel = SummaryViewModel()
    @State private var prompt: String = ""


    var body: some View {
        ZStack
        {
            // Background image
            Image("AI")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all) // Ensure it goes under the navigation bar
                .scaledToFit()
            
            VStack
            {
                
                // Naming TextField and Submit Button
                Text("Ask Anything about this Audio")
                    .font(.headline) // Make the prompt more noticeable
                    .padding(.bottom, 5)
                
                TextField("Enter name", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Submit") {
                    print("Recording name: \(prompt)")
                }
                .disabled(prompt.isEmpty)
                .padding()
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5) // Add shadow
                
                
                
                
                Button(action:
                        {
                    Task
                    {
                        var message = await recognizeFile(url: globaldata.recordings[index].fileURL) ?? "Could not transcribe audio."
                        //                    let prompt = "Give me a summary of what happened, where, who, and how of the summary above."
                        message += prompt
                        print("message", message)
                        await viewModel.fetchSummary(message: message)
                        DispatchQueue.main.async
                        {
                            globaldata.recordings[index].summary = viewModel.summary
                        }
                    }
                }) {
                    Text("Analyze this Audio")
                        .font(.title) // Make the font larger
                        .fontWeight(.bold) // Make the text bold
                        .foregroundColor(.white)
                        .padding(.vertical, 15) // Increase vertical padding
                        .padding(.horizontal, 20) // Increase horizontal padding
                        .background(
                            LinearGradient(gradient: Gradient(colors: [
                                Color(red: 1, green: 0, blue: 1), // Magenta
                                Color.blue,
                                Color.cyan
                            ]), startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15)) // Slightly rounded corners
                        .shadow(color: .black, radius: 10, x: 0, y: 5) // More pronounced shadow
                        .padding(.bottom, 5) // Ensure space between this and other elements
                }
                
                
                Spacer()
                
                if globaldata.recordings[index].summary != "dum"
                {
                    NavigationLink(destination: SummaryDetailView(summary: globaldata.recordings[index].summary))
                    {
                        Text("Show Summary Detail")
                            .font(.headline) // Make it more prominent
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple) // A distinct color
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    }
                }
                
                
                
                
            }
        }
    }
}
