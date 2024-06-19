import SwiftUI
import Combine

class WorkoutModel: ObservableObject {
    @Published var workouts: [String] = []
}
