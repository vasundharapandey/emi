import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:credemi/api/apiservice.dart';

class StackedExpandableWidgets extends StatefulWidget {
  const StackedExpandableWidgets({Key? key}) : super(key: key);

  @override
  _StackedExpandableWidgetsState createState() =>
      _StackedExpandableWidgetsState();
}

class _StackedExpandableWidgetsState extends State<StackedExpandableWidgets> {
  List<dynamic> itemsData = [];
  double creditAmount = 150000;
  //int expandedIndex = 0;
 List<bool> _isExpanded = [true, false, false];
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var data = await ApiService.fetchLoanData();
      setState(() {
        itemsData = data;
      });
    } catch (e) {
      print('Error fetching data: $e');
     
    }
  }

  Widget _buildCreditContent(Map<String, dynamic> body) {
    return Column(
      children: [
        Text(
          body['subtitle'],
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 20),
        GestureDetector(
          onPanUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(Offset.zero);
            final double angle = (details.localPosition - center).direction;
            setState(() {
              creditAmount = ((angle + math.pi) / (2 * math.pi)) *
                      (body['card']['max_range'].toDouble() -
                          body['card']['min_range'].toDouble()) +
                  body['card']['min_range'].toDouble();
              creditAmount = creditAmount.clamp(
                body['card']['min_range'].toDouble(),
                body['card']['max_range'].toDouble(),
              ) as double;
            });
          },
          child: Container(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(250, 250),
                  painter: CircularSliderPainter(
                    value: creditAmount,
                    min: body['card']['min_range'].toDouble(),
                    max: body['card']['max_range'].toDouble(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'credit amount',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '₹${creditAmount.round()}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '@1.04% monthly',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        Text(
          body['footer'],
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }


Widget _buildEMIContent(Map<String, dynamic> body) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        body['subtitle'],
        style: TextStyle(color: Colors.white70),
      ),
      SizedBox(height: 20),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: body['items'].map<Widget>((item) => _buildEMICard(item)).toList(),
        ),
      ),
      SizedBox(height: 20),
      Center(
        child: TextButton(
          onPressed: () {},
          child: Text(
            body['footer'],
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ],
  );
}

Widget _buildEMICard(Map<String, dynamic> item) {
  final randomColor = _getRandomColor(); 

  return Container(
    margin: EdgeInsets.only(right: 16),
    width: 150,
    child: Stack(
      children: [
        Card(
          color: randomColor,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Space at the top for the Recommended and Checkbox
                SizedBox(height: 24),
                Text(
                  item['emi'],
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  item['duration'],
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 8),
                Text(
                  item['subtitle'],
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
        ),
        // "Recommended" label at the top right
        if (item['tag'] == 'recommended')
          Positioned(
            top: -10,
            right: 8,
            child: Chip(
              label: Text('Recommended'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
          ),
        // Circular checkbox at the top left
        Positioned(
          top: 8,
          left: 8,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 12,
            child: Checkbox(
              value: item['isSelected'] ?? false, // Replace this with the selection logic
              onChanged: (bool? value) {
                // Handle selection logic here
              },
              shape: CircleBorder(),
              activeColor: Colors.green,
            ),
          ),
        ),
      ],
    ),
  );
}

Color _getRandomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}


  Widget _buildBankContent(Map<String, dynamic> body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          body['subtitle'],
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 20),
        ...body['items'].map<Widget>((item) => _buildBankCard(item)).toList(),
        SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              body['footer'],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(Map<String, dynamic> item) {
    return Card(
      color: Colors.grey[800],
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(item['title'][0], style: TextStyle(color: Colors.black)),
        ),
        title: Text(
          item['title'],
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          item['subtitle'].toString(),
          style: TextStyle(color: Colors.white70),
        ),
        trailing: Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  }
Widget _buildExpansionTile(int index) {
  if (itemsData.isEmpty) return SizedBox.shrink();
  final item = itemsData[index];

  return ClipRRect(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12.0),
      topRight: Radius.circular(12.0),
    ),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],  // Matches the background color
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),  // Darker shadow
            spreadRadius: 4,
            blurRadius: 15,
            offset: Offset(0, -5),  // Shadow extends further upwards
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent, // Removes the white border or dividers
        ),
        child: ExpansionTile(
          title: Text(
            item['closed_state']['body']['key1'] ?? '',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: Colors.transparent, // Ensures it matches parent background
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.0), // Adjust if needed
          initiallyExpanded: _isExpanded[index],
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded[index] = expanded;
              if (expanded) {
                for (int i = 0; i < _isExpanded.length; i++) {
                  if (i != index) {
                    _isExpanded[i] = false;
                  }
                }
              }
            });
          },
          children: [
            _buildExpandedContent(item['open_state']['body'], index),
          ],
        ),
      ),
    ),
  );
}


Widget _buildExpandedContent(Map<String, dynamic> body, int index) {
    if (!_isExpanded[index]) {
      return SizedBox.shrink(); 
    }
    
    switch (index) {
      case 0:
        return _buildCreditContent(body);
      case 1:
        return _buildEMIContent(body);
      case 2:
        return _buildBankContent(body);
      default:
        return SizedBox.shrink();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: itemsData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: SizedBox.shrink()),
                ListView.builder(
                  itemCount: 3,
                  reverse: false,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) => _buildExpansionTile(index),
                ),
              ],
            ),
    );
  }
}


  
  
class CircularSliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;

  CircularSliderPainter(
      {required this.value, required this.min, required this.max});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFFCC2B5E), Color(0xFF753A88)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke

      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final progressAngle = 2 * math.pi * ((value - min) / (max - min));
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progressAngle,
      false,
      progressPaint,
    );

    // Draw knob
    final knobPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final knobPosition = Offset(
      center.dx + radius * math.cos(progressAngle - math.pi / 2),
      center.dy + radius * math.sin(progressAngle - math.pi / 2),
    );
    canvas.drawCircle(knobPosition, 15, knobPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}