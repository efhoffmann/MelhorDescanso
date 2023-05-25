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
    @State private var coffeeAmount = 1
    @State private var image = "relogio"
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                RadialGradient(gradient: Gradient(colors: [.green, .white]), center: .center, startRadius: 20, endRadius: 200)
                Form {
                    
                    Text("Qual horário você quer acordar?")
                        .font(.headline)
                    
                    DatePicker("Por favor, escolha a hora", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Quantidade de sono desejável")
                            .font(.headline)
                        
                        Stepper("  \(sleepAmount.formatted()) horas", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Ingestão diária de café")
                            .font(.headline)
                        
                        Stepper(coffeeAmount == 1 ? "  1 xícara" : "  \(coffeeAmount) xícaras", value: $coffeeAmount, in: 1...20)
                    }
              
            }
                
                // .background(Color(.systemGroupedBackground)).opacity(0.4)
                .background(Color.green).opacity(0.5)
                .scrollContentBackground(.hidden)
            
           
            .navigationTitle("MelhorDescanso")
            .toolbar {
                Button("Calcular", action: calculateBedtime)
                
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK") { self.animateCoin.toggle()}
                    } message: {
                        Text(alertMessage)
                    }
            }
                
                VStack {
                   
                    Rectangle()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .frame(width: 150, height: 150, alignment: .center)
                        .offset(y: 0)
                        .mask(Image(systemName: "deskclock")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotation3DEffect(
                                Angle(degrees: self.animateCoin ? 360 : 0),
                                axis: (x: 0, y: self.animateCoin ? 360 : 0, z: 0)
                                
                            )
                        )
                        .offset(y: self.animateCoin ? 600 : 0)
                        .animation(.linear(duration: 1))
                   
                }
                
                
                VStack {
                    (Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 210.0, height: 110.0)
                        .clipShape(Circle())
                        .rotation3DEffect(
                            Angle(degrees: self.animateCoin ? 360 : 0),
                            axis: (x: 0, y: self.animateCoin ? 360 : 0, z: 0)
                            
                        )
                    )
                    .offset(y: self.animateCoin ? 600 : 0)
                    .animation(.linear(duration: 1))
                }
                
        }
           
          
    }
       
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "A hora ideal para você dormir é..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            alertTitle = "Erro"
            alertMessage = "Desculpe, houve um problema ao calcular sua hora de dormir"
        }
        showingAlert = true
        self.animateCoin.toggle()
       
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
