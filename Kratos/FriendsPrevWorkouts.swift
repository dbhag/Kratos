import SwiftUI
import FirebaseFirestore
struct FriendsPrevWorkouts: View {
    @ObservedObject var firestoreService = FirestoreService()
    @Binding var friendID: String
    @State private var previousWorkouts: [Workout] = []
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)
                RadialGradient(gradient: Gradient(colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.0)
                ]), center: .center, startRadius: 50, endRadius: 300)
                .blendMode(.overlay)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header with Text and Flame Image
                    HStack(spacing: geometry.size.width * 0.05) {
                        Text("Past Workouts")
                            .font(.custom("Poppins-Regular", size: geometry.size.width * 0.075))
                            .tracking(0.36)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 0, y: -geometry.size.height * 0.05)
                        
                    }
                    .padding(.horizontal, geometry.size.width * 0.08)
                    .frame(height: geometry.size.height * 0.1)
                    .padding(.top, geometry.size.height * 0.05)
                    
                    Spacer()
                    
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(previousWorkouts) { workout in
                                WorkoutRowViewFriend(workout: workout)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                    //.background(Color.white.opacity(0.09))
                    .cornerRadius(24)
                    .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                    .padding(.top, geometry.size.height * 0.05)
                    .offset(y: -geometry.size.height * 0.075)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchPreviousWorkouts(for: friendID)
        }
    }
    private func fetchPreviousWorkouts(for userID: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userID).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let workoutEntries = data?["workouts"] as? [[String: Any]] ?? []

                self.previousWorkouts = workoutEntries.compactMap { entry in
                    guard let exercises = entry["workouts"] as? [String],
                          let timestamp = entry["timestamp"] as? Timestamp,
                          let description = entry["description"] as? String else {
                            return nil
                    }
                    return Workout(id: UUID().uuidString, exercises: exercises, timestamp: timestamp.dateValue(), description: description)
                }.sorted(by: { $0.timestamp > $1.timestamp })

                print("Fetched workouts: \(self.previousWorkouts)")  // Debug print
            } else {
                print("Document does not exist or error: \(String(describing: error))")  // Debug print
            }
        }
    }
}

struct WorkoutRowViewFriend: View {
    var workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)

                Text("Workout Date: \(workout.timestamp, formatter: itemFormatter)")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(.white)
                    //.fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if !workout.exercises.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                    
                    Text(workout.exercises.joined(separator: ", "))
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                        //.fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Only show description if it exists
            if !workout.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)

                    Text(workout.description)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white)
                        .padding(.top, 2)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = workout.description
                            }) {
                                Text("Copy Description")
                                Image(systemName: "doc.on.doc")
                            }
                        }
                        //.frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(red: 0.16, green: 0.18, blue: 0.2).opacity(0.8))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading) // Setting a minimum width and allowing expansion
    }
}

// Date Formatter
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    FriendsPrevWorkouts(friendID: .constant(""))
}

