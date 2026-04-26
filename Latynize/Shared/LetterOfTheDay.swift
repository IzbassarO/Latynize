//
//  LetterOfTheDay.swift
//  Latynize
//
//  Created by Izbassar Orynbassar on 23.04.2026.
//

import Foundation

struct LetterOfTheDay: Equatable {
    let cyrillic: String
    let latin2021: String
    let latin2018: String
    let exampleCyrillic: String
    let exampleLatin: String
    let description: LocalizedStringResource
    
    /// Returns letter for a given date (deterministic — same letter all day)
    static func forDate(_ date: Date = .now) -> LetterOfTheDay {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % allLetters.count
        return allLetters[index]
    }
}

extension LetterOfTheDay {
    
    static let allLetters: [LetterOfTheDay] = [
        .init(cyrillic: "Ә ә", latin2021: "Ä ä", latin2018: "Á á",
              exampleCyrillic: "Әке", exampleLatin: "Äke",
              description: "Father"),
        
        .init(cyrillic: "Ө ө", latin2021: "Ö ö", latin2018: "Ó ó",
              exampleCyrillic: "Өзен", exampleLatin: "Özen",
              description: "River"),
        
        .init(cyrillic: "Ү ү", latin2021: "Ü ü", latin2018: "Ý ý",
              exampleCyrillic: "Үй", exampleLatin: "Üi",
              description: "House"),
        
        .init(cyrillic: "Ұ ұ", latin2021: "Ū ū", latin2018: "Ú ú",
              exampleCyrillic: "Ұл", exampleLatin: "Ūl",
              description: "Son"),
        
        .init(cyrillic: "Ғ ғ", latin2021: "Ğ ğ", latin2018: "Ǵ ǵ",
              exampleCyrillic: "Ғылым", exampleLatin: "Ğılım",
              description: "Science"),
        
        .init(cyrillic: "Қ қ", latin2021: "Q q", latin2018: "Q q",
              exampleCyrillic: "Қала", exampleLatin: "Qala",
              description: "City"),
        
        .init(cyrillic: "Ң ң", latin2021: "Ñ ñ", latin2018: "Ń ń",
              exampleCyrillic: "Таң", exampleLatin: "Tañ",
              description: "Dawn"),
        
        .init(cyrillic: "Һ һ", latin2021: "H h", latin2018: "H h",
              exampleCyrillic: "Гауһар", exampleLatin: "Gauhar",
              description: "Diamond"),
        
        .init(cyrillic: "І і", latin2021: "İ i", latin2018: "Í í",
              exampleCyrillic: "Іс", exampleLatin: "İs",
              description: "Work"),
        
        .init(cyrillic: "Ш ш", latin2021: "Ş ş", latin2018: "Sh sh",
              exampleCyrillic: "Шай", exampleLatin: "Şai",
              description: "Tea"),
        
        .init(cyrillic: "А а", latin2021: "A a", latin2018: "A a",
              exampleCyrillic: "Алма", exampleLatin: "Alma",
              description: "Apple"),
        
        .init(cyrillic: "Б б", latin2021: "B b", latin2018: "B b",
              exampleCyrillic: "Бала", exampleLatin: "Bala",
              description: "Child"),
        
        .init(cyrillic: "Д д", latin2021: "D d", latin2018: "D d",
              exampleCyrillic: "Дала", exampleLatin: "Dala",
              description: "Steppe"),
        
        .init(cyrillic: "Е е", latin2021: "E e", latin2018: "E e",
              exampleCyrillic: "Ел", exampleLatin: "El",
              description: "Country"),
        
        .init(cyrillic: "Ж ж", latin2021: "J j", latin2018: "J j",
              exampleCyrillic: "Жыл", exampleLatin: "Jıl",
              description: "Year"),
        
        .init(cyrillic: "З з", latin2021: "Z z", latin2018: "Z z",
              exampleCyrillic: "Зат", exampleLatin: "Zat",
              description: "Thing"),
        
        .init(cyrillic: "К к", latin2021: "K k", latin2018: "K k",
              exampleCyrillic: "Көл", exampleLatin: "Köl",
              description: "Lake"),
        
        .init(cyrillic: "Л л", latin2021: "L l", latin2018: "L l",
              exampleCyrillic: "Лас", exampleLatin: "Las",
              description: "Dirty"),
        
        .init(cyrillic: "М м", latin2021: "M m", latin2018: "M m",
              exampleCyrillic: "Мал", exampleLatin: "Mal",
              description: "Cattle"),
        
        .init(cyrillic: "Н н", latin2021: "N n", latin2018: "N n",
              exampleCyrillic: "Нан", exampleLatin: "Nan",
              description: "Bread"),
        
        .init(cyrillic: "О о", latin2021: "O o", latin2018: "O o",
              exampleCyrillic: "От", exampleLatin: "Ot",
              description: "Fire"),
        
        .init(cyrillic: "П п", latin2021: "P p", latin2018: "P p",
              exampleCyrillic: "Пері", exampleLatin: "Peri",
              description: "Angel"),
        
        .init(cyrillic: "Р р", latin2021: "R r", latin2018: "R r",
              exampleCyrillic: "Рас", exampleLatin: "Ras",
              description: "Truth"),
        
        .init(cyrillic: "С с", latin2021: "S s", latin2018: "S s",
              exampleCyrillic: "Су", exampleLatin: "Su",
              description: "Water"),
        
        .init(cyrillic: "Т т", latin2021: "T t", latin2018: "T t",
              exampleCyrillic: "Тас", exampleLatin: "Tas",
              description: "Stone"),
        
        .init(cyrillic: "У у", latin2021: "U u", latin2018: "U u",
              exampleCyrillic: "Ұшақ", exampleLatin: "Ūşaq",
              description: "Airplane"),
        
        .init(cyrillic: "Ф ф", latin2021: "F f", latin2018: "F f",
              exampleCyrillic: "Фото", exampleLatin: "Foto",
              description: "Photo"),
        
        .init(cyrillic: "Х х", latin2021: "H h", latin2018: "H h",
              exampleCyrillic: "Хат", exampleLatin: "Hat",
              description: "Letter"),
        
        .init(cyrillic: "Ы ы", latin2021: "I ı", latin2018: "Y y",
              exampleCyrillic: "Ырыс", exampleLatin: "Irıs",
              description: "Fortune"),
        
        .init(cyrillic: "Й й", latin2021: "I i", latin2018: "I i",
              exampleCyrillic: "Ай", exampleLatin: "Ai",
              description: "Moon"),
        
        .init(cyrillic: "Ё ё", latin2021: "Io io", latin2018: "Io io",
              exampleCyrillic: "Ёлка", exampleLatin: "Iolka",
              description: "Fir tree"),
    ]
}
