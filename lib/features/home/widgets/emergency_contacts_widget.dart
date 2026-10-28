import 'package:flutter/material.dart';
import '../../../domain/entities/emergency_contact.dart';
import '../controllers/profile_controller.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key, this.controller});

  final ProfileController? controller;

  @override
  State<EmergencyContactsPage> createState() => _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  List<EmergencyContact> get _contacts => widget.controller?.emergencyContacts ?? [];

  void _addContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEmergencyContactPage(
          onContactAdded: (contact) {
            widget.controller?.addEmergencyContact(contact);
          },
          currentContactCount: _contacts.length,
        ),
      ),
    );
  }

  void _editContact(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEmergencyContactPage(
          existingContact: _contacts[index],
          onContactAdded: (contact) {
            widget.controller?.updateEmergencyContact(index, contact);
          },
          currentContactCount: _contacts.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = _contacts.length < 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Notified by SMS with your live map link during an SOS.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8C8D93),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              if (_contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'No emergency contacts added',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8C8D93),
                      ),
                    ),
                  ),
                ),
              ..._contacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ContactCard(
                    contact: contact,
                    onTap: () => _editContact(index),
                  ),
                );
              }),
              if (canAddMore)
                _AddContactCard(
                  currentCount: _contacts.length,
                  maxCount: 3,
                  onTap: _addContact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onTap,
  });

  final EmergencyContact contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.phone_outlined,
                size: 22,
                color: Color(0xFF6B6C72),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${contact.relation} · ${contact.phoneNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8C8D93),
                    ),
                  ),
                ],
              ),
            ),
            if (contact.isFirstCall)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEC),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '1st call',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE51D24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddContactCard extends StatelessWidget {
  const _AddContactCard({
    required this.currentCount,
    required this.maxCount,
    required this.onTap,
  });

  final int currentCount;
  final int maxCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5E5E7),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                size: 22,
                color: Color(0xFF6B6C72),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add contact $currentCount of $maxCount',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Reached if your primary contact doesn\'t answer',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8C8D93),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddEmergencyContactPage extends StatefulWidget {
  const AddEmergencyContactPage({
    super.key,
    required this.onContactAdded,
    required this.currentContactCount,
    this.existingContact,
  });

  final Function(EmergencyContact) onContactAdded;
  final int currentContactCount;
  final EmergencyContact? existingContact;

  @override
  State<AddEmergencyContactPage> createState() =>
      _AddEmergencyContactPageState();
}

class _AddEmergencyContactPageState extends State<AddEmergencyContactPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _relationController;
  late final TextEditingController _phoneController;
  late bool _isFirstCall;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingContact;
    _nameController = TextEditingController(text: existing?.name);
    _relationController = TextEditingController(text: existing?.relation);
    _phoneController = TextEditingController(text: existing?.phoneNumber);
    _isFirstCall = existing?.isFirstCall ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveContact() {
    if (_formKey.currentState?.validate() ?? false) {
      final contact = EmergencyContact(
        name: _nameController.text.trim(),
        relation: _relationController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        isFirstCall: _isFirstCall,
      );
      widget.onContactAdded(contact);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingContact != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEditing ? 'Edit Contact' : 'Add Contact',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE51D24),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8C8D93),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _nameController,
                  label: 'Full name',
                  hint: 'Enter full name',
                  validator: (value) =>
                      value?.trim().isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _relationController,
                  label: 'Relationship',
                  hint: 'e.g., Sister, Brother, Friend',
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Relationship is required'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone number',
                  hint: '+63 900 000 0000',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? 'Phone number is required'
                      : null,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Set as first call',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Called first in an emergency',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8C8D93),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isFirstCall,
                        onChanged: (value) {
                          setState(() {
                            _isFirstCall = value;
                          });
                        },
                        activeThumbColor: const Color(0xFFE51D24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFB8B9BE),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5E7),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE5E5E7),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE51D24),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.redAccent,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
