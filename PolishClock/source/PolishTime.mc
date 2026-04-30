import Toybox.Lang;

module PolishTime {

    // Returns the full spoken Polish time string.
    // e.g. getTimeString(8, 15)  → "o ósmej piętnaście"
    //      getTimeString(12, 0)  → "o dwunastej"
    //      getTimeString(23, 59) → "o jedenastej pięćdziesiąt dziewięć"
    function getTimeString(hour as Number, minute as Number) as String {
        var h = hour % 12;  // 0–11

        var hours = [
            "o dwunastej",    // 0 / 12
            "o pierwszej",    // 1
            "o drugiej",      // 2
            "o trzeciej",     // 3
            "o czwartej",     // 4
            "o piątej",       // 5
            "o szóstej",      // 6
            "o siódmej",      // 7
            "o ósmej",        // 8
            "o dziewiątej",   // 9
            "o dziesiątej",   // 10
            "o jedenastej"    // 11
        ] as Array<String>;

        var minutes = [
            "",                          //  0  — silence, just the hour
            "jeden",                     //  1
            "dwa",                       //  2
            "trzy",                      //  3
            "cztery",                    //  4
            "pięć",                      //  5
            "sześć",                     //  6
            "siedem",                    //  7
            "osiem",                     //  8
            "dziewięć",                  //  9
            "dziesięć",                  // 10
            "jedenaście",                // 11
            "dwanaście",                 // 12
            "trzynaście",                // 13
            "czternaście",               // 14
            "piętnaście",                // 15
            "szesnaście",                // 16
            "siedemnaście",              // 17
            "osiemnaście",               // 18
            "dziewiętnaście",            // 19
            "dwadzieścia",               // 20
            "dwadzieścia jeden",         // 21
            "dwadzieścia dwa",           // 22
            "dwadzieścia trzy",          // 23
            "dwadzieścia cztery",        // 24
            "dwadzieścia pięć",          // 25
            "dwadzieścia sześć",         // 26
            "dwadzieścia siedem",        // 27
            "dwadzieścia osiem",         // 28
            "dwadzieścia dziewięć",      // 29
            "trzydzieści",               // 30
            "trzydzieści jeden",         // 31
            "trzydzieści dwa",           // 32
            "trzydzieści trzy",          // 33
            "trzydzieści cztery",        // 34
            "trzydzieści pięć",          // 35
            "trzydzieści sześć",         // 36
            "trzydzieści siedem",        // 37
            "trzydzieści osiem",         // 38
            "trzydzieści dziewięć",      // 39
            "czterdzieści",              // 40
            "czterdzieści jeden",        // 41
            "czterdzieści dwa",          // 42
            "czterdzieści trzy",         // 43
            "czterdzieści cztery",       // 44
            "czterdzieści pięć",         // 45
            "czterdzieści sześć",        // 46
            "czterdzieści siedem",       // 47
            "czterdzieści osiem",        // 48
            "czterdzieści dziewięć",     // 49
            "pięćdziesiąt",              // 50
            "pięćdziesiąt jeden",        // 51
            "pięćdziesiąt dwa",          // 52
            "pięćdziesiąt trzy",         // 53
            "pięćdziesiąt cztery",       // 54
            "pięćdziesiąt pięć",         // 55
            "pięćdziesiąt sześć",        // 56
            "pięćdziesiąt siedem",       // 57
            "pięćdziesiąt osiem",        // 58
            "pięćdziesiąt dziewięć"      // 59
        ] as Array<String>;

        var hourStr = hours[h];
        var minStr  = minutes[minute];

        if (minStr.equals("")) {
            return hourStr;
        }
        return hourStr + " " + minStr;
    }

    // Short Polish month abbreviations (genitive, as typically used in dates)
    function getMonthAbbr(month as Number) as String {
        var months = [
            "sty", "lut", "mar", "kwi",
            "maj", "cze", "lip", "sie",
            "wrz", "paź", "lis", "gru"
        ] as Array<String>;
        if (month >= 1 && month <= 12) {
            return months[month - 1];
        }
        return "???";
    }
}
