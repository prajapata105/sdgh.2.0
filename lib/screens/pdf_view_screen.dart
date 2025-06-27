import 'package:flutter/material.dart';

class ViewOrderInvoiceScreen extends StatelessWidget {
  const ViewOrderInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          ),
        ],
      ),

    );
  }
}
