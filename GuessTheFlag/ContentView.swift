//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Scott Obara on 4/1/21.
//

import SwiftUI

// https://stackoverflow.com/questions/62677059/swiftui-cant-directly-called-modifier-when-custom-image-modifier
extension Image {
    func flagImage() -> some View {
        self
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.8), radius: 20, x: 0, y: 10)
    }
}

//struct FlagImage: ViewModifier {
//    func body(content: Content) -> some View {
//        content
//            .clipShape(Capsule())
//            .overlay(Capsule().stroke(Color.gray, lineWidth: 1))
//            .shadow(color: Color.black.opacity(0.8), radius: 20, x: 0, y: 10)
//    }
//}
//
//extension View {
//    func flagStyle() -> some View {
//        self.modifier(FlagImage())
//    }
//}

// https://www.objc.io/blog/2019/10/01/swiftui-shake-animation/
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}


struct ContentView: View {
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var currentScore = (correctCount: 0, incorrectCount: 0)
//    @State var attempts: Int = 0
    @State private var incorrectPressed = [0, 0, 0]
    @State private var correctPressed = [false, false, false]
    @State private var correctNotPressed  = [false, false, false]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30.0) {
                VStack {
                    Text("Tap the flag of")
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    Text(countries[correctAnswer])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }
                
                ForEach(0 ..< 3) { number in
                    Button(action: {
                        self.flagTapped(number)
                        if number == correctAnswer {
                            correctPressed[number].toggle()
                        }
                    }) {
                        Image(self.countries[number])
//                            .renderingMode(.original)
                            .flagImage()
                            .accessibility(label: Text(self.labels[self.countries[number], default: "Unknown flag"]))
                            .modifier(Shake(animatableData: CGFloat(incorrectPressed[number])))
                            .rotationEffect(Angle.degrees(correctPressed[number] ? 360 : 0))
                            .animation(.easeInOut)
                            .opacity(correctNotPressed[number] ? 0.3 : 1)
                        
                    }
                }.padding(.top, 20)
                Spacer()
            }
        }
        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text(
                "Correct:  \(currentScore.correctCount), Incorrect: \(currentScore.incorrectCount)" //Debug: \(correctPressed.description)
            ), dismissButton: .default(Text("Continue")) {
                self.askQuestion()
                
            })
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            currentScore.correctCount += 1
            //correctPressed[number] += 1
            //correctPressed[number].toggle()
            for button in 0..<3 {
                if button != number {
                    correctNotPressed[button] = true
                }
            }
        } else {
            scoreTitle = """
                Wrong
                The correct answer is flag: \(correctAnswer + 1)
                """
            currentScore.incorrectCount += 1
            withAnimation(.default) {
                self.incorrectPressed[number] += 1
            }
        }

        showingScore = true
   
    }
    
    func askQuestion() {
//        incorrectPressed = [0, 0, 0]
//        correctPressed = [0, 0, 0]
//        correctPressed = [false, false, false]
        correctNotPressed  = [false, false, false]
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
