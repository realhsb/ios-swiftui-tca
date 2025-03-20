//
//  FavoritePrimesView.swift
//  tca-counter
//
//  Created by Soop on 3/13/25.
//

import SwiftUI

struct FavoritePrimesView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        List {
            ForEach(self.store.value.favoritePrimes, id: \.self) { prime in
                    Text("\(prime)")
            }
            .onDelete { indexSet in
                self.store.send(.favoritePrimes(.deleteFavoritePrimes(indexSet)))
            }
        }
        .navigationBarTitle(Text("Favorite Primes"))
        .navigationBarItems(
            trailing: HStack {
                Button("Save", action: self.saveFavoritePrimes)
                Button("Load", action: self.loadFavoritePrimes)
            }
        )
    }
    
    func saveFavoritePrimes() {
        let data = try! JSONEncoder().encode(self.store.value.favoritePrimes)
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0]
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-Primes.json")
        try! data.write(to: favoritePrimesUrl)
    }
    
    func loadFavoritePrimes() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        )[0]
        let documentsUrl = URL(fileURLWithPath: documentsPath)
        let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-Primes.json")
        guard
            let data = try? Data(contentsOf: favoritePrimesUrl),
            let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
        else {
            return
        }
        self.favoritePrimes = favoritePrimes
    }
}
