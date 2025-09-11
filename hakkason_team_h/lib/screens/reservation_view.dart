import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/reservation_storage.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
  DateTime _selectedDay = DateTime.now();
  final Map<String, Map<String, Reservation>> _bookedSlots = {};
  final List<Reservation> _reservations = [];
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _concernsController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _customerNumberController.dispose();
    _concernsController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    try {
      final loadedData = await ReservationStorage.loadReservations();
      if (mounted) {
        setState(() {
          _reservations.clear();
          _bookedSlots.clear();
          for (final data in loadedData) {
            final reservation = Reservation.fromMap(data);
            _reservations.add(reservation);
            final dateKey = reservation.date;
            _bookedSlots.putIfAbsent(dateKey, () => {});
            _bookedSlots[dateKey]![reservation.time] = reservation;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('予約データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  Future<void> _saveReservations() async {
    try {
      final dataList = _reservations.map((r) => r.toMap()).toList();
      await ReservationStorage.saveReservations(dataList);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('予約データの保存に失敗しました: $e')),
        );
      }
    }
  }

  List<String> _getAvailableSlots(DateTime day, String serviceType) {
    final slots = <String>[];
    final start = DateTime(day.year, day.month, day.day, 10, 0);
    final end = DateTime(day.year, day.month, day.day, 19, 0);
    final dateKey = DateFormat('yyyy-MM-dd').format(day);
    
    // サービスタイプによって時間枠を変更
    final duration = _getServiceDuration(serviceType);
    
    for (var time = start; time.isBefore(end); time = time.add(Duration(minutes: duration))) {
      final timeStr = DateFormat('HH:mm').format(time);
      
      // 今日の場合、現在時刻より前は除外
      if (DateUtils.isSameDay(day, DateTime.now()) && time.isBefore(DateTime.now())) {
        continue;
      }
      
      // 測定器が1台のため、すでに予約がある時間帯は除外
      bool isBlocked = false;
      if (_bookedSlots.containsKey(dateKey)) {
        for (final bookedTime in _bookedSlots[dateKey]!.keys) {
          final bookedStart = DateFormat('HH:mm').parse(bookedTime);
          final bookedReservation = _bookedSlots[dateKey]![bookedTime]!;
          final bookedDuration = _getServiceDuration(bookedReservation.serviceType);
          final bookedEnd = bookedStart.add(Duration(minutes: bookedDuration));
          
          final currentStart = DateFormat('HH:mm').parse(timeStr);
          final currentEnd = currentStart.add(Duration(minutes: duration));
          
          // 時間が重なる場合はブロック
          if (!((currentEnd.hour * 60 + currentEnd.minute <= bookedStart.hour * 60 + bookedStart.minute) ||
                (currentStart.hour * 60 + currentStart.minute >= bookedEnd.hour * 60 + bookedEnd.minute))) {
            isBlocked = true;
            break;
          }
        }
      }
      
      if (!isBlocked) {
        slots.add(timeStr);
      }
    }
    
    return slots;
  }

  int _getServiceDuration(String serviceType) {
    switch (serviceType) {
      case 'オーダーメイド枕測定':
        return 60;
      case '枕メンテナンス':
      case '睡眠相談':
        return 30;
      case '布団レンタル相談':
        return 20;
      case '布団受取予約':
      case '布団返却予約':
        return 10;
      default:
        return 30;
    }
  }

  String _getServiceDescription(String serviceType) {
    switch (serviceType) {
      case 'オーダーメイド枕測定':
        return '立位測定・カウンセリング・枕作成（約60分）';
      case '枕メンテナンス':
        return '高さ・硬さ調整（約30分）※購入後10年間無料';
      case '睡眠相談':
        return '睡眠のお悩み相談（約30分）';
      case '布団レンタル相談':
        return '布団セット選択・レンタル契約（約20分）※1日3,300円〜';
      case '布団受取予約':
        return '布団セット受取（約10分）※配送受取もお選びいただけます';
      case '布団返却予約':
        return '布団セット返却・清算（約10分）※配送返却もお選びいただけます';
      default:
        return '';
    }
  }

  void _makeReservation(String time, String name, String phone, String email,
      String serviceType, String? customerNumber, String concerns) {
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前と電話番号を入力してください')),
      );
      return;
    }

    if (!_isValidPhoneNumber(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('有効な電話番号を入力してください')),
      );
      return;
    }

    if (serviceType == '枕メンテナンス' && (customerNumber == null || customerNumber.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メンテナンスには顧客番号が必要です')),
      );
      return;
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDay);
    
    setState(() {
      final reservation = Reservation(
        date: dateKey,
        time: time,
        name: name,
        phone: phone,
        email: email,
        serviceType: serviceType,
        customerNumber: customerNumber,
        concerns: concerns,
      );
      
      _bookedSlots.putIfAbsent(dateKey, () => {});
      _bookedSlots[dateKey]![time] = reservation;
      _reservations.add(reservation);
    });
    
    _saveReservations();
    _clearControllers();
    
    // 予約完了メッセージ
    final duration = _getServiceDuration(serviceType);
    final endTime = DateFormat('HH:mm').parse(time).add(Duration(minutes: duration));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${DateFormat('MM/dd').format(_selectedDay)} $time-${DateFormat('HH:mm').format(endTime)}\n$serviceType で予約しました'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _customerNumberController.clear();
    _concernsController.clear();
  }

  bool _isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9-]+$');
    return phone.length >= 10 && phoneRegex.hasMatch(phone);
  }

  void _cancelReservation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('予約キャンセル'),
        content: const Text('この予約をキャンセルしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('いいえ'),
          ),
          ElevatedButton(
            onPressed: () {
              final reservation = _reservations[index];
              setState(() {
                _bookedSlots[reservation.date]?.remove(reservation.time);
                if (_bookedSlots[reservation.date]?.isEmpty ?? false) {
                  _bookedSlots.remove(reservation.date);
                }
                _reservations.removeAt(index);
              });
              _saveReservations();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('予約をキャンセルしました')),
              );
            },
            child: const Text('はい'),
          ),
        ],
      ),
    );
  }

  void _showReservationDialog() {
    String serviceType = 'オーダーメイド枕測定';
    String? selectedTime;
    bool isExistingCustomer = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final availableSlots = _getAvailableSlots(_selectedDay, serviceType);
          
          return Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: Text('予約 ${DateFormat('MM/dd').format(_selectedDay)}'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _clearControllers();
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: (selectedTime != null && 
                               _nameController.text.trim().isNotEmpty && 
                               _phoneController.text.trim().isNotEmpty &&
                               (!isExistingCustomer || _customerNumberController.text.trim().isNotEmpty)) ? () {
                      _makeReservation(
                        selectedTime!,
                        _nameController.text.trim(),
                        _phoneController.text.trim(),
                        _emailController.text.trim(),
                        serviceType,
                        isExistingCustomer ? _customerNumberController.text.trim() : null,
                        _concernsController.text.trim(),
                      );
                      Navigator.pop(context);
                    } : null,
                    child: const Text('予約する', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // サービス選択
                  Text('サービスを選択', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: serviceType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'オーダーメイド枕測定',
                        child: Text('オーダーメイド枕測定（新規）'),
                      ),
                      DropdownMenuItem(
                        value: '枕メンテナンス',
                        child: Text('枕メンテナンス（既存客）'),
                      ),
                      DropdownMenuItem(
                        value: '睡眠相談',
                        child: Text('睡眠相談'),
                      ),
                      DropdownMenuItem(
                        value: '布団レンタル相談',
                        child: Text('布団レンタル相談'),
                      ),
                      DropdownMenuItem(
                        value: '布団受取予約',
                        child: Text('布団受取予約'),
                      ),
                      DropdownMenuItem(
                        value: '布団返却予約',
                        child: Text('布団返却予約'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        serviceType = value!;
                        selectedTime = null;
                        isExistingCustomer = serviceType == '枕メンテナンス';
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getServiceDescription(serviceType),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  
                  // 時間選択
                  Text('時間を選択', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  if (availableSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('この日は予約可能な時間がありません'),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableSlots.map((time) {
                        final duration = _getServiceDuration(serviceType);
                        final endTime = DateFormat('HH:mm').parse(time).add(Duration(minutes: duration));
                        return ChoiceChip(
                          label: Text('$time-${DateFormat('HH:mm').format(endTime)}'),
                          selected: selectedTime == time,
                          onSelected: (selected) {
                            setState(() => selectedTime = selected ? time : null);
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                  
                  // 顧客番号（メンテナンス時のみ）
                  if (isExistingCustomer) ...[
                    TextField(
                      controller: _customerNumberController,
                      decoration: const InputDecoration(
                        labelText: '顧客番号 *',
                        hintText: '例：KY-2024-0001',
                        border: OutlineInputBorder(),
                        helperText: '購入時にお渡しした番号です',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 基本情報入力
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '名前 *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '電話番号 *',
                      hintText: '例：072-761-8097',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      hintText: '予約確認メールをお送りします',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  
                  // 事前問診
                  Text('お悩み・ご要望（任意）', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _concernsController,
                    decoration: const InputDecoration(
                      hintText: '例：肩こりがひどい、横向き寝が多い、いびきが気になる',
                      border: OutlineInputBorder(),
                      helperText: '事前にお悩みを共有いただくと、当日スムーズにご案内できます',
                    ),
                    maxLines: 3,
                  ),
                  ],
                ),
              ),
          ),
          );
        },
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
                  Icons.airline_seat_flat,
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
                      '快眠本舗 ヤマグチ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 16),
                        const Text(' FITLABO認定店', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '測定器1台のため、土日祝は混雑します。お早めのご予約を！',
                    style: TextStyle(fontSize: 12, color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, '大阪府池田市石橋1-15-7'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, '072-761-8097'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, '営業時間: 10:00 - 19:00 (月曜定休)'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.train, '石橋阪大前駅 西口より徒歩3分'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    const url = 'https://www.google.com/maps/search/%E5%BF%AB%E7%9C%A0%E6%9C%AC%E8%88%97%E3%83%A4%E3%83%9E%E3%82%B0%E3%83%81+%E6%B1%A0%E7%94%B0%E5%B8%82%E7%9F%B3%E6%A9%8B1-15-7/@34.8105,135.4478,17z';
                    final uri = Uri.parse(url);
                    
                    try {
                      final canLaunch = await canLaunchUrl(uri);
                      if (canLaunch) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.inAppWebView,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('シミュレーターでは地図機能が制限されています'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('地図で見る'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    const phoneNumber = 'tel:072-761-8097';
                    final uri = Uri.parse(phoneNumber);
                    
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('シミュレーターでは電話機能が利用できません\n実機でお試しください'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('シミュレーターでは電話機能が制限されています'),
                          ),
                        );
                      }
                    }
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
        title: const Text('オーダーメイド枕測定予約'),
        centerTitle: true,
        backgroundColor: Colors.blue[50],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // サービス料金表示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPriceCard('オーダー枕', '¥44,000', Colors.blue),
                  _buildPriceCard('メンテナンス', '10年無料', Colors.green),
                  _buildPriceCard('睡眠相談', '無料', Colors.orange),
                ],
              ),
            ),
            
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
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  final dateKey = DateFormat('yyyy-MM-dd').format(day);
                  if (_bookedSlots.containsKey(dateKey)) {
                    final bookingCount = _bookedSlots[dateKey]!.length;
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: bookingCount >= 5 ? Colors.red : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$bookingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
            
            const Divider(),
            
            // 予約一覧
            _isLoading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _reservations.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('予約はありません'),
                              SizedBox(height: 8),
                              Text(
                                'カレンダーの日付をタップして予約を作成',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _reservations.asMap().entries.map((entry) {
                          final index = entry.key;
                          final reservation = entry.value;
                          final duration = _getServiceDuration(reservation.serviceType);
                          final endTime = DateFormat('HH:mm').parse(reservation.time)
                              .add(Duration(minutes: duration));
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getServiceColor(reservation.serviceType),
                                child: Icon(
                                  _getServiceIcon(reservation.serviceType),
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                '${reservation.date} ${reservation.time}-${DateFormat('HH:mm').format(endTime)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reservation.serviceType),
                                  Text('${reservation.name} / ${reservation.phone}'),
                                  if (reservation.customerNumber != null)
                                    Text('顧客番号: ${reservation.customerNumber}',
                                      style: const TextStyle(fontSize: 11)),
                                  if (reservation.concerns.isNotEmpty)
                                    Text('要望: ${reservation.concerns}',
                                      style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _cancelReservation(index),
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }).toList(),
                      ),

            // 店舗情報  
            _buildStoreInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String title, String price, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            price,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Color _getServiceColor(String serviceType) {
    switch (serviceType) {
      case 'オーダーメイド枕測定':
        return Colors.blue;
      case '枕メンテナンス':
        return Colors.green;
      case '睡眠相談':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType) {
      case 'オーダーメイド枕測定':
        return Icons.straighten;
      case '枕メンテナンス':
        return Icons.build;
      case '睡眠相談':
        return Icons.chat;
      default:
        return Icons.event;
    }
  }
}

class Reservation {
  final String date;
  final String time;
  final String name;
  final String phone;
  final String email;
  final String serviceType;
  final String? customerNumber;
  final String concerns;

  Reservation({
    required this.date,
    required this.time,
    required this.name,
    required this.phone,
    required this.email,
    required this.serviceType,
    this.customerNumber,
    required this.concerns,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'time': time,
      'name': name,
      'phone': phone,
      'email': email,
      'serviceType': serviceType,
      'customerNumber': customerNumber,
      'concerns': concerns,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      serviceType: map['serviceType'] ?? 'オーダーメイド枕測定',
      customerNumber: map['customerNumber'],
      concerns: map['concerns'] ?? '',
    );
  }
}