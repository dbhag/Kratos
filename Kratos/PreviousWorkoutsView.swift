import SwiftUI

struct PreviousWorkoutsView: View {
    @ObservedObject var firestoreService = FirestoreService()

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
                            .font(.custom("Marker Felt", size: geometry.size.width * 0.075))
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
                            ForEach(firestoreService.previousWorkouts) { workout in
                                WorkoutRowView(workout: workout)
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
            firestoreService.fetchPreviousWorkouts()
        }
    }
}

struct WorkoutRowView: View {
    var workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Workout Date: \(workout.timestamp, formatter: itemFormatter)")
                .font(.custom("Marker Felt", size: 16))
                .foregroundColor(.white)
            ForEach(workout.exercises, id: \.self) { exercise in
                Text(exercise)
                    .font(.custom("Marker Felt", size: 14))
                    .foregroundColor(.gray)
            }
            Text(workout.description)
                .font(.custom("Marker Felt", size: 14))
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(red: 0.16, green: 0.18, blue: 0.2).opacity(0.8))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 5)
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
    PreviousWorkoutsView()
}
