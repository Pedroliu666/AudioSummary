import SwiftUI
import Speech

class SummaryViewModel: ObservableObject {
    @Published var summary: String = ""
    @Published var errorMessage: String = ""

    func fetchSummary(message: String) async {
        NetworkingService.shared.fetchSummary(for: message) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    self?.summary = summary
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
}

struct SummaryDetailView: View {
    @State private var editableSummary: String
    @State private var editableStory: String
    @StateObject public var viewModel = SummaryViewModel()
    @State public var index : Int

    @EnvironmentObject var globaldata: GlobalData


    @State private var editingSummary = false
    @State private var editingStory = false
    
    init(index: Int, summary: String, story: String) {
        _editableSummary = State(initialValue: summary)
        _editableStory = State(initialValue: story)
        self._index = State(initialValue: index)
        
    }
    
    func updateSummary() {
        Task {
//            print("2", editableStory)
            await viewModel.fetchSummary(message: editableStory)
            
            DispatchQueue.main.async {
                globaldata.recordings[index].summary = viewModel.summary
                editableSummary = viewModel.summary
            }
            
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if editingSummary {
                    TextField("Edit Summary", text: $editableSummary)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Done") {
                        editingSummary = false
                        // Add logic to save changes to summary here if needed
//                        updateSummary()
                    }
                    .padding(.vertical)
                } else {
                    Text(editableSummary)
                    Button("Edit Summary") {
                        editingSummary = true
                    }
                    .padding(.vertical)
                }
                
                Divider()
                
                Button("Ask Question")
                {
                    if !editingSummary
                    {
                        updateSummary()
                    }
                }
                
              
                if editingStory {
                    TextEditor(text: $editableStory)
                        .frame(minHeight: 200) // Ensure there's enough space for easier editing
                        .border(Color.gray, width: 1) // Visually distinguish the text editor area
                    Button("Done") {
                        editingStory = false
                        // Add logic to save changes to story here if needed
                    }
                    .padding(.vertical)
                } else {
                    Text(editableStory)
                    Button("Edit Story") {
                        editingStory = true
                    }
                    .padding(.vertical)
                }
            }
            .padding()
        }
        .navigationTitle("Summary Detail")
    }
}


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
    @State private var prompt: String = "Give me answers of this story in the following form, who, what, where, when, how:"
    @State private var message: String = ""

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
                                
                
                Button(action:
                        {
                    Task
                    {
                        message = await recognizeFile(url: globaldata.recordings[index].fileURL) ?? "Could not transcribe audio."
                        //                    let prompt = "Give me a summary of what happened, where, who, and how of the summary above."
                        
                        message += prompt
//                        print("message", message)
                        await viewModel.fetchSummary(message: message)
                        DispatchQueue.main.async
                        {
                            globaldata.recordings[index].summary = viewModel.summary
                        }
                    }
                }) {
                    Text("Transcribe this Audio")
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
                
//                if globaldata.recordings[index].summary != "dum"
//                {
                NavigationLink(destination: SummaryDetailView(index: index, summary: globaldata.recordings[index].summary, story: message))
                    {
                        Text("Show Summary Detail")
                            .font(.headline) // Make it more prominent
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple) // A distinct color
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                    }
//                }
                
                
                
                
            }
        }
    }
}
