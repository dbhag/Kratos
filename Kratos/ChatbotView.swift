import SwiftUI
import GoogleGenerativeAI

// Chat ViewModel using Google Gemini
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    private let model: GenerativeModel
    private var chat: Chat

    init() {
        // Access the API key from Config.plist
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let configDictionary = NSDictionary(contentsOfFile: path),
              let apiKey = configDictionary["GEMINI_API_KEY"] as? String else {
            fatalError("API Key not found in Config.plist")
        }
        
        let config = GenerationConfig(
            temperature: 1,
            topP: 0.95,
            topK: 64,
            maxOutputTokens: 1000,
            responseMIMEType: "text/plain"
        )
        
        self.model = GenerativeModel(
            name: "gemini-1.5-flash",
            apiKey: apiKey,  // Use the API key retrieved from Config.plist
            generationConfig: config,
            systemInstruction: "Be as concise as possible and if someone asks for exercises, only give them the exercise, how many reps and sets they should do, if they ask for multiple number them and don't label the whole thing or add additonal notes. If someone asks for an eating plan imagine you are a dietary professional and give them basic advice, don't mention that you aren't a professional"
        )
        
        self.chat = model.startChat(history: [])
    }
    
    func sendNewMessage(content: String) {
        let userMessage = ChatMessage(content: content, isUser: true)
        self.messages.append(userMessage)
        chat.history.append(ModelContent(role: "user", parts: [.text(content)]))
        getBotReply()
    }
    
    func getBotReply() {
        Task {
            do {
                let message = messages.last?.content ?? ""
                let response = try await chat.sendMessage(message)
                guard let responseText = response.text else {
                    DispatchQueue.main.async {
                        self.messages.append(ChatMessage(content: "Sorry, there was a problem. Please try again.", isUser: false))
                    }
                    return
                }
                // Process the response text to remove asterisks and unwanted formatting
                let formattedResponse = formatResponse(responseText)
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(content: formattedResponse, isUser: false))
                    self.chat.history.append(ModelContent(role: "model", parts: [.text(formattedResponse)]))
                }
            } catch {
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(content: "Error: \(error.localizedDescription)", isUser: false))
                }
            }
        }
    }
    
    func clearMessages() {
        messages.removeAll()
        chat.history.removeAll()
    }
    private func formatResponse(_ text: String) -> String {
        // Remove leading asterisks and extra whitespace
        return text.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// Chat Message Model
struct ChatMessage: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}

// Chatbot View
struct ChatbotView: View {
    @StateObject var chatViewModel = ChatViewModel()
    @State var userPrompt = ""
    @Binding var selectedTab: Tab

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: {
                        chatViewModel.clearMessages()
                        selectedTab = .home// Set the tab to home
                    }) {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .frame(width: geometry.size.width * 0.05, height: geometry.size.width * 0.05)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .padding(.leading, geometry.size.width * 0.02)
                .padding(.top, geometry.size.height * 0.02)
                
                ScrollView {
                    ForEach(chatViewModel.messages) { message in
                        ChatMessageView(message: message, fontSize: geometry.size.width * 0.04)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                    }
                }
                
                HStack {
                    TextField("Type your message here...", text: $userPrompt)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.horizontal)

                    Button {
                        chatViewModel.sendNewMessage(content: userPrompt)
                        userPrompt = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                            .padding()
                    }
                    .disabled(userPrompt.isEmpty)
                }
                .padding()
            }
            .background(Color(red: 0.16, green: 0.18, blue: 0.2)) // Set the background color here
        }
    }
}

// Chat Message View
struct ChatMessageView: View {
    var message: ChatMessage
    var fontSize: CGFloat

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.content)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.custom("Roboto", size: fontSize))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
            } else {
                Text(message.content)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.custom("Roboto", size: fontSize))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.content
                        }) {
                            Text("Copy")
                            Image(systemName: "doc.on.doc")
                        }
                    }
                Spacer()
            }
        }
    }
}

// Preview
#Preview {
    ChatbotView(selectedTab: .constant(.home))
}

