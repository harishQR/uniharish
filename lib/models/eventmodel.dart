import 'dart:math';

class Event {
  final int id;
  final String title;
  final DateTime startDate;
  final DateTime endDate;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.description,
  });
}

class MockEvents {
  static List<Event> generateMockEvents() {
    List<Event> events = [];
    int idCounter = 1;
    final random = Random();

    List<Map<String, String>> mockData = [
      {
        "title": "Pongal Festival",
        "description":
        "Pongal is a harvest festival celebrated in Tamil Nadu, marking the start of the sun's journey northwards."
      },
      {
        "title": "Abdul Kalam's Birthday",
        "description":
        "Celebrating the birth anniversary of Dr. A.P.J. Abdul Kalam, former President of India and renowned scientist."
      },
      {
        "title": "World Environment Day",
        "description":
        "A global event to raise awareness about environmental protection and sustainability."
      },
      {
        "title": "Christmas Celebration",
        "description":
        "Celebration of the birth of Jesus Christ, observed with joy, decorations, and gift exchanges."
      },
      {
        "title": "International Yoga Day",
        "description":
        "A day to promote yoga, mindfulness, and holistic wellness around the world."
      },
      {
        "title": "New Year's Eve Party",
        "description":
        "Celebrating the last day of the year with friends, family, and fireworks."
      },
      {
        "title": "Independence Day",
        "description":
        "Celebration of a nation's independence with parades, speeches, and patriotic events."
      },
      {
        "title": "World Literacy Day",
        "description":
        "A day to highlight the importance of literacy and education globally."
      },
      {
        "title": "Diwali Festival",
        "description":
        "Festival of lights, celebrated with lamps, sweets, and fireworks."
      },
      {
        "title": "Halloween",
        "description":
        "A fun-filled celebration with costumes, spooky decorations, and trick-or-treating."
      },
      {
        "title": "Republic Day",
        "description":
        "Commemorating the day the constitution of India came into effect with parades and patriotic events."
      },
      {
        "title": "Earth Hour",
        "description":
        "An annual event encouraging people to turn off non-essential lights to raise awareness about energy consumption."
      },
      {
        "title": "Children's Day",
        "description":
        "A day to honor children and promote their welfare and education."
      },
      {
        "title": "Teacher's Day",
        "description":
        "A day to recognize and appreciate the contributions of teachers."
      },
      {
        "title": "Labour Day",
        "description": "A day to honor workers and their contributions to society."
      },
      {
        "title": "Gandhi Jayanti",
        "description":
        "Commemorating the birth anniversary of Mahatma Gandhi, the Father of the Nation."
      },
      {
        "title": "Raksha Bandhan",
        "description":
        "A festival celebrating the bond between brothers and sisters with rakhis and gifts."
      },
      {
        "title": "Holi Festival",
        "description":
        "Festival of colors celebrated with vibrant powders, water, and joy."
      },

      {
        "title": "Easter",
        "description":
        "Christian festival celebrating the resurrection of Jesus Christ."
      },
      {
        "title": "Ganesh Chaturthi",
        "description":
        "Celebration of Lord Ganesha's birth with idols, prayers, and festivities."
      },
      {
        "title": "Makar Sankranti",
        "description":
        "A harvest festival celebrated with kite flying and traditional sweets."
      },
      {
        "title": "International Women's Day",
        "description":
        "A day to celebrate women's achievements and promote gender equality."
      },
      {
        "title": "World Health Day",
        "description":
        "A global health awareness day organized by the World Health Organization."
      },
      {
        "title": "Diabetes Awareness Day",
        "description":
        "Raising awareness about diabetes prevention, management, and treatment."
      },
      {
        "title": "National Sports Day",
        "description":
        "Honoring athletes and promoting sports activities among youth."
      },
      {
        "title": "National Science Day",
        "description":
        "Celebrating scientific achievements and encouraging innovation and research."
      },
      {
        "title": "International Day of Peace",
        "description":
        "A day devoted to strengthening ideals of peace among nations and people."
      },
      {
        "title": "World Mental Health Day",
        "description":
        "Raising awareness and education about mental health issues globally."
      },
      {
        "title": "Black Friday",
        "description":
        "A major shopping event with discounts and offers before the holiday season."
      },
    ];


    DateTime start = DateTime(2025, 1, 1);
    DateTime end = DateTime(2025, 12, 31);
    DateTime current = start;

    while (!current.isAfter(end)) {
      // 1-2 normal events per day
      int eventsToday = random.nextInt(2) + 1; // 1 or 2
      for (int i = 0; i < eventsToday; i++) {
        final data = mockData[random.nextInt(mockData.length)];

        DateTime eventStart =
        current.add(Duration(hours: i * (1 + random.nextInt(3))));
        DateTime eventEnd =
        eventStart.add(Duration(hours: 1 + random.nextInt(2)));

        events.add(Event(
          id: idCounter++,
          title: data['title']!,
          startDate: eventStart,
          endDate: eventEnd,
          description: data['description']!,
        ));
      }

      // multi-day event every 10 days
      if (current.day % 10 == 0) {
        final data = mockData[random.nextInt(mockData.length)];
        DateTime multiStart = current;
        DateTime multiEnd = current.add(Duration(days: 2 + random.nextInt(2))); // 2-3 days

        events.add(Event(
          id: idCounter++,
          title: "Multi-day: ${data['title']}",
          startDate: multiStart,
          endDate: multiEnd,
          description: "Multi-day event: ${data['description']}",
        ));
      }

      current = current.add(Duration(days: 1));
    }

    return events;
  }
}
