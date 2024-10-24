import SwiftUI

struct AnalyticsView: View {
    let diameter: Double
    let selectedTree: TreeType?

    private let growthFactor = 4.5

    private var estimatedAge: Int {
        // Convert diameter to centimeters if it's in meters
        let diameterInCm = diameter * 100
        // Calculate age using the growth factor
        return Int(round(diameterInCm * growthFactor))
    }

    private var formattedDiameter: String {
        String(format: "%.1f cm", diameter * 100)
    }

    private var birthYear: Int {
        Calendar.current.component(.year, from: Date()) - estimatedAge
    }

    var body: some View {
        VStack(spacing: 25) {
            VStack(alignment: .leading, spacing: 15) {
                InfoCard(title: "Estimated Age", value: "\(estimatedAge) years")
                InfoCard(title: "Tree Diameter", value: formattedDiameter)
                InfoCard(title: "Species", value: selectedTree?.name ?? "Unknown")
                InfoCard(title: "Fun Fact", value: getFunFact(age: estimatedAge))
            }
            .padding()

            NavigationLink(destination: HistoryView(estimatedAge: estimatedAge, birthYear: birthYear)) {
                Text("Explore Historical Context")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(TreeTheme.darkGreen)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Tree Analysis")
                    .font(.headline)
                    .foregroundColor(TreeTheme.darkGreen)
            }
        }
    }

    private func getFunFact(age: Int) -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let birthYear = currentYear - age

        if age < 10 {
            return "This tree is still very young!"
        } else if age < 50 {
            return "This tree was planted around \(birthYear)."
        } else if age < 100 {
            return "This tree has been here since \(birthYear)!"
        } else {
            return "This tree has been standing since \(birthYear) - that's over a century!"
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(TreeTheme.forestBrown)
            Text(value)
                .font(.title3)
                .foregroundColor(TreeTheme.darkGreen)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalyticsView(diameter: 0.5, selectedTree: TreeType.types.first)
        }
    }
}
