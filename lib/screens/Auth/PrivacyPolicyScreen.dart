// Path: lib/screens/privacy_policy_screen.dart
// WHAT TO DO: Create this new file and paste the code below.

import 'package:flutter/material.dart';
import 'package:ssda/utils/constent.dart'; // Apne constants file ko import karein

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: kBackgroundColor, // Apne theme ka color use karein
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Privacy Policy for Sridungargarh City

**Effective Date:** July 21, 2025

"Sridungargarh City" ("we," "us," or "our") is committed to protecting your privacy. This Privacy Policy outlines our practices concerning the collection, use, and disclosure of your information through our mobile application (the "App").

By using the App, you agree to the collection and use of information in accordance with this policy.

**1. Information We Collect**

We collect information to provide and improve our Services. The types of information include:

* **Personal Information:** Name, phone number, and delivery address, collected during account creation and checkout.
* **Transactional Information:** Details of your purchases made through our marketplace, including products, order value, and transaction IDs. We do not collect or store sensitive financial data like credit card numbers; this is handled by our secure payment gateway partner.
* **Usage and Technical Data:** Information on how you interact with our Services (e.g., searches, pages viewed), device information, and Firebase Cloud Messaging (FCM) tokens for push notifications.

**2. Use of Your Information**

Your information is used for the following specific purposes:

* **To Facilitate E-commerce Transactions:** To process your orders, we share your name, address, and phone number with the respective third-party Vendors and our delivery partners for order fulfillment.
* **To Operate the Directory Service:** To allow you to contact businesses listed in the directory via the `CALL_PHONE` permission.
* **To Provide News & Notifications:** To send you local news, promotional offers, and order updates via push notifications.
* **To Manage Your Account & Provide Support:** To manage your account and respond to your queries.
* **For Legal Compliance & Security:** To prevent fraud, enforce our Terms, and comply with legal obligations.

**3. Disclosure of Your Information**

We are not in the business of selling your personal information. We disclose your information only as described below:

* **Third-Party Vendors:** We share necessary information (name, address, contact number) with the Vendors from whom you purchase products on our marketplace to enable them to process and deliver your order.
* **Service Providers:** We engage third-party companies for services like payment processing (e.g., Razorpay) and server hosting (Hostinger). These providers have access to your information only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.
* **Legal Requirements:** We may disclose your information if required by law or in the good faith belief that such action is necessary to comply with a legal obligation.

**4. Data Security & Retention**

* **Security:** We use industry-standard security measures, including SSL/TLS encryption for data in transit, to protect your information.
* **Retention:** We retain your data for as long as your account is active or as needed to fulfill the purposes outlined in this policy and to comply with our legal obligations.

**5. Your Rights and Data Deletion**

You have the right to access, correct, and request the deletion of your personal data. You can initiate an account deletion request through the 'Profile' section of the App or by contacting us. Upon receiving a request, we will delete your data from our active databases, subject to any legal or regulatory retention requirements.

**6. Grievance Officer**

In compliance with India's Information Technology (Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021, the contact details of our Grievance Officer are:

* **Name:** Anil Prajapat
* **Designation:** Grievance Officer
* **Email:** the.anilprajapat@gmail.com
* **Address:** Bigga Bass, Ward No. 18, Sri Dungargarh, Rajasthan

**7. Changes to This Policy**

We may update this Privacy Policy periodically. We will notify you of any material changes by posting the new policy in the App and updating the effective date.

**8. Contact Us**

For any general questions about this Privacy Policy, please contact us at the.anilprajapat@gmail.com.

          ''',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}
