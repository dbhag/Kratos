import SwiftUI

struct PreviousWorkoutsView: View {
    @EnvironmentObject var firestoreService: FirestoreService

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
                            ForEach(firestoreService.previousWorkouts) { workout in
                                WorkoutRowView(workout: workout)
                                    .padding(.horizontal)
                            }
                        }
                        /*.refreshable
                        {
                            firestoreService.fetchPreviousWorkouts()
                        }*/
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
                    //.background(Color.white.opacity(0.09))
                    //.background(Color.black.opacity(0.2))
                    .cornerRadius(24)
                    .shadow(color: Color.white.opacity(0.5), radius: 50, x: 5, y: 5)
                    .padding(.top, geometry.size.height * 0.05)
                    .offset(y: -geometry.size.height * 0.085)
                    
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)

                Text("Date: \(workout.timestamp, formatter: itemFormatter)")
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
    PreviousWorkoutsView()
}
