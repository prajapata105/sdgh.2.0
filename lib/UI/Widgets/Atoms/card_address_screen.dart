import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ssda/models/address_model.dart';
import 'package:ssda/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSelect;
  final bool selected;

  const AddressCard({
    Key? key,
    required this.address,
    this.onEdit,
    this.onDelete,
    this.onSelect,
    this.selected = false,
  }) : super(key: key);

  void _launchMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar("Error", "Unable to open Maps link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Card(
        elevation: selected ? 3 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.primaryGreenColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Phone Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    address.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    address.phone,
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Address Details Row
              Text(
                [
                  address.house,
                  address.area,
                  address.city,
                  address.state,
                  address.pincode
                ].where((v) => v.isNotEmpty).join(', '),
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),

              const SizedBox(height: 7),

              // Google Maps Link Row (if available)
              if (address.googleMapLink != null && address.googleMapLink!.isNotEmpty)
                InkWell(
                  onTap: () => _launchMaps(address.googleMapLink!),
                  child: Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.blue, size: 18),
                      SizedBox(width: 3),
                      Text(
                        "View on Map",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text("Esdit"),
                    onPressed: onEdit,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    label: const Text("Delete", style: TextStyle(color: Colors.red)),
                    onPressed: () async {
                      if (onDelete != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text("Are you sure you want to delete this address?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.of(ctx).pop(false),
                              ),
                              TextButton(
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) onDelete!();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
