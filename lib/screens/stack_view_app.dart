import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:credemi/api/apiservice.dart';

class StackViewApp extends StatefulWidget {
  @override
  _StackViewAppState createState() => _StackViewAppState();
}

class _StackViewAppState extends State<StackViewApp> {
  List<dynamic> itemsData = [];
  List<bool> expandedStates = [true, false, false];
  double creditAmount = 150000;

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
      // Handle error (e.g., show error message to user)
    }
  }

  void toggleView(int index) {
    setState(() {
      for (int i = 0; i < expandedStates.length; i++) {
        expandedStates[i] = i == index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.question_mark, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: itemsData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: List.generate(itemsData.length, (index) {
                  return _buildExpandableContainer(index);
                }),
              ),
            ),
    );
  }

  Widget _buildExpandableContainer(int index) {
    final item = itemsData[index];
    final isExpanded = expandedStates[index];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => toggleView(index),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isExpanded
                        ? item['open_state']['body']['title']
                        : item['closed_state']['body']['key1'] ?? '',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            _buildExpandedContent(item['open_state']['body'], index),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> body, int index) {
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
                (body['card']['max_range'].toDouble() - body['card']['min_range'].toDouble()) + 
                body['card']['min_range'].toDouble();
            creditAmount = creditAmount.clamp(
              body['card']['min_range'].toDouble(),
              body['card']['max_range'].toDouble()
            )as double;
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
        ...body['items'].map<Widget>((item) => _buildEMICard(item)).toList(),
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
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['emi'],
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (item['tag'] == 'recommended')
                  Chip(
                    label: Text('Recommended'),
                    backgroundColor: Colors.green,
                  ),
              ],
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
}

class CircularSliderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;

  CircularSliderPainter({required this.value, required this.min, required this.max});

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