import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class MandiPriceScreen extends StatefulWidget {
  @override
  _MandiPriceScreenState createState() => _MandiPriceScreenState();
}

class _MandiPriceScreenState extends State<MandiPriceScreen> {
  bool _isLoading = true;
  List<dynamic> _mandiPrices = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMandiPrices();
  }

  // सिर्फ़ मंडी भाव लाने का फंक्शन
  Future<void> _fetchMandiPrices() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _mandiPrices = [];
      });
    }

    const apiKey = '579b464db66ec23bdd000001cdd3946e44ce4aad7209ff7b23ac571b'; // data.gov.in की API Key
    // URL में तारीख के हिसाब से सॉर्टिंग है, जिससे सबसे नया डेटा पहले आता है
    final url = Uri.parse(
        'https://api.data.gov.in/resource/9ef84268-d588-465a-a308-a864a43d0070?api-key=$apiKey&format=json&limit=100&filters[district]=Bikaner&sort[arrival_date]=desc');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final records = data['records'];

        if (records != null && records is List && records.isNotEmpty) {
          // सबसे ताज़ा उपलब्ध डेटा दिखाएँ
          setState(() {
            _mandiPrices = records;
          });
        } else {
          // अगर कोई भी रिकॉर्ड नहीं मिला
          setState(() {
            _errorMessage = 'बीकानेर मंडी के लिए कोई ताजा भाव उपलब्ध नहीं है।';
          });
        }
      } else {
        if(mounted) {
          setState(() {
            _errorMessage = 'सर्वर से संपर्क नहीं हो पा रहा है। (Error: ${response.statusCode})';
          });
        }
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _errorMessage = 'कृपया अपना इंटरनेट कनेक्शन जांचें।';
        });
      }
      print('Mandi API Error: $e');
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('बीकानेर मंडी के भाव'),
      ),
      body: _buildMandiList(),
    );
  }

  Widget _buildMandiList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchMandiPrices,
                child: Text('फिर से कोशिश करें'),
              )
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMandiPrices,
      child: ListView.builder(
        itemCount: _mandiPrices.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final item = _mandiPrices[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                item['commodity'] ?? 'N/A',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                'मंडी: ${item['market'] ?? 'N/A'}\nतारीख: ${item['arrival_date'] ?? 'N/A'}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              trailing: Text(
                '₹ ${item['modal_price'] ?? '0'} /क्विंटल',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}