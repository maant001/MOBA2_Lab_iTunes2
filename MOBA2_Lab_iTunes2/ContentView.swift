//
//  ContentView.swift
//  MOBA2_Lab_iTunes2
//
//  Created by Tony Mamaril on 13.05.23.
//

import SwiftUI

struct ContentView: View {
    @State var artistList = [ArtistItem] ()
    @State var searchEntry : String = "The Rolling Stones"
    
    var body: some View {
        
        // TODO
        VStack {
            HStack {
                TextField("Search", text: $searchEntry, onCommit: {
                    self.artistList = loadJSON(searchEntry: self.searchEntry)
                })
                Image(systemName: "magnifyingglass")
            }.padding().background(Color(.secondarySystemBackground)).cornerRadius(15.5)
                
            List(artistList) { artistItem in
                HStack {
                    Image(uiImage: artistItem.albumCover ?? UIImage()).shadow(radius: 3)
                    VStack {
                        Text(artistItem.collectionName!).frame(maxWidth: .infinity, alignment: .center)
                        Text(artistItem.artistName!).font(.footnote)
                    }
                }
            }
            
        }.onAppear() {
            DispatchQueue.main.async {
                self.artistList = loadJSON(searchEntry: self.searchEntry)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ArtistItem: Identifiable, Decodable {
    var artistName : String?
    var collectionName : String?
    var collectionType : String?
    var collectionId : Int?
    var id: Int {
        get {
            return collectionId ?? 0
        }
    }
    
    // important that the attribute names are the same than in call/json!
    var artworkUrl100: String?
    var albumCover : UIImage? {
        get {
            return loadAlbumImage(urlImage: self.artworkUrl100)
        }
    }
    
    func loadAlbumImage(urlImage: String?) -> UIImage? {
        if urlImage != nil {
            let url = NSURL(string: urlImage!)! as URL
            
            if let imageContent: NSData = NSData(contentsOf: url) {
                let albumImage = UIImage(data: imageContent as Data)
                return albumImage
            }
        }
        
        return nil
    }
}

struct ArtistWrapper: Decodable {
    // needs to be named results, because check json file!
    // "results": [...
    var results : [ArtistItem]
}

func loadJSON(searchEntry: String) -> [ArtistItem] {
    do {
        let urlString = "https://itunes.apple.com/search?term=" + searchEntry + "&entity=album"
        let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlFinal = URL(string: urlEncoded)
        let data = try Data(contentsOf: urlFinal!)
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode(ArtistWrapper.self, from: data)
        
        return decodedData.results.filter({
            return $0.collectionType != nil
        })
    } catch {
        fatalError("json not loaded\n\(error)")
    }
}
