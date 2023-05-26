//
//  ContentView.swift
//  BetterRest
//
//  Created by Eduardo Hoffmann on 24/05/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    
    @State var animateCoin = false
    @Environment(\.colorScheme) var colorScheme
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    @State private var image = "relogio"
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = true
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(stops: [
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                ], center: .top, startRadius: 200, endRadius: 400).opacity(0.9)
                    .ignoresSafeArea()
                Form {
                    
                    Section {
                        
                        DatePicker("Por favor, escolha a hora", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        
                    } header: {
                        Text("Qual horário você quer acordar?")
                            .titleStyle()
                           
                    }
                    
                    Section() {

                        Stepper("  \(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                            
                    } header: {
                        Text("Quantidade de sono desejável")
                            .titleStyle()
                            
                    }
                    // VStack(alignment: .leading, spacing: 0) {
                    Section() {
                        
                        Picker("Xícaras ingeridas", selection: $coffeeAmount) {
                            ForEach(1..<21) { item in
                                Text((item == 1 ? "1 xícara" : "\(item) xícaras"))
                            }
                        }
                        
                    } header: {
                        Text("Ingestão diária de café")
                            .titleStyle()

                    }
                    Section() {
                        HStack() {
                            (Image(image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 210.0, height: 110.0, alignment: .center)
                                .offset(y: 0)
                                .clipShape(Circle()))
                            
                            Text("\(calculateBedtime())")
                                .font(.system(size: 30, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.green)
                        }
                     
                    } header: {
                        Text("A hora ideal para você dormir é...")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.orange)
                    }
                }
                // .background(Color(.systemGroupedBackground)).opacity(0.4)
               // .background(Color.green).opacity(0.5)
                .scrollContentBackground(.hidden)
                .navigationTitle("MelhorDescanso")
                    
                }
                
            }
            
        }
    
func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
          
           let date = sleepTime.formatted(date: .omitted, time: .shortened)
            return date
        } catch {
           
            alertMessage = "Desculpe, houve um problema ao calcular sua hora de dormir"
            showingAlert = true
           
        }
    return ""
      
        
    }
}

    struct Title: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(Color.orange)
            }
        }

    extension View {
        func titleStyle() -> some View {
            self.modifier(Title())
        }
    }
    


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
