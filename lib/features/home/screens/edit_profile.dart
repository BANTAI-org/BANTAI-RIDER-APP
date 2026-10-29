import 'package:flutter/material.dart';

import '../../../domain/entities/rider_profile.dart';
import '../../auth/widgets/signup_step_layout.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.controller});

  final ProfileController controller;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _birthDate;
  late final TextEditingController _address;
  late final TextEditingController _mobile;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final profile = widget.controller.riderDetails;
    _firstName = TextEditingController(text: profile?.firstName ?? '');
    _lastName = TextEditingController(text: profile?.lastName ?? '');
    _birthDate = TextEditingController(text: profile?.birthday ?? '');
    _address = TextEditingController(text: profile?.address ?? '');
    _mobile = TextEditingController(text: profile?.phoneNumber ?? '');
    _email = TextEditingController(text: profile?.emailAddress ?? '');
  }

  @override
  void dispose() {
    for (final controller in [
      _firstName,
      _lastName,
      _birthDate,
      _address,
      _mobile,
      _email,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final current = widget.controller.riderDetails;
    if (current == null) return;
    try {
      await widget.controller.saveEditedProfile(
        RiderProfile(
          id: current.id,
          firstName: _firstName.text.trim(),
          middleName: current.middleName,
          lastName: _lastName.text.trim(),
          birthday: _birthDate.text.trim(),
          gender: current.gender,
          emailAddress: _email.text.trim(),
          phoneNumber: _mobile.text.trim(),
          address: _address.text.trim(),
          licenseNumber: current.licenseNumber,
          licenseExpiry: current.licenseExpiry,
          serviceProvider: current.serviceProvider,
          fleetOperatorId: current.fleetOperatorId,
          experienceYears: current.experienceYears,
          motorcycleMake: current.motorcycleMake,
          motorcycleModel: current.motorcycleModel,
          motorcyclePlateNumber: current.motorcyclePlateNumber,
          motorcycleYear: current.motorcycleYear,
          motorcycleColor: current.motorcycleColor,
          bloodType: current.bloodType,
          medicalConditions: current.medicalConditions,
          emergencyContacts: current.emergencyContacts,
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save profile: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SignupSection(
            title: 'Personal details',
            child: Column(
              children: [
                SignupField(controller: _firstName, label: 'First Name'),
                SignupField(controller: _lastName, label: 'Last Name'),
                SignupDateField(
                  controller: _birthDate,
                  label: 'Birth date (DD/MM/YYYY)',
                  validator: (_) => null,
                  firstDate: DateTime(1900),
                  lastDate: DateUtils.dateOnly(DateTime.now()),
                ),
                SignupField(controller: _address, label: 'Home Address'),
                SignupField(
                  controller: _mobile,
                  label: 'Mobile number',
                  keyboardType: TextInputType.phone,
                ),
                SignupField(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: widget.controller.isLoading ? null : _save,
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}
