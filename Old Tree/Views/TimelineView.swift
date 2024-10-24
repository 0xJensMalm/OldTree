// Views/TimelineView.swift
import SwiftUI

struct TimelineView: View {
    let estimatedAge: Int
    let birthYear: Int

    @State private var scrollOffset: CGFloat = 0
    @State private var currentAge: Int = 0
    @State private var currentYear: Int = 0

    // Calculate points per year dynamically based on screen height and tree age
    private var pointsPerYear: CGFloat {
        // Define the maximum timeline height as 1.5 times the screen height to allow scrolling
        let maxTimelineHeight = UIScreen.main.bounds.height * 1.5
        // Calculate points per year
        return maxTimelineHeight / CGFloat(estimatedAge)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                // Ground Line with dynamic opacity
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(TreeTheme.forestBrown)
                        .frame(height: 4)
                        .padding(.horizontal)
                        .opacity(groundOpacity())
                        .animation(.easeInOut, value: scrollOffset)
                }

                // Scrollable Timeline using CustomScrollView
                CustomScrollView(maxScrollHeight: maxScrollHeight(), onScroll: { offset in
                    // Clamp the offset between 0 and maxScrollHeight
                    let clampedOffset = min(max(offset, 0), maxScrollHeight())
                    scrollOffset = clampedOffset
                    updateCounters()
                }) {
                    VStack {
                        // Spacer to position the timeline at the bottom initially
                        Spacer()
                            .frame(height: geometry.size.height / 2 - 50) // Adjust as needed

                        // Timeline Line with Events
                        ZStack(alignment: .bottom) {
                            // Timeline Line
                            Rectangle()
                                .fill(TreeTheme.darkGreen)
                                .frame(width: 4, height: currentAgeHeight())
                                .animation(.linear(duration: 0.2), value: currentAgeHeight())

                            // Event Markers
                            ForEach(historicalEvents.filter { $0.year >= birthYear && $0.year <= (birthYear + estimatedAge) }) { event in
                                let eventAge = event.year - birthYear
                                let position = CGFloat(eventAge) * pointsPerYear

                                // Ensure position is within current timeline height
                                if position <= currentAgeHeight() {
                                    VStack {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 12, height: 12)
                                            .accessibilityLabel("Event: \(event.description) in \(event.year)")
                                        Text(event.description)
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }
                                    .position(x: 20, y: currentAgeHeight() - position)
                                }
                            }
                        }
                        .frame(width: 4, height: currentAgeHeight())
                        .clipped()

                        // Spacer to allow scrolling upwards
                        Spacer()
                            .frame(height: maxScrollHeight())
                    }
                    .frame(minHeight: geometry.size.height + maxScrollHeight())
                }

                // Counters on the Right Side
                VStack(alignment: .trailing, spacing: 10) {
                    CounterView(title: "Tree Age", value: currentAge)
                    CounterView(title: "Current Year", value: currentYear)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    // Calculate the height of the timeline based on current age and dynamic scaling
    private func currentAgeHeight() -> CGFloat {
        CGFloat(currentAge) * pointsPerYear
    }

    // Calculate the maximum scrollable height based on dynamic scaling
    private func maxScrollHeight() -> CGFloat {
        CGFloat(estimatedAge) * pointsPerYear
    }

    // Update the current age and year based on scroll position
    private func updateCounters() {
        // Calculate the proportion scrolled and update counters accordingly
        let proportion = scrollOffset / maxScrollHeight()

        // Update Tree Age
        currentAge = Int(Double(estimatedAge) * Double(proportion))

        // Update Current Year
        currentYear = birthYear + currentAge
    }

    // Calculate the opacity of the ground line based on scroll position
    private func groundOpacity() -> Double {
        // Opacity decreases as scrollOffset increases
        let opacity = 1.0 - (Double(scrollOffset / maxScrollHeight()))
        return max(opacity, 0)
    }

    // Example historical events
    let historicalEvents: [HistoricalEvent] = [
        HistoricalEvent(year: 1980, description: "Major Event A"),
        HistoricalEvent(year: 1990, description: "Major Event B"),
        HistoricalEvent(year: 2000, description: "Major Event C"),
        HistoricalEvent(year: 2010, description: "Major Event D"),
        HistoricalEvent(year: 2020, description: "Major Event E"),
        HistoricalEvent(year: 2030, description: "Major Event F"),
        // Add more events as needed
    ]
}

// Custom ScrollView to Disable Bouncing
struct CustomScrollView<Content: View>: UIViewRepresentable {
    let maxScrollHeight: CGFloat
    let onScroll: (CGFloat) -> Void
    let content: Content

    init(maxScrollHeight: CGFloat, onScroll: @escaping (CGFloat) -> Void, @ViewBuilder content: () -> Content) {
        self.maxScrollHeight = maxScrollHeight
        self.onScroll = onScroll
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.bounces = false // Disable bouncing

        // Hosting the SwiftUI content
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear

        scrollView.addSubview(hostingController.view)

        // Constraints to fit the content
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update the SwiftUI view inside the UIScrollView if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScroll: onScroll, maxScrollHeight: maxScrollHeight)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        let onScroll: (CGFloat) -> Void
        let maxScrollHeight: CGFloat

        init(onScroll: @escaping (CGFloat) -> Void, maxScrollHeight: CGFloat) {
            self.onScroll = onScroll
            self.maxScrollHeight = maxScrollHeight
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // Calculate the current scroll offset
            let offset = scrollView.contentOffset.y

            // Clamp the offset between 0 and maxScrollHeight
            let clampedOffset = min(max(offset, 0), maxScrollHeight)

            // Notify the parent view of the scroll offset
            onScroll(clampedOffset)
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            // Prevent scrolling below 0
            if scrollView.contentOffset.y < 0 {
                scrollView.setContentOffset(.zero, animated: true)
            }
        }

        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            // Prevent scrolling below 0
            if scrollView.contentOffset.y < 0 {
                scrollView.setContentOffset(.zero, animated: true)
            }
        }
    }
}

// Historical Event Model
struct HistoricalEvent: Identifiable {
    let id = UUID()
    let year: Int
    let description: String
}

// Counter View
struct CounterView: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(TreeTheme.forestBrown)
            Text("\(value)")
                .font(.headline)
                .foregroundColor(TreeTheme.darkGreen)
        }
        .padding(8)
        .background(Color.white.opacity(0.7))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}

// Preview
struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(estimatedAge: 150, birthYear: 1874)
    }
}
