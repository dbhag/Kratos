import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct WorkoutGoalsView: View {
    @State private var workoutGoal: Double = 3 // Default value for the slider
    @EnvironmentObject var authViewModel: AuthViewModel
    private let db = Firestore.firestore()
    @State private var navigateToMainContainer: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.16, green: 0.18, blue: 0.2)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Header
                    Text("Set Your Weekly Workout Goal")
                        .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
                        .foregroundColor(.white)
                        .padding(.top, geometry.size.height * 0.1)
                        .padding(.bottom, 20)

                    // Slider
                    Slider(value: $workoutGoal, in: 1...7, step: 1)
                        .padding(.horizontal, geometry.size.width * 0.1)
                    Text("\(Int(workoutGoal)) times per week")
                        .font(.custom("Marker Felt", size: geometry.size.width * 0.055))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)

                    // Submit Button
                    Button(action: saveWorkoutGoal) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.2))
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.white)
                            .cornerRadius(15.0)
                            .shadow(color: .gray, radius: 5, x: 0, y: 5)
                    }
                    .padding(.top, 40)

                    Spacer()
                }
                .background(
                    NavigationLink(destination: MainContainerView(), isActive: $navigateToMainContainer) {
                        EmptyView()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func saveWorkoutGoal() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(currentUserID)

        userRef.setData(["workoutGoal": Int(workoutGoal)], merge: true) { error in
            if let error = error {
                print("Error saving workout goal: \(error.localizedDescription)")
            } else {
                print("Workout goal saved successfully.")
                navigateToMainContainer = true
            }
        }
    }
}

#Preview {
    WorkoutGoalsView()
}
