import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  DateTime _selectedDay = DateTime.now();
  final Map<String, Set<String>> _bookedSlots = {};
  final List<Reservation> _reservations = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  List<String> _getAvailableSlots(DateTime day) {
    final slots = <String>[];
    final start = DateTime(day.year, day.month, day.day, 10, 0);
    final end = DateTime(day.year, day.month, day.day, 18, 0);
    
    for (var time = start; time.isBefore(end); time = time.add(const Duration(minutes: 30))) {
      final timeStr = DateFormat('HH:mm').format(time);
      
      // 今日の場合、現在時刻より前は除外
      if (DateUtils.isSameDay(day, DateTime.now()) && time.isBefore(DateTime.now())) {
        continue;
      }
      
      slots.add(timeStr);
    }
    
    return slots;
  }

  bool _isSlotBooked(DateTime day, String time) {
    final key = DateFormat('yyyy-MM-dd').format(day);
    return _bookedSlots[key]?.contains(time) ?? false;
  }

  void _makeReservation(String time, String name, String phone) {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
    
    setState(() {
      _bookedSlots.putIfAbsent(dateKey, () => <String>{}).add(time);
      _reservations.add(Reservation(
        date: dateKey,
        time: time,
        name: name,
        phone: phone,
      ));
    });
    
    _nameController.clear();
    _phoneController.clear();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${DateFormat('MM/dd').format(_selectedDay)} $time で予約しました')),
    );
  }

  void _cancelReservation(int index) {
    final reservation = _reservations[index];
    setState(() {
      _bookedSlots[reservation.date]?.remove(reservation.time);
      _reservations.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('予約をキャンセルしました')),
    );
  }

  void _showReservationDialog() {
    final availableSlots = _getAvailableSlots(_selectedDay);
    String? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('予約 ${DateFormat('MM/dd').format(_selectedDay)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 時間選択
              Text('時間を選択', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: availableSlots.map((time) {
                  final isBooked = _isSlotBooked(_selectedDay, time);
                  return ChoiceChip(
                    label: Text(time),
                    selected: selectedTime == time,
                    onSelected: isBooked ? null : (selected) {
                      setState(() => selectedTime = selected ? time : null);
                    },
                    backgroundColor: isBooked ? Colors.grey.shade300 : null,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              
              // 名前入力
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名前',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              
              // 電話番号入力
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '電話番号',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: (selectedTime != null && 
                         _nameController.text.trim().isNotEmpty && 
                         _phoneController.text.trim().isNotEmpty) ? () {
                _makeReservation(selectedTime!, _nameController.text.trim(), _phoneController.text.trim());
                Navigator.pop(context);
              } : null,
              child: const Text('予約する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bed,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '山口寝装店',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        const Text(' 4.3 (89件のレビュー)'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, '大阪府池田市石橋周辺'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, '072-XXX-XXXX'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, '営業時間: 10:00 - 18:00'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    const url = 'https://www.google.com/maps/search/%E5%B1%B1%E5%8F%A3%E5%AF%9D%E8%A3%85%E5%BA%97+%E7%9F%B3%E6%A9%8B/@34.8062217,135.4430031,17z';
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Googleマップで開きます')),
                    );
                    // 実際にブラウザで開く場合:
                    // if (await canLaunchUrl(Uri.parse(url))) {
                    //   await launchUrl(Uri.parse(url));
                    // }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('地図で見る'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('電話をかけます')),
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('電話する'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予約システム'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // カレンダー
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _selectedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() => _selectedDay = selectedDay);
              _showReservationDialog();
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
          ),
          
          const Divider(),
          
          // 予約一覧
          Expanded(
            child: _reservations.isEmpty
                ? const Center(child: Text('予約はありません'))
                : ListView.builder(
                    itemCount: _reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = _reservations[index];
                      return ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text('${reservation.date} ${reservation.time}'),
                        subtitle: Text('${reservation.name} / ${reservation.phone}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _cancelReservation(index),
                        ),
                      );
                    },
                  ),
          ),

          // 店舗情報
          _buildStoreInfo(),
        ],
      ),
    );
  }
}

class Reservation {
  final String date;
  final String time;
  final String name;
  final String phone;

  Reservation({
    required this.date,
    required this.time,
    required this.name,
    required this.phone,
  });
}