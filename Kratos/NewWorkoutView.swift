import SwiftUI

struct NewWorkoutView: View {
    @State private var isLiftSelected = true
    @State private var liftOptions: [String] = ["Chest", "Back", "Triceps", "Biceps", "Shoulders", "Legs"]
    @State private var cardioOptions: [String] = ["Run", "Walk", "Bike", "Swim", "Row", "HIIT"]
    @State private var selectedLiftOptions: Set<String> = []
    @State private var selectedCardioOptions: Set<String> = []
    @State private var showAlert = false
    @Binding var selectedWorkouts: Array<String>
    @EnvironmentObject var workoutModel: WorkoutModel
    
    @Binding var selectedTab: Tab
    @State private var navigateToDescription: Bool = false

    //private let db = Firestore.firestore()

    var body: some View {
        //NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color(red: 0.16, green: 0.18, blue: 0.2)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        // Header with Text and Flame Image
                        HStack(spacing: geometry.size.width * 0.05) {
                            Text("New Workout")
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
                        
                        HStack {
                            Text("Lift")
                                .font(.custom("Poppins-Regular", size: geometry.size.width * 0.05))
                                .foregroundColor(isLiftSelected ? .black : .gray)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(isLiftSelected ? Color.white : Color(red: 0.16, green: 0.18, blue: 0.2))
                                .cornerRadius(20)
                                .onTapGesture {
                                    isLiftSelected = true
                                }
                            
                            Text("Cardio")
                                .font(.custom("Poppins-Regular", size: geometry.size.width * 0.05))
                                .foregroundColor(!isLiftSelected ? .white : .gray)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(!isLiftSelected ? Color.black : Color(red: 0.16, green: 0.18, blue: 0.2))
                                .cornerRadius(20)
                                .onTapGesture {
                                    isLiftSelected = false
                                }
                        }
                        //.padding(.bottom, 0)
                        .padding(.top, -geometry.size.height * 0.055)
                        
                        Spacer()
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: geometry.size.width * 0.85, height: geometry.size.height * 0.55)
                                .background(Color.white.opacity(0.09))
                                .cornerRadius(24)
                                .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                            
                            VStack {
                                let options = isLiftSelected ? liftOptions : cardioOptions
                                ForEach(options, id: \.self) { option in
                                    let isSelected = isLiftSelected ? selectedLiftOptions.contains(option) : selectedCardioOptions.contains(option)
                                    Text(option)
                                        .font(.custom("Poppins-Regular", size: geometry.size.width * 0.055))
                                        .foregroundColor(isSelected ? .black : .white)
                                        .padding()
                                        .frame(width: geometry.size.width * 0.75)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .foregroundColor(isSelected ? Color.orange : Color.gray.opacity(0.01))
                                        )
                                        .onTapGesture {
                                            if isLiftSelected {
                                                if isSelected {
                                                    selectedLiftOptions.remove(option)
                                                } else {
                                                    selectedLiftOptions.insert(option)
                                                }
                                            } else {
                                                if isSelected {
                                                    selectedCardioOptions.remove(option)
                                                } else {
                                                    selectedCardioOptions.insert(option)
                                                }
                                            }
                                        }
                                }
                            }
                            .padding()
                        }
                        .padding(.vertical, geometry.size.height * 0.03)
                        .offset(y: -geometry.size.height * 0.0275)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedWorkouts = Array(selectedLiftOptions)
                            selectedWorkouts.append(contentsOf: selectedCardioOptions)
                            
                            if selectedWorkouts.isEmpty {
                                // Show alert if no options are selected
                                showAlert = true
                            } else {
                                // Proceed with navigation and other actions
                                navigateToDescription = true
                                selectedTab = .workoutDescription
                                clearSelections()
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.16, green: 0.18, blue: 0.2))
                                .padding()
                                .frame(width: 220, height: 60)
                                .background(Color.white)
                                .cornerRadius(15.0)
                                .shadow(color: .gray, radius: 5, x: 0, y: 5)
                                .offset(y: -geometry.size.height * 0.04)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Alert"), message: Text("Please select an option to continue"), dismissButton: .default(Text("OK")))
                        }
                        .padding(.bottom, geometry.size.height * 0.02)
                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    //}

    func clearSelections() {
        selectedLiftOptions.removeAll()
        selectedCardioOptions.removeAll()
    }
}

#Preview {
    NewWorkoutView(selectedWorkouts: .constant(["Bench Press", "Squat", "Deadlift"]), selectedTab:  .constant(.newWorkout))
}

