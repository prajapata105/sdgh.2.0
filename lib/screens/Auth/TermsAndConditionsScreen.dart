// Path: lib/screens/terms_and_conditions_screen.dart
// WHAT TO DO: Create this new file and paste the code below.

import 'package:flutter/material.dart';
import 'package:ssda/utils/constent.dart'; // Apne constants file ko import karein

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: kBackgroundColor, // Apne theme ka color use karein
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Terms and Conditions for Sridungargarh City

**Effective Date:** July 21, 2025

**1. Introduction & Acceptance of Terms**

Welcome to "Sridungargarh City" (the "App"). These Terms and Conditions ("Terms") constitute a legally binding agreement between you ("User" or "you") and us. The App provides an e-commerce marketplace, a local business directory, and a news content portal (collectively, the "Services"). By accessing, Browse, or using the App, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy.

**2. Definition of Role: An Intermediary Platform**

You explicitly understand and agree that "Sridungargarh City" is an intermediary platform. Our role is limited to providing a technology platform to connect users with third-party vendors, service providers, and content creators. We do not own, sell, or endorse any of the products, services, or content offered by third parties on the App.

**3. Terms Specific to Marketplace / E-commerce**

* **Contract of Sale:** "Sridungargarh City" is not a party to the contract for sale between you and the Vendor.
* **Product & Service Liability:** We are not responsible for any non-performance or breach of any contract entered into between you and the Vendors. Any claims regarding the product (including but not limited to quality, defects, or warranty) must be directed solely to the Vendor.
* **Pricing:** All product prices are determined by the Vendors.
* **Returns & Refunds:** Return, replacement, and refund policies are set by the individual Vendors and will be specified on the product page. "Sridungargarh City" does not have control over these policies.

**4. Terms Specific to Business Directory**

* **Third-Party Information:** The business directory contains information provided by third-party businesses. We do not verify, guarantee, or endorse the accuracy, completeness, or reliability of any information in the listings.
* **No Endorsement:** The inclusion of a business in our directory does not imply an endorsement or recommendation by "Sridungargarh City".

**5. Terms Specific to News and Content**

* **Content Source:** The news content provided in the App is sourced from our affiliate WordPress website (https://sridungargarhone.com) and is for informational purposes only. We do not guarantee the accuracy of the content.

**6. Limitation of Liability**

IN NO EVENT SHALL "SRIDUNGARGARH CITY", ITS DIRECTORS, EMPLOYEES, OR AFFILIATES BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES, OR ANY LOSS OF PROFITS OR REVENUES, ARISING OUT OF OR RELATED TO YOUR USE OF THE APP, THE CONDUCT OF ANY VENDOR, OR THE QUALITY OF ANY PRODUCT, SERVICE, OR CONTENT OBTAINED THROUGH THE APP.

**7. Governing Law and Jurisdiction**

These Terms shall be governed by the laws of India. Any dispute arising from these Terms shall be subject to the exclusive jurisdiction of the competent courts located in Sridungargarh, Rajasthan, India.

**8. Contact & Grievance Redressal**

For any questions, please contact us at the.anilprajapat@gmail.com. For grievances, please contact our Grievance Officer as detailed in our Privacy Policy.
          ''',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }
}
