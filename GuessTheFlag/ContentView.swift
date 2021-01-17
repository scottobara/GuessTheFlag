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
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var currentScore = (correctCount: 0, incorrectCount: 0)
    @State var attempts: Int = 0
    @State private var incorrectPressed = [0, 0, 0]
    @State private var correctPressed = [0, 0, 0]
    
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
//                        withAnimation(.default) {
//                            self.incorrectPressed[number] += 1
//                        }
                    }) {
                        Image(self.countries[number])
//                            .renderingMode(.original)
                            .flagImage()
                            .modifier(Shake(animatableData: CGFloat(incorrectPressed[number])))
                            .rotationEffect(Angle.degrees((correctPressed[number] >= 1) ? 360 : 0))
                            .animation(.easeInOut)
                        
                    }
                }.padding(.top, 20)
                Spacer()
            }
        }
        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text(
                "Correct:  \(currentScore.correctCount), Incorrect: \(currentScore.incorrectCount) Debug: \(incorrectPressed.description)"
            ), dismissButton: .default(Text("Continue")) {
                self.askQuestion()
                incorrectPressed = [0, 0, 0]
                correctPressed = [0, 0, 0]
            })
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            currentScore.correctCount += 1
            correctPressed[number] += 1
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
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
