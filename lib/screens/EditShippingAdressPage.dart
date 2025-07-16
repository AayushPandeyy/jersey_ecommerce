import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jersey_ecommerce/service/FirestoreService.dart';

class EditShippingAddressPage extends StatefulWidget {
  const EditShippingAddressPage({Key? key}) : super(key: key);

  @override
  State<EditShippingAddressPage> createState() => _EditShippingAddressPageState();
}

class _EditShippingAddressPageState extends State<EditShippingAddressPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController(text: '44600');

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreService().getUserDataByEmail(FirebaseAuth.instance.currentUser!.email!),
      builder: (context, asyncSnapshot) {
        if(asyncSnapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        final userData = asyncSnapshot.data!.first;
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Edit Shipping Address',
              style: GoogleFonts.pixelifySans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 20),
                    _buildFormCard(userData),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff0F4C75), Color(0xff3282B8), Color(0xff0F4C75)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff3282B8).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                    Colors.white.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY ADDRESS',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your shipping information',
                          style: GoogleFonts.pixelifySans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Decorative elements
          Positioned(
            top: -10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(Map<String,dynamic> userData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              value: userData["fullname"],
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              value: userData["phoneNumber"],
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneNumberFormatter()],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              value: userData["address"],
              hint: 'Enter your street address',
              icon: Icons.home_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _cityController,
              value: userData["city"],
              label: 'City',
              hint: 'Enter your city',
              icon: Icons.location_city_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _postalCodeController,
              label: 'Postal Code',
              hint: '44600',
              icon: Icons.mail_outline,
              enabled: false,
              validator: null,
            ),
            const SizedBox(height: 12),
            _buildPostalCodeInfo(),
            const SizedBox(height: 30),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? value
  }) {
    controller.text = value??"";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.pixelifySans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.grey[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            style: GoogleFonts.pixelifySans(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.pixelifySans(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: enabled ? const Color(0xff015888) : Colors.grey[500],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              errorStyle: GoogleFonts.pixelifySans(
                fontSize: 12,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostalCodeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff015888).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xff015888).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xff015888).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xff015888),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This postal code is fixed for Jersey Store deliveries in this region',
              style: GoogleFonts.pixelifySans(
                fontSize: 12,
                color: const Color(0xff015888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _handleCancel,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.pixelifySans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff015888),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff015888).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _isLoading ? null : _handleSave,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Save Address',
                      style: GoogleFonts.pixelifySans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Changes',
          style: GoogleFonts.pixelifySans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel? Any unsaved changes will be lost.',
          style: GoogleFonts.pixelifySans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Stay',
              style: GoogleFonts.pixelifySans(
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.pixelifySans(
                color: const Color(0xff015888),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    final updatedData = {
      'fullname': _fullNameController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
    };

    try {
      await FirestoreService().updateUserByEmail(
        FirebaseAuth.instance.currentUser!.email!,
        updatedData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shipping address saved successfully!',
              style: GoogleFonts.pixelifySans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xff015888),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save address. Please try again.',
              style: GoogleFonts.pixelifySans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
  }

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.length <= 3) {
      return newValue.copyWith(text: text);
    } else if (text.length <= 6) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3)}',
      );
    } else if (text.length <= 10) {
      return newValue.copyWith(
        text: '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}',
      );
    } else {
      return oldValue;
    }
  }
}