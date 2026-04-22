import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodOrderScreen extends StatefulWidget {
  const FoodOrderScreen({super.key});
  @override 
  State<FoodOrderScreen> createState() => _FoodOrderScreenState();
}

class _FoodOrderScreenState extends State<FoodOrderScreen> {
  final List<Map<String, dynamic>> _menu = [
    {'name': 'Veg Biryani', 'price': 180, 'icon': Icons.rice_bowl, 'count': 0},
    {'name': 'Butter Naan', 'price': 60, 'icon': Icons.lunch_dining, 'count': 0},
    {'name': 'Paneer Tikka', 'price': 220, 'icon': Icons.kebab_dining, 'count': 0},
    {'name': 'Masala Chai', 'price': 40, 'icon': Icons.emoji_food_beverage, 'count': 0},
    {'name': 'Club Sandwich', 'price': 150, 'icon': Icons.fastfood, 'count': 0},
    {'name': 'Fresh Juice', 'price': 90, 'icon': Icons.local_drink, 'count': 0},
  ];

  int get _total => _menu.fold(0, (s, i) => s + (i['price'] as int) * (i['count'] as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgPage,
      appBar: AppBar(
        title: Text('Food Order',
            style: GoogleFonts.playfairDisplay(
                color: kNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: kNavy),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF8F00).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item['icon'] as IconData, color: const Color(0xFFFF8F00), size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item['name'] as String,
                              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14, color: kNavy)),
                          Text('₹${item['price']}',
                              style: GoogleFonts.lato(color: const Color(0xFFFF8F00), fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                      ),
                      Row(children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: kNavy, size: 22),
                          onPressed: () { if ((item['count'] as int) > 0) setState(() => _menu[index]['count']--); },
                        ),
                        Text('${item['count']}', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Color(0xFFFF8F00), size: 22),
                          onPressed: () => setState(() => _menu[index]['count']++),
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: Colors.white,
            child: Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text('Total', style: GoogleFonts.lato(color: Colors.grey, fontSize: 12)),
                  Text('₹$_total', style: GoogleFonts.lato(color: kNavy, fontWeight: FontWeight.bold, fontSize: 22)),
                ]),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_total == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add items')));
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Order Placed! 🎉'),
                          content: const Text('Your food will arrive in 30 minutes.'),
                          actions: [ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: kGold),
                            onPressed: () {
                              setState(() { for (var i in _menu) i['count'] = 0; });
                              Navigator.pop(context);
                            },
                            child: const Text('OK', style: TextStyle(color: kNavy)),
                          )],
                        ),
                      );
                    },
                    child: Text('Place Order', style: GoogleFonts.lato(color: kNavy, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}