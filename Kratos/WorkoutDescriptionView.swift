//
//  WorkoutDescriptionView.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 7/23/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct WorkoutDescriptionView: View {
        @State private var description: String = ""
        //var selectedWorkouts: [String]
        @Binding var selectedWorkouts: Array<String>
        @EnvironmentObject var workoutModel: WorkoutModel
        @Binding var selectedTab: Tab
        @Binding var isTyping: Bool
        private let db = Firestore.firestore()

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Text("What did you do?")
                            .font(.custom("Poppins-Regular", size: geometry.size.width * 0.075))
                            .foregroundColor(.white)
                            .padding(.top, geometry.size.height * 0.05)
                            .offset(y: geometry.size.height * 0.03)
                        
                        TextEditor(text: $description)
                            .foregroundColor(.white)
                                .padding()
                                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.5)
                                .scrollContentBackground(.hidden)
                                .background(Color.white.opacity(0.09))
                                .offset(y: geometry.size.height * 0.05)
                        
                        Spacer()
                        
                        Button(action: {
                            logWorkoutTimestamp()
                            selectedTab = .takePhoto
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.2))
                                .padding()
                                .frame(width: 220, height: 60)
                                .background(Color.white)
                                .cornerRadius(15.0)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                .offset(y: -geometry.size.height * 0.03)
                        }
                        .padding(.bottom, geometry.size.height * 0.02)
                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        
        func logWorkoutTimestamp() {
            guard let currentUserID = Auth.auth().currentUser?.uid else { return }
            let userRef = db.collection("users").document(currentUserID)
            
            // Set the server timestamp
            db.collection("server_time").document("current_time").setData(["timestamp": FieldValue.serverTimestamp()]) { error in
                if let error = error {
                    print("Error getting server timestamp: \(error.localizedDescription)")
                    return
                }

                // Get the server timestamp
                db.collection("server_time").document("current_time").getDocument { (document, error) in
                    if let document = document, document.exists, let timestamp = document.data()?["timestamp"] as? Timestamp {

                        userRef.getDocument { document, error in
                            if let document = document, document.exists {
                                var workouts = document.data()?["workouts"] as? [[String: Any]] ?? []
                                let newWorkout = [
                                    "timestamp": timestamp,
                                    "workouts": selectedWorkouts,
                                    "description": description
                                ] as [String : Any]

                                workouts.append(newWorkout)

                                let currentWeek = getCurrentWeek()
                                let lastWeek = document.data()?["lastWeek"] as? String ?? ""
                                var streak = document.data()?["streak"] as? Int ?? 0
                                var longestStreak = document.data()?["longestStreak"] as? Int ?? 0
                                var score = document.data()?["score"] as? Int ?? 0
                                var totalWorkouts = document.data()?["totalWorkouts"] as? Int ?? 0
                                let workoutGoal = document.data()?["workoutGoal"] as? Int ?? 0

                                // Check if the week has changed
                                if currentWeek != lastWeek {
                                    // Check if the user met their goal last week
                                    if countWorkoutsInWeek(workouts, week: lastWeek) >= workoutGoal {
                                        streak += 1
                                    } else {
                                        streak = 0
                                    }
                                    userRef.updateData(["lastWeek": currentWeek])
                                }

                                // Update longest streak
                                if streak > longestStreak {
                                    longestStreak = streak
                                }

                                // Update total workouts
                                totalWorkouts += 1

                                // Calculate points
                                let basePoints = 10
                                let multiplier = 1.0 + Double(streak) * 0.1
                                score += Int(Double(basePoints) * multiplier)

                                userRef.updateData([
                                    "workouts": workouts,
                                    "recentWorkout": timestamp,
                                    "score": score,
                                    "streak": streak,
                                    "longestStreak": longestStreak,
                                    "totalWorkouts": totalWorkouts
                                ]) { error in
                                    if let error = error {
                                        print("Error updating workouts: \(error.localizedDescription)")
                                    } else {
                                        print("Workouts updated successfully.")
                                    }
                                }
                            } else {
                                let newWorkout = [
                                    "timestamp": timestamp,
                                    "workouts": selectedWorkouts,
                                    "description": description
                                ] as [String : Any]

                                userRef.setData([
                                    "workouts": [newWorkout],
                                    "recentWorkout": timestamp,
                                    "lastWeek": getCurrentWeek(),
                                    "score": 10,
                                    "streak": 0,
                                    "longestStreak": 0,
                                    "totalWorkouts": 1
                                ]) { error in
                                    if let error = error {
                                        print("Error setting workouts: \(error.localizedDescription)")
                                    } else {
                                        print("Workouts set successfully.")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        func getCurrentWeek() -> String {
            let date = Date()
            let calendar = Calendar.current
            let weekOfYear = calendar.component(.weekOfYear, from: date)
            let year = calendar.component(.year, from: date)
            return "\(year)-W\(weekOfYear)"
        }

        func countWorkoutsInWeek(_ workouts: [[String: Any]], week: String) -> Int {
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-'W'ww"

            guard let weekStartDate = formatter.date(from: week) else { return 0 }
            let weekEndDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate)!

            return workouts.filter { workout in
                if let timestamp = workout["timestamp"] as? Timestamp {
                    let date = timestamp.dateValue()
                    return date >= weekStartDate && date < weekEndDate
                }
                return false
            }.count
        }
    }

#Preview {
    WorkoutDescriptionView(selectedWorkouts: .constant(["Bench Press", "Squat", "Deadlift"]), selectedTab:  .constant(.newWorkout), isTyping: .constant(true))
}
